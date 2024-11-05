%% Analysis FEISTY Coupled 
function [] =  netcdf_read_FEISTY_Online_BATS(name, loc, yr)
% TO DO: 
% use get 
arguments 
    name      char    = 'BATS_nonFmort_0.1_encounter_70_k_1_k50_1_yr_'      % Default experiment
    loc       char    = 'BATS'
    yr        double  = 5      
end 

% dbstop in netcdf_read_FEISTY_Online_BATS at 186

%! set up variable names
coupling = 'online'; 
Spinup = {''}; 

disp(['Read netcdf files from COBALT-FEISTY ' coupling ' at ' loc, ...
    ' for ' num2str(yr) ' years spinup!'])

%% Get information about the simulation 
disp(['Get information about the ' loc ' system'])
topog.dir = ['../../CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/' loc '/'];
topog.var = {'x', 'y', 'depth', 'Layer'};
topog.longname = {'geographic_longitude', 'geographic_latitude', 'depth', 'Layer pseudo-depth'};
topog.unit = {'degree_east', 'degree_north', 'meters', 'meters'};
topog.files = {'ocean_hgrid.nc', 'ocean_hgrid.nc', 'ocean_topog.nc', 'FEISTY_2023_10_spinup_subset.nc'}; 

for i = 1:length(topog.var)
    ncid = netcdf.open([topog.dir, topog.files{i}], 'NC_NOWRITE');
    varid = netcdf.inqVarID(ncid, topog.var{i});
    topog.(topog.var{i}) = netcdf.getVar(ncid, varid);
end

% Calculate the actual depth for each layer based on the layer pseuco-depth
% and the max depth from the location: 
topog.Layer_depth = mean(topog.depth, [1, 2]) .* (topog.Layer/4000);
% save in folder of the location as its the same for every experiment in a location
save(['../output/Matlab_Average/', coupling, '/' loc, '/Topology.mat'], 'topog') 

%% Get Fish tracers: ------------------------------------------------------
disp("Get Fish tracer values & process them for visualisation")
for yr_i = 1:yr
    %! get directory containing output
    name_yr = [name num2str(yr_i)];
    disp(['year: ', num2str(yr_i)])

    %! get data 
    dir_input = ['../../COBALT_output/parallel/', loc, '/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', [name num2str(yr)] , '/' ];
    if ~exist(dir_output,"dir") 
        mkdir(dir_output)
    end    
    
    %! Define variables:       
    var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; 
    idx_var_dem = [6, 8, 9];
    idx_var_pel = [1:5, 7];

    %! get fish Biomass
    ncid = netcdf.open([dir_input '20040101.ocean_feisty_tracers.nc'], 'NC_NOWRITE');
    for i = 1:length(var)
            varid = netcdf.inqVarID(ncid, [var{i} '_B']);
            eval([ var{i} '_B = netcdf.getVar(ncid, varid);']);
            eval([ var{i} '_B(' var{i} '_B < 0) = 0;']);
            eval([ var{i} '_B =' var{i} '_B(:,:,:,1:365) ;']);
    end
    netcdf.close(ncid);
    dim = size(eval([var{1} '_B']));
    time = 1:dim(4);
    depth = 1:dim(3);
    timerange = ((yr_i - 1) * dim(4) + 1):(yr_i * dim(4)); 
    
    % Calcul average over dimensions: -----------------------------------------
    %! Calculate average over lat and long: 
    for i = idx_var_pel
        eval([var{i} '_B_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} '_B, [1,2])));']);
        eval([var{i} '_B_tmean(timerange) = squeeze(sum(' var{i} '_B_spacemean(timerange, :) * topog.Layer_depth, 2));']);
        eval([var{i} '_B_zmean(yr_i,:) = transpose(squeeze(nanmean(' var{i} '_B_spacemean(timerange, :), 1)));']);
    end
    for i = idx_var_dem %! for demersal we assume the last layer 1m thick (topog.Layer_depth = 1)
        eval([var{i} '_B_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} '_B, [1,2])));']);
        eval([var{i} '_B_tmean(timerange) = squeeze(sum(' var{i} '_B_spacemean(timerange, :), 2));']);
        eval([var{i} '_B_zmean(yr_i,:) = transpose(squeeze(nanmean(' var{i} '_B_spacemean(timerange, :), 1)));']);
    end

