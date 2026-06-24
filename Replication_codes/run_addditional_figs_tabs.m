clc
close all
clear
% This code generates tables and figures in online appendix.
% Code author: Kohei Hasui (Aichi University)


%% Common Preamble:
oldFolder = cd; % memorize current folder
addpath Utils   % adding path to the folder Utils

indent_ = '   ';
description_ = ' is generated.';

% Common Figure Appearance Control:
iplot = 0;

MainFontSize = 14;
SubFontSize  = 15;
MainFontName = 'Times';
SubFontName  = 'Arial';

% FN: Font mame,  FS: Font size
[Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
[Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);

Positionf1 = [550 400 600 500];

%% TABLE: STICKINESS WEIGHTS
load Database_model fcdata GAMs OMGs V indfc_notzero GG ind_irf_sector StrengthG
load Database_estim sector_name sector_code

fc_tab   = fcdata;
GAMs_tab = GAMs;
OMGs_tab = OMGs;
V_tab    = V;

ind_fc_NaN = logical(1-indfc_notzero);

fc_tab(ind_fc_NaN)   = NaN;
GAMs_tab(ind_fc_NaN) = NaN;

filetitle = 'table_append_H2_sect_price_stickiness.tex';
tablabel  = 'tab:sectoral_stickiness1';
    table_stickiness_weight(sector_code,sector_name,OMGs_tab,GAMs_tab,fc_tab,V_tab,filetitle,tablabel)

disp([indent_, filetitle, description_])


%% TABLE: BEA code and NIPA line

database_name1 = 'Database_PCE_bridge.xlsx';

% Memorize current folder
cd DATA/PCE
data_flag_Weight = readmatrix(database_name1,'Sheet',2,'Range','A2:I269');
name_NIPA_BEA    =   readcell(database_name1,'Sheet',2,'Range','A2:E269');
cd(oldFolder)

% PRODUCE TABLE
flag = logical(data_flag_Weight(:,7));
nn_ = 5; nupper_ = sum(flag);
[nbegins, nends, flag_] = n_for(nn_,nupper_);

txttitle =  'table_append_H4_BEA_NIPA.tex';
tablabel = 'tab: BEA and NIPA';

txtfilename   = fopen(txttitle,'w');
for k=1:numel(nends)
        table_BEA_NIPA(nbegins(k), nends(k), nupper_, data_flag_Weight,name_NIPA_BEA,tablabel,txtfilename)
end
fclose('all');

disp([indent_, txttitle, description_])



%% TABLE: NIPA line and ELI

database_name2 = 'Database_Match_ELI_NIPA.xlsx';

cd DATA/PCE
data_Freq_Weight = readmatrix(database_name2,'Sheet',2,'Range','C2:H272');
name_ELI_NIPA    =   readcell(database_name2,'Sheet',2,'Range','A2:D272');
cd(oldFolder)

% PRODUCE TABLE
nn_ = 5; nupper_ = size(name_ELI_NIPA,1);
[nbegins, nends, flag] = n_for(nn_,nupper_);

txttitle = 'table_append_H3_NIPA_ELI.tex';
tablabel = 'tab: NIPA and ELI';

txtfilename  = fopen(txttitle,'w');
for k=1:numel(nends)
        table_NIPA_ELI(nbegins(k), nends(k), nupper_, data_Freq_Weight,name_ELI_NIPA,tablabel,txtfilename)
end
fclose('all');

disp([indent_, txttitle, description_])


%% TABLE: Original format Abbreviation

database_name3 = 'Database_indSige.xlsx';

cd DATA/GroupIndex
sector_labels    =   readcell(database_name3,'Sheet',1,'Range','E2:F67');
cd(oldFolder)

txttitle =  'table_append_H1_abbreviation.tex';
tablabel = 'tab:abb';
txtfilename  = fopen(txttitle,'w');
    table_abbreviation(sector_labels,tablabel,txtfilename,2)
fclose('all');

disp([indent_, txttitle, description_])



%% TABLE and FIGURE: BEA gross output price vs BLS PPI by industry

database_name4 = 'Database_estim_PPIdata_BLS.xlsx';

cd DATA/PPI
sector_code_name =    readcell(database_name4,'Sheet',9,'Range','A2:C67');
stdev_BEA_BLS    =  readmatrix(database_name4,'Sheet',9,'Range','A2:E67');
cd(oldFolder)
txttitle = 'table_append_H7_PPI_BEA_BLS.tex';
tablabel = 'tab:PPI_BEA_BLS';
txtfilename  = fopen(txttitle,'w');
    table_ppi_BEA_BLS(sector_code_name,stdev_BEA_BLS,txtfilename,txttitle,tablabel)
fclose('all');

stdBEA = stdev_BEA_BLS(:,4);
stdBLS = stdev_BEA_BLS(:,5);
indnotNaN_BLS = logical(1-isnan(stdBLS));


iplot = iplot+1;
f=figure(iplot);
f.Position = Positionf1;

maxval = max([stdBLS(indnotNaN_BLS);stdBEA(indnotNaN_BLS)]);
%aux = round(maxval,0)<maxval;
xyupper = round(maxval,0) + (round(maxval,0)<maxval);
plot((0:xyupper),(0:xyupper),'LineStyle',':','Color',[0,0,0],'LineWidth',1.1);hold on
f=scatter(stdBLS(indnotNaN_BLS),stdBEA(indnotNaN_BLS),60 ,'MarkerEdgeColor',[0,0,0],'LineWidth',1.5);
f_h_axe(Axis_FN,Axis_FS)
xlim([0 14]);ylim([0 14])
    figname = 'fig_append_stdPPI_BLS_BEA';
    saveas(f,figname,'svg')
    xylabel({'$\sigma_{\pi(s)}|_{\rm data}$, BLS','$\sigma_{\pi(s)}|_{\rm data}$, BEA'},[xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1)


%% FGIGURE: Counter-cumulative distribution of sales and consumption shares.

ind_fczero = logical(1-indfc_notzero);

% rename
fc_appendix = fcdata;
V_appendix  = V;
StrengthG_appendix = StrengthG;
OMGs_appendix = OMGs;
GAMs_appendix = GAMs;

fc_appendix(ind_fczero) = NaN;
GAMs_appendix(ind_fczero) = NaN;


[cdfv,  xv] = ecdf(V_appendix);
[cdffc,xfc] = ecdf(fc_appendix);

iplot = iplot+1;
f=figure(iplot);
f.Position = Positionf1;
    tindex = 1;
    nbins = 41;
    h1=stairs(xfc,1-cdffc,'LineStyle','-','LineWidth',3,'Color',[0.65,0.65,0.65]);
    hold on
    h2=stairs(xv,1-cdfv,'LineStyle','--','LineWidth',3,'Color',[0,0,0]);
    grid on
    f_h_axe(Axis_FN,Axis_FS)
    set(gca,'XScale','log')
    legend('Consumption share, $f^{\rm c}_s$','Sales share, $v_s$',...
        'Interpreter','Latex','FontSize',Legend_FS,'EdgeColor','none','Color','none','Location','SouthWest')
        figname = 'fig_append_fc_v';
        saveas(f,figname,'svg')
    xlabel('$f_s^{\rm c}$, $v_s$','Interpreter','Latex','FontSize',1.5*xLabel_FS)
    ylabel('Counter-cumulative distribution','FontName','arial','FontSize',1.15*yLabel_FS)




%% FIGURES for pass-through

load Result_run06_ Ptt0 Ptt1 U
Ptt0_appendix = Ptt0;
U_appendix = U;

% Ptt0_appendix(ind_fczero) = NaN;
Ptt0_irf_sector = Ptt0_appendix(ind_irf_sector);
Ptt0_appendix(ind_irf_sector) = NaN;

VG_appendix = (V')*(GG');

% StrengthG_appendix = NaN;
% GAMs_appendix = GAMs;
% OMGs_appendix = OMGs;
formatSpec_   = '%.2f';
formatSpec_3   = '%.3f';

% vs fc
figname = 'fig_append_Passthrough_fc';
xlabelname = '$f^{\rm c}_s$';
Xforany = fc_appendix;
mdl_fc_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_fc_y.Coefficients.Estimate;
Radjsut = mdl_fc_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    ylim([0 0.014])
    f_h_axe(Axis_FN,Axis_FS)
    xylabel({xlabelname,'$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),'+ ',num2str(Coeff(2),formatSpec_3),'\times f_s^{\rm c}$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.124321220791846 0.843731949475574 0.748575943555258 0.0602681561533965])
    text(0.03, 0.012, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters


% vs VG

figname = 'fig_append_Passthrough_vg';
% xlabelname = "$\sum_{s'}G_{ss'}v_s$";
Xforany = VG_appendix;
mdl_VG_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_VG_y.Coefficients.Estimate;
Radjsut = mdl_VG_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,70,'MarkerEdgeColor',[0.5,0.5,0.5],'LineWidth',1.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,70,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2.5);
    f_h_axe(Axis_FN,Axis_FS)
    ylim([0 0.016])
    % xylabel({xlabelname,'$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    % xylabel({'Strength (weighted)','$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_),'+ ',num2str(Coeff(2),formatSpec_),'\times \textrm{Strength (weighted)}$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.210987887458513 0.838931949475574 0.748575943555258 0.0602681561533965])
    text(0.016, 0.0135, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
    xlabel('Strength (weighted)','FontSize',1.2*xLabel_FS,'FontName','arial')
    ylabel('$\mathcal{P}_{t,t}(s)$','FontSize',1.3*yLabel_FS,'Interpreter','Latex','Rotation',1)
    saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters


% vs Strength


figname = 'fig_append_Passthrough_strength';
% xlabelname = "$\sum_{s'}G_{ss'}$";
Xforany = StrengthG_appendix;
mdl_G_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_G_y.Coefficients.Estimate;
Radjsut = mdl_G_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    f_h_axe(Axis_FN,Axis_FS)
    ylim([0 0.014])
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),'+ ',num2str(Coeff(2),formatSpec_3),'\times \textrm{Strength}$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.164321220791846 0.840531949475574 0.748575943555258 0.0602681561533965])
    text(1, 0.012, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
    xlabel('Strength','FontSize',1.2*xLabel_FS,'FontName','arial')
    ylabel('$\mathcal{P}_{t,t}(s)$','FontSize',1.3*yLabel_FS,'Interpreter','Latex','Rotation',1)
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters


% vs omegas
figname = 'fig_append_Passthrough_omega';
xlabelname = '$\omega_s$';
Xforany = OMGs_appendix;
mdl_OMGs_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_OMGs_y.Coefficients.Estimate;
Radjsut = mdl_OMGs_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    ylim([0 0.014])
    f_h_axe(Axis_FN,Axis_FS)
    xylabel({xlabelname,'$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),' ',num2str(Coeff(2),formatSpec_3),'\times \omega_s$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.164321220791846 0.840531949475574 0.748575943555258 0.0602681561533965])
    text(0.2, 0.012, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters



% vs V(s)
figname = 'fig_append_Passthrough_v';
xlabelname = '$v_s$';
Xforany = V_appendix;
mdl_V_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_V_y.Coefficients.Estimate;
Radjsut = mdl_V_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    ylim([0 0.014])
    f_h_axe(Axis_FN,Axis_FS)
    xylabel({xlabelname,'$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),'+ ',num2str(Coeff(2),formatSpec_3),'\times v_s$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.164321220791846 0.840531949475574 0.748575943555258 0.0602681561533965])
    text(0.02, 0.012, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters

% vs gammas
figname = 'fig_append_Passthrough_gamma';
xlabelname = '$\gamma_s$';
Xforany = GAMs_appendix;
mdl_GAMs_y = fitlm(Xforany,Ptt0_appendix);
Coeff = mdl_GAMs_y.Coefficients.Estimate;
Radjsut = mdl_GAMs_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    ylim([0 0.014])
    f_h_axe(Axis_FN,Axis_FS)
    xylabel({xlabelname,'$\mathcal{P}_{t,t}(s)$'},[1.2*xLabel_FS,yLabel_FS],{xLabel_FN,yLabel_FN},1.3,1,1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),'',num2str(Coeff(2),formatSpec_3),'\times \gamma_s$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.164321220791846 0.840531949475574 0.748575943555258 0.0602681561533965])
    text(0.25, 0.012, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters


% vs gammas
figname = 'fig_append_Passthrough_U';
xlabelname = 'Upstreamness';
Xforany = U_appendix;
mdl_U_y = fitlm(Xforany,Ptt0_appendix, 'poly2');
Coeff = mdl_U_y.Coefficients.Estimate;
Radjsut = mdl_U_y.Rsquared.Adjusted;
xgrid = linspace(min(Xforany),max(Xforany),21);
    iplot = iplot+1;
    f=figure(iplot);
    f.Position = Positionf1;
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid+Coeff(3)*xgrid.^2,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(Xforany, Ptt0_appendix,60,'MarkerEdgeColor',[0,0,0],'LineWidth',0.5);
    hold on
    scatter(Xforany(ind_irf_sector), Ptt0_irf_sector,60,'MarkerEdgeColor',[0.3,0.6,1],'LineWidth',2);
    ylim([-0.002 0.014])
    f_h_axe(Axis_FN,Axis_FS)
    xlabel('Upstreamness','FontSize',1.2*xLabel_FS,'FontName','arial')
    ylabel('$\mathcal{P}_{t,t}(s)$','FontSize',1.3*yLabel_FS,'Interpreter','Latex','Rotation',1)
    legend(['$ \mathcal{P}_{t,t} = ',num2str(Coeff(1),formatSpec_3),' + ',num2str(Coeff(2),formatSpec_3),'\times U+ ',num2str(Coeff(3),formatSpec_3),'\times U^2$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.164321220791846 0.840531949475574 0.748575943555258 0.0602681561533965])
    text(-0.52, 0.0115, ['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS); % labels on scatters
        % saveas(f,figname,'svg')
        saveas(f,figname,'svg')
    text(Xforany(ind_irf_sector), Ptt0_irf_sector, sector_name(ind_irf_sector),...
        'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters
%%
rmpath Utils
