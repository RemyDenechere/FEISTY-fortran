%% Analysis FEISTY Coupled 
function [] =  netcdf_read_FEISTY_Online_BATS(name, loc, yr, exp)
% TO DO: 
% use get 
arguments 
    name      char    = 'BATS_nonFmort_.100_encounter_90_k_1_Rfug_.00000000010000000000_yr_'      % Default experiment
    loc       char {mustBeMember(loc, {'BATS', 'CCE', 'GOM', 'NS', 'GMX'})} = 'BATS'
    yr        char    = '7'      
    exp       char    = 'FEISTY--non-vertical-16Jun25'
end 
dbclear all 
% dbstop in netcdf_read_FEISTY_Online_BATS at 31

%! set up variable names
coupling = 'online';
yr = str2double(yr); % Use str2double for faster performance with scalar values

disp(['Read netcdf files from COBALT-FEISTY ' coupling ' at ' loc, ...
    ' for ' num2str(yr) ' years spinup!'])

%% Get information about the simulation 
disp(['Get information about the ' loc ' system'])
topog.dir = ['../../CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/' loc '/'];
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
topog.idx_100m = find(topog.Layer > 100, 1, 'first'); % index of the 100m layer to integrate plankton over 100m

% save in folder of the location as its the same for every experiment in a location
if ~exist(['../output/Matlab_Average/', coupling, '/' loc], "dir")
    mkdir(['../output/Matlab_Average/', coupling, '/' loc])
end
save(['../output/Matlab_Average/', coupling, '/', loc, '/Topology.mat'], 'topog') 

