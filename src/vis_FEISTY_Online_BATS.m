%% Analysis FEISTY Coupled 
clear all
close all 
addpath('../../COBALT_output/COBALT_FEISTY/')

%! get directory containing output
dir_outpur = '../output/Matlab_Average/';
save_dir = '../Fig/';
exp = 'COBALT_online_BATS_';
Spinup = {''}; 
var = {'Sf', 'Sp', 'Sd', 'Mf', 'Mp', 'Md', 'Lp', 'Ld', 'BE'}; 
functional_group = {'Forage', 'Pelagic', 'Demersal'};

%% get tracers: 
load(['../output/Matlab_Average/' exp 'Time_Depth_Means_Tracers' '.mat'])
load(['../output/Matlab_Average/' exp 'Time_Means_Tracers' '.mat'])
load(['../output/Matlab_Average/' exp 'Depth_Means_Tracers' '.mat'])

%% plot average tracer over depth: -----------------------------------------------
%!! functional group: 
F_B_zmean = Sf_B_zmean + Mf_B_zmean;
P_B_zmean = Sp_B_zmean + Mp_B_zmean + Lp_B_zmean;
D_B_zmean = Sd_B_zmean + Md_B_zmean + Ld_B_zmean;

figure(1)
axes_formating()
t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");

nexttile
hold on
for i = 1:length(var)
    plot(eval([var{i} '_B_zmean']), -depth)
end
hold off 
legend(var, 'Location', 'north')
title("All sizes")

nexttile 
plot(F_B_zmean, -depth, P_B_zmean, -depth, D_B_zmean, -depth)
legend('Forage', 'Pelagic', 'Demersal', 'Location', 'southeast')
title("Functional groups")

% tiled labels: 
xlabel(t, "Biomass gWW m-3")
ylabel(t, "Layers")
title(t, [exp 'Depth_Means_Time_Series'], Interpreter = 'none')

save_graph(gcf, "png", [save_dir exp 'Depth_Means_Time_Series'], 16, 12)
%% plot average over time:-------------------------------------------------
%!! functional group: 
F_B_tmean = Sf_B_tmean + Mf_B_tmean;
P_B_tmean = Sp_B_tmean + Mp_B_tmean + Lp_B_tmean;
D_B_tmean = Sd_B_tmean + Md_B_tmean + Ld_B_tmean;

figure(2)
axes_formating()
t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");

nexttile
hold on
for i = 1:length(var)
    plot(time, eval([var{i} '_B_tmean']))
end
hold off 
legend(var, 'Location', 'best')
title("All sizes")

nexttile 
hold on 
plot(time, F_B_tmean, time, P_B_tmean, time, D_B_tmean, time, BE_B_tmean)
hold off 
legend('Forage', 'Pelagic', 'Demersal', 'Benthos', 'Location', 'best')
title("Functional groups")

ylabel(t, "Biomass gWW m-3")
xlabel(t, "time days")
title(t, [exp 'Time_Means_Time_Series'], Interpreter = 'none')

save_graph(gcf, "png", [save_dir exp 'Time_Means_Time_Series'], 16, 12)

%% plot over time and depth:-----------------------------------------------
%!! functional group: 
var_group = {'F', 'P', 'D'};
F_B_spacemean = Sf_B_spacemean + Mf_B_spacemean;
P_B_spacemean = Sp_B_spacemean + Mp_B_spacemean + Lp_B_spacemean;
D_B_spacemean = Sd_B_spacemean + Md_B_spacemean + Ld_B_spacemean;

%! Plot each size:--------------------------------------------------------- 
figure(3)
axes_formating()
t = tiledlayout(3, 3, "TileSpacing", "compact", "Padding", "compact");
for i = 1:length(var)
    ti(i) = nexttile;
    surface(time, -depth, transpose(eval([var{i} '_B_spacemean'])), ...
        'EdgeColor', 'none')
    caxis([-8*10^(-10), 10^(-9)])
    title(var{i})
end
colormap ocean
cbr = colorbar(ti(end), 'orientation','vertical');
cbr.Layout.Tile = 'east'; 
title(cbr, {'Biomass', 'gWW m-3'}); 
xlabel(t, 'Time (days)')
ylabel(t, 'Depth (layers)')
title(t, [exp 'Time_depth_Time_series'], Interpreter = 'none'  )

save_graph(gcf, "png", [save_dir exp 'Time_depth_Time_series_all_size'], 16, 12)

% ! Plot each functional group: --------------------------------------------
figure(4)
axes_formating()
t = tiledlayout(1, 3, "TileSpacing", "compact", "Padding", "compact");
for i = 1:3
    ti = nexttile; 
    surface(time, -depth, transpose(eval([var_group{i} '_B_spacemean'])), ...
        'EdgeColor', 'none')
    caxis([-8*10^(-10), 10^(-9)])
    % set(gca,'CameraPosition', [-1965.326178421259,-536.7230011599994,8.072870736606727e-9])
    title(functional_group{i});
end
colormap ocean
cbr = colorbar(ti(end), 'orientation','vertical');
cbr.Layout.Tile = 'east'; 
title(cbr, {'Biomass', 'gWW m-3'}); 

