%
%
%                    VISUALISE Data from IC files for 
%                           Online Simulation
%
% -------------------------------------------------------------------------

%% Initial condition COBALT 
ncid = netcdf.open('Z:/CEFI-regional-MOM6/exps/OM4.single_column.COBALT/INPUT/COBALT_2023_10_spinup_2003_subset.nc', 'NC_NOWRITE');
Time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Time'));
lath = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lath'));
lonh = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lonh'));
Layer = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Layer'));
netcdf.close(ncid);

%% Initial condition FEISTY 
ncid = netcdf.open('../output/FEISTY_2023_10_spinup_subset.nc', 'NC_NOWRITE');
Time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Time'));
lath = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lath'));
lonh = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lonh'));
Layer = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Layer'));
Sf_B = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Sf_B'));
netcdf.close(ncid);
