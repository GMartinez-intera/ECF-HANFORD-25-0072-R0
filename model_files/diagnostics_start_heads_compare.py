#!/data/projects/gmartinez/ECF-HANFORD-25-0072-R0/model_files/gmdsi/bin/python
"""
Standalone script for MODFLOW-2005 (MF2005) using FloPy.

What it does
------------
- Loads one or two MF2005 models (you pass each model's folder and namefile)
- Reads starting heads (BAS6 STRT), honoring external REF files
- Masks inactive cells (IBOUND <= 0)
- Ignores a nodata value (default -999) when computing color limits,
  and draws those cells as RED on top of the map
- Saves a PNG per layer for each model
- If both grids align, also saves per-layer difference maps (Model1 - Model2),
  also honoring nodata as above

Output location
---------------
Creates/uses a folder named 'diagnostics' next to this script.

Examples
--------
# Only one model
python start_heads_diagnostics_mf2005.py \
  --dir1 /path/to/modelA \
  --namefile1 modelA.nam

# Two models + diffs
python start_heads_diagnostics_mf2005.py \
  --dir1 /path/to/modelA --namefile1 modelA.nam \
  --dir2 /path/to/modelB --namefile2 modelB.nam \
  --label1 A --label2 B --make-diff

# Add REF layer names to titles (comma-separated) + custom nodata
python start_heads_diagnostics_mf2005.py \
  --dir1 /path/to/modelA --namefile1 modelA.nam \
  --refs star_heads_lay_1.ref,star_heads_lay_2.ref,star_heads_lay_3.ref,star_heads_lay_4.ref,star_heads_lay_5.ref,star_heads_lay_6.ref,star_heads_lay_7.ref,star_heads_lay_8.ref \
  --nodata -999

Requirements
------------
- flopy, numpy, matplotlib
"""

import argparse
import sys
from pathlib import Path
from typing import Optional, Tuple, List

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl

try:
    import flopy
except Exception:
    print("[ERROR] FloPy is required. Install with: pip install flopy", file=sys.stderr)
    raise


def script_output_dir(tag='') -> Path:
    """Return the 'diagnostics' directory alongside this script file."""
    here = Path(__file__).resolve().parent
    out = here / f"diagnostics{tag}" 
    out.mkdir(parents=True, exist_ok=True)
    return out


def load_mf2005(model_ws: Path, namefile: str):
    """Load an MF2005 model from folder + namefile using FloPy."""
    model_ws = Path(model_ws)
    if not model_ws.exists():
        raise FileNotFoundError(f"Model workspace not found: {model_ws}")
    nam_path = model_ws / namefile
    if not nam_path.exists():
        raise FileNotFoundError(f"Namefile not found: {nam_path}")
    print(f"[*] Loading MF2005 from: {nam_path}")
    mf = flopy.modflow.Modflow.load(
        namefile,
        model_ws=str(model_ws),
        load_only=["DIS", "BAS6"],
        forgive=True,
        check=False,
        verbose=False,
    )
    if mf is None:
        raise RuntimeError(f"FloPy could not load model from {nam_path}")
    return mf


def get_strt_ibound(mf) -> Tuple[np.ndarray, np.ndarray]:
    """Return starting heads (strt) and ibound arrays as shape (nlay, nrow, ncol)."""
    bas6 = mf.get_package("BAS6")
    if bas6 is None:
        raise RuntimeError("BAS6 package missing. Make sure BAS6 is in the model and was loaded.")
    strt = np.array(bas6.strt.array)
    ibound = np.array(bas6.ibound.array)
    if strt.ndim == 2:
        strt = strt[np.newaxis, ...]
    if ibound.ndim == 2:
        ibound = ibound[np.newaxis, ...]
    return strt, ibound


def mask_active_excl_nodata(arr3d: np.ndarray, ibound3d: np.ndarray, nodata: float) -> np.ma.MaskedArray:
    """Mask (for plotting scale) cells where IBOUND <= 0, arr == nodata, or invalid."""
    m = np.ma.masked_where(ibound3d <= 0, arr3d)
    m = np.ma.masked_where(np.isclose(arr3d, nodata), m)
    m = np.ma.masked_invalid(m)
    return m


def global_minmax_excl_nodata(arr3dA: np.ndarray, ibA: np.ndarray,
                              nodata: float,
                              arr3dB: Optional[np.ndarray] = None, ibB: Optional[np.ndarray] = None
                              ) -> Tuple[Optional[float], Optional[float]]:
    """Compute vmin/vmax across active cells of one or two models, excluding nodata."""
    mA = mask_active_excl_nodata(arr3dA, ibA, nodata).compressed()
    data = mA
    if arr3dB is not None and ibB is not None:
        mB = mask_active_excl_nodata(arr3dB, ibB, nodata).compressed()
        data = np.concatenate([mA, mB]) if mB.size else mA
    if data.size == 0:
        return None, None
    return float(np.nanmin(data)), float(np.nanmax(data))


