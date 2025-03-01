% FEISTY output at all locations
function [] = netcdf_read_FEISTY_Offline_BATS(loc, exp, Rockfish)

arguments 
    loc                   char {mustBeMember(loc, {'BATS', 'CCE', 'GOM', 'NS'})} = 'BATS'
    exp                   char    = '2D'
    Rockfish              logical = true
end 
% dbclear all 
% dbstop in netcdf_read_FEISTY_Offline_BATS at 59

%% Root directory: 
param.Rockfish = Rockfish; % true; %
param = param_setup(param);

coupling = 'offline'; 
Spinup = {'_Spinup_Time_Serie', ''};

%! get directory containing output
dir_input_offline_forcing = ['../../COBALT_output/COBALT_offline_forcing_files/' loc '/']; 
dir_input_offline_FEISTY = ['../output/netcdf/' coupling '/' loc '/', ...
                            'COBALT_' coupling '_' loc '_' exp '_'];
dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', ...
                            'FEISTY_' coupling '_' loc '_' exp '_'];
dir_topog = ['../output/Matlab_Average/', 'online', '/' loc, '/Topology.mat'];
 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE', 'dZm', 'dZl'};
var_diag = {'f', 'cmax', 'cons', 'met', 'mu_p', 'mu_f', 'mu_a', 'mu',...
            'E_A', 'Fout', 'Repro', 'f_Zm', 'f_Zl', 'f_Sf', 'f_Sp', 'f_Sd',... 
            'f_Mf', 'f_Mp', 'f_Md', 'f_Lp', 'f_Ld', 'f_BE'};

if ~exist(['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/'], "dir")
    mkdir(['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/'])
end

%% Get information about the simulation 

%% Get information about the simulation 
disp(['Get information about the ' loc ' system'])
topog.dir = ['../../CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/' loc '/'];
topog.var = {'x', 'y', 'depth', 'Layer'};
topog.longname = {'geographic_longitude', 'geographic_latitude', 'depth', 'Layer'};
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
save(['../output/Matlab_Average/', coupling, '/' loc, '/Topology.mat'], 'topog') 
disp(['../output/Matlab_Average/', coupling, '/' loc, '/Topology.mat'])

%% Get Spinup Time Series data:
disp('Get Spinup Time Series data')

