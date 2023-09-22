#
# gfortran:
#
# Compiler
FC = gfortran # mpif90 # 

# Compiler flags
FFLAGS = -O2

# netCDF library path
NETCDF_PATH_inc = "C:/Program Files/netCDF 4.9.2/include" 
NETCDF_PATH_lib = "C:/Program Files/netCDF 4.9.2/lib"

# netCDF library flags
# NETCDF_FLAGS = -I"C:/Program Files/netCDF 4.9.2/include" -L"C:/Program Files/netCDF 4.9.2/lib" -lnetcdff -lnetcdf -Wl,-Bstatic -lnetcdff -lnetcdf
NETCDF_FLAGS = `nf-config --fflags --flibs`

# Fortran source file
SOURCE_FEISTY = Parameters.f90  Structure.f90 Physiology.f90 Derivative.f90 GetNetCDFInf.f90 Run_physiology.f90
SOURCE_NETCDF = Parameters.f90 Structure.f90 GetNetCDFInf.f90 OpenNetCDFFiles.f90
 
OUTPUT_FEISTY = FEISTY
OUTPUT_NETCDF = Open_Netcdf

# Targets
all: $(OUTPUT_FEISTY)
$(OUTPUT_FEISTY): $(SOURCE_FEISTY)
	$(FC) $(FFLAGS) $(SOURCE_FEISTY) -o $(OUTPUT_FEISTY) $(NETCDF_FLAGS)

all: $(OUTPUT_NETCDF)
$(OUTPUT_NETCDF): $(SOURCE_NETCDF)
	$(FC) $(FFLAGS) $(SOURCE_NETCDF) -o $(OUTPUT_NETCDF) $(NETCDF_FLAGS)


# -c "C:\Program Files\netcdf-fortran-4.6.1\fortran\netcdf.f90"
# "C:\Program Files\netcdf-fortran-4.6.1\fortran\netcdf3_file.F90"
#gfortran -c Parameters.f90 Structure.f90 Physiology.f90 Derivative.f90 Run_physiology.f90 -o Run_physiology `nf-config --fflags --flibs`
#gfortran -c "C:\Program Files\netcdf-fortran-4.6.1\fortran\netcdf3_file.f90" Parameters.f90 Structure.f90 Physiology.f90 Derivative.f90 Run_physiology.f90 