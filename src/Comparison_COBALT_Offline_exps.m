% Visualize output of The single column COBALT simulation without FEISTY
% Comparison of two offline experiments of COBALT
% Rémy Denéchère 

function [] = Comparison_COBALT_Offline_exps(option)
arguments
    option.loc       char {mustBeMember(option.loc, {'BATS', 'CCE', 'GOM', 'GOM_2', 'NS', 'GMX', 'GMX_2'})} = 'BATS'
    option.exp1       char      = 'NUDGING_BATS'
    option.exp2       char      = 'NEW_IC_FILE'
    option.yr_spinup  char      = '7'    % number of spinup years to read                                  
end
dbclear all 
% dbstop in Comparison_COBALT_Offline_exps.m at 113

addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')  

%% Root directory: 
coupling = 'offline'; 
Spinup = {'_Spinup_Time_Serie', ''};
option.exp = [option.exp1 '_VS_' option.exp2];

var_COBALT = {'nmdz', 'nlgz', 'nsmz', 'nbact', 'ndet', 'ndi', 'nlg', 'nmd', 'nsm', ...
                'jhploss_n_Mdz', 'jprod_nmdz', 'jhploss_n_Lgz', 'jprod_nlgz',...
                'nh4', 'no3', 'o2', 'dic', 'thetao', 'Pop_btm'};
units = {'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg',...
         'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
         'mol/kg', 'mol/kg', 'mol/kg', 'mol/kg', '°C', 'Mol m-2 s-1'};
units_int = {'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2',...
         'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
         'mol m-2', 'mol m-2', 'mol m-2', 'mol m-2', '°C', 'Mol m-2 s-1'};
idx_biomass =   [1:9]; % index of the variables that are biomass
idx_rates =     [10:13]; % index of the variables that are mortality and production
idx_env =       [14:17]; % index of the environmental variables
indx_temp =     18;     % index of Temperature
idx_pop_flux =  length(var_COBALT); % index of the detritus flux to the bottom

% make output directory: 
dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/']; 
if ~exist(dir_output) 
    mkdir(dir_output)
end 
dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/' , ...
                option.loc '_' option.exp '_' ];

%% ============================================================================= %%  
%                                                                                 %
%                           COBALT OFFLINE SPINUP over XX year                    %
%                                                                                 %
%! ============================================================================= !%
disp(['Comparison of COBALT offline Spinup over ' option.yr_spinup ' years for the experiments', ...
       option.exp1 ' and ' option.exp2 ])

%! ============================================================================= !%
name = [option.loc, '_offline_yr_'] ; % name of the spinup file
% Directory for exp 1: 
dir_input_COBALT_spinup_exp1 = ['../output/Matlab_Average/', coupling, '/' option.loc, '/', ...
                            option.exp1, '/', [name option.yr_spinup], '/']; % directory of the spinup experiment at option.yr_spinup
disp("Searching for .mat data files in:")
disp(dir_input_COBALT_spinup_exp1)

% Directory for exp 2: 
dir_input_COBALT_spinup_exp2 = ['../output/Matlab_Average/', coupling, '/' option.loc, '/', ...
                            option.exp2, '/', [name option.yr_spinup], '/']; % directory of the spinup experiment at option.yr_spinup
disp("Searching for .mat data files in:")
disp(dir_input_COBALT_spinup_exp2)

%! ============================================================================= !%
load(['../output/Matlab_Average/', coupling, '/', option.loc, '/Topology.mat'], 'topog') % load topography data

% Load data exp 1: 
load([dir_input_COBALT_spinup_exp1 'Time_Depth_Means_forcing' '.mat']); % load depth means
load([dir_input_COBALT_spinup_exp1 'Time_Means_forcing_100m'  '.mat']); % load 100m means
load([dir_input_COBALT_spinup_exp1 'Time_Means_forcing'       '.mat'], [var_COBALT{idx_pop_flux} '_tmean']); % load average over time 
% Change name of variable for experiment 1:
for i = 1:(length(var_COBALT)-1)
    eval([var_COBALT{i} '_spacemean_exp1 =' var_COBALT{i} '_spacemean;']);
    eval([var_COBALT{i} '_tmean_100m_exp1 =' var_COBALT{i} '_tmean_100m;']);
    clear([var_COBALT{i} '_spacemean'])
    clear([var_COBALT{i} '_tmean_100m'])
