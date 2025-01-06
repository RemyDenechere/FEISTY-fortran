%
%
%                    VISUALISE Data from IC files for 
%                           Online Simulation
%
% -------------------------------------------------------------------------
addpath('../../Programing-Tutorials/Matlab/Matlab_functions/')
%% Initial condition COBALT 
ncid = netcdf.open('Z:/CEFI-regional-MOM6/exps/OM4.single_column.COBALT/INPUT/COBALT_2023_10_spinup_2003_subset.nc', 'NC_NOWRITE');
Time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Time'));
lath = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lath'));
lonh = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lonh'));
Layer = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Layer'));
netcdf.close(ncid);

%% Initial condition FEISTY 
ncid = netcdf.open('../../../CEFI-regional-MOM6/exps/OM4.single_column.COBALT/INPUT/FEISTY_2023_10_spinup_subset.nc', 'NC_NOWRITE'); 
Time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Time'));
lath = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lath'));
lonh = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lonh'));
Layer = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Layer'));
Sf_B = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Sf_B'));
BE_B = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'BE_B'));
netcdf.close(ncid);

%% check input detritus for offline simulation: 
ncid = netcdf.open("../../COBALT_output/COBALT_offline_forcing_files/20040101.ocean_feisty_forcing_offline_detritus.nc");
Pop_btm = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Pop_btm'));
netcdf.close(ncid);

%% visualise type 3 functional response: 

%! Parameter definition: --------------------------------------------------
p.gamma = 70;
p.q = 0.80;
p.n = 3/4; 
p.h = 20.0;
alph_sat = 1000;
k = [10, 50]; 
p.w(1) = 10.0^((log10(0.001)+log10(0.5))/2);
p.w(2) = 10.0^((log10(0.5)+log10(250.0))/2) ;
p.w(3) = 10.0^((log10(250.0)+log10(125000.0))/2);
p.R = logspace(-5, 1, 100); 
p.V = p.gamma * p.w .^ p.q;
p.Cmax = p.h * p.w .^ p.n;

%! Type II functional response: 
p.typeII = p.R .* p.V' ./ (p.R .* p.V' + p.Cmax'); % .* p.Cmax';
dIIdR_0 = (p.V' ./ p.Cmax') .* p.R ; % p.Cmax' .* 

%%                          Figure 1
axes_formating(groot)
figure(1)
t = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");
%! Type III functional response: 
k50 = 2;
k = 2; 
%!! formulation 1: 
p.typeIII_1 =  (p.R .* p.V').^(k) ./ ((p.R .* p.V').^(k) + p.Cmax' * k50);
%!! formulation 2: 
p.typeIII_2 =  (p.R .* p.V').^(k) ./ ((p.R .* p.V').^(k) + (p.Cmax' * k50).^(k));

ax1 = nexttile; 
plot(p.R, p.typeII)
hold on 
plot(p.R, dIIdR_0)
hold off 
title("Type II")

ax2 = nexttile; 
plot(p.R, p.typeIII_1)
title({'Type III - formulation 1', 'k50 = 2; k = 2'})

xlabel(t, "Resource concentration (g WW m-2)")
ylabel(t, "Feeding level")
set(ax1, "YLim", [0 1])

save_graph(gcf, "pdf", "../Fig/Fuct_resp_Type_II_III", 16, 8)

%%                          Figure 2
% Test values of k50 and k : ----------------------------------------------
figure(2)
cm10 = cmocean('tarn', 10); 
axes_formating(gcf, "AxesBackgroundColor", [0.95,0.99,1.00])
t = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");
xlabel(t, "Resource concentration (g WW m-2)")
ylabel(t, "Feeding level")


%! test K50: 
k50 = 1:2:10; 
k = 2;
% Calculation functional response: 
%!! formulation 1: 
p.typeIII_1 =  (p.R .* p.V(2)').^(k) ./ ((p.R .* p.V(2)').^(k) + p.Cmax(2)' * k50');
%!! formulation 2: 
p.typeIII_2 =  (p.R .* p.V(2)').^(k) ./ ((p.R .* p.V(2)').^(k) + (p.Cmax(2)' * k50').^(k));

