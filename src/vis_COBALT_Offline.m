% Visualize output of FEISTY
% Time series plots

function [] = vis_COBALT_Offline(option)
arguments
    option.loc       char {mustBeMember(option.loc, {'BATS', 'CCE', 'GOM', 'GOM_2', 'NS', 'GMX', 'GMX_2'})} = 'BATS'
    option.exp       char      = 'DIAG_COORD_DEF_01_FNC1_4680'
    option.yr_spinup char      = '2'    % number of spinup years to read                                  
end
dbclear all 
% dbstop in vis_COBALT_Offline.m at 74

addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')  

%% Root directory: 
coupling = 'offline'; 
Spinup = {'_Spinup_Time_Serie', ''};

var_COBALT = {'nmdz', 'nlgz', 'nbact', 'ndet', 'ndi', 'nlg', 'nmd', 'nsm', ...
                'jhploss_n_Mdz', 'jprod_nmdz', 'jhploss_n_Lgz', 'jprod_nlgz',...
                'nh4', 'no3', 'o2', 'dic', 'thetao', 'Pop_btm'};
units = {'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg', 'Mol N/kg',...
         'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
         'mol/kg', 'mol/kg', 'mol/kg', 'mol/kg', '°C', 'Mol m-2 s-1'};
units_int = {'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2', 'Mol N m-2',...
         'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1', 'mol N m-2 s-1',...
         'mol m-2', 'mol m-2', 'mol m-2', 'mol m-2', '°C', 'Mol m-2 s-1'};
idx_biomass =   [1:8]; % index of the variables that are biomass
idx_rates =     [9:12]; % index of the variables that are mortality and production
idx_env =       [13:16]; % index of the environmental variables
idx_pop_flux =  length(var_COBALT); % index of the detritus flux to the bottom
indx_temp = 17;

% make output directory: 
dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/']; 
if ~exist(dir_output) 
    mkdir(dir_output)
end 
dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/' , ...
                option.loc '_' option.exp '_' ];

%% colors
cm10=[0.5 0.5 0;... %tan/army
    0 0.7 0;...     %g
    1 0 1;...       %m
    1 0 0;...       %r
    0.5 0 0;...     %maroon
    0/255 206/255 209/255;... %turq
    0 0.5 0.75;...  %med blue
    0 0 0.75;...    %b
    0.5 0.5 0.5; ...%med grey
    0 0 0];...      %black

%% ============================================================================= %%  
%                                                                                 %
%                           COBALT OFFLINE SPINUP over XX year                    %
%                                                                                 %
%! ============================================================================= !%
disp(['Analysis of COBALT offline Spinup over ' option.yr_spinup ' years'])

name = [option.loc, '_offline_yr_'] ; % name of the spinup file
dir_input_COBALT_spinup = ['../output/Matlab_Average/', coupling, '/' option.loc, '/', ...
                            option.exp, '/', [name option.yr_spinup], '/']; % directory of the spinup experiment at option.yr_spinup
disp("Searching for .mat data files in:")
disp(dir_input_COBALT_spinup)

load(['../output/Matlab_Average/', coupling, '/', option.loc, '/Topology.mat'], 'topog') % load topography data
load([dir_input_COBALT_spinup 'Time_Depth_Means_forcing' '.mat']); % load depth means
load([dir_input_COBALT_spinup 'Time_Means_forcing_100m'  '.mat']); % load 100m means
load([dir_input_COBALT_spinup 'Time_Means_forcing'       '.mat'], [var_COBALT{idx_pop_flux} '_tmean']); % load average over time 
cm7  = colormap(turbo(7)); % colormap for the figures
start_date = datetime("2004-01-01"); % start date of the expriment 
end_date   = datetime("2004-12-31"); % end date of the expriment
time = start_date:end_date; % time vector for the expriment in days 
n = 0; % counter for the number of figures

