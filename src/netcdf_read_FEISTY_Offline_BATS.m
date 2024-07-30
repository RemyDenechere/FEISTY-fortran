% FEISTY output at all locations
clear all
close all

%% Root directory: 
param.Rockfish = true; %    false; % 
param = param_setup(param);

%! get directory containing output
dir = '../output/'; 
exp = 'COBALT_offline_BATS_';
Spinup = {'_Spinup_Time_Serie', ''}; 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE', 'dZm', 'dZl'};
var_diag = {'f', 'cmax', 'cons', 'met', 'mu_p', 'mu_f', 'mu_a', 'mu',...
            'E_A', 'Fout', 'Repro', 'f_Zm', 'f_Zl', 'f_Sf', 'f_Sp', 'f_Sd',... 
            'f_Mf', 'f_Mp', 'f_Md', 'f_Lp', 'f_Ld', 'f_BE'};

if ~exist([dir 'Matlab_Average/'])
    mkdir([dir 'Matlab_Average/'])
end

%% Get Spinup Time Series data:  
for i = 1:(length(var)-2)
    ncid = netcdf.open([dir exp var{i} '_bio' Spinup{1} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0);']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval([var{1}]));

%! Take mean over latitude and longitude and sum over depth for visualization:
time = 1:dim(1);

for i = 1:(length(var)-2)
    sum_depth(:,:,:) = squeeze(eval(['sum(' var{i} ', 2)'])); 
    eval([var{i} '_tmean = transpose(nanmean(sum_depth, [2, 3]));']);
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
depth = 1:dim(2);

% Calcul average over dimensions: -----------------------------------------
%! Calculate average over lat and long: 
for i = 1:(length(var))
    eval([var{i} '_spacemean = transpose(squeeze(nanmean(' var{i} ', [3, 4])));']);
end

%! Integrated biomass over depth: 
for i = 1:(length(var))
    eval([var{i} '_tmean = squeeze(sum(' var{i} '_spacemean, 1));']);
end

%! Average over time : 
for i = 1:(length(var))
    eval([var{i} '_zmean = squeeze(nanmean(' var{i} '_spacemean, 2));']);
end

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save(['../output/Matlab_Average/' exp 'Time_Depth_Means' Spinup{2} '.mat'], 'time', 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Depth_Means' Spinup{2} '.mat'], ...
        [var{i} '_spacemean'] ,'-append')
end

%!! integrated over depth
save(['../output/Matlab_Average/' exp 'Time_Means' Spinup{2} '.mat'], 'time')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Means' Spinup{2} '.mat'], ...
        [var{i} '_tmean'] ,'-append')
end

%!! Average over time 
save(['../output/Matlab_Average/' exp 'Depth_Means' Spinup{2} '.mat'], 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Depth_Means' Spinup{2} '.mat'], ...
        [var{i} '_zmean'] ,'-append')
end


%% Initial condition for Online Coupling: 

ncid = netcdf.open([dir, 'FEISTY_2023_10_spinup_subset.nc'],'NC_NOWRITE');
for i = 1:(length(var)-2)
    varid = netcdf.inqVarID(ncid, [var{i} '_B']);
    eval([ var{i} '_B = netcdf.getVar(ncid, varid);']);
end 
dim = size(Sf_B);
depth = 1:dim(3);

%! Calculate average over lat and long: 
for i = 1:(length(var)-2)
    eval([var{i} '_spacemean = squeeze(nanmean(' var{i} '_B, [1, 2]));']);
end

%! Save average over lat and long: 
save(['../output/Matlab_Average/' 'COBALT_IC' '.mat'], 'depth')
for i = 1:(length(var)-2)
    save(['../output/Matlab_Average/' 'COBALT_IC' '.mat'], ...
        [var{i} '_spacemean'] ,'-append')
end

