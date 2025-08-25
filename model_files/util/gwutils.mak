#
# MKMF template makefile for protected mode executables.
#
FC        = lf95
LINKER    = lf95
PROGRAM   = default.exe
DEST      = .
EXTHDRS         =
#FFLAGS    = -c -nfix -g -nsav -in -chk -trap dio -trace
FFLAGS    = -c -nfix -nsav -in -o1
HDRS            =
LDFLAGS   = -nvm -winconsole -o1
#LDFLAGS   = -nvm -winconsole -o1 -chk -trace
LDMAP     = nul
LIBS      = gwlib.lib
COMPRESS1 = gwutils1.exe
COMPRESS2 = gwutils2.exe
COMPRESS3 = gwutils3.exe
COMPRESS4 = source.exe
MAKEFILE  = gwutils.mak

LIBSRCS         = addquote.f90 casetran.f90 cell2rc.f90 char2dat.f90 \
                  char2num.f90 \
                  char2tim.f90 charadd.f90 closefil.f90 closspec.f90 \
                  corner.f90 elapsdat.f90 factor.f90 freebmem.f90 \
                  freegmem.f90 freepmem.f90 freermem.f90 getidint.f90 \
                  getfile.f90 \
                  getnumid.f90 \
                  grd2eth.f90 int2alph.f90 keyread.f90 leap.f90 \
                  linsplit.f90 newdate.f90 nextunit.f90 nnegtest.f90 \
                  num2char.f90 numdays.f90 numsecs.f90 openin.f90 \
                  opennam.f90 openout.f90 pointint.f90 postest.f90 \
                  rc2cell.f90 readbcf.f90 readblf.f90 readfig.f90 \
                  readiarr.f90 readitab.f90 readppf.f90 readprep.f90 \
                  readrarr.f90 \
                  readropl.f90 readrosf.f90 \
                  readrosl.f90 readrtab.f90 readsarr.f90 readset.f90 \
                  readsdim.f90 \
                  readspdm.f90 readspdt.f90 rdrtbint.f90 relcntcd.f90 sectime.f90 \
                  sgsim.f specopen.f90 \
                  suberror.f90 time2cha.f90 timeint.f90 tran2eth.f90 \
                  travel.f90 writiarr.f90 writimid.f90 writinit.f90 \
                  writmess.f90 writmif.f90 writrarr.f90 writrmid.f90 \
                  writrtab.f90 writsarr.f90 xfinish.f90 xheader.f90 xpolyfin.f90 \
                  xpolyhea.f90 xvertex.f90


EXECS1     =  adjobs.exe arrayobs.exe grid2arc.exe grid2bln.exe grid2dxf.exe grid2pt.exe \
              int2mif.exe int2real.exe many2one.exe mkpmp1.exe mksmp1.exe \
              mod2smp.exe pmp2info.exe pmpchek.exe pt2array.exe ptingrid.exe \
              qdig2dxf.exe qdig2xyz.exe real2int.exe real2mif.exe \
              real2srf.exe real2tab.exe reparray.exe bud2smp.exe

EXECS2     =  rotbln.exe rotdat.exe rotdxf.exe section.exe smp2dat.exe \
              smp2hyd.exe smp2info.exe smp2pm1.exe smp2pm2.exe smp2smp.exe \
              smpchek.exe srf2real.exe tab2int.exe tab2real.exe tabconv.exe \
              twoarray.exe zone2bln.exe zone2dxf.exe smpcal.exe mod2obs.exe \
              pestprep.exe bud2hyd.exe

EXECS3     =  fac2mf2k.exe fac2real.exe fieldgen.exe ppk2fac.exe ppkreg.exe \
              ppk2facf.exe fac2fem.exe fem2smp.exe mod2obs1.exe smpdiff.exe \
              smptrend.exe smpcon.exe laydiff.exe vertreg.exe ppkreg1.exe \
              ppk2fac1.exe parm3d.exe genreg.exe facgen.exe ppk2facm.exe fac2fhm1.exe \
              fac2fhm2.exe ppcov.exe logarray.exe

.f90.obj :
	make -f defint.mak defn.lib
	make -f defint.mak inter.mod
	$(FC) $(FFLAGS) $<

.obj.exe :
	make -f gwlib.mak gwlib.lib
        $(LINKER) $(@,.exe=.obj) -EXE $@ $(LDFLAGS) -LIB $(LIBS)
#       uncomment these lines if all utilties use the same extender
#        rebindb -noautobind $@
#        cfig386 -dosxname $(STUB) $@
#	cfig386 $@ -nosignon

compress :	$(COMPRESS1) $(COMPRESS2) $(COMPRESS3) $(COMPRESS4)

$(COMPRESS1) :
	!if -e $(COMPRESS1)
	   del $(COMPRESS1)
	!endif
	!if -e $(COMPRESS1,.exe=.zip)
	   del $(COMPRESS1,.exe=.zip)
	!endif
	!if -e temp.dat
	   del temp.dat
	!endif
	echo $(EXECS1,.exe=.exe$(RETURN)) >>temp.dat
	pkzip $(@,.exe=.zip) @temp.dat
	zip2exe $(@,.exe=.zip)
	del $(@,.exe=.zip)

