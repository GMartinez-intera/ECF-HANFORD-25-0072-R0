FC        = lf95

FFLAGS    = -c -nfix -g -nsav -in -chk -trap dio -f90 -trace
#FFLAGS    = -c -nfix -nsav -in -trace


defn.lib :      defn.f90
        $(FC) $(FFLAGS) defn.f90


inter.mod :     defn.lib inter.f90
        $(FC) $(FFLAGS) inter.f90

