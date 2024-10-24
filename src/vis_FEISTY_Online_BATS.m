%% Analysis FEISTY Coupled 
function [] =  vis_FEISTY_Online_BATS(list, name, loc, yr)

arguments 
    list      logical = false
    name      string  = 'BATS_nonFmort_0.1_encounter_70_k_1_k50_1_yr_'      % Default experiment
    loc       char    = 'BATS'
    yr        double  = 5
end 


%! set up variable names
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'};
var_COBALT = {'nmdz', 'jhploss_n_Mdz', 'nlgz', 'jhploss_n_Lgz', 'Pop_btm'};
functional_group = {'Forage', 'Pelagic', 'Demersal'};
coupling = 'online'; 
addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')

%! colors
cm10 = colormap(turbo(10));
cm4  = colormap(turbo(4));
cm3  = colormap(turbo(3));

%! get experiment folder names: 
if list
    [exp_name] = experiment_name(); 
else 
    exp_name = name;
end 

%! print command line: 
disp(['Visualisation from COBALT-FEISTY ' coupling ' at ' loc, ...
    ' for ' num2str(yr) ' years spinup!'])

%% Loop over all experiments:
for nm = 1:length(exp_name)
    n = 0; 
    name = exp_name{nm}; 
    name_yr = [name num2str(yr)]; 
    disp(['experiment: ' name_yr])

    coupling = 'online';
    dir_input =['../output/Matlab_Average/', coupling, '/' loc, '/', [name num2str(yr)] , '/'];
    dir_output =['../Fig/', coupling, '/' loc, '/', [name num2str(yr)], '/'];
    dir_input_offline = ['../output/Matlab_Average/', 'offline', '/' loc, '/'];

    if ~exist(dir_output) 
        mkdir(dir_output)
    end    
 
    %% ------------------------------------------------------------------------
    %                               Tracers 
    % -------------------------------------------------------------------------
    %!  get tracers: 
    load([dir_input 'Time_Depth_Means_Tracers' '.mat'])
    load([dir_input 'Time_Means_Tracers' '.mat'])
    load([dir_input 'Depth_Means_Tracers' '.mat'])
    
    % plot average tracer over depth: -----------------------------------------------
    n = n+1;
    %!! functional group: 
    F_B_zmean = Sf_B_zmean(end, :) + Mf_B_zmean(end, :);
    P_B_zmean = Sp_B_zmean(end, :) + Mp_B_zmean(end, :) + Lp_B_zmean(end, :);
    D_B_zmean = Sd_B_zmean(end, :) + Md_B_zmean(end, :) + Ld_B_zmean(end, :);
    
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10)
    t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");
    
    %! plot all size: 
    ax = nexttile;
    hold on 
    for i = 1:(length(var)-1)
        plot(ax, eval([var{i} '_B_zmean(end, :)']), -depth)
    end
    % plot(ax, Ld_B_zmean, -depth, '.')
    hold off
    ax.XScale = "log";
    % ax.XLim = [10^(-6) 10^1];
    L = legend(var{1:(end-1)}, 'Location', 'best'); 
    L.Box = 'off'; L.Color = 'none';
    title("All sizes")
    
    %! plot functional group:
    nexttile
    axes_formating(gcf, "defaultAxesColorOrder", cm4)
    semilogx(F_B_zmean, -depth, P_B_zmean, -depth, BE_B_zmean, -depth)
    hold on 
    semilogx(double(D_B_zmean(end)), -depth(end), '.')
    hold off 
    L = legend('Forage', 'Pelagic', 'Benthic', 'Demersal', 'Location', 'southwest');
    %set(gca, 'XLim', [10^(-6) 10^1])
    L.Box = 'off'; L.Color = 'none';
    title("Functional groups")
    
    % tiled labels: 
    xlabel(t, "Biomass gWW m-3")
    ylabel(t, "Layers")
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], 'Depth_Means_Time_Series'}, ...
        Interpreter = 'none')
    
    save_graph(gcf, "png", [dir_output 'Depth_Means_Time_Series'], 16, 12)
    
    %% plot average over time:-------------------------------------------------
    n = n+1;

    %!! functional group: 
    F_B_tmean = Sf_B_tmean + Mf_B_tmean;
    P_B_tmean = Sp_B_tmean + Mp_B_tmean + Lp_B_tmean;
    D_B_tmean = Sd_B_tmean + Md_B_tmean + Ld_B_tmean;
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-30");
    time = repmat(start_date:end_date, 1, yr);
    time = month(time);
    
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10)
    t = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
    
    % plot all size: 
    ax = nexttile;
    hold on
    for i = 1:length(var)
        plot(ax, time, eval([var{i} '_B_tmean']))
    end
    set(gca, 'YLim', [10^(-10) 2*10^2])
    hold off 
    ax.YScale = "log";
    % ax.XLim   = [0, 366*1.45];
    L = legend(var, 'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("All sizes")
    
    % plot functional groups: 
    nexttile 
    axes_formating(gcf, "defaultAxesColorOrder", cm4)
    semilogy(time, F_B_tmean, time_days, P_B_tmean, time_days, D_B_tmean, time_days, BE_B_tmean)
    set(gca, 'YLim', [10^(-10) 2*10^2])
    L = legend('Forage', 'Pelagic', 'Demersal', 'Benthos', ...
            'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("Functional groups")
    
    ylabel(t, "Biomass gWW m-3")
    xlabel(t, "time days")
    title(t, 'Offline Fish simulations')
    
    save_graph(gcf, "png", [dir_output 'Time_Means_Time_Series'], 16, 10)
    
    %% plot average over a year:-------------------------------------------------
    n = n+1;
    %!! functional group: 
    F_B_tmean = Sf_B_tmean + Mf_B_tmean;
    P_B_tmean = Sp_B_tmean + Mp_B_tmean + Lp_B_tmean;
    D_B_tmean = Sd_B_tmean + Md_B_tmean + Ld_B_tmean;
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-31");
    time = start_date:end_date;
   
    
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10)
    t = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
    
    % plot all size:
    ax = nexttile;
    hold on
    for i = 1:length(var)
        plot(ax, time, eval([var{i} '_B_tmean((end-365):end)']))
    end
    set(gca, 'YLim', [10^(-6) 2*10^2])
    hold off 
    ax.YScale = "log";
    % ax.XLim   = [0, 366*1.45];
    L = legend(var, 'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("All sizes")
    
    % plot functional groups: 
    nexttile 
    axes_formating(gcf, "defaultAxesColorOrder", cm4)
    semilogy(time, F_B_tmean((end-365):end), ...
             time, P_B_tmean(end-365:end), ...
             time, D_B_tmean(end-365:end), ...
             time, BE_B_tmean(end-365:end))
    set(gca, 'YLim', [10^(-6) 2*10^2])
    L = legend('Forage', 'Pelagic', 'Demersal', 'Benthos', ...
            'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("Functional groups")
    
    ylabel(t, "Biomass gWW m-3")
    xlabel(t, "time days")
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], 'Time_Means'}, Interpreter = 'none')
    
    save_graph(gcf, "png", [dir_output 'Time_Means'], 16, 12)
    
    %% ------------------------------------------------------------------------
    %                Zooplankton Biomass TIME SERIES 
    % -------------------------------------------------------------------------
    n= n+1;
    %! Load data offline : 
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'])
    
    %! Load data online : 
    load([dir_input 'Time_Depth_Means_forcing' '.mat'])
    load([dir_input 'Time_Means_forcing'       '.mat'])
    load([dir_input 'Depth_Means_forcing'      '.mat'])
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-31");
    % time = start_date:end_date;
    % indexes: 
    idx_bio = [1, 3]; 
    idx_rate = [2,4,5];
    
    % ---------------------- plot zooplankton biomass -------------------------
    % Plots average over time: 
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm3);
    t = tiledlayout(3, 1, "TileSpacing","compact","Padding","compact");
    
    % Offline zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        % Make offline data same length as the online :
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, val)
    end 
    hold off
    title('Offline')
    legend(var_COBALT{idx_bio}, Interpreter = 'none', Location = "best")
    
    % Online zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        plot(time_days, eval([var_COBALT{i} '_tmean']))
    end 
    hold off
    title("Online")
    
    % difference: 
    nexttile
    hold on 
    for i = idx_bio
            val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
            plot(time_days, eval([var_COBALT{i} '_tmean']) - val)
    end 
    plot([time_days(1) time_days(end)], [0 0], 'k:', 'LineWidth', 1)
    hold off
    title("Difference")
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], 'Zooplankton biomass COBALT ONLINE'}, ...
        Interpreter = 'none')
    xlabel(t, "Time (days)")
    ylabel(t, "Biomass (mol N kg-1)")
    save_graph(gcf, "png", [dir_output 'Comparison_online_offline_zooplanktons_Biomass'], 16, 12)
    
    
    % ---------------- plot zooplankton rate and detritus flux ----------------
    % Plots average over time: 
    n=n+1;
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10);
    t = tiledlayout(3, 1, "TileSpacing","compact","Padding","compact");
    
    % Offline zooplankton Biomass
    nexttile
    hold on 
    for i = idx_rate
        % Make offline data same length as the online :
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, val)
    end 
    hold off
    title('Offline')
    legend(var_COBALT{idx_rate}, Interpreter = 'none', Location = "best")
    
    % Online zooplankton Biomass
    nexttile
    hold on 
    for i = idx_rate
        plot(time_days, eval([var_COBALT{i} '_tmean']))
    end 
    hold off
    title("Online")
    
    % difference: 
    nexttile
    hold on 
    for i = idx_rate
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, eval([var_COBALT{i} '_tmean']) - val)
    end 
    plot([time_days(1) time_days(end)], [0 0], 'k:', 'LineWidth', 1)
    hold off
    title("Difference")
    
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], ...
        'Zooplankton mortality rates and det flux COBALT ONLINE'}, ...
        Interpreter = 'none')
    xlabel(t, "Time (days)")
    ylabel(t, "rates (mol N m-2 s-1) and (g WW m-3 d-1)")
    
    save_graph(gcf, "png", [dir_output 'Comparison_online_offline_zooplanktons'], 16, 12)
    
    %% ------------------------------------------------------------------------
    %                         Zooplankton Biomass
    % -------------------------------------------------------------------------
    n= n+1;
    %! Load data offline : 
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'])
    
    %! Load data online : 
    load([dir_input 'Time_Depth_Means_forcing' '.mat'])
    load([dir_input 'Time_Means_forcing'       '.mat'])
    load([dir_input 'Depth_Means_forcing'      '.mat'])
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-31");
    % time = start_date:end_date;
    % indexes: 
    idx_bio = [1, 3]; 
    idx_rate = [2,4,5];
    
    % ---------------------- plot zooplankton biomass -------------------------
    % Plots average over time: 
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10);
    t = tiledlayout(3, 1, "TileSpacing","compact","Padding","compact");
    
    % Offline zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        % Make offline data same length as the online :
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, val)
    end 
    hold off
    title('Offline')
    legend(var_COBALT{idx_bio}, Interpreter = 'none', Location = "best")
    
    % Online zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        plot(time_days, eval([var_COBALT{i} '_tmean']))
    end 
    hold off
    title("Online")
    
    % difference: 
    nexttile
    hold on 
    for i = idx_bio
            val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
            plot(time_days, eval([var_COBALT{i} '_tmean']) - val)
    end 
    plot([time_days(1) time_days(end)], [0 0], 'k:', 'LineWidth', 1)
    hold off
    title("Difference")
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], 'Zooplankton biomass COBALT ONLINE'}, ...
        Interpreter = 'none')
    xlabel(t, "Time (days)")
    ylabel(t, "Biomass (mol N kg-1)")
    save_graph(gcf, "png", [dir_output 'Comparison_online_offline_zooplanktons_Biomass'], 16, 12)
    
    %% 
    % ---------------- plot zooplankton rate and detritus flux ----------------
    % Plots average over time: 
    n=n+1;
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10);
    t = tiledlayout(3, 1, "TileSpacing","compact","Padding","compact");
    
    % Offline zooplankton Biomass
    nexttile
    hold on 
    for i = idx_rate
        % Make offline data same length as the online :
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, val)
    end 
    hold off
    title('Offline')
    legend(var_COBALT{idx_rate}, Interpreter = 'none', Location = "best")
    
    % Online zooplankton Biomass
    nexttile
    hold on 
    for i = idx_rate
        plot(time_days, eval([var_COBALT{i} '_tmean']))
    end 
    hold off
    title("Online")
    
    % difference: 
    nexttile
    hold on 
    for i = idx_rate
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, eval([var_COBALT{i} '_tmean']) - val)
    end 
    plot([time_days(1) time_days(end)], [0 0], 'k:', 'LineWidth', 1)
    hold off
    title("Difference")
    
    title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], ...
        'Zooplankton mortality rates and det flux COBALT ONLINE'}, ...
        Interpreter = 'none')
    xlabel(t, "Time (days)")
    ylabel(t, "rates (mol N m-2 s-1) and (g WW m-3 d-1)")
    
    save_graph(gcf, "png", [dir_output 'Comparison_online_offline_zooplanktons'], 16, 12)
    
    %% Plot the First time step for meso zooplankton 
    n = n+1;
    figure(n)
    axes_formating()
    idx = [1, 3]; 
    hold on 
    for i = 1:length(idx)
        plot(eval([var_COBALT{idx(i)} '_spacemean(1,:)' ]), -depth)
    end 
    title({[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], ...
        'First time step mesozooplankton'}, Interpreter = 'none')
    hold off
    ylabel('Depth (layer ID)')
    xlabel('Biomass (gww m-3)')
    save_graph(gcf, "png", [dir_output 'First_time_step_zooplankton'], 16, 12)
    
    
    %% ------------------------------------------------------------------------
    %                         Diagnostics FISH 
    % -------------------------------------------------------------------------
    
    %% plot average over time:-------------------------------------------------
    load([dir_input 'Time_Depth_Means_Diagnostics' '.mat'])
    load([dir_input 'Time_Means_Diagnostics' '.mat'])
    load([dir_input 'Depth_Means_Diagnostics' '.mat'])
    
    dimension_average = {'_tmean', '_zmean', '_spacemean'};
    dimensions = {'time_days', 'depth'};
    var = {'SF', 'SP', 'SD', 'MF', 'MP', 'MD', 'LP', 'LD'}; % , 'BE'
    diag = {'_met', '_enc_Mz', '_enc_Lz', '_enc_f', '_enc_p', '_enc_d', '_enc_BE', ...
            '_cons_Mz', '_cons_Lz', '_cons_f', '_cons_p', '_cons_d', '_cons_BE', '_cons_tot', ...
            '_f_tot', '_mu_p', '_E_A', '_prod', '_Fout', '_rho', '_yield'};
    
    %!! Calcul mean per functional group: -------------------------------------
    for j = 1:length(dimension_average)
        for i = 1:length(diag)
            eval(['F' diag{i} dimension_average{j} ' = SF' diag{i} dimension_average{j} ' + MF' diag{i} dimension_average{j} ';']);
            eval(['P' diag{i} dimension_average{j} ' = SP' diag{i} dimension_average{j} ' + MP' diag{i} dimension_average{j} ' + LP' diag{i} dimension_average{j} ';']);
            eval(['D' diag{i} dimension_average{j} ' = SD' diag{i} dimension_average{j} ' + MD' diag{i} dimension_average{j} ' + LD' diag{i} dimension_average{j} ';']);
        end 
    end
    
    
    % ! Plot per group of diagnostic variable: --------------------------------
    grp(1).name = 'Encounter rates'     ; grp(1).idx = 2:7;        grp(1).panel_grid = [2, 3];
    grp(2).name = 'Consumption rates'   ; grp(2).idx = 8:14;       grp(2).panel_grid = [2, 4];
    grp(3).name = 'Physiological rates' ; grp(3).idx = [1, 15:21]; grp(3).panel_grid = [2, 4];
    grp(1).leg_loc = 'eastoutside'; grp(2).leg_loc = 'best'; grp(3).leg_loc = 'eastoutside'; 
    n=n+1;
    plotwidth = [12, 27];
    
    % All sizes: --------------------------------------------------------------
    for d = 1:length(dimension_average)-1
        for i = 1:3
            n = n+1;
            figure(n)
            axes_formating(gcf, "defaultAxesColorOrder", cm10)
        
            t = tiledlayout(grp(i).panel_grid(1), grp(i).panel_grid(2), ...
                "TileSpacing", "compact", "Padding", "compact");
            
            % plot 1: 'Encounter rates': -------------------------------------- 
            % loop over diagnostic for each group:
            for j = 1:length(grp(i).idx)
                ti = nexttile;
                hold on
                % Loop over all fish for each diagnostic: 
                for v = 1:length(var) 
                    if d == 1
                        plot(ti, eval(dimensions{d}), eval([var{v} diag{grp(i).idx(j)} dimension_average{d}]))
                    elseif d == 2
                        plot(ti, eval([var{v} diag{grp(i).idx(j)} dimension_average{d} '(end, :)']), -eval(dimensions{d}))
                    end 
                end 
                hold off 
                title(ti, diag{grp(i).idx(j)}(2:end), Interpreter='none')
            end
            %! place legend
            if i == 2
                L = legend(var, 'Location', grp(i).leg_loc, ...
                    'Position', [0.797169564618937 0.07854110148341 0.113009922822492 0.303308823529412]);
            else 
                L = legend(var, 'Location', grp(i).leg_loc);
            end 
            title(L,'All Sizes');
            title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], ...
                       ['Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_all_size']}, ...
                       Interpreter='none')
            ylabel(t, 'physiological rates')
            if dimension_average{d} == "_zmean"
                xlabel(t, 'depth (layer ID)')
            elseif dimension_average{d} == "_tmean"
                xlabel(t, 'time (days)')
            end 
            save_graph(gcf, "png", [dir_output 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_all_size'], 27, plotwidth(d))
        end 
    end
    
    %% Functional groups: ------------------------------------------------------
    var = {'F', 'P', 'D'};
    
    for d = 1:length(dimension_average)-1
        for i = 1:3
            n = n+1;
            figure(n)
            axes_formating(gcf, "defaultAxesColorOrder", cm10)
        
            t = tiledlayout(grp(i).panel_grid(1), grp(i).panel_grid(2), ...
                "TileSpacing", "compact", "Padding", "compact");
            
            % plot 1: 'Encounter rates': --------------------------------------      
            % loop over diagnostic for each group:
            for j = 1:length(grp(i).idx)
                ti = nexttile;
                hold on
                % Loop over all fish for each diagnostic: 
                for v = 1:length(var) 
                    if d == 1
                        plot(ti, eval(dimensions{d}), eval([var{v} diag{grp(i).idx(j)} dimension_average{d}]))
                    elseif d == 2
                        plot(ti, eval([var{v} diag{grp(i).idx(j)} dimension_average{d} '(end, :)']), -eval(dimensions{d}))
                    end 
                end 
                hold off 
                title(ti, diag{grp(i).idx(j)}(2:end), Interpreter='none')
            end
            %! place legend
            if i == 2
                L = legend(var, 'Location', grp(i).leg_loc, ...
                    'Position',[0.797169564618937 0.07854110148341 0.113009922822492 0.303308823529412]);
            else 
                L = legend(var, 'Location', grp(i).leg_loc);
            end 
            title(L,'All Sizes');
            title(t, {[loc '_'  coupling '_' name_yr '_yr_' num2str(yr)], ...
                ['Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_Functional_grp']}, ...
                Interpreter='none')
            ylabel(t, 'physiological rates')
            if dimension_average{d} == "_zmean"
                xlabel(t, 'depth (layer ID)')
            elseif dimension_average{d} == "_tmean"
                xlabel(t, 'time (days)')
            end 
            save_graph(gcf, "png", [dir_output 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_Functional_grp'], 16, 12)
        end 
    end
    
    
    %% ------------------------------------------------------------------------
    %                          Figure poster 
    %                       Zooplankton Biomass
    % -------------------------------------------------------------------------
    n= n+1;
    %! Load data offline : 
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Depth_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Time_Means_forcing' '.mat'])
    load([dir_input_offline 'COBALT_offline_' loc '_Depth_Means_forcing' '.mat'])
    
    %! Load data online : 
    load([dir_input 'Time_Depth_Means_forcing' '.mat'])
    load([dir_input 'Time_Means_forcing'       '.mat'])
    load([dir_input 'Depth_Means_forcing'      '.mat'])
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-31");
    % time = start_date:end_date;
    % indexes: 
    idx_bio = [1, 3]; 
    idx_rate = [2,4,5];
    
    % ---------------------- plot zooplankton biomass -------------------------
    % Plots average over time: 
    figure(n)
    axes_formating(gcf, "defaultAxesColorOrder", cm10);
    t = tiledlayout(5, 1, "TileSpacing","compact","Padding","compact");
    
    % Offline zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        % Make offline data same length as the online :
        val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
        plot(time_days, val)
    end 
    hold off
    title('Mesozooplankton COBALT Offline')
    
    % Online zooplankton Biomass
    nexttile
    hold on 
    for i = idx_bio
        plot(time_days, eval([var_COBALT{i} '_tmean']))
    end 
    hold off
    title('Mesozooplankton COBALT-FEISTY Oline')
    L = legend('Small','Large', Interpreter = 'none', Location = "eastoutside");
    L.Color = 'none'; L.Box = 'off';
    title(L, 'Mesozooplankton')
    
    % difference: 
    nexttile
    hold on 
    for i = idx_bio
            val = repmat(eval([var_COBALT{i} '_offline_tmean']), 1, yr);
            plot(time_days, eval([var_COBALT{i} '_tmean']) - val)
    end 
    plot([time_days(1) time_days(end)], [0 0], 'k:', 'LineWidth', 1)
    hold off
    title("Mesozooplankton difference online-offline")
    xlabel(t, "Time (days)")
    ylabel(t, "Biomass (mol N kg-1)")
    
    
    
    % plot average over time:-------------------------------------------------
    n = n+1;
    %!! functional group: 
    F_B_tmean = Sf_B_tmean + Mf_B_tmean;
    P_B_tmean = Sp_B_tmean + Mp_B_tmean + Lp_B_tmean;
    D_B_tmean = Sd_B_tmean + Md_B_tmean + Ld_B_tmean;
    
    start_date = datetime("2004-01-01");
    end_date   = datetime("2004-12-31");
    % time = start_date:end_date;
    
    axes_formating(gcf, "defaultAxesColorOrder", cm10)
    
    % plot all size: 
    var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; 
    ax = nexttile;
    hold on
    for i = 1:length(var)
        plot(ax, time_days, eval([var{i} '_B_tmean']))
    end
    set(gca, 'YLim', [10^(-6) 2*10^2])
    hold off 
    ax.YScale = "log";
    % ax.XLim   = [0, 366*1.45];
    L = legend(var, 'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("Fish online all sizes")
    
    % plot functional groups: 
    nexttile 
    axes_formating(gcf, "defaultAxesColorOrder", cm4)
    semilogy(time_days, F_B_tmean, time_days, P_B_tmean, time_days, D_B_tmean, time_days, BE_B_tmean)
    set(gca, 'YLim', [10^(-6) 2*10^2])
    L = legend('Forage', 'Pelagic', 'Demersal', 'Benthos', ...
            'Location', 'eastoutside');
    L.Color = 'none'; L.Box = 'off';
    title("Fish online functional groups")
    
    ylabel(t, "Biomass gWW m-3 (fish) and mol N kg-1 (zooplankton)")
    xlabel(t, "time days")
    
    save_graph(gcf, "png", [dir_output 'Print_Poster'], 19, 20)
    
    %% Comparison Online Offline Fish biomass 

    %! get directory containing output
    exp = 'baseparam';
    coupling = 'offline';
    dir_input_offline_fish =['../output/Matlab_Average/', coupling, '/' loc, '/', exp, '/', ...
                            'FEISTY_' coupling '_' loc '_' exp '_'];
    var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; % 
    
    %! Load data offline: 
    load([dir_input_offline_fish 'Time_Means' '.mat']);

    % Sum per functional group: 
    F_tmean_offline  = Sf_tmean + Mf_tmean;
    P_tmean_offline  = Sp_tmean + Mp_tmean + Lp_tmean;
    D_tmean_offline  = Sd_tmean + Md_tmean + Ld_tmean;

    % transform offline data to match online time series : So far offfline
    % is simply one unique run (consider spining the offline COBALT
    % simulation): 
    for i = 1:length(var)
         eval([var{i} '_tmean_offline = repmat(' var{i} '_tmean, 1, yr);']);
    end
    F_tmean_offline  = repmat(F_tmean_offline, 1, yr);
    P_tmean_offline  = repmat(P_tmean_offline, 1, yr);
    D_tmean_offline  = repmat(D_tmean_offline, 1, yr);
    time = 1:(yr*365);

    %! plot Offline Simulation: ------------------------------------------- 
    figure(1)
    axes_formating(gcf)
    t = tiledlayout(3, 2, "TileSpacing", "compact", "Padding", "compact");
    
    % offline all size: 
    t1 = nexttile;
    axes_formating(t1, "defaultAxesColorOrder", cm10)
    set(t1, 'YScale', 'log')
    title('All sizes')
    hold on 
    for i = 1:length(var)-1
        plot(eval([var{i} '_tmean_offline']))
    end 
    hold off

    % offline functional group
    t2 = nexttile;
    axes_formating(t2, "defaultAxesColorOrder", cm4)
    set(t2, 'YScale', 'log')
    title('Functional Grps')
    hold on
    plot(time, F_tmean_offline, ...
         time, P_tmean_offline, ...
         time, D_tmean_offline)
    plot([1, length(time)], [80 80])
    hold off

    %! plot Online Simulation: --------------------------------------------
    %! Load data online : 
    load([dir_input 'Time_Depth_Means_Tracers' '.mat'])
    load([dir_input 'Time_Means_Tracers' '.mat'])
    load([dir_input 'Depth_Means_Tracers' '.mat'])

    %!! functional group: 
    F_B_tmean = Sf_B_tmean + Mf_B_tmean;
    P_B_tmean = Sp_B_tmean + Mp_B_tmean + Lp_B_tmean;
    D_B_tmean = Sd_B_tmean + Md_B_tmean + Ld_B_tmean;
    
   
    t3 = nexttile; 
    axes_formating(gca, "defaultAxesColorOrder", cm10)
    set(t3, 'YScale', 'log')

    % plot all size: 
    hold on
    for i = 1:length(var)
        plot(time_days, eval([var{i} '_B_tmean']))
    end
    set(gca, 'YLim', [10^(-6) 2*10^2])
    hold off 
    L = legend(var, 'Location', 'eastoutside'); L.Color = 'none'; L.Box = 'off';
    title("Online")
    
    % plot functional groups: 
    t4 = nexttile; 
    axes_formating(t4, "defaultAxesColorOrder", cm4)
    plot(time_days, F_B_tmean, ...
            time_days, P_B_tmean, ...
            time_days, D_B_tmean, ...
            time_days, BE_B_tmean)
    L = legend('Forage', 'Pelagic', 'Demersal', 'Benthos', ...
            'Location', 'eastoutside'); L.Color = 'none'; L.Box = 'off';
        set(gca, 'YScale', 'log', 'YLim', [10^(-6) 2*10^2])
    title("Online")

    % plot difference: ----------------------------------------------------
    t5 = nexttile; 
    axes_formating(t5, "defaultAxesColorOrder", cm10)
    title("Online")
    
    % plot all size: 
    hold on
    for i = 1:length(var)-1
        plot(time_days, eval([var{i} '_B_tmean - ' var{i} '_tmean_offline']))
    end
    hold off 

    % plot functional groups: 
    t6 = nexttile; 
    title("Difference")
    axes_formating(t6, "defaultAxesColorOrder", cm4)
    set(gca, 'YScale', 'linear')
    plot(time_days, F_B_tmean - F_tmean_offline, ...
         time_days, P_B_tmean - P_tmean_offline, ...
         time_days, D_B_tmean - D_tmean_offline)

end