end 
for i = length(var_COBALT)
    eval([var_COBALT{i} '_tmean_exp1 =' var_COBALT{i} '_tmean;']);
    clear([var_COBALT{i} '_tmean'])
end 

% Load data exp 2: 
load([dir_input_COBALT_spinup_exp2 'Time_Depth_Means_forcing' '.mat']); % load depth means
load([dir_input_COBALT_spinup_exp2 'Time_Means_forcing_100m'  '.mat']); % load 100m means
load([dir_input_COBALT_spinup_exp2 'Time_Means_forcing'       '.mat'], [var_COBALT{idx_pop_flux} '_tmean']); % load average over time 
% Change name of variables for experiment 2: 
for i = 1:(length(var_COBALT)-1)
    eval([var_COBALT{i} '_spacemean_exp2 =' var_COBALT{i} '_spacemean;']);
    eval([var_COBALT{i} '_tmean_100m_exp2 =' var_COBALT{i} '_tmean_100m;']);
    clear([var_COBALT{i} '_spacemean'])
    clear([var_COBALT{i} '_tmean_100m'])
end 
for i = length(var_COBALT)
    eval([var_COBALT{i} '_tmean_exp2 =' var_COBALT{i} '_tmean;']);
    clear([var_COBALT{i} '_tmean'])
end 

% parameters : --------------------------------------------
cm7  = colormap(turbo(7)); % colormap for the figures
start_date = datetime("2004-01-01"); % start date of the expriment 
end_date   = datetime("2004-12-31"); % end date of the expriment
time = start_date:end_date; % time vector for the expriment in days 
n = 0; % counter for the number of figures

% Loop over each COBALT bgc tracer:
for i = [idx_biomass idx_rates idx_env indx_temp]
    n = n+1;
    % Figure 1: Depth profiles of the time mean over all spinup years: ---------------------------
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(2, 2, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ' ' option.exp1 '-'  option.exp2 ]}, ...
        Interpreter = 'none')

        % Panel 1: time average over all spinup years:
        ax = nexttile([1, 2]);
        surf(time_days', -topog.Layer', eval(['transpose(' var_COBALT{i} '_spacemean_exp1 -' var_COBALT{i} '_spacemean_exp2)']), ...
            'EdgeColor', 'none')
        view(2)
        % Add a dashed line at time 366
        hold on
        plot3(366 * ones(size(-topog.Layer')), -topog.Layer', ...
            max(eval(['transpose(' var_COBALT{i} '_spacemean_exp1 -' var_COBALT{i} '_spacemean_exp2)']),...
            [], 'all') * ones(size(-topog.Layer')), ...
            '--', 'LineWidth', 1.5, 'Color', 'r')
        hold off
        clb = colorbar(ax);
        title(clb, units{i})
        title(['Depth Change of \Delta ' var_COBALT{i} ' over spinup years'])
        xlabel('Spinup time (days)')
        ylabel('Depth (m)')

        % Panel 2: time average over first spinup years:
        nexttile; 
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m_exp1(1:366) - ' var_COBALT{i} '_tmean_100m_exp2(1:366)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units_int{i} ')'])
        % set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2'])), ...
        %                     max(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2']))])

        % Panel 3: time average over last spinup years:
        nexttile;   
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m_exp1(end-365:end) - ' var_COBALT{i} '_tmean_100m_exp2(end-365:end)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units_int{i} ')'])
        % set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2'])), ...
        %                     max(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2']))])
    save_graph(gcf, "png", [dir_output 'COBALT_offline_' option.exp '_'  var_COBALT{i} '_100mInt_' option.yr_spinup '_yrs'], 16, 12)

    % Figure 2: Time series of the time at several depths: ---------------------------
        n = n+1;
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(3, 1, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ' ' option.exp1 '-'  option.exp2 ]}, Interpreter = 'none')
        
        % Panel 1: time average over all spinup years surface --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_spacemean_exp1(:, 1) -' var_COBALT{i} '_spacemean_exp2(:, 1)']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel(['\Delta' var_COBALT{i} ' ' units{i}])
        title(['\Delta' var_COBALT{i} ' at Surface'])

        % Panel 2: time average over all spinup years bottom --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_spacemean_exp1(:, end) - ' var_COBALT{i} '_spacemean_exp2(:, end)']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units{i} ')'])
        title(['\Delta' var_COBALT{i} ' at Bottom'])

        % Panel 3: time average over all spinup years int 100m --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_tmean_100m_exp1 -' var_COBALT{i} '_tmean_100m_exp1']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units_int{i} ')'])
        if i == indx_temp
            title(['\Delta' var_COBALT{i} ' average over top 100m'])
        else 
            title(['\Delta' var_COBALT{i} ' int. over top 100m'])
        end 
        save_graph(gcf, "png", [dir_output 'COBALT_offline_' option.exp '_' var_COBALT{i} '_Surface_Bottom_Time_series_' option.yr_spinup '_yrs'], 16, 12)

   % Figure 3:  Layer profiles of the time mean over all spinup years: ---------------------------
        n = n+1;
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(2, 2, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ' ' option.exp1 '-'  option.exp2 ]}, ...
        Interpreter = 'none')

        % Panel 1: time average over all spinup years:
        ax = nexttile([1, 2]);
        surf(time_days', -(1:75)', eval(['transpose(' var_COBALT{i} '_spacemean_exp1 -' var_COBALT{i} '_spacemean_exp2 )']), ...
            'EdgeColor', 'none')
        view(2)
        % Add a dashed line at time 366
        hold on
        plot3(366 * ones(size(-topog.Layer')), -[1:75]', ...
            max(eval(['transpose(' var_COBALT{i} '_spacemean_exp1 -' var_COBALT{i} '_spacemean_exp2)']),...
            [], 'all') * ones(size(-topog.Layer')), ...
            '--', 'LineWidth', 1.5, 'Color', 'r')
        hold off

        clb = colorbar(ax);
        title(clb,[var_COBALT{i} units{i}])
        title(['Layer Change of \Delta' var_COBALT{i} ' over spinup years'])
        xlabel('Spinup time (days)')
        ylabel(' Layer ID')

        % Panel 2: time average over first spinup years:
        nexttile; 
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m_exp1(1:366) - ' var_COBALT{i} '_tmean_100m_exp2(1:366)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units_int{i} ')'])
%         set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2'])),...
%                          max(eval([var_COBALT{i} '_tmean_100m_exp1 - ' var_COBALT{i} '_tmean_100m_exp2']))])

        % Panel 3: time average over last spinup years:
        nexttile;   
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m_exp1(end-365:end) - ' var_COBALT{i} '_tmean_100m_exp2(end-365:end)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel(['\Delta' var_COBALT{i} ' (' units_int{i} ')'])
        %set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m_exp1(end-365:end) - ' var_COBALT{i} '_tmean_100m_exp2(end-365:end)'])),...
        %                 max(eval([var_COBALT{i} '_tmean_100m_exp1(end-365:end) - ' var_COBALT{i} '_tmean_100m_exp2(end-365:end)']))])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' option.exp '_'  var_COBALT{i} '_Layer_100mInt_' option.yr_spinup '_yrs'], 16, 12)
