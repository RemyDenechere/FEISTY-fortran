%% Analysis FEISTY Coupled
% DESCRIPTION OF THE FUNCTION:
% This function reads the netcdf files from COBALT-offline, i.e., COBALT ran without 
% FEISTY and calculates the average over the lat and long for the different variables. 
% It also calculates the average over the depth for the different variables. The function saves the
% data in a folder called 'output' 
% See function vis_FEISTY_offline_spinup.m for the plot analysis of the data.
% 
function [] =  netcdf_read_COBALT_Offline(option)
%=========================================================================%
arguments 
    option.loc         char {mustBeMember(option.loc, {'BATS', 'CCE', 'GOM', 'GOM_2'...
                                                       'NS', 'GMX', 'GMX_2', })} = 'BATS'
    option.exp         char    = 'DIAG_COORD_DEF_01_FNC1_4680'
    option.yr_spinup   char    = '2'    % number of spiup years to read
end 
dbclear all 
% dbstop in netcdf_read_COBALT_Offline at 91

%% set up variable names
spinup = true; 
coupling = 'offline';
yr = str2double(option.yr_spinup); % Use str2double for faster performance with scalar values
name = [option.loc, '_offline_yr_'] ;

%! LIST OF VARIABLES: -----------------------------------------------
var = {'nmdz', 'nlgz', 'nbact', 'ndet', 'ndi', 'nlg', 'nmd', 'nsm', ...
        'jhploss_n_Mdz', 'jprod_nmdz', 'jhploss_n_Lgz', 'jprod_nlgz',...
        'nh4', 'no3', 'o2', 'thetao', 'Pop_btm'};
idx_biomass =   [1:8]; % index of the variables that are biomass
idx_rates =     [9:12]; % index of the variables that are mortality and production
idx_env =       [13:16]; % index of the environmental variables
idx_pop_flux =  length(var); % index of the detritus flux to the bottom
idx_var_restart = [3:8, 13:15]; % index of the variables that are in the restart file
% [mol N kg-1]
%    nmdz: medium zooplankton nitrogen
%    nlgz: large zooplankton nitrogen
%    nbact: bacteria
%    ndet: nitrogen detritus
%    ndi: diazotroph nitrogen
%    nlg: large, coastal or chain-forming, phytoplankton nitrogen
%    nmd: medium phytoplankton nitrogen
%    nsm: high-light adapted small phytoplankton nitrogen
% [mol N Kg-1 s-1]
%    jhploss_n_Mdz: medium zooplankton nitrogen mortality
%    jprod_nmdz: medium zooplankton nitrogen production
%    jhploss_n_Lgz: large zooplankton nitrogen mortality
%    jprod_nlgz: large zooplankton nitrogen production
% environemnetal variables:
%    nh4: ammonia
%    no3: nitrate
%    o2: oxygen
%    thetao: temperature
%    Pop_btm: bottom detritus production (detritus flux to the bottom)

disp(['Read netcdf files from COBALT-FEISTY ' coupling ' at ' option.loc, ...
    ' for ' num2str(yr) ' years spinup!'])

%% Get information about the simulation 
disp(['Get information about the ' option.loc ' system'])
topog.dir = ['../../CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/' option.loc '/'];
topog.var = {'x', 'y', 'depth', 'Layer'};
topog.longname = {'geographic_longitude', 'geographic_latitude', 'depth', 'Layer pseudo-depth'};
topog.unit = {'degree_east', 'degree_north', 'meters', 'meters'};
topog.files = {'ocean_hgrid.nc', 'ocean_hgrid.nc', 'ocean_topog.nc', 'FEISTY_2D_2023_10_spinup_subset.nc'}; 
topog.Layer_thikness = zeros(1, 75, "double"); 

for i = 1:length(topog.var)
    ncid = netcdf.open([topog.dir, topog.files{i}], 'NC_NOWRITE');
    varid = netcdf.inqVarID(ncid, topog.var{i});
    topog.(topog.var{i}) = netcdf.getVar(ncid, varid);
end

% Calculate the actual depth for each layer based on the layer pseuco-depth
% and the max depth from the location: 
topog.Layer_thikness(1) = topog.Layer(1);
topog.Layer_thikness(2:end) = topog.Layer(2:end) - topog.Layer(1:(end-1));
if max(topog.Layer) < 100
    topog.idx_100m = length(topog.Layer);
else 
    topog.idx_100m = find(topog.Layer >= 100, 1, 'first'); % index of the 100m layer to integrate plankton over 100m
end 


% save in folder of the location as its the same for every experiment in a location
if ~exist(['../output/Matlab_Average/', coupling, '/' option.loc], "dir")
    mkdir(['../output/Matlab_Average/', coupling, '/' option.loc])
end
save(['../output/Matlab_Average/', coupling, '/', option.loc, '/Topology.mat'], 'topog') 
    
%% get COBALT outputs for each offline spinup year : 