def grids_align(mf1, mf2) -> bool:
    """Check if two MF2005 grids align (shape, delr/delc, rotation, offsets)."""
    g1, g2 = mf1.modelgrid, mf2.modelgrid
    if g1.nlay != g2.nlay or g1.nrow != g2.nrow or g1.ncol != g2.ncol:
        return False
    if not (np.allclose(np.atleast_1d(g1.delr), np.atleast_1d(g2.delr)) and
            np.allclose(np.atleast_1d(g1.delc), np.atleast_1d(g2.delc))):
        return False
    if not np.isclose(g1.angrot, g2.angrot):
        return False
    if not (np.isclose(g1.xoffset, g2.xoffset) and np.isclose(g1.yoffset, g2.yoffset)):
        return False
    return True


def plot_layer(orig2d: np.ndarray, masked2d: np.ma.MaskedArray, extent, vmin, vmax,
               title: str, outfile: Path, nodata: float, dpi: int = 200):
    """Plot a single 2D layer and overlay nodata cells as red, then save to PNG."""
    fig = plt.figure(figsize=(8, 6))
    ax = fig.add_subplot(111)

    # Main colormap with transparent 'bad' (masked) so overlays can show through
    base_cmap = mpl.cm.get_cmap(plt.rcParams.get('image.cmap', 'viridis')).copy()
    base_cmap.set_bad((0, 0, 0, 0))  # fully transparent for masked cells

    # Draw main data
    im = ax.imshow(masked2d, origin='upper', extent=extent,
                   vmin=vmin, vmax=vmax, interpolation='none', cmap=base_cmap)
    cbar = fig.colorbar(im, ax=ax, shrink=0.9)
    cbar.set_label("Starting head")

    # Overlay nodata cells (orig == nodata) as solid red
    nodata_bool = np.isclose(orig2d, nodata)
    if np.any(nodata_bool):
        overlay = np.zeros(nodata_bool.shape + (4,), dtype=float)  # RGBA
        overlay[..., 0] = 1.0   # red channel
        overlay[..., 3] = nodata_bool.astype(float)  # alpha 1 where nodata, else 0
        ax.imshow(overlay, origin='upper', extent=extent, interpolation='none')

    ax.set_title(title)
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_aspect('equal')
    fig.tight_layout()
    outfile.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(outfile, dpi=dpi)
    plt.close(fig)
    print(f"[✓] Wrote {outfile}")


def sanitize(s: str) -> str:
    return "".join(c if c.isalnum() or c in "-_." else "_" for c in s)


