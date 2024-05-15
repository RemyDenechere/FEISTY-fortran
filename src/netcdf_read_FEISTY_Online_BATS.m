%% Analysis FEISTY Coupled 
clear all 
%! get directory containing output
addpath('../../COBALT_output/COBALT_FEISTY/')
dir_outpur = '../output/Matlab_Average/';
exp = 'COBALT_online_BATS_';
Spinup = {''}; 

%! Get Fish tracers: ------------------------------------------------------
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; 

%! get fish 
ncid = netcdf.open('20040101.ocean_feisty_tracers.nc', 'NC_NOWRITE');
for i = 1:length(var)
    varid = netcdf.inqVarID(ncid, [var{i} '_B']);
    eval([ var{i} '_B = netcdf.getVar(ncid, varid);']);
    eval([ var{i} '_B(' var{i} '_B == 99999) = NaN;']);
end
netcdf.close(ncid);
dim = size(eval([var{1} '_B']));
time = 1:dim(4);
depth = 1:dim(3);

% Calcul average over dimensions: -----------------------------------------
%! Calculate average over lat and long: 
for i = 1:(length(var))
    eval([var{i} '_B_spacemean = transpose(squeeze(nanmean(' var{i} '_B, [1,2])));']);
end

%! Integrated biomass over depth: 
for i = 1:(length(var))
    eval([var{i} '_B_tmean = squeeze(sum(' var{i} '_B_spacemean, 2));']);
end

%! Average over time : 
for i = 1:(length(var))
    eval([var{i} '_B_zmean = squeeze(nanmean(' var{i} '_B_spacemean, 1));']);
end

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Tracers' '.mat'], 'time', 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Tracers' '.mat'], ...
        [var{i} '_B_spacemean'] ,'-append')
end

%!! integrated over depth
save(['../output/Matlab_Average/' exp 'Time_Means_Tracers' '.mat'], 'time')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Means_Tracers' '.mat'], ...
        [var{i} '_B_tmean'] ,'-append')
end

%!! Average over time 
save(['../output/Matlab_Average/' exp 'Depth_Means_Tracers' '.mat'], 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Depth_Means_Tracers' '.mat'], ...
        [var{i} '_B_zmean'] ,'-append')
end