% ! Loop over years: --------------------------------------------------
for yr_i = 1:yr
    
    disp(['Get COBALT output at ' option.loc ' for year ' num2str(yr_i)])
    %! get directory containing output   
    name_yr = [name num2str(yr_i)]; 
    dir_input = ['../../COBALT_output/COBALT_offline_forcing_files/', option.loc,'/', option.exp ,'/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' option.loc, '/', option.exp, '/', [name num2str(yr)], '/'];

    if ~exist(dir_output, 'dir') 
        disp(['output directory:' dir_output ' does not exist, making it...'])
        mkdir(dir_output)
        if ~exist(dir_output, 'dir')    
            disp(['error making output dir:' dir_output ' exiting...'])
            exit
        end
    end 

    dir = {[dir_input '20040101.ocean_feisty_forcing.nc']
           [dir_input '20040101.ocean_cobalt_restart.nc']
           [dir_input '20040101.ocean_feisty_forcing_detritus.nc']}; % detritus flux to the bottom is save in a different file
    
    % Getting data from netcdf for each variable:
    for i = 1:length(var)
        disp(['var ', num2str(i), ' = ', var{i}])
        %! Read data from netcdf file: -------------------------------------
        % open the netcdf file: 
        if i == idx_pop_flux % pop_flux is save in a different file
            ncid = netcdf.open(dir{3},'NC_NOWRITE');
        elseif ismember(i, idx_var_restart)
            ncid = netcdf.open(dir{2},'NC_NOWRITE');
        else 
            ncid = netcdf.open(dir{1},'NC_NOWRITE');
        end
        % get the variable id and get data:
        varid = netcdf.inqVarID(ncid, var{i});
        eval([ var{i} ' = netcdf.getVar(ncid, varid);']);
        eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
        if i == idx_pop_flux % pop_flux does not have vertical dimension
            eval([ var{i} ' = ' var{i} '(:,:,1:366);']);
        else
            eval([ var{i} ' = ' var{i} '(:,:,:,1:366);']);
        end
        netcdf.close(ncid);
        
        %! Convert units: --------------------------------------------------
        if ismember(i, idx_biomass) % conversions biomass 
            eval([ var{i} '_conv = ' var{i} '*6.625* 12.01 * 9.0 * 1000.0;' ]);     % Conversion from Mol N/kg --> gC WW m-3
        elseif ismember(i, [idx_rates, idx_pop_flux]) % conversion mortality and pop flux
            eval([ var{i} '_conv = ' var{i} '*6.625* 12.01 * 9.0 * 24.0*3600;' ]);  % Conversion from Mol mol N m-2 s-1 (Layer integrated) --> gC WW m-3 d-1
        end
    end 
    
    %! Take mean over dimensions: ---------------------------------------------
    dim = size(eval([var{1}]));
    time = 1:dim(4);
    depth = 1:dim(3);
    timerange = ((yr_i - 1) * dim(4) + 1):(yr_i * dim(4)); % indexes for the year yr_i
    
    %! Calculate average over lat and long for zooplanton biomass (integrate over 100m depth): 
    for i = idx_biomass
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :) .* 1000 .* topog.Layer_thikness, 2));']); % integrated biomass over depth [mol N m-2]
        eval([var{i} '_tmean_100m(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, 1:topog.idx_100m) .* 1000 .* topog.Layer_thikness(1:topog.idx_100m), 2));']); % integrated biomass over 100m [mol N m-2]
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); % concentration at every depth
    end
    % Calculate average over lat and long for zooplanton mortality and production: these comes as layer integrated no need to multiply by layer thickness:
    % or are variables that do not need layer depth integration (temperature)
    for i = [idx_rates idx_env]
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :), 2));']); % integrated biomass over depth
        eval([var{i} '_tmean_100m(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, 1:topog.idx_100m), 2));']); % integrated biomass over 100m
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); % concentration at every depth
    end 
    for i = idx_env  % for environemntal variables, we do not need to integrate over depth we take the mean over the depth instead.
        eval([var{i} '_tmean_100m(timerange) = squeeze(nanmean(' var{i} '_spacemean(timerange, 1:topog.idx_100m), 2));']);
    end 
    for i = idx_pop_flux % pop_flux does not have vertical dimension
        eval([var{i} '_tmean(timerange) = nanmean(' var{i} ', [1,2]);']);
    end 
end 
    
time_days = 1:(366*yr); % Total number of days in the simulation
time_year = yr; % Total number of years in the simulation

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save([dir_output 'Time_Depth_Means_forcing' '.mat'], 'time_days', 'time_year', 'depth')
save([dir_output 'Time_Means_forcing' '.mat'], 'time_days', 'time_year')
save([dir_output 'Time_Means_forcing_100m' '.mat'], 'time_days', 'time_year')
save([dir_output 'Depth_Means_forcing' '.mat'], 'time_days', 'time_year', 'depth')
for i = [idx_biomass idx_rates idx_env]
    save([dir_output 'Time_Depth_Means_forcing' '.mat'], [var{i} '_spacemean'] ,'-append')
    save([dir_output 'Time_Means_forcing' '.mat'], [var{i} '_tmean'] ,'-append')
    save([dir_output 'Time_Means_forcing_100m' '.mat'], [var{i} '_tmean_100m'] ,'-append')
    save([dir_output 'Depth_Means_forcing' '.mat'], [var{i} '_zmean'] ,'-append')
end
save([dir_output 'Time_Means_forcing' '.mat'], [var{end} '_tmean'] ,'-append')

end
