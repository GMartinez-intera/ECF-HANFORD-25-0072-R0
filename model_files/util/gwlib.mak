#
# MKMF template makefile for libraries.
#
FC        = lf95
DEST      = .
EXTHDRS         =
#FFLAGS    = -c -nfix -g -nsav -in -chk -trap dio -f90 -trace
FFLAGS    = -c -nfix -nsav -in -trace -o1
HDRS            =
LIBRARY         = gwlib.lib

MAKEFILE  = Makefile
OBJS            = addquote.obj casetran.obj cell2rc.obj char2dat.obj \
                  char2num.obj \
                  char2tim.obj charadd.obj closefil.obj closspec.obj \
                  corner.obj datestr.obj elapsdat.obj factor.obj freebmem.obj \
                  freegmem.obj freepmem.obj freermem.obj getidint.obj \
                  getfile.obj \
                  getnumid.obj \
                  grd2eth.obj int2alph.obj keyread.obj leap.obj \
                  linsplit.obj newdate.obj nextunit.obj nnegtest.obj \
                  num2char.obj numdays.obj numsecs.obj openin.obj \
                  opennam.obj openout.obj pointint.obj postest.obj \
                  rc2cell.obj readbcf.obj readblf.obj readfig.obj \
                  readiarr.obj readitab.obj readppf.obj readprep.obj \
                  readrarr.obj readdppf.obj \
                  readropl.obj readrosf.obj \
                  readrosl.obj readrtab.obj readsarr.obj readset.obj \
                  readsdim.obj \
                  readspdm.obj readspdt.obj rdrtbint.obj relcntcd.obj sectime.obj \
                  sgsim.obj specopen.obj \
                  suberror.obj time2cha.obj timeint.obj tran2eth.obj \
                  travel.obj writiarr.obj writimid.obj writinit.obj \
                  writmess.obj writmif.obj writrarr.obj writrmid.obj \
                  writrtab.obj writsarr.obj xfinish.obj xheader.obj xpolyfin.obj \
                  xpolyhea.obj xvertex.obj
SRCS            = addquote.f90 casetran.f90 cell2rc.f90 char2dat.f90 \
                  char2num.f90 \
                  char2tim.f90 charadd.f90 closefil.f90 closspec.f90 \
                  corner.f90 datestr.f90 elapsdat.f90 factor.f90 freebmem.f90 \
                  freegmem.f90 freepmem.f90 freermem.f90 getidint.f90 \
                  getfile.f90 \
                  getnumid.f90 \
                  grd2eth.f90 int2alph.f90 keyread.f90 leap.f90 \
                  linsplit.f90 newdate.f90 nextunit.f90 nnegtest.f90 \
                  num2char.f90 numdays.f90 numsecs.f90 openin.f90 \
                  opennam.f90 openout.f90 pointint.f90 postest.f90 \
                  rc2cell.f90 readbcf.f90 readblf.f90 readfig.f90 \
                  readiarr.f90 readitab.f90 readppf.f90 readprep.f90 \
                  readrarr.f90 readdppf.f90 \
                  readropl.f90 readrosf.f90 \
                  readrosl.f90 readrtab.f90 readsarr.f90 readset.f90 \
                  readsdim.f90 \
                  readspdm.f90 readspdt.f90 rdrtbint.f90 relcntcd.f90 sectime.f90 \
                  sgsim.f specopen.f90 \
                  suberror.f90 time2cha.f90 timeint.f90 tran2eth.f90 \
                  travel.f90 writiarr.f90 writimid.f90 writinit.f90 \
                  writmess.f90 writmif.f90 writrarr.f90 writrmid.f90 \
                  writrtab.f90 ritsarr.f90 xfinish.f90 xheader.f90 xpolyfin.f90 \
                  xpolyhea.f90 xvertex.f90
LIBOBJS         = +addquote.obj +casetran.obj +cell2rc.obj +char2dat.obj \
                  +char2num.obj \
                  +char2tim.obj +charadd.obj +closefil.obj +closspec.obj \
                  +corner.obj +elapsdat.obj +factor.obj +freebmem.obj \
                  +freegmem.obj +freepmem.obj +freermem.obj +getidint.obj \
                  +getfile.obj \
                  +getnumid.obj \
                  +grd2eth.obj +int2alph.obj +keyread.obj +leap.obj \
                  +linsplit.obj +newdate.obj +nextunit.obj +nnegtest.obj \
                  +num2char.obj +numdays.obj +numsecs.obj +openin.obj \
                  +opennam.obj +openout.obj +pointint.obj +postest.obj \
                  +rc2cell.obj +readbcf.obj +readblf.obj +readfig.obj \
                  +readiarr.obj +readitab.obj +readppf.obj +readprep.obj \
                  +readrarr.obj +readdppf.obj \
                  +readropl.obj +readrosf.obj \
                  +readrosl.obj +readrtab.obj +readsarr.obj +readset.obj \
                  +readsdim.obj \
                  +readspdm.obj +readspdt.obj +rdrtbint.obj +relcntcd.obj +sectime.obj \
                  +sgsim.obj specopen.obj \
                  +suberror.obj +time2cha.obj +timeint.obj +tran2eth.obj \
                  +travel.obj +writiarr.obj +writimid.obj +writinit.obj \
                  +writmess.obj +writmif.obj +writrarr.obj +writrmid.obj \
                  +writrtab.obj +writsarr.obj +xfinish.obj +xheader.obj +xpolyfin.obj \
                  +xpolyhea.obj +xvertex.obj +defn.obj +inter.obj +datestr.obj


