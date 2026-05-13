FOPTS = -c -r8 -implicitnone -fpp -warn all $(OPTS) -DUSEBLAS -DPETSC_VERSION=319
CCOPTS  = -c -DPETSC_VERSION=319
R8OPTS = -r8

ifeq ($(OPT), 1)
  FOPTS  := $(FOPTS) -O2 -qopt-report=0 -qopt-report-phase=vec
  CCOPTS := $(CCOPTS) -O
else
  FOPTS := $(FOPTS) -g -check all -check noarg_temp_created -debug all -ftrapuv -traceback -fpe=all
  CCOPTS := $(CCOPTS) -g -check=uninit -debug all
endif

ifeq ($(PAR), 1)
  FOPTS := $(FOPTS) -DUSEPARTICLES
endif

CC = mpiicx
CPP = mpiicpx
F90 = mpiifx
F77 = mpiifx
LOADER = mpiifx
LDOPTS := $(LDOPTS) -cxxlib
F90OPTS = $(F90FLAGS) $(FOPTS) -gen-interfaces
F77OPTS = $(F77FLAGS) $(FOPTS)

# define where you want to locate the mesh adapt libraries
MPIVER=intel2021.1.2-intelmpi2021.3.1


PETSC_DIR=/APP/libraries/intel/2026.0.0
ifeq ($(COM), 1)
  PETSC_ARCH=petsc-cplx-static
  M3DC1_SCOREC_LIB=-lm3dc1_scorec_complex

PETSC_WITH_EXTERNAL_LIB = -L${PETSC_DIR}/${PETSC_ARCH}/lib \
        -Wl,-rpath,/${PETSC_DIR}/${PETSC_ARCH}/lib \
        -L/${PETSC_DIR}/${PETSC_ARCH}/lib  \
        -lpetsc \
        -lcmumps -ldmumps -lsmumps -lzmumps -lmumps_common \
        -lpord -lsuperlu -lsuperlu_dist \
        -lscalapack -lflapack -lfblas -lzoltan \
        -lparmetis -lmetis \
        -lz -lmpifort -lmpi -lrt -lpthread \
        -lifport -lifcoremt_pic -limf -lsvml -lm -lipgo -lirc -lgcc_s -lirc_s -lquadmath \
        -lstdc++ -ldl -lmpfr -lgmp
else
  PETSC_ARCH=petsc-real-static
  M3DC1_SCOREC_LIB=-lm3dc1_scorec

PETSC_WITH_EXTERNAL_LIB = -L${PETSC_DIR}/${PETSC_ARCH}/lib \
        -Wl,-rpath,/${PETSC_DIR}/${PETSC_ARCH}/lib \
        -L/${PETSC_DIR}/${PETSC_ARCH}/lib  \
        -lpetsc \
        -lHYPRE -lcmumps -ldmumps -lsmumps -lzmumps -lmumps_common \
        -lpord -lsuperlu -lsuperlu_dist \
        -lscalapack -lflapack -lfblas -lzoltan \
        -lparmetis -lmetis \
        -lz -lmpifort -lmpi -lrt -lpthread \
        -lifport -lifcoremt_pic -limf -lsvml -lm -lipgo -lirc -lgcc_s -lirc_s -lquadmath \
        -lstdc++ -ldl -lmpfr -lgmp
endif







SCOREC_BASE_DIR=/home/jsh8708/core-240527/tdst
SCOREC_UTIL_DIR=$(SCOREC_BASE_DIR)/bin



ifdef SCORECVER
  SCOREC_DIR=$(SCOREC_BASE_DIR)/$(SCORECVER)
else
  SCOREC_DIR=$(SCOREC_BASE_DIR)
endif

ZOLTAN_LIB=-L$(PETSC_DIR)/$(PETSC_ARCH)/lib -lzoltan

SCOREC_LIBS= -L$(SCOREC_DIR)/lib $(M3DC1_SCOREC_LIB) \
             -Wl,--start-group,-rpath,$(SCOREC_BASE_DIR)/lib -L$(SCOREC_BASE_DIR)/lib \
             -lpumi -lapf -lapf_zoltan -lgmi -llion -lma -lmds -lmth -lparma \
             -lpcu -lph -lsam -lspr -lcrv -Wl,--end-group

LIBS =  -L$(I_MPI_ROOT)/lib -lmpicxx\
        $(SCOREC_LIBS) \
        $(ZOLTAN_LIB) \
        $(PETSC_WITH_EXTERNAL_LIB) \
        -L$(FFTW_HOME)/lib -lfftw3_mpi -lfftw3l_mpi -lfftw3f_mpi -lfftw3 \
        -L$(PETSC_DIR)/$(PETSC_ARCH)/lib -lhdf5_hl_fortran -lhdf5_hl_f90cstub -lhdf5_fortran -lhdf5_f90cstub -lhdf5_hl -lhdf5 -lz \
        -L$(PETSC_DIR)/$(PETSC_ARCH)/lib -lgsl -lgslcblas




INCLUDE = -I$(PETSC_DIR)/include \
        -I$(PETSC_DIR)/$(PETSC_ARCH)/include \
	-I$(SCOREC_DIR)/include \
        -I$(PETSC_DIR)/$(PETSC_ARCH)/include \
        -I$(PETSC_DIR)/$(PETSC_ARCH)/include

ifeq ($(ST), 1)
  LIBS += -L$(PETSC_DIR)/$(PETSC_ARCH)/lib -lnetcdf \
		-L/APP/libraries/intel/2026.0.0/netcdf-f-static/lib -lnetcdff

  INCLUDE += -I$(PETSC_DIR)/$(PETSC_ARCH)/include \
		-I/APP/libraries/intel/2026.0.0/netcdf-f-static/include
endif

%.o : %.c
	$(CC)  $(CCOPTS) $(INCLUDE) $< -o $@

%.o : %.cpp
	$(CPP) $(CCOPTS) $(INCLUDE) $< -o $@

%.o: %.f
	$(F77) $(F77OPTS) $(INCLUDE) $< -o $@

%.o: %.F
	$(F77) $(F77OPTS) $(INCLUDE) $< -o $@

%.o: %.f90
	$(F90) $(F90OPTS) $(INCLUDE) -fpic $< -o $@

