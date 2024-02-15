# Fortran code for FEISTY - Petrik 2019
The current version runs the climatology on Rockfish.

Change Spinup option (.true. or .false.) in runphysiology.f90 to spinup the model on new data.
Comming soon: input.nlm file with option to change the parameters without recompiling

## Run the model from Rockfish
All the packages are installed on rockfish, to run the model simply run in the comand lines:
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


## Run Matlab analysis 
```
cd /project/rdenechere/FEISTY-fortran/src
matlab
```
when matlab is open : 
```
netcdf_read_FEISTY_fort
vis_FEISTY_fort
```

## Run in UCAR system 

```
cd /glade/u/home/rdenechere/FEISTY_Fortran
module load nvhpc
man nvfortran
module help netcdf

make 
./FEISTY
```

If make does not work: (To be updated from makefile)
netcdf should be in the environement so the flags refering to the library are not needed

```
mpif90 Parameters.f90  Structure.f90 Physiology.f90 Derivative.f90 GetNetCDFInf.f90 Run_physiology.f90
./a.out
```

------------------------------------------------------------------------
# To Do
- Add Mesozooplankton loss output - DONE 
- add other way to calculate the time in pelagic/benthic for Ld that include biomass and depth cutoff. - DONE 
- Move weight, Cmax and clearance rate calculation to param.
- Construct a parallel version 
