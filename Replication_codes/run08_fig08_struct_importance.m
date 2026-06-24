clc
close all
clear
% This code plots Figure 8:
% This code derives structural importance (SI).
% Code author: K. Hasui

%% Preamble
load Database_estim.mat sector_name
load Database_model.mat GG ind_irf_sector V
addpath Utils

Save_fig = 1;
figformat = 'svg';

oldcd = cd;

%% Case: empirical graph

cd model_network_emp/Output/
    load results_model_network_emp oo_a M_a
    for im = 1:M_a.endo_nbr
        eval(['ind_',M_a.endo_names{im,:}, ' = im;']);
    end
    for ie = 1:M_a.exo_nbr
        eval(['ind_',M_a.exo_names{ie},' = ie;',])
    end
cd(oldcd)

% Indices are common:
inds_ps   = ind_p1:ind_p66;       % p(s)
inds_pais = ind_pai1:ind_pai66;   % pi(s)
inds_e_ep = ind_e_ep1:ind_e_ep66; % e(s)

[~,Qemp]=get_pq(oo_a.dr,M_a.nstatic,M_a.nfwrd);
Dpck0emp_over_Deps = Qemp(ind_pcf_k0,inds_e_ep)';
clear oo_a M_a


%% Case: complete graph
cd model_network_comp/Output
    load results_model_network_comp.mat oo_a M_a
cd(oldcd)

[~,Qcomp]=get_pq(oo_a.dr,M_a.nstatic,M_a.nfwrd);
Dpck0comp_over_Deps = Qcomp(ind_pcf_k0,inds_e_ep)';


%% Structural Importance (SI)
y = Dpck0emp_over_Deps./Dpck0comp_over_Deps;

upperY = numel(y);
xmaxp = round(1.4*max( max(y),max(y) ),2);
x_axis = (linspace(-xmaxp, xmaxp,5));
y_axis = 1:upperY;

%% PLOT FIGURE

% common figure control:

MainFontSize = 12;
SubFontSize  = 15;
MainFontName = 'Arial';
SubFontName  = 'Arial';

% FN: Font mame,  FS: Font size
[Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
[Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);

% figure position
fPosition1 = [550 400 500 500];
fPosition11 = [550 400 750 500];
fPosition2 = [250 400 1600 500];
fPosition3 = [150 200 1000 600];

% initial figure number
iplot = 0;

%% (a) BARH: SI

plotsize = 20;

[yascend, indascend] = sort(y,'ascend');
extractRANGE = upperY:-1:upperY-plotsize+1;

xlimupper = 2.6;
iplot = iplot + 1;
f=figure(iplot);
f.Position = fPosition11;
    b=barh(1:upperY,yascend',0.5,'stacked');
    set(b(1),'FaceColor',[0,0,0],'EdgeColor','none') % 'FaceColor',[0,0,0.9]
    %set(b(2),'FaceColor',[0.8,0.8,0.8],'EdgeColor','none') % 'FaceColor',[0.7,0.8,1]
    f_h_axe(Axis_FN,Axis_FS)
    yticks(y_axis); yticklabels(sector_name(indascend))
    xticks(0:9)
    % xticks(x_axis); xticklabels(abs(x_axis))
    ylim([upperY-plotsize+0.25 upperY+0.75])
    % xlim([0 max(x_axis)+0.0015])
    xlim([0 9])
    xtips1 = b(1).YEndPoints+xlimupper/15; %- 0.005;
    ytips1 = b(1).XEndPoints;
    labels1 = string(round(b(1).YData, 2));
    text(xtips1(extractRANGE), ytips1(extractRANGE), labels1(extractRANGE),...
            'VerticalAlignment','middle','FontName','Times','FontSize',1.12*Textbox_FS)
    legend('$\textrm{SI}(s)$',...
        'Interpreter','Latex','EdgeColor','none','Color','none','FontSize',1.2*Legend_FS,...
        'Position',[0.765136590662981 0.77290513126624 0.116953240189397 0.0617615354004271])
    if Save_fig == 1
        figname = 'fig08a';
        saveas(f,figname,figformat)
    end


%% (b) SCATTER: SI vs strength
% formatSpec_   = '%.2f';

Gstrength = sum(GG,2);

% mdl_strength_y = fitlm(Gstrength,y);
% Coeff = mdl_strength_y.Coefficients.Estimate;
% Radjsut = mdl_strength_y.Rsquared.Adjusted;
% 
% xgrid = linspace(min(Gstrength),max(Gstrength),21);

iplot = iplot + 1;
% f=figure(iplot);
% f.Position = fPosition1;
%     % plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0.3,0.6,1]); hold on
%     plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
%     scatter(Gstrength,y,60,'LineWidth',1.5,'MarkerEdgeColor',[0.55,0.55,0.55])
%     f_h_axe(Axis_FN,Axis_FS)
%     %scatter(Gstrength(ind_irf_sector),y(ind_irf_sector))
%     xlabel('Strength','FontName',xLabel_FN,'FontSize',xLabel_FS)
%     ylabel('SI','FontName',yLabel_FN,'FontSize',xLabel_FS)
%     legend(['$\textrm{SI} = ',num2str(Coeff(1),formatSpec_),'+ ',num2str(Coeff(2),formatSpec_),'\times \textrm{Strength}$'],...
%         'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
%         'Position',[0.149846890319512 0.844265388437877 0.580191271166593 0.0528012782287904])
%     text(0.8,6.9,['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS)
%     ylim([-0.5 8])
%     if Save_fig == 1
%         figname = 'fig08b';
%         saveas(f,figname,figformat)
%     end



%% (b) SCATTER: SI vs weighted strength
formatSpec_   = '%.2f';

GV = V'*GG';

mdl_strength_y = fitlm(GV,y);
Coeff = mdl_strength_y.Coefficients.Estimate;
Radjsut = mdl_strength_y.Rsquared.Adjusted;

xgrid = linspace(min(GV),max(GV),21);

iplot = iplot + 1;
f=figure(iplot);
f.Position = fPosition1;
    % plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0.3,0.6,1]); hold on
    plot(xgrid,Coeff(1)+Coeff(2)*xgrid,'LineWidth',2.5,'Color',[0,0,0]); hold on
    scatter(GV,y,60,'LineWidth',1.5,'MarkerEdgeColor',[0.55,0.55,0.55])
    f_h_axe(Axis_FN,Axis_FS)
    %scatter(Gstrength(ind_irf_sector),y(ind_irf_sector))
    xlabel('Strength (weighted)','FontName',xLabel_FN,'FontSize',xLabel_FS)
    ylabel('SI','FontName',yLabel_FN,'FontSize',xLabel_FS)
    legend(['$\textrm{SI} = ',num2str(Coeff(1),formatSpec_),'+ ',num2str(Coeff(2),formatSpec_),'\times \textrm{Strength (weighted)}$'],...
        'EdgeColor','none','Color','none','Interpreter','Latex','FontSize',Legend_FS,...
        'Position',[0.171666346139106 0.849065388437877 0.763752359527406 0.0528012782287904])
    text(0.02,6.9,['$\bar{R}^2 = ',num2str(Radjsut,formatSpec_),'$'],'Interpreter','Latex','FontSize',Legend_FS)
    ylim([-0.5 8])
    if Save_fig == 1
        figname = 'fig08b';
        saveas(f,figname,figformat)
    end