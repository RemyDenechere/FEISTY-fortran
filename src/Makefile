#
# gfortran:
#
# Compiler
FC = gfortran # mpif90 # 

# Compiler flags
FFLAGS = -O2

# netCDF library flags
NETCDF_FLAGS = `nf-config --fflags --flibs`

# OpenMP flag
OPENMP_FLAGS = -fopenmp

# Fortran source file
SOURCE_FEISTY = Parameters.f90  Structure.f90 Physiology.f90 Derivative.f90 GetNetCDFInf.f90 Run_physiology.f90
# SOURCE_NETCDF = Parameters.f90 Structure.f90 GetNetCDFInf.f90 OpenNetCDFFiles.f90
 
OUTPUT_FEISTY = FEISTY
# OUTPUT_NETCDF = Open_Netcdf

# Targets
all: $(OUTPUT_FEISTY)
$(OUTPUT_FEISTY): $(SOURCE_FEISTY)
	$(FC) $(FFLAGS) $(OPENMP_FLAGS) $(SOURCE_FEISTY) -o $(OUTPUT_FEISTY) $(NETCDF_FLAGS) 

#all: $(OUTPUT_NETCDF)
#$(OUTPUT_NETCDF): $(SOURCE_NETCDF)
#	$(FC) $(FFLAGS) $(OPENMP_FLAGS) $(SOURCE_NETCDF) -o $(OUTPUT_NETCDF) $(NETCDF_FLAGS) 