end 

time_days = 1:(365*yr);
time_year = yr; 

%! Save data: -------------------------------------------------------------
save([dir_output 'Time_Depth_Means_Tracers' '.mat'], 'time_days', 'time_year', 'depth')
save([dir_output 'Time_Means_Tracers' '.mat'], 'time_days', 'time_year')
save([dir_output 'Depth_Means_Tracers' '.mat'], 'time_days', 'time_year', 'depth')
for i = 1:length(var)
    save([dir_output 'Time_Depth_Means_Tracers' '.mat'], ...
        [var{i} '_B_spacemean'] ,'-append')
    save([dir_output 'Time_Means_Tracers' '.mat'], ...
        [var{i} '_B_tmean'] ,'-append')
    save([dir_output 'Depth_Means_Tracers' '.mat'], ...
        [var{i} '_B_zmean'] ,'-append')
end

%% Get Fish diagnostics
disp("Get Fish Diagnostic values & process them for visualisation")
for yr_i = 1:yr
    %! get directory containing output
    name_yr = [name num2str(yr_i)];
    dir_input = ['../../COBALT_output/parallel/', loc, '/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', [name num2str(yr)], '/'];
    if ~exist(dir_output, 'dir') 
        mkdir(dir_output)
    end 
    
    disp([ 'year: ' num2str(yr_i)])

    %! get fish diagnostics: --------------------------------------------------     
    ncid = netcdf.open([dir_input '20040101.ocean_feisty_fluxes.nc'], 'NC_NOWRITE');

    %! Get variable from varID: ----------------------------------------------
    [~, nvars, ~, ~] = netcdf.inq(ncid);
    diag_list = cell(168, 1);
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
            eval([ varname '=' varname '(:,:,:,1:365);'])
            diag_list{i-6} = varname;
        end
    end

    %! Method 2 get veriable from name:-------------------------------------
    var = {'SF', 'SP', 'SD', 'MF', 'MP', 'MD', 'LP', 'LD'};
    diag = {'_met', '_enc_Mz', '_enc_Lz', '_enc_f', '_enc_p', '_enc_d', '_enc_BE', ...
            '_cons_Mz', '_cons_Lz', '_cons_f', '_cons_p', '_cons_d', '_cons_BE', '_cons_tot', ...
            '_f_tot', '_mu_p', '_E_A', '_prod', '_Fout', '_rho', '_yield'};
    for i = 1:length(var)
        for j = 1:length(diag)
            varid = netcdf.inqVarID(ncid, [var{i} diag{j}]);
            eval([ var{i} '_B = netcdf.getVar(ncid, varid);']);
            eval([ var{i} '_B(' var{i} '_B < 0) = 0;']);
            eval([ var{i} '_B =' var{i} '_B(:,:,:,1:365) ;']);
        end 
    end     
    netcdf.close(ncid);
    
    %! Get dimension: 
    dim = size(eval([var{1} '_B']));
    depth = 1:dim(3);
    timerange = ((yr_i - 1) * dim(4) + 1):(yr_i * dim(4));  

    
    % Calcul average over dimensions: -----------------------------------------
    %! Calculate average over lat and long: 
    for j = 1:length(diag)
        for i = idx_var_pel
            eval([var{i} diag{j} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} diag{j} ', [1,2])));']);
            eval([var{i} diag{j} '_tmean(timerange) = squeeze(sum(' var{i} diag{j} '_spacemean(timerange, :) * topog.Layer_depth, 2));']);
            eval([var{i} diag{j} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} diag{j} '_spacemean(timerange, :), 1)));']);
        end 
        for i = idx_var_dem(1:end-1)
            eval([var{i} diag{j} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} diag{j} ', [1,2])));']);
            eval([var{i} diag{j} '_tmean(timerange) = squeeze(sum(' var{i} diag{j} '_spacemean(timerange, :), 2));']);
            eval([var{i} diag{j} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} diag{j} '_spacemean(timerange, :), 1)));']);
        end
    end