$(COMPRESS2) :
	!if -e $(COMPRESS2)
	   del $(COMPRESS2)
	!endif
	!if -e $(COMPRESS2,.exe=.zip)
	   del $(COMPRESS2,.exe=.zip)
	!endif
	!if -e temp.dat
	   del temp.dat
	!endif
	echo $(EXECS2,.exe=.exe$(RETURN)) >> temp.dat
	pkzip $(@,.exe=.zip) @temp.dat
	zip2exe $(@,.exe=.zip)
	del $(@,.exe=.zip)

$(COMPRESS3) :
	!if -e $(COMPRESS3)
	   del $(COMPRESS3)
	!endif
	!if -e $(COMPRESS3,.exe=.zip)
	   del $(COMPRESS3,.exe=.zip)
	!endif
	!if -e temp.dat
	   del temp.dat
	!endif
	echo $(EXECS3,.exe=.exe$(RETURN)) >> temp.dat
	pkzip $(@,.exe=.zip) @temp.dat
	zip2exe $(@,.exe=.zip)
	del $(@,.exe=.zip)


$(COMPRESS4) :
	!if -e $(COMPRESS4)
	   del $(COMPRESS4)
	!endif
	!if -e $(COMPRESS4,.exe=.zip)
	   del $(COMPRESS4,.exe=.zip)
	!endif
	pkzip $(@,.exe=.zip) *.f90 *.inc
	pkzip $(@,.exe=.zip) -a *.mak
	zip2exe $(@,.exe=.zip)
	del $(@,.exe=.zip)
	


clean:;         @del *.obj

depend:;   @mkmf -f $(MAKEFILE) PROGRAM=$(PROGRAM) DEST=$(DEST)
	
# The Groundwater Modelling Executables -------->

all : $(EXECS1) $(EXECS2) $(EXECS3)


# The stub which holds the DOS extender ------->

#$(STUB) :	$(STUB,.exe=.f90)
#	$(FC) $(STUBFFLAGS) $(STUB,.exe=.f90)
#	$(LINKER) $(@,.exe=.obj) -EXE $@ $(STUBLDFLAGS)
#	cfig386 $@ -nosignon


# Further dependencies follow: -------->

adjobs.exe :	$(LIBSRCS)
adjobs.obj :	defn.f90 inter.f90

arrayobs.exe :	$(LIBSRCS)
arrayobs.obj :	defn.f90 inter.f90

bud2hyd.exe :	$(LIBSRCS)
bud2hyd.obj :	defn.f90 inter.f90

bud2smp.exe :	$(LIBSRCS)
bud2smp.obj :	defn.f90 inter.f90

fac2mf2k.exe :	$(LIBSRCS)
fac2mf2k.obj :	defn.f90 inter.f90

fac2real.exe :	$(LIBSRCS)
fac2real.obj :	defn.f90 inter.f90

fac2fem.exe :	$(LIBSRCS)
fac2fem.obj :	defn.f90 inter.f90

fac2fhm1.exe :	$(LIBSRCS)
fac2fhm1.obj :	defn.f90 inter.f90

fac2fhm2.exe :	$(LIBSRCS)
fac2fhm2.obj :	defn.f90 inter.f90

fem2smp.exe :	$(LIBSRCS)
fem2smp.obj :	defn.f90 inter.f90

fieldgen.exe :  $(LIBSRCS)
fieldgen.obj :  defn.f90 inter.f90

genreg.exe :  $(LIBSRCS)
genreg.obj :  defn.f90 inter.f90

grid2arc.exe :	$(LIBSRCS)
grid2arc.obj :	defn.f90 inter.f90

grid2bln.exe :	$(LIBSRCS)
grid2bln.obj :	defn.f90 inter.f90

grid2dxf.exe :	$(LIBSRCS)
grid2dxf.obj :	defn.f90 inter.f90

grid2pt.exe :	$(LIBSRCS) 
grid2pt.obj :	defn.f90 inter.f90

int2mif.exe :	$(LIBSRCS) 
int2mif.obj :	defn.f90 inter.f90

int2real.exe :	$(LIBSRCS) 
int2real.obj :	defn.f90 inter.f90

laydiff.exe :   $(LIBSRCS)
laydiff.obj :   defn.f90 inter.f90

logarray.exe :	$(LIBSRCS)
logarray.obj :	defn.f90 inter.f90

many2one.exe :	$(LIBSRCS) 
many2one.obj :	defn.f90 inter.f90

mkpmp1.exe :	$(LIBSRCS) 
mkpmp1.obj :	defn.f90 inter.f90

mksmp1.exe :	$(LIBSRCS) 
mksmp1.obj :	defn.f90 inter.f90

mod2smp.exe :	$(LIBSRCS) 
mod2smp.obj :	defn.f90 inter.f90

mod2obs.exe :	$(LIBSRCS) 
mod2obs.obj :	defn.f90 inter.f90

