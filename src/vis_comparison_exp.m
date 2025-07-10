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
var_COBALT       = {'nmdz', 'jhploss_n_Mdz', 'jprod_nmdz', 'nlgz', 'jhploss_n_Lgz', 'jprod_nlgz', 'Pop_btm'};
functional_group = {'Forage', 'Pelagic', 'Demersal'};

% indexes for plotting: 
idx_mz_bio          = [1, 4]; % indexes biomass zooplankton 
idx_mz_rate_loss    = [2, 5, 7]; % indexes mortality rates and detritus flux 
idx_mz_rate_growth  = [3, 6]; % indexes growth rates 
    
coupling = 'online'; 
addpath('/project/rdenechere/Programing-Tutorials/Matlab/Matlab_functions/')
% addpath('\\sio-smb.ucsd.edu\petrik-lab\rdenechere\Programing-Tutorials\Matlab\Matlab_functions\')

%! thickness of the lines:
thickness.grp = [1.5 1.5 2 1.5];
thickness.size = [1.5 1.5 2 2 2 2 2 2 1.5];


%=========================================================================%
%               plot comparison between each experiemnt                   %
%=========================================================================%

for i = 1:N_param % one plot per parameter to test: 
    N_values = table2array(unique(tab(:, i))); % values for the parameter

    %! colors
    cm = colormap(turbo(length(N_values)));

    % create the figure
    figure(i)
    axes_formating(gcf);
    t = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
    title(t, {[option.exp, ' at ' option.loc, ' for ' num2str(option.yr) ' Spinup year'], ...
            ['Parameter tested: ' char(param_name(i))]})
    mzaxes = nexttile;    
    lzaxes = nexttile;


    for j = 1:length(N_values)
        % find eperiment with the same value for the parameter: 
        idx_exp = find(table2array(tab(:, i)) == N_values(j));
        idx_exp = idx_exp(round(length(idx_exp)/2)); % Take a value close to the middle of the list
        
        exp_to_test = EXP_LIST{idx_exp};

        % load the data
        dir_input =['../output/Matlab_Average/', coupling, '/' option.loc, '/', option.exp, '/', [exp_to_test num2str(option.yr)] , '/'];
        dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp , '/Comparison_experiments/' ];
        if ~exist(dir_output, 'dir')
            mkdir(dir_output)
        end
        load([dir_input 'Time_Means_forcing_100m' '.mat']) % Cobalt tracers 
 
        k = idx_mz_bio(1); % index of small zooplanton
        axes_formating(gca, "defaultAxesColorOrder", cm);
        hold on 
        plot(mzaxes, time_days, eval([var_COBALT{k} '_tmean_100m']))
        hold off 

        k = idx_mz_bio(2); % index of large zooplanton 
        axes_formating(gca, "defaultAxesColorOrder", cm);
        hold on
        plot(lzaxes, time_days, eval([var_COBALT{k} '_tmean_100m']))
        hold off
    end
    L=legend(lzaxes, string(N_values), 'Location', 'best');
    title(L, param_name(i))
    title(mzaxes, 'Medium Zooplankton')
    title(lzaxes, 'Large Zooplankton')
    xlabel(t, ['Time over' option.yr 'year(s) Spinup (day)'])
    ylabel(t, 'Biomass of Zooplankton integrated over 100m (g WW C m^-^2)')
    save_graph(gcf, 'png', [dir_output 'Comparison_' char(param_name(i))], 16, 13)
end 