###   For make to take advantage of compiler response files, uncomment
###   the next four lines, and the additional three lines listed after
###   the '$(PROGRAM):   $(OBJS) $(LIBS)' line.
###.BEFORE:
###       DEL LF90.RSP
###.for.obj:
###       ECHO $<,$@ $(FFLAGS) >>LF90.RSP


.f90.obj:
	make -f defint.mak defn.lib
	make -f defint.mak inter.mod
	$(FC) $(FFLAGS) $<


$(LIBRARY):	$(OBJS) 
###       !IF -e LF90.RSP
###           $(FC) @LF90.RSP
###       !ENDIF
	  del $(LIBRARY)
	  lm $(LIBRARY) $(LIBOBJS);

clean:;               @del -f $(OBJS)

depend:;    @mkmf -f $(MAKEFILE) LIBRARY=$(LIBRARY) DEST=$(DEST)

install:    $(LIBRARY)
            @echo Installing $(LIBRARY) in $(DEST)
            @if not $(DEST)x==.x copy $(LIBRARY) $(DEST)

### OPUS MKMF:  Do not remove this line!  Automatic dependencies follow.

addquote :

casetran.obj :	inter.f90

cell2rc.obj :	defn.f90

char2dat.obj :	defn.f90 inter.f90

char2num.obj :	defn.f90

char2tim.obj :	defn.f90 inter.f90

closspec.obj :	defn.f90 inter.f90

corner.obj :	defn.f90 inter.f90

datestr.obj :	defn.f90 inter.f90

elapsdat.obj :	inter.f90

factor.obj :	defn.f90 inter.f90

freebmem.obj :	defn.f90 inter.f90

freegmem.obj :	defn.f90 inter.f90

freepmem.obj :	defn.f90 inter.f90

freermem.obj :  defn.f90 inter.f90

getidint.obj :	inter.f90

getfile.obj :	defn.f90 inter.f90

getnumid.obj :	defn.f90 inter.f90

grd2eth.obj :	defn.f90 inter.f90

keyread.obj :	defn.f90

linsplit.obj :	defn.f90 inter.f90

newdate.obj :	inter.f90

nnegtest.obj :	defn.f90

num2char.obj :	inter.f90

openin.obj :	defn.f90 inter.f90

openout.obj :	defn.f90 inter.f90        

opennam.obj :	defn.f90 inter.f90

postest.obj :	defn.f90

rc2cell.obj :	defn.f90

readbcf.obj :	defn.f90 inter.f90

readblf.obj :	defn.f90 inter.f90

readfig.obj :	inter.f90

readiarr.obj :	defn.f90 inter.f90

readitab.obj :	defn.f90 inter.f90

readppf.obj :	defn.f90 inter.f90

readdppf.obj :	defn.f90 inter.f90

readprep.obj :	defn.f90 inter.f90

readrarr.obj :	defn.f90 inter.f90

readrosf.obj :	defn.f90 inter.f90

readrosl.obj :	defn.f90 inter.f90

readropl.obj :	defn.f90 inter.f90

readrtab.obj :	defn.f90 inter.f90

readsarr.obj :	defn.f90 inter.f90

readset.obj :	defn.f90 inter.f90

readsdim.obj :	defn.f90 inter.f90

readspdm.obj :	defn.f90 inter.f90

readspdt.obj :	defn.f90 inter.f90

rdrtbint.obj :	defn.f90 inter.f90

relcntcd.obj :	defn.f90 inter.f90

sectime.obj :	inter.f90

sgsim.obj :     sgsim.f sgsim.inc
	$(FC) -c -nsav -trace sgsim.f

specopen.obj :	defn.f90 inter.f90

tran2eth.obj :	defn.f90 inter.f90

travel.obj :	defn.f90 inter.f90

timeint.obj :	defn.f90 inter.f90

writiarr.obj :	defn.f90 inter.f90

writimid.obj :	defn.f90 inter.f90

writinit.obj :	defn.f90 inter.f90

writmif.obj :	defn.f90 inter.f90

writmess.obj :	defn.f90 inter.f90

writrarr.obj :	defn.f90 inter.f90

writrmid.obj :	defn.f90 inter.f90

writrtab.obj :	defn.f90 inter.f90

writsarr.obj :	defn.f90 inter.f90
