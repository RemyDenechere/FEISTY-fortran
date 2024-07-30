%% Some visualisation of the data: 
% -------------------------------------------------------------------------

file = "20040101.ocean_feisty_forcing_offline.nc";
ncid = netcdf.open(file); 
var = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "nlgz")); 
var_spacemean = squeeze(nanmean(var, [1,2]));
var_timemean = sum(var_spacemean);
plot(1:length(var_timemean), var_timemean)

%%

file = "exps/datasets/datasets_1yr_run/OM4_025.JRA.single_column/ocean_hgrid.nc";
ncid = netcdf.open(file); 
x = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "x")); % longitude
y = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "y")); % lat 

long_min = min(min(x))
long_max = max(max(x))
lat_min  = min(min(y))
lat_max  = max(max(y))

file = "exps/datasets/OM4_025.JRA.single_column/ocean_hgrid.nc";
ncid = netcdf.open(file); 
x = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "x"))
y = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "y"));

%
file = "exps/OM4.single_column.COBALT/INPUT/COBALT_2023_10_spinup_2003_subset.nc";
ncid = netcdf.open(file); 
x = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "lonh"))

%% look at Yi-cheng IC file: 
file = "Z:/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/INPUT/FEISTY_2023_10_spinup_subset.nc"; 
ncid = netcdf.open(file); 
lz = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "Layer"));
lz(end)

file = "Z:/rdenechere/FEISTY-fortran/output/FEISTY_2023_10_spinup_subset.nc";
ncid = netcdf.open(file); 
lz = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "Layer"));
lz(end)

file = "Z:/rdenechere/FEISTY-fortran/output/Yi_cheng_outputs/BE_B_IC_rescaled.nc";
ncid = netcdf.open(file); 
BE_B = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "BE_B"));
lz = netcdf.getVar(ncid, netcdf.inqVarID(ncid, "Layer"));

plot(lz, squeeze(mean(BE_B, [1,2])))