% Loop over each COBALT bgc tracer:
for i = [idx_biomass idx_rates idx_env]
    n = n+1;

    % Figure 1: Depth profiles of the time mean over all spinup years: ---------------------------
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(2, 2, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ]}, ...
        Interpreter = 'none')

        % Panel 1: time average over all spinup years:
        ax = nexttile([1, 2]);
        surf(time_days', -topog.Layer', eval(['transpose(' var_COBALT{i} '_spacemean)']), ...
            'EdgeColor', 'none')
        view(2)
        % Add a dashed line at time 366
        hold on
        plot3(366 * ones(size(-topog.Layer')), -topog.Layer', max(eval(['transpose(' var_COBALT{i} '_spacemean)']), [], 'all') * ones(size(-topog.Layer')), ...
            '--', 'LineWidth', 1.5, 'Color', 'r')
        hold off
        clb = colorbar(ax);
        title(clb, units{i})
        title('Depth Change over spinup years')
        xlabel('Spinup time (days)')
        ylabel('Depth (m)')

        % Panel 2: time average over first spinup years:
        nexttile; 
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m(1:366)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m'])) max(eval([var_COBALT{i} '_tmean_100m']))])

        % Panel 3: time average over last spinup years:
        nexttile;   
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m(end-365:end)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m'])) max(eval([var_COBALT{i} '_tmean_100m']))])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' var_COBALT{i} '_100mInt_' option.yr_spinup '_yrs'], 16, 12)

    % Figure 2: Time series of the time at several depths: ---------------------------
        n = n+1;
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(3, 1, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ' ' option.exp]}, Interpreter = 'none')
        
        % Panel 1: time average over all spinup years surface  --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_spacemean(:, 1)']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel([var_COBALT{i} units{i}])
        title([var_COBALT{i} ' at Surface'])

        % Panel 2: time average over all spinup years bottom  --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_spacemean(:, end)']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel([var_COBALT{i} ' (' units{i} ')'])
        title([var_COBALT{i} ' at Bottom'])

        % Panel 3: time average over all spinup years surface  --------------------------------------------------------
        nexttile
        hold on
        plot(time_days', eval([var_COBALT{i} '_tmean_100m']))
        plot([time_days(1) time_days(end)], [0 0], 'k--')
        hold off
        xlabel('Spinup time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        if i == indx_temp
            title([var_COBALT{i} ' average over top 100m'])
        else 
            title([var_COBALT{i} ' int. over top 100m'])
        end 
        

        save_graph(gcf, "png", [dir_output 'COBALT_offline_' var_COBALT{i} '_Surface_Bottom_Time_series_' option.yr_spinup '_yrs'], 16, 12)

   % Figure 3:  Layer profiles of the time mean over all spinup years: ---------------------------
        n = n+1;
        figure(n)
        axes_formating(gcf, "defaultAxesColorOrder", cm7, "AxesTitleHorizontalAlignment", "left"); 
        t = tiledlayout(2, 2, "TileSpacing","tight","Padding","loose");
        title(t, {['COBALT ' coupling ' ' var_COBALT{i} ]}, ...
        Interpreter = 'none')

        % Panel 1: time average over all spinup years:
        ax = nexttile([1, 2]);
        surf(time_days', -(1:75)', eval(['transpose(' var_COBALT{i} '_spacemean)']), ...
            'EdgeColor', 'none')
        view(2)
        % Add a dashed line at time 366
        hold on
        plot3(366 * ones(size(-topog.Layer')), -(1:75)', max(eval(['transpose(' var_COBALT{i} '_spacemean)']), [], 'all') * ones(size(-topog.Layer')), ...
            '--', 'LineWidth', 1.5, 'Color', 'r')
        hold off

        clb = colorbar(ax);
        title(clb,[var_COBALT{i} units{i}])
        title('Depth Change over spinup years')
        xlabel('Spinup time (days)')
        ylabel('Depth (m)')

        % Panel 2: time average over first spinup years:
        nexttile; 
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m(1:366)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m'])) max(eval([var_COBALT{i} '_tmean_100m']))])
        
        % Panel 3: time average over last spinup years:
        nexttile;   
        hold on 
        plot(time, eval([var_COBALT{i} '_tmean_100m(end-365:end)']))
        plot(time, zeros(length(time), 1), 'k--')
        hold off
        if i == indx_temp
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m'])) max(eval([var_COBALT{i} '_tmean_100m']))])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' var_COBALT{i} '_Layer_100mInt_' option.yr_spinup '_yrs'], 16, 12)
end
        
for i = idx_pop_flux
    n = n+1;
    axes_formating(gcf, "defaultAxesColorOrder", cm7); 
    t = tiledlayout(2, 2, "TileSpacing","compact","Padding","compact");
    title(t, {['COBALT ' coupling ' ' var_COBALT{i}]}, ...
    Interpreter = 'none')

    ax = nexttile([1, 2]);
    plot(time_days, eval([var_COBALT{i} '_tmean']))
    view(2)
    clb = colorbar(ax);
    title(clb, var_COBALT{i})
    title('Depth Change over spinup years')
    xlabel('Spinup time (days)')
    ylabel([var_COBALT{i} units{i}])

    nexttile; 
    plot(time, eval([var_COBALT{i} '_tmean(1:366)']))
    title('First spinup year')
    xlabel('time (days)')
    ylabel([var_COBALT{i} units{i}])


    nexttile;   
    plot(time, eval([var_COBALT{i} '_tmean(end-365:end)']))
    title('Last spinup year')
    xlabel('time (days)')
    ylabel([var_COBALT{i} units{i}])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' var_COBALT{i} '_100mInt_' option.yr_spinup '_yrs'], 16, 12)
end 