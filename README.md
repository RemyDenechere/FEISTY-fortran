# Fortran files for FEISTY (Petrik 2019)
The current version runs the climatology on Rockfish.
Change Spinup option (.true. or .false.) in runphysiology.f90 to spinup the model on new data. 

## Run the model from Rockfish
All the packages are installed on rockfish, to run the model simply run in the comand line:
```
cd /project/rdenechere/FEISTY-fortran/src
make
./FEISTY
```

## Run on a laptop (linux or wsl)
### Set up fortran
```
sudo apt install gfortran make netcdf-bin libnetcdf-dev libnetcdff-dev openmpi-bin libopenmpi-dev
```
- Fortran compiler: gfortran
- NetCDF packages: netcdf-bin libnetcdf-dev libnetcdff-dev
- parallel simulation: openmpi-bin libopenmpi-dev
Flags for netcdf and OpenMP are already in the makefile.

------------------------------------------------------------------------
# To Do
- 
