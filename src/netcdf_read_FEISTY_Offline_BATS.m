% FEISTY output at all locations
clear all
close all

%% Root directory: 
param.Rockfish =  true; % false; % 
param = param_setup(param);

%! get directory containing output
dir = '../output/'; 
exp = 'COBALT_offline_BATS_';
Spinup = {'_Spinup_Time_Serie', ''}; 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE', 'dZm', 'dZl'}; 

%% Get Spinup Time Series data:  
for i = 1:(length(var)-2)
    ncid = netcdf.open([dir exp var{i} '_bio' Spinup{1} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval(var{1}));

%! Take mean over latitude and longitude and sum over depth for visualization:
time = 1:dim(1);
for i = 1:(length(var)-2)
    sum_depth(:,:,:) = squeeze(eval(['sum(' var{i} ', 2)'])); 
    eval([var{i} '_tmean = transpose(nanmean( sum_depth, [2, 3]));']);
end 
clear sum_depth
save([dir 'Matlab_Average/' exp 'Time_Means' Spinup{1} '.mat'], 'time',...
    'Sf_tmean','Sp_tmean','Sd_tmean',...
    'Mf_tmean','Mp_tmean','Md_tmean',...
    'Lp_tmean','Ld_tmean','BE_tmean')

%% Get Time Series from offline simulations:
%! Fish:
for i = 1:(length(var)-2)
    ncid = netcdf.open([dir exp var{i} '_bio' Spinup{2} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 

%! zoo oversoncumption: 
for i = (length(var)-1):length(var)
    ncid = netcdf.open([dir exp var{i} Spinup{2} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval(var{1}));

%! Take mean over latitude and longitude for visualization:
time = 1:dim(1);
for i = 1:length(var)
    sum_depth(:,:,:) = squeeze(eval(['sum(' var{i} ', 2)'])); 
    eval([var{i} '_tmean = transpose(nanmean( sum_depth, [2, 3]));']);
end 
clear sum_depth

save([dir 'Matlab_Average/' exp 'Time_Means' Spinup{2} '.mat'], 'time',...
    'Sf_tmean','Sp_tmean','Sd_tmean',...
    'Mf_tmean','Mp_tmean','Md_tmean',...
    'Lp_tmean','Ld_tmean','BE_tmean', ...
    'dZm_tmean', 'dZl_tmean')

%% get input varaibles from COBALT 
dir = {'/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline.nc', ...
       '/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline.nc', ...
       '/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline.nc', ...
       '/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline.nc', ...
       '/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline.nc', ...
       '/rdenechere/COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline_detritus.nc'};
var = {'thetao', 'nmdz', 'jhploss_n_Mdz', 'nlgz', 'jhploss_n_Lgz', 'Pop_btm'};

for i = 1:length(var) 
    ncid = netcdf.open([param.rootdir dir{i}],'NC_NOWRITE');
    varid = netcdf.inqVarID(ncid, var{i});
    eval([ var{i} ' = netcdf.getVar(ncid, varid);']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 

%! Take mean over latitude and longitude for visualization:
dim = size(eval(var{1}));
time = 1:dim(4);
for i = 1:(length(var)-1)
    eval([var{i} '_tmean = squeeze(nanmean(' var{i} ', [1,2,3]));']);
end 

% Only at the bottom layer for detritus flux: 
Pop_btm_lz(:,:,:) = Pop_btm(:,:, end, :);
Pop_btm_tmean = squeeze(nanmean(Pop_btm_lz, [1, 2]));

save(['../output/Matlab_Average/' exp 'Time_Means_forcing_files' Spinup{2} '.mat'], 'time',...
    'thetao_tmean', ...
    'nmdz_tmean','jhploss_n_Mdz_tmean',...
    'nlgz_tmean','jhploss_n_Lgz_tmean',...
    'Pop_btm_tmean')