def main():
    ap = argparse.ArgumentParser(description="Plot MF2005 starting heads per layer (and optional diffs).")
    ap.add_argument("--dir1", required=True, help="Path to Model 1 folder (workspace)")
    ap.add_argument("--namefile1", required=True, help="Namefile for Model 1 (e.g., modelA.nam)")
    ap.add_argument("--dir2", default=None, help="Path to Model 2 folder (workspace)")
    ap.add_argument("--namefile2", default=None, help="Namefile for Model 2 (e.g., modelB.nam)")
    ap.add_argument("--label1", default=None, help="Label for Model 1 (defaults to folder name)")
    ap.add_argument("--label2", default=None, help="Label for Model 2 (defaults to folder name)")
    ap.add_argument("--refs", default=None,
                    help="Comma-separated list of layer reference filenames to show in titles (e.g., star_heads_lay_1.ref,...)")
    ap.add_argument("--make-diff", action="store_true", help="If two models provided and grids align, also save difference maps")
    ap.add_argument("--nodata", type=float, default=-999.0, help="Value to treat as nodata (ignored in scale, drawn as red)")
    ap.add_argument("--dpi", type=int, default=200, help="PNG DPI")
    ap.add_argument("--tag", default='', help='tag used as suffix in diagnostics dir')
    args = ap.parse_args()

    outdir = script_output_dir(tag=args.tag)
    print(f"[*] Output directory: {outdir}")

    # Load model(s)
    mf1 = load_mf2005(Path(args.dir1), args.namefile1)
    strt1, ib1 = get_strt_ibound(mf1)
    extent1 = mf1.modelgrid.extent  # (xmin, xmax, ymin, ymax)

    label1 = args.label1 or Path(args.dir1).name or "Model1"

    refs: Optional[List[str]] = None
    if args.refs:
        refs = [r.strip() for r in args.refs.split(",")]

    mf2 = None
    strt2 = ib2 = extent2 = None
    label2 = args.label2

    if args.dir2 and args.namefile2:
        mf2 = load_mf2005(Path(args.dir2), args.namefile2)
        strt2, ib2 = get_strt_ibound(mf2)
        extent2 = mf2.modelgrid.extent
        if not label2:
            label2 = Path(args.dir2).name or "Model2"

        if (strt2.shape != strt1.shape):
            print("[!] WARNING: Models have different (nlay, nrow, ncol). Plots will be made separately; diffs disabled.", file=sys.stderr)
            args.make_diff = False

    # Determine global color limits for heads across provided model(s), excluding nodata
    if mf2 is not None:
        vmin, vmax = global_minmax_excl_nodata(strt1, ib1, args.nodata, strt2, ib2)
    else:
        vmin, vmax = global_minmax_excl_nodata(strt1, ib1, args.nodata, None, None)

    if vmin is None or vmax is None:
        raise RuntimeError("Could not determine color limits (no active non-nodata cells?).")

    # Plot Model 1
    nlay = strt1.shape[0]
    for k in range(nlay):
        masked1k = mask_active_excl_nodata(strt1[k], ib1[k], args.nodata)
        title_bits = [f"{label1} - Start Heads - Layer {k+1}"]
        if refs and k < len(refs):
            title_bits.append(f"({refs[k]})")
        title = " ".join(title_bits)
        fname = f"{sanitize(label1)}_start_heads_L{k+1:02d}.png"
        plot_layer(strt1[k], masked1k, extent1, vmin, vmax, title, outdir / fname, args.nodata, dpi=args.dpi)

    # Plot Model 2 if present
    if mf2 is not None:
        for k in range(strt2.shape[0]):
            masked2k = mask_active_excl_nodata(strt2[k], ib2[k], args.nodata)
            title_bits = [f"{label2} - Start Heads - Layer {k+1}"]
            if refs and k < len(refs):
                title_bits.append(f"({refs[k]})")
            title = " ".join(title_bits)
            fname = f"{sanitize(label2)}_start_heads_L{k+1:02d}.png"
            plot_layer(strt2[k], masked2k, extent2, vmin, vmax, title, outdir / fname, args.nodata, dpi=args.dpi)

        # Differences if grids align
        if args.make_diff and grids_align(mf1, mf2):
            print("[*] Grids align; writing difference maps (Model1 - Model2).")

            # Build masked diffs: mask inactives, invalids, and any nodata from either model
            nodata_mask = np.isclose(strt1, args.nodata) | np.isclose(strt2, args.nodata)
            active_mask = (ib1 > 0) & (ib2 > 0)
            diffs = np.ma.array(strt1 - strt2, mask=~active_mask)
            diffs = np.ma.masked_where(nodata_mask, diffs)
            diffs = np.ma.masked_invalid(diffs)

            # Symmetric color scale across all layers, ignoring masked cells
            if diffs.count() > 0:
                dmin = float(np.nanmin(diffs.compressed()))
                dmax = float(np.nanmax(diffs.compressed()))
            else:
                dmin = dmax = 0.0
            dabs = max(abs(dmin), abs(dmax))
            dvmin, dvmax = (-dabs, dabs) if dabs > 0 else (-1.0, 1.0)

            for k in range(nlay):
                # For plotting we need both original layer values to identify nodata
                nodata_bool_k = np.isclose(strt1[k], args.nodata) | np.isclose(strt2[k], args.nodata)
                # Use the masked layer for imshow
                diff_k = diffs[k]

                # Render similar to plot_layer: main image + red overlay for nodata
                fig = plt.figure(figsize=(8, 6))
                ax = fig.add_subplot(111)
                base_cmap = mpl.cm.get_cmap(plt.rcParams.get('image.cmap', 'viridis')).copy()
                base_cmap.set_bad((0, 0, 0, 0))

                im = ax.imshow(diff_k, origin='upper', extent=extent1,
                               vmin=dvmin, vmax=dvmax, interpolation='none', cmap=base_cmap)
                cbar = fig.colorbar(im, ax=ax, shrink=0.9)
                cbar.set_label("Start head Δ (Model1 - Model2)")

                if np.any(nodata_bool_k):
                    overlay = np.zeros(nodata_bool_k.shape + (4,), dtype=float)
                    overlay[..., 0] = 1.0
                    overlay[..., 3] = nodata_bool_k.astype(float)
                    ax.imshow(overlay, origin='upper', extent=extent1, interpolation='none')

                ax.set_title(f"Difference ( {label1} - {label2} ) - Layer {k+1}")
                ax.set_xlabel("X")
                ax.set_ylabel("Y")
                ax.set_aspect('equal')
                fig.tight_layout()
                fname = f"DIFF_{sanitize(label1)}_MINUS_{sanitize(label2)}_L{k+1:02d}.png"
                fig.savefig(outdir / fname, dpi=args.dpi)
                plt.close(fig)
                print(f"[✓] Wrote {outdir / fname}")
        elif args.make_diff:
            print("[!] WARNING: Grids do not align; skipping difference maps.", file=sys.stderr)


if __name__ == "__main__":
    main()