%% Get Fish tracers: ------------------------------------------------------
disp("Get Fish tracer values & process them for visualisation")
for yr_i = 1:yr
    %! get directory containing output
    name_yr = [name num2str(yr_i)];
    disp(['year: ', num2str(yr_i)])

    %! get data 
    dir_input = ['../../COBALT_output/parallel/', loc, '/', exp, '/',  name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', [name num2str(yr)] , '/' ];
    if ~exist(dir_output, "dir") 
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
            eval([ var{i} '_B =' var{i} '_B(:,:,1,1:366) ;']);
    end
    netcdf.close(ncid);
    dim = size(eval([var{1} '_B']));
    timerange = ((yr_i - 1) * dim(4) + 1):(yr_i * dim(4)); 
    
    % Calcul average over dimensions: -----------------------------------------
    %! Calculate average over lat and long: 
    for i = 1:length(var)
        eval([var{i} '_B_tmean(timerange) = nanmean(' var{i} '_B, [1,2]);']);
    end
end 

time_days = 1:(366*yr);
time_year = yr; 

%! Save data: -------------------------------------------------------------
save([dir_output 'Time_Means_Tracers' '.mat'], 'time_days', 'time_year')
for i = 1:length(var)
    save([dir_output 'Time_Means_Tracers' '.mat'], ...
        [var{i} '_B_tmean'] , '-append')
end

%% Get Fish diagnostics
disp("Get Fish Diagnostic values & process them for visualisation")
for yr_i = 1:yr
    %! get directory containing output
    name_yr = [name num2str(yr_i)];
    dir_input = ['../../COBALT_output/parallel/', loc, '/', exp, '/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', [name num2str(yr)], '/'];
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
            eval([ varname '=' varname '(:,:,1:366);'])
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
            eval([ var{i} diag{j} '= netcdf.getVar(ncid, varid);']);
            eval([ var{i} diag{j} '(' var{i} diag{j}  '< 0) = 0;']);
            eval([ var{i} diag{j} '=' var{i} diag{j}  '(:,:,1:366) ;']);
        end 
    end     
    netcdf.close(ncid);
    
    %! Get dimension: 
    dim = size(eval([var{1} diag{1}]));
    timerange = ((yr_i - 1) * dim(3) + 1):(yr_i * dim(3));  
    
    % Calcul average over dimensions: -----------------------------------------
    %! Calculate average over lat and long: 
    for j = 1:length(diag)
        for i = 1:length(var)
            eval([var{i} diag{j} '_tmean(timerange) = nanmean(' var{i} diag{j} ', [1,2]);']);
        end 
    end
end 

time_days = 1:(366*yr);
time_year = yr; 
%! Save data: -------------------------------------------------------------
save([dir_output 'Time_Means_Diagnostics' '.mat'], 'time_days', 'time_year')
for j = 1:length(diag)
    for i = 1:length(var)
        save([dir_output 'Time_Means_Diagnostics' '.mat'], [var{i} diag{j} '_tmean'], '-append')
    end 
end
    
%% get COBALT Zooplankton outputs from the online simulations: 
%! Also get some environmental parameters 

disp("Get Zooplankton outputs from COBALT-FEISTY online  & process them for visualisation")

%! LIST OF VARIABLES: -----------------------------------------------
var = {'nmdz', 'nlgz', 'nsmz', 'nbact', 'ndet', 'ndi', 'nlg', 'nmd', 'nsm', ...
        'jhploss_n_Mdz', 'jprod_nmdz', 'jhploss_n_Lgz', 'jprod_nlgz',...
        'nh4', 'no3', 'o2', 'po4', 'dic', 'fed', 'thetao', 'so' , 'irr_aclm', 'Pop_btm', 'MLD_003'};
idx_biomass =       [1:9]; % index of the variables that are biomass
idx_rates =         [10:13]; % index of the variables that are mortality and production
idx_env =           [14:19]; % index of the environmental variables
idx_physic =        [20, 21, 22]; % index of the physical variables
idx_pop_flux =       23;     % index of the detritus flux to the bottom
idx_2D_flux =       [23 24]; % index of the detritus flux to the bottom
idx_var_restart =   [3:9, 14:19, 22]; % index of the variables that are in the restart file
idx_var_ocean   =   [21 24]; % index of the variables that are in the ocean file
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
%    po4: Phosphate
%    o2: oxygen
%    dic: disolved inorganic carbon
%    thetao: temperature
%    Pop_btm: bottom detritus production (detritus flux to the bottom)
% --------------------------------------------------------------------------------------------------------------------------------- % 

% consider taking nmdz_100 instead of nmdz
for yr_i = 1:yr
    %! get directory containing output   
    name_yr = [name num2str(yr_i)]; 
    dir_input = ['../../COBALT_output/parallel/', loc, '/', exp, '/' name_yr , '/'];
    dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', [name num2str(yr)], '/'];

    if ~exist(dir_output, 'dir') 
            disp(['output directory:' dir_output ' does not exist, making it...'])
            mkdir(dir_output)
            if ~exist(dir_output, 'dir')    
                disp(['error making output dir:' dir_output ' exiting...'])
                exit
            end
    end  

dir = { [dir_input '20040101.ocean_feisty_forcing.nc']
                [dir_input '20040101.ocean_cobalt_restart.nc']
                [dir_input '20040101.ocean_daily.nc']
                [dir_input '20040101.ocean_feisty_forcing_detritus.nc']}; % detritus flux to the bottom is save in a different file
    
    % Getting data from netcdf
    for i = 1:length(var) 
          disp(['var ', num2str(i), ' = ', var{i}])
        %! Read data from netcdf file: -------------------------------------
        % open the netcdf file: 
        if i == idx_pop_flux % pop_flux is save in a different file
            ncid = netcdf.open(dir{4},'NC_NOWRITE');
        elseif ismember(i, idx_var_ocean) % variables that are in the ocean file
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
        if ismember(i, idx_2D_flux) % pop_flux does not have vertical dimension
            eval([ var{i} ' = ' var{i} '(:,:,1:366);']);
        else
            eval([ var{i} ' = ' var{i} '(:,:,:,1:366);']);
        end
        netcdf.close(ncid);
        disp(['var ', num2str(i), ' = ', var{i} ' done'])
    
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
    for i = [idx_biomass idx_env]
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :) .* 1000 .* topog.Layer_thikness, 2));']); % integrated biomass over depth [mol N m-2]
        eval([var{i} '_tmean_100m(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, 1:topog.idx_100m) .* 1000 .* topog.Layer_thikness(1:topog.idx_100m), 2));']); % integrated biomass over 100m [mol N m-2]
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); % concentration at every depth
    end
    % Calculate average over lat and long for zooplanton mortality and production: these comes as layer integrated no need to multiply by layer thickness:
    % or are variables that do not need layer depth integration (temperature)
    for i = [idx_rates]
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, :), 2));']); % integrated biomass over depth
        eval([var{i} '_tmean_100m(timerange) = squeeze(sum(' var{i} '_spacemean(timerange, 1:topog.idx_100m), 2));']); % integrated biomass over 100m
        eval([var{i} '_zmean(yr_i, :) = transpose(squeeze(nanmean(' var{i} '_spacemean(timerange, :), 1)));']); % concentration at every depth
    end 
    for i = idx_physic  % for temperature, we do not need to integrate over depth we take the mean over the depth instead.
        eval([var{i} '_spacemean(timerange, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
        eval([var{i} '_tmean_100m(timerange) = squeeze(nanmean(' var{i} '_spacemean(timerange, 1:topog.idx_100m), 2));']);
    end 
    for i = idx_2D_flux % 2D vars do not have vertical dimension
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
for i = [idx_biomass idx_rates idx_env ]
    save([dir_output 'Time_Depth_Means_forcing' '.mat'], [var{i} '_spacemean'] ,'-append')
    save([dir_output 'Time_Means_forcing' '.mat'], [var{i} '_tmean'] ,'-append')
    save([dir_output 'Time_Means_forcing_100m' '.mat'], [var{i} '_tmean_100m'] ,'-append')
    save([dir_output 'Depth_Means_forcing' '.mat'], [var{i} '_zmean'] ,'-append')
end
for i = idx_physic
    save([dir_output 'Time_Depth_Means_forcing' '.mat'], [var{i} '_spacemean'] ,'-append')
    save([dir_output 'Time_Means_forcing_100m' '.mat'], [var{i} '_tmean_100m'] ,'-append')
end 
for i = idx_2D_flux % 2D vars do not have vertical dimension
    save([dir_output 'Time_Means_forcing' '.mat'], [var{i} '_tmean'] ,'-append')
end 

end










