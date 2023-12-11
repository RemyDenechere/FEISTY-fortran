% FEISTY output at all locations
% clear all
% close all

%% Root directory: 
param.Rockfish =  true; % false; % 
param.newColor = false; 

param = param_setup(param);

%! get directory containing output
dir = '../output/'; 

%% Small Pelagic SP
ncid = netcdf.open([dir 'Sp' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

[ni,nt] = size(Sp);

SP.bio = Sp;
clear Sp 
time = 1:nt;

%% SF
ncid = netcdf.open([dir 'Sf' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

SF.bio = Sf;
clear Sf

% SD
ncid = netcdf.open([dir 'Sd' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

SD.bio = Sd;
clear Sd

% MP
ncid = netcdf.open([dir 'Mp' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

MP.bio = Mp;
clear Mp

% MF
ncid = netcdf.open([dir 'Mf' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

MF.bio = Mf;
clear Mf

% MD
ncid = netcdf.open([dir 'Md' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

MD.bio = Md;
clear Md

% LP
ncid = netcdf.open([dir 'Lp' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

LP.bio = Lp;
clear Lp

% LD
ncid = netcdf.open([dir 'Ld' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

LD.bio = Ld;
clear Ld

% Benthic material
ncid = netcdf.open([dir 'BE' '_bio.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

Bent.bio = BE;
clear BE

%% MZ loss
ncid = netcdf.open([dir 'dZm.nc'],'NC_NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);
for i = 1:nvars
    varname = netcdf.inqVar(ncid, i-1);
    eval([ varname ' = netcdf.getVar(ncid,i-1);']);
    eval([ varname '(' varname ' == 99999) = NaN;']);
end
netcdf.close(ncid);

MZ.frac = dZm;
clear dZm

%% Take means for visualization

%Time
sp_tmean = nanmean(SP.bio, 1);
sf_tmean = nanmean(SF.bio, 1);
sd_tmean = nanmean(SD.bio, 1);
mp_tmean = nanmean(MP.bio, 1);
mf_tmean = nanmean(MF.bio, 1);
md_tmean = nanmean(MD.bio, 1);
lp_tmean = nanmean(LP.bio, 1);
ld_tmean = nanmean(LD.bio, 1);
b_tmean  = nanmean(Bent.bio,1);
mz_tmfrac =nanmean(MZ.frac,1);

%% Space

sp_sbio = nanmean(SP.bio,2);
sf_sbio = nanmean(SF.bio,2);
sd_sbio = nanmean(SD.bio,2);
mp_sbio = nanmean(MP.bio,2);
mf_sbio = nanmean(MF.bio,2);
md_sbio = nanmean(MD.bio,2);
lp_sbio = nanmean(LP.bio,2);
ld_sbio = nanmean(LD.bio,2);
b_sbio  = nanmean(Bent.bio,2);
mz_smfrac= nanmean(MZ.frac,2);

%% Total times overcon happens
MZ.over = nan*ones(size(MZ.frac));
MZ.over(MZ.frac > 1) = ones;
MZ.over(MZ.frac <= 1) = zeros;
% Time
mz_ttf=nansum(MZ.over,1);
% Space
mz_stf=nansum(MZ.over,2);

%% Annual means
nyr = nt/12;
st=1:12:length(time);
en=12:12:length(time);
mz_mtf = nan*ones(ni,nyr);

for n=1:length(st)
    % total overcon
    mz_mtf(:,n)=nansum(MZ.over(:,st(n):en(n)),2);

    % mean biomass
    sp_abio(:,n)=nanmean(SP.bio(:,st(n):en(n)),2);
    sf_abio(:,n)=nanmean(SF.bio(:,st(n):en(n)),2);
    sd_abio(:,n)=nanmean(SD.bio(:,st(n):en(n)),2);
    mp_abio(:,n)=nanmean(MP.bio(:,st(n):en(n)),2);
    mf_abio(:,n)=nanmean(MF.bio(:,st(n):en(n)),2);
    md_abio(:,n)=nanmean(MD.bio(:,st(n):en(n)),2);
    lp_abio(:,n)=nanmean(LP.bio(:,st(n):en(n)),2);
    ld_abio(:,n)=nanmean(LD.bio(:,st(n):en(n)),2);
    b_abio(:,n)=nanmean(Bent.bio(:,st(n):en(n)),2);



%     % Save Oct of each year for initializing forecast runs
%     Sml_f.bio = nanmean(SF.bio(:,en(n)-2),2);
%     Sml_p.bio = nanmean(SP.bio(:,en(n)-2),2);
%     Sml_d.bio = nanmean(SD.bio(:,en(n)-2),2);
%     Med_f.bio = nanmean(MF.bio(:,en(n)-2),2);
%     Med_p.bio = nanmean(MP.bio(:,en(n)-2),2);
%     Med_d.bio = nanmean(MD.bio(:,en(n)-2),2);
%     Lrg_p.bio = nanmean(LP.bio(:,en(n)-2),2);
%     Lrg_d.bio = nanmean(LD.bio(:,en(n)-2),2);
%     BENT.bio  = nanmean(Bent.bio(:,en(n)-2),2);
% 
%     save(['../output/' 'Last_mo_FOSI_' num2str(1947+n) '_' harv cfile '.mat'],...
%         'Sml_f','Sml_p','Sml_d','Med_f','Med_p','Med_d','Lrg_p','Lrg_d',...
%         'BENT')

end

%%
save_dir = [dir, 'Matlab_Average/']; 
if ~exist(save_dir)
    mkdir(save_dir)
end

save([save_dir 'Time_Means_FOSI' '.mat'],'time',...
    'sf_tmean','sp_tmean','sd_tmean',...
    'mf_tmean','mp_tmean','md_tmean',...
    'lp_tmean','ld_tmean','b_tmean', 'mz_ttf')

save([save_dir 'Space_Means_FOSI' '.mat'],'time',...
    'sf_sbio','sp_sbio','sd_sbio',...
    'mf_sbio','mp_sbio','md_sbio',...
    'lp_sbio','ld_sbio','b_sbio', ...
    'mz_smfrac', 'mz_stf')

save([save_dir 'Annual_Means_FOSI' '.mat'],'time',...
    'sf_abio','sp_abio','sd_abio',...
    'mf_abio','mp_abio','md_abio',...
    'lp_abio','ld_abio','b_abio', 'mz_mtf')

% STOPPED HERE 

%%
% mo = time/12;
% figure
% plot(mo,log10(lp_tmean),'b'); hold on;
% plot(mo,log10(mf_tmean),'r'); hold on;
% plot(mo,log10(ld_tmean),'k'); hold on;
% 
% [nid,nt] = size(MZ.frac);
% figure
% plot(mo,mz_ttf/nid,'b'); hold on; %~7.5%
