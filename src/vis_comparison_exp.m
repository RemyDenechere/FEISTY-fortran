%=========================================================================%
%                                                                         %
%                Visualition Comparison between experiments               %
%                                                                         %
%=========================================================================%

function [] = vis_comparison_exp(option)

arguments
    option.exp       char                                                           = 'FEISTY--non-vertical-refuge-2'
    option.loc       char {mustBeMember(option.loc, {'BATS', 'CCE', 'GOM', 'NS'})}  = 'BATS'
    option.rockfish  logical                                                        = true
    option.yr        double                                                         = 7
end
clf
dbclear all 
% dbstop in vis_comparison_exp at 144

%=========================================================================%
%                        Open the experiment name file                    %
%=========================================================================%
% Open the file for reading
FID = fopen('experiment_name.txt', 'r');

% Check if the file was opened successfully
if FID == -1
    error('Failed to open experiment_name.txt');
end

% Read the contents of the file
EXP_LIST = textscan(FID, '%s', 'Delimiter', '\n');
EXP_LIST = EXP_LIST{1};

% Close the file
fclose(FID);

EXP_LIST_reverse = char(EXP_LIST)';

% Find the index of _ in the experiment name 
idx = find(EXP_LIST_reverse == '_');

% Number of _ per experiment name
N_exp = height(EXP_LIST);
N = length(idx)/N_exp;

% matrix of index of _ in the experiment name
idx = reshape(idx, N, height(EXP_LIST));

%=========================================================================%
%                        Extract information about experiment             %
%=========================================================================%
N_param = (N - 2)/2; % number of parameter to test: 
param_name = strings(N_param, 1); % name of the parameter to test
tab = zeros(N_exp, N_param); % matrix of parameter value
for i = 1:N_exp % loop over the number of experiment
    for j = 1:N_param % loop over the number of parameter to test
        if i == 1 
            location = EXP_LIST_reverse(1:idx(i, 1)-1);
            idx_name = idx((j-1)*2+1, i)+1:idx(j*2, i)-1;          
            param_name(j) = string(EXP_LIST_reverse(idx_name)); 
        end 
        % Extract the value of the parameter
        tab(i, j) = str2double(EXP_LIST_reverse(idx(j*2, i)+1:idx(j*2+1, i)-1));
    end 
end 

% Convert tab to a table with variable names from param_name
tab = array2table(tab, 'VariableNames', param_name);

% Display the table
disp('List of experiment and values for each parameter:');
disp(tab);

%=========================================================================%
%               plot comparison between each experiemnt                   %
%=========================================================================%

%! set up variable names
var              = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'};
functional_group = {'Forage', 'Pelagic', 'Demersal'};
var_COBALT = {'nmdz', 'nlgz', 'nsmz', 'nbact', 'ndet', 'ndi', 'nlg', 'nmd', 'nsm', ...
              'jhploss_n_Mdz', 'jprod_nmdz', 'jhploss_n_Lgz', 'jprod_nlgz',...
              'nh4', 'no3', 'o2', 'po4', 'dic', 'fed', 'thetao', 'so', 'irr_aclm', 'Pop_btm', 'MLD_003'};
units = {'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg',...
         'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
         'mol/kg', 'mol/kg', 'mol/kg', 'mol/kg', 'mol/kg', 'mol/kg', '°C', 'Watts/m^2', 'psu', 'Mol m-2 s-1', 'm'};
units_int = {'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2',...
             'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
             'mol m-2', 'mol m-2', 'mol m-2', 'mol m-2', 'mol m-2', 'mol m-2', '°C', 'Watts/m^2', 'psu', 'Mol m-2 s-1', 'm'};
idx_biomass =   [1:9]; % index of the variables that are biomass
idx_rates =     [10:13]; % index of the variables that are mortality and production
idx_env =       [14:19]; % index of the environmental variables
idx_physic =    [20, 21, 22]; % index of the physical variables
idx_2D_flux =   [23 24]; % index of the detritus flux to the bottom
    
coupling = 'online'; 
addpath('/project/rdenechere/Programing-Tutorials/Matlab/Matlab_functions/')
% addpath('\\sio-smb.ucsd.edu\petrik-lab\rdenechere\Programing-Tutorials\Matlab\Matlab_functions\')

%! thickness of the lines:
thickness.grp = [1.5 1.5 2 1.5];
thickness.size = [1.5 1.5 2 2 2 2 2 2 1.5];

dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp , '/Comparison_experiments/' ];

%=========================================================================%
%               plot comparison between each experiemnt                   %
%=========================================================================%

for i = 1:N_param % one plot per parameter to test: 
    N_values = table2array(unique(tab(:, i))); % values for the parameter

    %! colors
    cm = colormap(turbo(length(N_values)));
        
    for k = [idx_biomass idx_rates idx_env]
         % create the figure
        figure
        axes_formating(gcf);
        t = tiledlayout(1, 1, "TileSpacing", "compact", "Padding", "compact");
        title(t, {[option.exp, ' at ' option.loc, ' for ' num2str(option.yr) ' Spinup year'], ...
                ['Parameter tested: ' char(param_name(i))], ...
                ['Variable: ' char(var_COBALT{k})]})

        %! set the axes! 
        for j = 1:length(N_values)
            % find eperiment with the same value for the parameter: 
            idx_exp = find(table2array(tab(:, i)) == N_values(j));
            idx_exp = idx_exp(round(length(idx_exp)/2)); % Take a value close to the middle of the list
            
            exp_to_test = EXP_LIST{idx_exp};

            % load the data
            dir_input =['../output/Matlab_Average/', coupling, '/' option.loc, '/', option.exp, '/', [exp_to_test num2str(option.yr)] , '/'];

            if ~exist(dir_output, 'dir')
                mkdir(dir_output)
            end
            load([dir_input 'Time_Means_forcing_100m' '.mat']) % Cobalt tracers 
    
            axes_formating(gca, "defaultAxesColorOrder", cm);
            hold on 
            plot(time_days, eval([var_COBALT{k} '_tmean_100m']))
            hold off 
        end
        L=legend(string(N_values), 'Location', 'best');
        title(L, param_name(i))
        xlabel(t, ['Time over' option.yr 'year(s) Spinup (day)'])
        ylabel(t, [var_COBALT{k} ' (' units{k} ')'])
        save_graph(gcf, 'png', [dir_output 'Comparison_' char(param_name(i)) '_for_var' var_COBALT{k}], 16, 13)
    end 
end 