mod2obs1.exe :	$(LIBSRCS)
mod2obs1.obj :	defn.f90 inter.f90

parm3d.exe :    $(LIBSRCS)
parm3d.obj :    defn.f90 inter.f90

pestprep.exe :	$(LIBSRCS) 
pestprep.obj :	defn.f90 inter.f90

pmp2info.exe :	$(LIBSRCS) 
pmp2info.obj :	defn.f90 inter.f90

pmpchek.exe :	$(LIBSRCS) 
pmpchek.obj :	defn.f90 inter.f90

ppcov.exe :     $(LIBSRCS)
ppcov.obj :     defn.f90 inter.f90

ppk2fac.exe :	$(LIBSRCS) 
ppk2fac.obj :	defn.f90 inter.f90 kb2d.inc

ppk2facf.exe :	$(LIBSRCS)
ppk2facf.obj :	defn.f90 inter.f90 kb2d.inc

ppk2fac1.exe :	$(LIBSRCS) 
ppk2fac1.obj :	defn.f90 inter.f90 kb2d.inc

ppk2facm.exe :	$(LIBSRCS)
ppk2facm.obj :	defn.f90 inter.f90 kb2d.inc

facgen.exe :	$(LIBSRCS)
facgen.obj :	defn.f90 inter.f90 kb2d.inc

ppkreg.exe :	$(LIBSRCS) 
ppkreg.obj :	defn.f90 inter.f90 kb2d.inc

ppkreg1.exe :	$(LIBSRCS) 
ppkreg1.obj :	defn.f90 inter.f90 kb2d.inc

pt2array.exe :	$(LIBSRCS) 
pt2array.obj :	defn.f90 inter.f90

ptingrid.exe :	$(LIBSRCS) 
ptingrid.obj :	defn.f90 inter.f90

qdig2dxf.exe :	$(LIBSRCS) 
qdig2dxf.obj :	defn.f90 inter.f90

qdig2xyz.exe :	$(LIBSRCS) 
qdig2xyz.obj :	defn.f90 inter.f90

real2int.exe :	$(LIBSRCS) 
real2int.obj :	defn.f90 inter.f90

real2mif.exe :	$(LIBSRCS) 
real2mif.obj :	defn.f90 inter.f90

real2srf.exe :	$(LIBSRCS) 
real2srf.obj :	defn.f90 inter.f90

real2tab.exe :	$(LIBSRCS)
real2tab.obj :	defn.f90 inter.f90

reparray.exe :	$(LIBSRCS) 
reparray.obj :	defn.f90 inter.f90

rotbln.exe :	$(LIBSRCS) 
rotbln.obj :	defn.f90 inter.f90

rotdat.exe :	$(LIBSRCS) 
rotdat.obj :	defn.f90 inter.f90

rotdxf.exe :	$(LIBSRCS) 
rotdxf.obj :	defn.f90 inter.f90

section.exe :	$(LIBSRCS) 
section.obj :	defn.f90 inter.f90

smp2dat.exe :	$(LIBSRCS) 
smp2dat.obj :	defn.f90 inter.f90

smp2hyd.exe :	$(LIBSRCS) 
smp2hyd.obj :	defn.f90 inter.f90

smp2info.exe :	$(LIBSRCS) 
smp2info.obj :	defn.f90 inter.f90

smp2pm1.exe :	$(LIBSRCS) 
smp2pm1.obj :	defn.f90 inter.f90

smp2pm2.exe :	$(LIBSRCS) 
smp2pm2.obj :	defn.f90 inter.f90

smp2smp.exe :	$(LIBSRCS) 
smp2smp.obj :	defn.f90 inter.f90

smpcal.exe :	$(LIBSRCS) 
smpcal.obj :	defn.f90 inter.f90

smpchek.exe :	$(LIBSRCS) 
smpchek.obj :	defn.f90 inter.f90

smpcon.exe :   $(LIBSRCS)
smpcon.obj :   defn.f90 inter.f90

smpdiff.exe :	$(LIBSRCS)
smpdiff.obj :	defn.f90 inter.f90

smptrend.exe :	$(LIBSRCS)
smptrend.obj :	defn.f90 i

srf2real.exe :	$(LIBSRCS) 
srf2real.obj :	defn.f90 inter.f90

tab2int.exe :	$(LIBSRCS) 
tab2int.obj :	defn.f90 inter.f90

tab2real.exe :	$(LIBSRCS) 
tab2real.obj :	defn.f90 inter.f90

tabconv.exe :	$(LIBSRCS) 
tabconv.obj :	defn.f90 inter.f90

twoarray.exe :	$(LIBSRCS) 
twoarray.obj :	defn.f90 inter.f90

vertreg.exe :   $(LIBSRCS)
vertreg.obj :   defn.f90 inter.f90

zone2bln.exe :	$(LIBSRCS) 
zone2bln.obj :	defn.f90 inter.f90

zone2dxf.exe :	$(LIBSRCS) 
zone2dxf.obj :	defn.f90 inter.f90

