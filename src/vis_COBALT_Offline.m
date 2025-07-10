% Visualize output of FEISTY
% Time series plots

function [] = vis_COBALT_Offline(option)
arguments
    option.loc       char {mustBeMember(option.loc, {'BATS', 'CCE', 'GOM', 'GOM_2', 'NS', 'GMX', 'GMX_2', 'GBK'})} = 'BATS'
    option.exp       char      = 'FE_FORCING'
    option.yr_spinup char      = '7'    % number of spinup years to read     
    option.multiyear logical   = false  % if true, all years are concatenated in the same netcdf file 
                                        % This is happening when the we run several years (2004 to 2006) 
                                        % at the same time instead of re running the 
                                        % same year over an over for spinup.                               
end
dbclear all 
% dbstop in vis_COBALT_Offline.m at 90

addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')  

%% Root directory: 
coupling = 'offline'; 
Spinup = {'_Spinup_Time_Serie', ''};

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

%% spinup years:
if ~option.multiyear
    % make output directory: 
    dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/']; 
    if ~exist(dir_output) 
        mkdir(dir_output)
    end 
    dir_output =['../Fig/', coupling, '/' option.loc, '/', option.exp, '/' 'Offline_' option.yr_spinup 'yrs/' , ...
                    option.loc '_' option.exp '_' ];
    
    % make input directory: 
    name = [option.loc, '_offline_yr_'] ; % name of the spinup file
    % directory of the spinup experiment at option.yr_spinup
    dir_input_COBALT_spinup = ['../output/Matlab_Average/', coupling, '/' option.loc, '/', ...
                            option.exp, '/', [name option.yr_spinup], '/']; 
elseif option.multiyear
    % make input directory: 
    name_yr = [option.yr_spinup 'years']; 
    dir_input_COBALT_spinup = ['../output/Matlab_Average/', coupling, '/' ,...
                                option.loc,'/multiyear/', name_yr , '/', option.exp ,'/' ];
    
    % make output directory: 
    dir_output =['../Fig/', coupling, '/' option.loc,'/multiyear/', name_yr , '/', option.exp ,'/']; 
    if ~exist(dir_output) 
        mkdir(dir_output)
    end 
    dir_output =['../Fig/', coupling, '/' option.loc,'/multiyear/', name_yr , '/', option.exp ,'/', ...
                    option.loc '_' option.exp '_' name_yr '_'];
end 

%% ============================================================================= %%  
%                                                                                 %
%                           COBALT OFFLINE SPINUP over XX year                    %
%                                                                                 %
%! ============================================================================= !%
disp(['Analysis of COBALT offline Spinup over ' option.yr_spinup ' years'])

%! ============================================================================= !%
disp("Searching for .mat data files in:")
disp(dir_input_COBALT_spinup)

%! ============================================================================= !%
% load the topological data for the specific location 
load(['../output/Matlab_Average/', coupling, '/', option.loc, '/Topology.mat'], 'topog') % load topography data
load([dir_input_COBALT_spinup 'Time_Depth_Means_forcing' '.mat']); % load depth means
load([dir_input_COBALT_spinup 'Time_Means_forcing_100m'  '.mat']); % load 100m means
load([dir_input_COBALT_spinup 'Time_Means_forcing'       '.mat']); % load average over time 
cm7  = colormap(turbo(7)); % colormap for the figures
start_date = datetime("2004-01-01"); % start date of the expriment 
end_date   = datetime("2004-12-31"); % end date of the expriment
time = start_date:end_date; % time vector for the expriment in days 
n = 0; % counter for the number of figures

% Loop over each COBALT bgc tracer:
for i = [idx_biomass idx_rates idx_env idx_physic]
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
        if ismember(i, idx_physic)
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
        if ismember(i, idx_physic)
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
        if ismember(i, idx_physic)
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
        if ismember(i, idx_physic)
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
        if ismember(i, idx_physic)
            title('Last spinup year 100 m average')
        else 
            title('Last spinup year 100 m int.')
        end 
        xlabel('time (days)')
        ylabel([var_COBALT{i} ' (' units_int{i} ')'])
        set(gca, 'YLim', [min(eval([var_COBALT{i} '_tmean_100m'])) max(eval([var_COBALT{i} '_tmean_100m']))])

    save_graph(gcf, "png", [dir_output 'COBALT_offline_' var_COBALT{i} '_Layer_100mInt_' option.yr_spinup '_yrs'], 16, 12)
end
        
for i = idx_2D_flux
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

% Figure 4: Plot the depth at each layer:
n = n+1;
figure(n)
axes_formating(gcf); 
semilogy(1:75, -topog.Layer(1:75))
hold on 
plot([1 75], [-200 -200], 'k--')
hold off
xlabel('Layer ID')
ylabel('Depth (m)')
title('Depth at each layer Based on BATS')
legend('Layer depth', '200 m')
save_graph(gcf, "png", [dir_output 'Layer_Depth'], 12, 10)