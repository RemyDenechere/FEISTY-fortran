%% Analysis FEISTY Coupled 
clear all 
%! get directory containing output
addpath('../../COBALT_output/COBALT_FEISTY/')
dir_outpur = '../output/Matlab_Average/';
exp = 'COBALT_online_BATS_';
Spinup = {''}; 

%% Get Fish tracers: ------------------------------------------------------
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; 

%! get fish Biomass
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

%% Get Fish diagnostics

%! get fish diagnostics: -------------------------------------------------- 
ncid = netcdf.open('20040101.ocean_feisty_fluxes.nc', 'NC_NOWRITE');

%! Get variable from varID:------------------------------------------------
ncid = netcdf.open('20040101.ocean_feisty_fluxes.nc', 'NC_NOWRITE');
[ndims, nvars, ngatts, unlimdimid] = netcdf.inq(ncid);
diag_list{1} = '';
for i = 7:(nvars-4)
    do_var = true;
    try 
        varname = netcdf.inqVar(ncid, i-1);
    catch ME
        warning([ME.message])
        do_var = false;
    end
    % if no warning get var: 
    if do_var
        eval([ varname ' = netcdf.getVar(ncid,i-1);']);
        eval([ varname '(' varname ' == 99999) = NaN;']);
        diag_list{i-6} = varname;
    end
end
netcdf.close(ncid);

% Calcul average over dimensions: -----------------------------------------
%! Calculate average over lat and long: 
for i = 1:(length(diag_list))
    eval([diag_list{i} '_spacemean = transpose(squeeze(nanmean(' diag_list{i} ', [1,2])));']);
end

%! Integrated biomass over depth: 
for i = 1:(length(diag_list))
    eval([diag_list{i} '_tmean = squeeze(sum(' diag_list{i} '_spacemean, 2));']);
end

%! Average over time : 
for i = 1:(length(diag_list))
    eval([diag_list{i} '_zmean = squeeze(nanmean(' diag_list{i} '_spacemean, 1));']);
end

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Diagnostics' '.mat'], 'diag_list', 'time', 'depth')
for i = 1:length(diag_list)
    save(['../output/Matlab_Average/' exp 'Time_Depth_Means_Diagnostics' '.mat'], ...
        [diag_list{i} '_spacemean'] ,'-append')
end

%!! integrated over depth
save(['../output/Matlab_Average/' exp 'Time_Means_Diagnostics' '.mat'], 'diag_list', 'time')
for i = 1:length(diag_list)
    save(['../output/Matlab_Average/' exp 'Time_Means_Diagnostics' '.mat'], ...
        [diag_list{i} '_tmean'] ,'-append')
end

%!! Average over time 
save(['../output/Matlab_Average/' exp 'Depth_Means_Diagnostics' '.mat'], 'diag_list', 'depth')
for i = 1:length(diag_list)
    save(['../output/Matlab_Average/' exp 'Depth_Means_Diagnostics' '.mat'], ...
        [diag_list{i} '_zmean'] ,'-append')
end


%% does not work for some reason: 
% %! Get variable from varnam (lots of error):-------------------------------
% for i = 1:(length(var)-1)
%     for j = 1:length(diag)
%         do_var = true;
%         try 
%             varid = netcdf.inqVarID(ncid, [var{i} diag{j}]);
%         catch ME
%             warning([var{i} diag{j} ' : ' ME.message])
%             do_var = false;
%         end
%         % if no warning get var: 
%         if do_var
%             eval([ var{i} diag{j} '= netcdf.getVar(ncid, varid);']);
%             eval([ var{i} diag{j} '(' var{i} diag{j} ' == 99999) = NaN;']);
%         end 
%     end
% end
% netcdf.close(ncid);