end 

time_days = 1:(365*yr);
time_year = yr; 
%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save([dir_output 'Time_Depth_Means_Diagnostics' '.mat'], 'time_days', 'time_year', 'depth')
save([dir_output 'Time_Means_Diagnostics' '.mat'],       'time_days', 'time_year')
save([dir_output 'Depth_Means_Diagnostics' '.mat'],      'time_days', 'time_year', 'depth')

for j = 1:length(diag)
    for i = 1:length(var)
        save([dir_output 'Time_Depth_Means_Diagnostics' '.mat'], [var{i} diag{j} '_spacemean']  ,'-append')
        save([dir_output 'Time_Means_Diagnostics' '.mat'],       [var{i} diag{j} '_tmean']      ,'-append')
        save([dir_output 'Depth_Means_Diagnostics' '.mat'],      [var{i} diag{j} '_zmean']      ,'-append')
    end 
end
    
%% get COBALT Zooplankton outputs from the online simulations: 
disp("Get Zooplankton outputs from COBALT-FEISTY online  & process them for visualisation")

var = {'nmdz', 'jhploss_n_Mdz', 'jprod_nmdz', 'nlgz', 'jhploss_n_Lgz', 'jprod_nlgz', 'Pop_btm'};
for yr_i = 1:yr
    %! get directory containing output   
    name_yr = [name num2str(yr_i)]; 
    dir_input = ['../../COBALT_output/parallel/', loc, '/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', [name num2str(yr)], '/'];

    if ~exist(dir_output, 'dir') 
        mkdir(dir_output)
    end 

    dir = {[dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing.nc'], ...
           [dir_input '20040101.ocean_feisty_forcing_detritus.nc']};
    
    % Getting data from netcdf
    for i = 1:length(var) 
        ncid = netcdf.open(dir{i},'NC_NOWRITE');
        varid = netcdf.inqVarID(ncid, var{i});
        eval([ var{i} ' = netcdf.getVar(ncid, varid);']);
        eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
        eval([ var{i} '=' var{i} '(:,:,:,1:365);']);
        netcdf.close(ncid);
    
        if ismember(i, [1, 4]) % conversions biomass 
            eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 1000.0;' ]);     % Conversion from Mol N/kg --> gC WW m-3
        elseif ismember(i, [2, 3, 5, 6]) % conversion mortality
            eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 24.0*3600;' ]);  % Conversion from Mol mol N m-3 s-1 --> gC WW m-3 d-1
        end
    end 
    
    %! Take mean over dimensions: ---------------------------------------------
    dim = size(eval([var{1}]));
    time = 1:dim(4);
    depth = 1:dim(3);
    timerange = ((yr_i - 1) * dim(4) + 1):(yr_i * dim(4)); 
    
    %! Calculate average over lat and long: 
    for i = 1:(length(var)-1)
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :) * topog.Layer_depth, 2));']); % integrated biomass over depth
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); % concentration at every depth
    end
    for i = length(var) % pop_flux already in dimension of per area. 
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :), 2));']); 
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); 
    end 
end 
    
time_days = 1:(365*yr);
time_year = yr; 

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save([dir_output 'Time_Depth_Means_forcing' '.mat'], 'time_days', 'time_year', 'depth')
save([dir_output 'Time_Means_forcing' '.mat'], 'time_days', 'time_year')
save([dir_output 'Depth_Means_forcing' '.mat'], 'time_days', 'time_year', 'depth')
for i = 1:length(var)
    save([dir_output 'Time_Depth_Means_forcing' '.mat'], [var{i} '_spacemean'] ,'-append')
    save([dir_output 'Time_Means_forcing' '.mat'], [var{i} '_tmean'] ,'-append')
        save([dir_output 'Depth_Means_forcing' '.mat'], [var{i} '_zmean'] ,'-append')
end