end
        
for i = idx_pop_flux
    n = n+1;
    axes_formating(gcf, "defaultAxesColorOrder", cm7); 
    t = tiledlayout(2, 2, "TileSpacing","compact","Padding","compact");
    title(t, {['COBALT ' coupling ' ' var_COBALT{i} ' ' option.exp1 '-'  option.exp2 ]}, ...
    Interpreter = 'none')

    ax = nexttile([1, 2]);
    plot(time_days, eval([var_COBALT{i} '_tmean_exp1 - ' var_COBALT{i} '_tmean_exp2']), ...
        'LineWidth', 1.5)
    view(2)
    clb = colorbar(ax);
    title(clb, var_COBALT{i})
    title(['Depth Change of \Delta ' var_COBALT{i} ' over spinup years'])
    xlabel('Spinup time (days)')
    ylabel(['\Delta ' var_COBALT{i} ' (' units{i} ')'])

    nexttile; 
    plot(time, eval([var_COBALT{i} '_tmean_exp1(1:366) - ' var_COBALT{i} '_tmean_exp2(1:366)']))
    title('First spinup year')
    xlabel('time (days)')
    ylabel(['\Delta ' var_COBALT{i} ' (' units{i} ')'])


    nexttile;   
    plot(time, eval([var_COBALT{i} '_tmean_exp1(end-365:end) - ' var_COBALT{i} '_tmean_exp2(end-365:end)']))
    title('Last spinup year')
    xlabel('time (days)')
    ylabel(['\Delta ' var_COBALT{i} ' (' units{i} ')'])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' option.exp '_'  var_COBALT{i} '_100mInt_' option.yr_spinup '_yrs'], 16, 12)
end 