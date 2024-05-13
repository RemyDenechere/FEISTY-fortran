% FEISTY output at all locations
clear all
close all

%% Root directory: 
param.Rockfish =  false; % true; % 
param = param_setup(param);

%! get directory containing output
dir = '../output/'; 
exp = 'COBALT_offline_';
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

%! Take mean over latitude and longitude for visualization:
time = 1:dim(1);
for i = 1:(length(var)-2)
    eval([var{i} '_tmean = nanmean(' var{i} ', [2, 3, 4]);']);
end 

save([dir 'Matlab_Average/' exp 'Time_Means' Spinup{1} '.mat'], 'time',...
    'Sf_tmean','Sp_tmean','Sd_tmean',...
    'Mf_tmean','Mp_tmean','Md_tmean',...
    'Lp_tmean','Ld_tmean','BE_tmean')

%% Get Time Series from offline simulations:
for i = 1:length(var)
    ncid = netcdf.open([dir exp var{i} '_bio' Spinup{2} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval(var{1}));

%! Take mean over latitude and longitude for visualization:
time = 1:dim(1);
for i = 1:length(var)
    eval([var{i} '_tmean = nanmean(' var{i} ', [2, 3, 4]);']);
end 

save([dir 'Matlab_Average/' exp 'Time_Means' Spinup{2} '.mat'], 'time',...
    'Sf_tmean','Sp_tmean','Sd_tmean',...
    'Mf_tmean','Mp_tmean','Md_tmean',...
    'Lp_tmean','Ld_tmean','BE_tmean', ...
    'dZm_tmean', 'dZl_tmean')