% plot k50 test
ax1 = nexttile; 
plot(p.R, p.typeIII_1)
title({'Type III - formulation 1'})
L = legend(num2str(k50')); 
L.Box = 'off'; L.Color = 'none'; L.NumColumns = 2; L.Location = "southeast";
set(ax1, "YLim", [0 1])
title(L, 'k50'); 

ax2 = nexttile; 
plot(p.R, p.typeIII_2)
title({'Type III - formulation 2'})

%! test k: 
k50 = 5; 
k = 1:10;
% Calculation functional response: 
%!! formulation 1: 
p.typeIII_1 =  (p.R .* p.V(2)').^(k') ./ ((p.R .* p.V(2)').^(k') + p.Cmax(2)' * k50');
%!! formulation 2: 
p.typeIII_2 =  (p.R .* p.V(2)').^(k') ./ ((p.R .* p.V(2)').^(k') + (p.Cmax(2)' * k50').^(k'));
k50 = 20;
p.typeIII_2_2 =  (p.R .* p.V(2)').^(k') ./ ((p.R .* p.V(2)').^(k') + (p.Cmax(2)' * k50').^(k'));

% plot k50 test
ax1 = nexttile; 
plot(p.R, p.typeIII_1)
title({'Type III - formulation 1'})
L = legend(num2str(k')); 
L.Box = 'off'; L.Color = 'none'; L.NumColumns = 2; L.Location = "southeast";
title(L, 'k'); 

ax2 = nexttile; 
hold on 
p1 = plot(p.R, p.typeIII_2);
p2 = plot(p.R, p.typeIII_2_2, '--');
plot([0 k50*p.Cmax(2)/p.V(2)], [0.5 0.5], 'k:', ...
     [k50*p.Cmax(2)/p.V(2) k50*p.Cmax(2)/p.V(2)], [0 0.5], 'k:')
hold off
title({'Type III - formulation 2'})

% Legend: 
for i = 2:10
    p1(i).HandleVisibility = 'off'; 
    p2(i).HandleVisibility = 'off'; 
end
L = legend('5', '20'); 
L.Box = 'off'; L.Color = 'none'; L.Location = "southeast";
L.Position = [0.839955907721576 0.194390959626667 0.108134921202584 0.106845690515146];
title(L, 'k50'); 

% Create textbox
annotation(gcf, 'textbox',...
     [0.761582010582003 0.0998487140695912 0.0849788359788364 0.048411497730711],...
    'String', {'$\frac{k_{50} C_{max}}{V}$'},...
    'Interpreter', 'latex',  'EdgeColor', 'none', 'FontSize', 12)


xlabel(t, "Resource concentration (g ww m-3)")
ylabel(t, "Feeding level")
set(ax1, "YLim", [0 1])

save_graph(gcf, "pdf", "../Fig/Fuct_resp_Type_III_test_param", 16, 12)

%% Comparison between sum of power and power of a sum

S1 = (p.R/3).^4 + (p.R/3).^4 + (p.R/3).^4; 
S2 = (p.R).^4;
figure(3)
axes_formating(gcf, "AxesBackgroundColor", [0.95,0.99,1.00])
t = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");

nexttile
plot(p.R, S1, ...
     p.R, S2)
L = legend('Sum of power $\sum(R_i^n)_{i = 1}^{n}$' ,'Power of sum $(\sum(R_i)_{i = 1}^{n})^n$', "Interpretor");
L.Interpreter = "latex"; L.Box = "off"; L.Color = "none"; L.Location = "northwest"; 
title('Comparison summing type')
ylabel('Resource powered')

%!! Sum of the power:
nexttile 
k = 1:10;
S1 = (p.R/3).^(k') + (p.R/3).^(k') + (p.R/3).^(k'); 
S2 = (p.R).^(k');
k50 = 1;
p.typeIII_2 =  S1 .* (p.V(2)').^(k') ./ (S1 .* (p.V(2)').^(k') + (p.Cmax(2)' * k50).^(k'));
k50 = 5;
p.typeIII_2_2 =  S1 .* (p.V(2)').^(k') ./ (S1 .* (p.V(2)').^(k') + (p.Cmax(2) * k50).^(k'));

hold on 
p1 = plot(p.R, p.typeIII_2);
p2 = plot(p.R, p.typeIII_2_2, '--');
plot(p.R, p.typeIII_2(end,:), 'k');
plot(p.R, p.typeIII_2_2(end,:), 'k--');
hold off
title({'Sum of the power'})

% Legend: 
for i = 1:10
    p1(i).HandleVisibility = 'off'; 
    p2(i).HandleVisibility = 'off'; 
end
L = legend('5', '20'); 
L.Box = 'off'; L.Color = 'none'; L.Location = "southeast";
L.Position = [0.839955907721576 0.194390959626667 0.108134921202584 0.106845690515146];
title(L, 'k50'); 
ylabel('Feeding level')


%!! Sum of the power:
nexttile
k50 = 5;
p.typeIII_2 =  S2 .* (p.V(2)').^(k') ./ (S2 .* (p.V(2)').^(k') + (p.Cmax(2)' * k50').^(k'));
k50 = 20;
p.typeIII_2_2 =  S2 .* (p.V(2)').^(k') ./ (S2 .* (p.V(2)').^(k') + (p.Cmax(2)' * k50').^(k'));

hold on 
p1 = plot(p.R, p.typeIII_2);
p2 = plot(p.R, p.typeIII_2_2, '--');
hold off
title({'Power of the sum'})

% Legend: 
for i = 1:10
    p2(i).HandleVisibility = 'off'; 
end
L = legend(num2str(k')); 
L.Box = 'off'; L.Color = 'none'; L.Location = "southeast"; L.NumColumns = 2;
L.Position = [0.580861992188437 0.138025442572932 0.208333334279438 0.233686072065296];
title(L, 'k');

ylabel('Feeding level')
xlabel(t, 'Resource concentration (g ww m-3)')
save_graph(gcf, "jpeg", "../Fig/Comparison_summing_methods", 16, 12) 