%% diagnotic variables 
% 
% for sp = 2
%     ! get diagnostics:
%     for i = 1:(length(var)-3)
%         ncid = netcdf.open([dir exp var{i} '_diag_' Spinup{sp} 'Time_Serie' '.nc'],'NC_NOWRITE');
%         for j = 1:length(var_diag)
%             varid = netcdf.inqVarID(ncid, var_diag{j});
%             eval([ var{i} '_' var_diag{j} ' = netcdf.getVar(ncid, varid );']);
%             eval([ var{i} '_' var_diag{j} '(' var{i} '_' var_diag{j} ' == -99999) = NaN;']);
%         end 
%         netcdf.close(ncid);
%     end 
%     
%     dim = size(eval('Sf_f'));
%     time = 1:dim(4);
%     depth = 1:dim(3);
%     
%     Calcul average over dimensions: -----------------------------------------
%     ! Calculate average over lat and long: 
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             eval([var{i} '_' var_diag{j} '_spacemean = transpose(squeeze(nanmean(' var{i} '_' var_diag{j} ', [1, 2])));']);
%         end 
%     end
%     
%     ! Integrated biomass over depth: 
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             eval([var{i} '_' var_diag{j} '_tmean = squeeze(sum(' var{i} '_' var_diag{j} '_spacemean, 2));']);
%         end 
%     end
%     
%     ! Average over time : 
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             eval([var{i} '_' var_diag{j} '_zmean = squeeze(nanmean(' var{i} '_' var_diag{j} '_spacemean, 1));']);
%         end 
%     end
%     
%     ! Save data: -------------------------------------------------------------
%     !! average over lat and long: 
%     save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Diag' Spinup{sp} '.mat'], 'time', 'depth')
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Diag' Spinup{sp} '.mat'], ...
%                 [var{i} '_' var_diag{j} '_spacemean'] ,'-append')
%         end
%     end
%     
%     !! integrated over depth
%     save(['../output/Matlab_Average/' exp 'Time_Means_Diag' Spinup{sp} '.mat'], 'time')
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             save(['../output/Matlab_Average/' exp 'Time_Means_Diag' Spinup{sp} '.mat'], ...
%                 [var{i} '_' var_diag{j} '_tmean'] ,'-append')
%         end 
%     end
%     
%     !! Average over time 
%     save(['../output/Matlab_Average/' exp 'Depth_Means_Diag' Spinup{sp} '.mat'], 'depth')
%     for i = 1:(length(var)-3)
%         for j = 1:length(var_diag)
%             save(['../output/Matlab_Average/' exp 'Depth_Means_Diag' Spinup{sp} '.mat'], ...
%                 [var{i} '_' var_diag{j} '_zmean'] ,'-append')
%         end 
%     end
% end 


%% get FEISTY input varaibles from COBALT 
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

    if ismember(i, [2, 4]) % conversion 
        eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 1000.0;' ]);     % Conversion from Mol N/kg --> gC WW / m3
    elseif ismember(i, [3, 5]) 
        eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 24.0*3600;' ]);  % Conversion from Mol mol N m-3 s-1 --> gC WW m-3 d-1
    end
end 

%! Take mean over dimensions: ---------------------------------------------
dim = size(eval(var{1}));
time = 1:dim(4);
depth = 1:dim(3);

%! Calculate average over lat and long: 
for i = 1:(length(var))
    eval([var{i} '_spacemean = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
end

%! Integrated biomass over depth: 
for i = 1:(length(var))
    eval([var{i} '_tmean = transpose(squeeze(sum(' var{i} '_spacemean, 2)));']);
end

%! Average over time : 
for i = 1:(length(var))
    eval([var{i} '_zmean = squeeze(nanmean(' var{i} '_spacemean, 1));']);
end

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save(['../output/Matlab_Average/' exp 'Time_Depth_Means_forcing_files' '.mat'], 'time', 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Depth_Means_forcing_files' '.mat'], ...
        [var{i} '_spacemean'] ,'-append')
end

%!! integrated over depth
save(['../output/Matlab_Average/' exp 'Time_Means_forcing_files' '.mat'], 'time')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Time_Means_forcing_files' '.mat'], ...
        [var{i} '_tmean'] ,'-append')
end

%!! Average over time 
save(['../output/Matlab_Average/' exp 'Depth_Means_forcing_files' '.mat'], 'depth')
for i = 1:length(var)
    save(['../output/Matlab_Average/' exp 'Depth_Means_forcing_files' '.mat'], ...
        [var{i} '_zmean'] ,'-append')
end