for i = 1:(length(var)-2)
    ncid = netcdf.open([dir_input_offline_FEISTY var{i} '_bio' Spinup{1} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0);']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval([var{1}]));

%! Take mean over latitude and longitude and sum over depth for visualization:
time = 1:dim(1);

for i = 1:(length(var)-2)
    eval([var{i} '_tmean = nanmean(' var{i} ', [2, 3]);']);
end 
save([dir_output 'Time_Means' Spinup{1} '.mat'], 'time',...
    'Sf_tmean','Sp_tmean','Sd_tmean',...
    'Mf_tmean','Mp_tmean','Md_tmean',...
    'Lp_tmean','Ld_tmean','BE_tmean')

%% Get Time Series from offline simulations:
disp('Get Time Series from offline simulations')

%! Fish: 
for i = 1:(length(var)-2)
    ncid = netcdf.open([dir_input_offline_FEISTY var{i} '_bio' Spinup{2} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 

%! zoo oversoncumption: 
for i = (length(var)-1):length(var)
    ncid = netcdf.open([dir_input_offline_FEISTY var{i} Spinup{2} '.nc'],'NC_NOWRITE');
    eval([ var{i} ' = netcdf.getVar(ncid, 0 );']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    netcdf.close(ncid);
end 
dim = size(eval(var{1}));

%! Take mean over latitude and longitude for visualization:
time = 1:dim(1);

% Calcul average over time: -----------------------------------------
for i = 1:(length(var))
    eval([var{i} '_tmean = nanmean(' var{i} ', [2, 3]);']);
end

%! Save data: -------------------------------------------------------------
save([dir_output 'Time_Means' Spinup{2} '.mat'], 'time')
for i = 1:length(var)
    save([dir_output 'Time_Means' Spinup{2} '.mat'], ...
        [var{i} '_tmean'] ,'-append')
end



%% Initial condition for Online Coupling: 
disp('Get IC for Online COBALT')
ncid = netcdf.open(['../output/netcdf/' coupling '/' loc '/', ...
                    'FEISTY_2D_2023_10_spinup_subset.nc'],'NC_NOWRITE');
for i = 1:(length(var)-2)
    varid = netcdf.inqVarID(ncid, [var{i} '_B']);
    eval([ var{i} '_IC = netcdf.getVar(ncid, varid);']);
end

%! Calculate average over lat and long: 
for i = 1:(length(var)-2)
    eval([var{i} '_IC = squeeze(nanmean(' var{i} '_IC, [1, 2]));']);
end

%! Save average over lat and long: 
x = 1:(length(var)-2); 
if ~exist([dir_output 'COBALT_IC' '.mat'])
    delete([dir_output 'COBALT_IC' '.mat'])
end 
save([dir_output 'COBALT_IC' '.mat'], 'x')
for i = 1:(length(var)-2)
    save([dir_output 'COBALT_IC' '.mat'], ...
        [var{i} '_IC'] ,'-append')
end

%% diagnotic variables
disp(['Get Diagnostic variables from COBALT ', coupling, ' at ', loc])

sp = 2;
% get diagnostics:
for i = 1:(length(var)-3)
    ncid = netcdf.open([dir_input_offline_FEISTY var{i} '_diag_' Spinup{sp} 'Time_Serie' '.nc'],'NC_NOWRITE');
    for j = 1:length(var_diag)
        varid = netcdf.inqVarID(ncid, var_diag{j});
        eval([ var{i} '_' var_diag{j} ' = netcdf.getVar(ncid, varid );']);
        eval([ var{i} '_' var_diag{j} '(' var{i} '_' var_diag{j} ' == -99999) = NaN;']);
    end 
    netcdf.close(ncid);
end 

dim = size(eval([ var{i} '_' var_diag{j}]));
time = 1:dim(3);

% Calcul average over dimensions: -----------------------------------------
% Calculate average over lat and long:
for i = 1:(length(var)-3)
    for j = 1:length(var_diag)
        eval([var{i} '_' var_diag{j} '_tmean = transpose(squeeze(nanmean(' var{i} '_' var_diag{j} ', [1, 2])));']);
    end 
end
% Save data: -------------------------------------------------------------
save([dir_output 'Time_Means_Diag' Spinup{sp} '.mat'], 'time')
for i = 1:(length(var)-3)
    for j = 1:length(var_diag)
        save([dir_output 'Time_Means_Diag' Spinup{sp} '.mat'], ...
            [var{i} '_' var_diag{j} '_tmean'] ,'-append')
    end 
end

%% get COBALT Zooplankton outputs from the COBALT offline simulations: 
disp("Get Zooplankton outputs from COBALT offline simulations & process them for visualisation")

var = {'nmdz', 'jhploss_n_Mdz', 'jprod_nmdz', 'nlgz', 'jhploss_n_Lgz', 'jprod_nlgz', 'Pop_btm'};
coupling = 'offline';

%! get directory containing output
dir_input_offline_forcing = ['../../COBALT_output/COBALT_offline_forcing_files/' loc '/'];
dir_output =['../output/Matlab_Average/', coupling, '/' loc, '/', ];

if ~exist(dir_output) 
    mkdir(dir_output)
end 

dir = {[dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing.nc'], ...
        [dir_input_offline_forcing '20040101.ocean_feisty_forcing_detritus.nc']};

% Getting data from netcdf
for i = 1:length(var)
    ncid = netcdf.open(dir{i},'NC_NOWRITE');
    varid = netcdf.inqVarID(ncid, var{i});
    eval([ var{i} ' = netcdf.getVar(ncid, varid);']);
    eval([ var{i} '(' var{i} ' == 99999) = NaN;']);
    if i == 7
        eval([ var{i} ' = ' var{i} '(:,:,1:366);']);
    else
        eval([ var{i} ' = ' var{i} '(:,:,:,1:366);']);
    end
    netcdf.close(ncid);

    if ismember(i, [1, 4]) % conversions biomass 
        eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 1000.0;' ]);     % Conversion from Mol N/kg --> gC WW m-3
    elseif ismember(i, [2, 3, 5, 6, 7]) % conversion mortality
        eval([ var{i} ' = ' var{i} '*6.625* 12.01 * 9.0 * 24.0*3600;' ]);  % Conversion from Mol mol N m-2 s-1 (Layer integrated) --> gC WW m-3 d-1
    end
end 

%! Take mean over dimensions: ---------------------------------------------
dim = size(eval([var{1}]));
time = 1:dim(4);
depth = 1:dim(3);
   
%! Calculate average over lat and long for zooplanton biomass (integrate over 100m depth): 
for i = [1, 4] 
    eval([var{i} '_offline_spacemean(time, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
    eval([var{i} '_offline_tmean(time) = squeeze(sum(' var{i} '_offline_spacemean(time, :) .* topog.Layer_thikness, 2));']); % integrated biomass over depth
    eval([var{i} '_offline_tmean_100m(time) = squeeze(sum(' var{i} '_offline_spacemean(time, 1:topog.idx_100m) .* topog.Layer_thikness(1:topog.idx_100m), 2));']); % integrated biomass over 100m
    eval([var{i} '_offline_zmean = transpose(squeeze(nanmean(' var{i} '_offline_spacemean(time, :), 1)));']); % concentration at every depth
end
% Calculate average over lat and long for zooplanton mortality and production: these comes as layer integrated no need to multiply by layer thickness: 
for i = [2, 3, 5, 6] 
    eval([var{i} '_offline_spacemean(time, :) = transpose(squeeze(nanmean(' var{i} ', [1,2])));']);
    eval([var{i} '_offline_tmean(time) = squeeze(sum(' var{i} '_offline_spacemean(time, :), 2));']); % integrated biomass over depth
    eval([var{i} '_offline_tmean_100m(time) = squeeze(sum(' var{i} '_offline_spacemean(time, 1:topog.idx_100m), 2));']); % integrated biomass over 100m
    eval([var{i} '_offline_zmean = transpose(squeeze(nanmean(' var{i} '_offline_spacemean(time, :), 1)));']); % concentration at every depth
end 
for i = length(var) % pop_flux does not have vertical dimension
    eval([var{i} '_offline_tmean(time) = nanmean(' var{i} ', [1,2]);']);
end  

%! Save data: -------------------------------------------------------------
%!! average over lat and long: 
save([dir_output 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'], 'time', 'depth')
save([dir_output 'COBALT_offline_' loc  '_Time_Means_forcing' '.mat'], 'time')
save([dir_output 'COBALT_offline_100m_' loc  '_Time_Means_forcing' '.mat'], 'time')
save([dir_output 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'], 'time', 'depth')
for i = 1:(length(var)-1)
    save([dir_output 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'], [var{i} '_offline_spacemean']   ,'-append')
    save([dir_output 'COBALT_offline_' loc  '_Time_Means_forcing' '.mat'],      [var{i} '_offline_tmean']       ,'-append')
    save([dir_output 'COBALT_offline_100m_' loc  '_Time_Means_forcing' '.mat'], [var{i} '_offline_tmean_100m']  ,'-append')
    save([dir_output 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'],      [var{i} '_offline_zmean']       ,'-append')
end
save([dir_output 'COBALT_offline_' loc  '_Time_Means_forcing' '.mat'], [var{end} '_offline_tmean'], '-append')

clear all 