ylabel(t, "Biomass gWW m-3")
xlabel(t, "time")
title(t, [exp 'Time_depth_Time_series'], Interpreter = 'none'  )

save_graph(gcf, "png", [save_dir exp 'Time_depth_Time_series_funct_grp'], 16, 12)

%% plot average over time:-------------------------------------------------
load(['../output/Matlab_Average/' exp 'Time_Depth_Means_Diagnostics' '.mat'])
load(['../output/Matlab_Average/' exp 'Time_Means_Diagnostics' '.mat'])
load(['../output/Matlab_Average/' exp 'Depth_Means_Diagnostics' '.mat'])

dimension_average = {'_tmean', '_zmean', '_spacemean'};
dimensions = {'time', 'depth'};
var = {'SF', 'SP', 'SD', 'MF', 'MP', 'MD', 'LP', 'LD'}; % , 'BE'
diag = {'_met', '_enc_Mz', '_enc_Lz', '_enc_f', '_enc_p', '_enc_d', '_enc_BE', ...
        '_cons_Mz', '_cons_Lz', '_cons_f', '_cons_p', '_cons_d', '_cons_BE', '_cons_tot', ...
        '_f_tot', '_mu_p', '_E_A', '_prod', '_Fout', '_rho', '_yield'};

%!! Calcul mean per functional group:
for j = 1:length(dimension_average)
    for i = 1:length(diag)
        eval(['F' diag{i} dimension_average{j} ' = SF' diag{i} dimension_average{j} ' + MF' diag{i} dimension_average{j} ';']);
        eval(['P' diag{i} dimension_average{j} ' = SP' diag{i} dimension_average{j} ' + MP' diag{i} dimension_average{j} ' + LP' diag{i} dimension_average{j} ';']);
        eval(['D' diag{i} dimension_average{j} ' = SD' diag{i} dimension_average{j} ' + MD' diag{i} dimension_average{j} ' + LD' diag{i} dimension_average{j} ';']);
    end 
end


% ! Plot per group of diagnostic variable
close all 
grp(1).name = 'Encounter rates'     ; grp(1).idx = 2:7;        grp(1).panel_grid = [2, 3];
grp(2).name = 'Consumption rates'   ; grp(2).idx = 8:14;       grp(2).panel_grid = [2, 4];
grp(3).name = 'Physiological rates' ; grp(3).idx = [1, 15:21]; grp(3).panel_grid = [2, 4];
grp(1).leg_loc = 'eastoutside'; grp(2).leg_loc = 'best'; grp(3).leg_loc = 'eastoutside'; 

% All sizes: --------------------------------------------------------------
for d = 1:length(dimension_average)-1
    for i = 1:3
        figure()
        axes_formating()
    
        t = tiledlayout(grp(i).panel_grid(1), grp(i).panel_grid(2), ...
            "TileSpacing", "compact", "Padding", "compact");
        
        % plot 1: 'Encounter rates': ------------------------------------------       
        % loop over diagnostic for each group:
        for j = 1:length(grp(i).idx)
            ti = nexttile;
            hold on
            % Loop over all fish for each diagnostic: 
            for v = 1:length(var) 
                plot(ti, eval(dimensions{d}), eval([var{v} diag{grp(i).idx(j)} dimension_average{d}]))
            end 
            hold off 
            title(ti, diag{grp(i).idx(j)}(2:end), Interpreter='none')
        end
        %! place legend
        if i == 2
            L = legend(var, 'Location', grp(i).leg_loc, 'Position',[0.797169564618937 0.07854110148341 0.113009922822492 0.303308823529412]);
        else 
            L = legend(var, 'Location', grp(i).leg_loc);
        end 
        title(L,'All Sizes');
        title(t, [exp 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_all_size'], Interpreter='none')
        save_graph(gcf, "png", [save_dir exp 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_all_size'], 16, 12)
    end 
end

% Functional groups: ------------------------------------------------------
var = {'F', 'P', 'D'};

for d = 1:length(dimension_average)-1
    for i = 1:3
        figure()
        axes_formating()
    
        t = tiledlayout(grp(i).panel_grid(1), grp(i).panel_grid(2), ...
            "TileSpacing", "compact", "Padding", "compact");
        
        % plot 1: 'Encounter rates': ------------------------------------------       
        % loop over diagnostic for each group:
        for j = 1:length(grp(i).idx)
            ti = nexttile;
            hold on
            % Loop over all fish for each diagnostic: 
            for v = 1:length(var) 
                plot(ti, eval(dimensions{d}), eval([var{v} diag{grp(i).idx(j)} dimension_average{d}]))
            end 
            hold off 
            title(ti, diag{grp(i).idx(j)}(2:end), Interpreter='none')
        end
        %! place legend
        if i == 2
            L = legend(var, 'Location', grp(i).leg_loc, 'Position',[0.797169564618937 0.07854110148341 0.113009922822492 0.303308823529412]);
        else 
            L = legend(var, 'Location', grp(i).leg_loc);
        end 
        title(L,'All Sizes');
        title(t, [exp 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_Functional_grp'], Interpreter='none')
        save_graph(gcf, "png", [save_dir exp 'Diagnostic_' grp(i).name '_' dimension_average{d}(2:end) '_Functional_grp'], 16, 12)
    end 
end

%% 
