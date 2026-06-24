clc
close all
clear
% This code plots Figures 9 and 10.
%
% PREAMBLE:
% This code plots Cost-shock-induced producer price pass-through.
% Figures 9: Cost-shock-induced producer price pass-through.
% Figures 10: The volatility-adjusted aggregate impacts of sectoral cost-push shocks
%
% This code uses springRank.m.
%
% Code author: K. Hasui (Aichi University)

addpath Utils

Save_fig = 1;
figformat = 'svg';



%% 1: Pass-through Price level

% Common Figure Overview Controls

formatSpec_   = '%.2f';
digits_ = 3;

MainFontSize = 12;
SubFontSize  = 15;
MainFontName = 'Times';
SubFontName  = 'Arial';

% FN: Font mame,  FS: Font size
[Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
[Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);

fPosition1 = [550 400 600 500];
fPosition2 = [250 400 1600 500];
fPosition3 = [550 400 800 500];

% Lines
LW = [2,2,2,2];
LS = {'-',':','-.','--'};
c1 = [0,0,1]; c2 = [1,0,0]; c3 = [1,0.7,0]; c4 = [0,0.7,0.2];
LC = [c1;c2;c3;c4];

alphabets = 'abcdefghijklmnopqrstuvwxyz';

% Load data:
addpath model_network/Output
load model_network_results M_ options_ oo_
load Database_model indfc_notzero fc V StrengthG GAMs OMGs GG ind_irf_sector
load Database_estim sector_name
% load Result_run04_xopt xopt ind_x_to_sige_group_order ng

% Extract variable names
for ind_endo = 1:M_.endo_nbr
    eval(['ind_',M_.endo_names{ind_endo},' = ind_endo;',])
end
for ind_exo = 1:M_.exo_nbr
    eval(['ind_',M_.exo_names{ind_exo},' = ind_exo;',])
end
inds_ps   = ind_p1:ind_p66;       % p(s)
inds_pais = ind_pai1:ind_pai66;   % pi(s)
inds_e_ep = ind_e_ep1:ind_e_ep66; % e(s)

[P,Q]=get_pq(oo_.dr,M_.nstatic,M_.nfwrd);

Dpck0_over_Deps = Q(ind_pcf_k0,inds_e_ep)';
Dpck1_over_Deps = Q(ind_pcf_k1,inds_e_ep)';
Dps_over_Deps   = diag( Q(inds_ps,inds_e_ep) );

Ptt0 = Dpck0_over_Deps./Dps_over_Deps;
Ptt1 = Dpck1_over_Deps./Dps_over_Deps;

save Result_run06_ Ptt0 Ptt1

% [Ptt0_ascend, ind_ascend] = sort(Ptt0(indfc_notzero),'ascend');
[Ptt0_ascend, ind_ascend] = sort(Ptt0,'ascend');
% Ptt1_ = Ptt1(indfc_notzero);
% sector_name_ = sector_name(indfc_notzero);
Ptt1_ascend = Ptt1(ind_ascend);
sector_name_ascend = sector_name(ind_ascend);
% Snotzero = sum(double(indfc_notzero));
% upperY = Snotzero;
upperY = size(sector_name_ascend,1);

iplot=0;
xmaxp = round(1.4*max( max(Ptt0_ascend),max(Ptt1_ascend) ),2);
x_axis = (linspace(-xmaxp, xmaxp,5));
y_axis = 1:upperY;

plotsize = 20;
%size(Ptt1_ascend(upperY:-1:upperY-sizeplot+1))
% y=[-Ptt0_ascend(upperY:-1:upperY-sizeplot+1),Ptt1_ascend(upperY:-1:upperY-sizeplot+1)];
y=[-Ptt0_ascend,Ptt1_ascend];

extractRANGE = upperY:-1:upperY-plotsize+1;


%% PLOT Figure 9: Pass-through Inflation
iplot=iplot+1;
f=figure(iplot);
f.Position = fPosition3;
    b=barh(1:upperY,y',0.5,'stacked');
    set(b(1),'FaceColor',[0,0,0],'EdgeColor','none') % 'FaceColor',[0,0,0.9]
    set(b(2),'FaceColor',[0.8,0.8,0.8],'EdgeColor','none') % 'FaceColor',[0.7,0.8,1]
    f_h_axe(Axis_FN,Axis_FS)
    yticks(y_axis); yticklabels(sector_name_ascend)
    xticks(x_axis); xticklabels(abs(x_axis))
    ylim([upperY-plotsize+0.25 upperY+0.75])
    xlim([min(x_axis) max(x_axis)+0.0015])
xtips1 = b(1).YEndPoints - xmaxp/5; %- 0.005;
ytips1 = b(1).XEndPoints;
labels1 = string(round(abs(b(1).YData), digits_));
xtips2 = b(2).YEndPoints + xmaxp/20;
ytips2 = b(2).XEndPoints;
labels2 = string(round(b(2).YData, digits_));
text(xtips1(extractRANGE),ytips1(extractRANGE),labels1(extractRANGE),'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',Textbox_FS)
text(xtips2(extractRANGE),ytips2(extractRANGE),labels2(extractRANGE),'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',Textbox_FS)
legend('$\mathcal{P}_{t,t}(s)$','$\mathcal{P}_{t,t+1}(s)$',...
    'FontSize',1.16*Legend_FS,'EdgeColor','n','Color','n','Interpreter','Latex','Location',[0.761113592113735 0.422430520916713 0.16082833330818 0.112938958166574])
if Save_fig == 1
    figname = 'fig09';
    saveas(f,figname,figformat)
end








%% 2. Figure 10: pc to e(s) with estimated values

load Result_run04_xopt xopt ind_x_to_sige_group_order ng
xoptez = xopt(1:ng);
xoptep = xopt(ng+1:end);

sigez = xoptez(ind_x_to_sige_group_order);
sigep = xoptep(ind_x_to_sige_group_order);

Dpck0_over_Deps_sigep = Q(ind_pcf_k0,inds_e_ep)'.*sigep;
Dpck1_over_Deps_sigep = Q(ind_pcf_k1,inds_e_ep)'.*sigep;
Dpaick0_over_Deps_sigep = Q(ind_paicf_k0,inds_e_ep)'.*sigep;
Dpaick1_over_Deps_sigep = Q(ind_paicf_k1,inds_e_ep)'.*sigep;

% Dpck0_over_Deps_sigep and Dpck1_over_Deps_sigep
[Dpck0_ascend, ind_Dpck0_ascend] = sort(Dpck0_over_Deps_sigep,'ascend');
Dpck1_ascend = Dpck1_over_Deps_sigep(ind_Dpck0_ascend);
sector_name_ascend = sector_name(ind_Dpck0_ascend);

y=[-Dpck0_ascend, Dpck1_ascend];
xmaxpai = round(1.3*max( max(Dpck0_ascend),max(Dpck1_ascend) ),2);
x_axis = (linspace(-xmaxpai, xmaxpai,9));
% x_axis = [0.04 0.03 0.02 0.01 0 0.01 0.0]

% PLOT BUTTERFY CHART with barh
iplot=iplot+1;
f=figure(iplot);
f.Position = fPosition3;
    b=barh(1:upperY,y',0.5,'stacked');
    set(b(1),'FaceColor',[0,0,0],'EdgeColor','none') % 'FaceColor',[0,0,0.9]
    set(b(2),'FaceColor',[0.8,0.8,0.8],'EdgeColor','none') % 'FaceColor',[0.7,0.8,1]
    f_h_axe(Axis_FN,Axis_FS)
    yticks(y_axis);  yticklabels(sector_name_ascend)
    xticks(x_axis);  xticklabels(abs(x_axis))
    ylim([upperY-plotsize+0.25 upperY+0.75])
    xlim([min(x_axis) max(x_axis)])
xtips1 = b(1).YEndPoints  - xmaxpai/5;
ytips1 = b(1).XEndPoints;
labels1 = string(round(abs(b(1).YData), digits_));
xtips2 = b(2).YEndPoints + xmaxpai/35;
ytips2 = b(2).XEndPoints;
labels2 = string(round(b(2).YData, digits_));
text(xtips1(extractRANGE),ytips1(extractRANGE),labels1(extractRANGE),'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',Textbox_FS)
text(xtips2(extractRANGE),ytips2(extractRANGE),labels2(extractRANGE),'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',Textbox_FS)
legend('$\displaystyle \frac{\partial p_t^{\rm c}}{\partial e_t(s)}\sigma_{e}(s)$','$\displaystyle \frac{\partial p_{t+1}^{\rm c}}{\partial e_t(s)}\sigma_{e}(s)$',...
    'FontSize',1.16*Legend_FS,'EdgeColor','n','Color','n','Interpreter','Latex','Location',[0.725138512267947 0.537630520916713 0.266778492999756 0.112938958166574])
if Save_fig == 1
    figname = 'fig10';
    saveas(f,figname,figformat)
end




%% 4. Regression

addpath Utils/Spring_Rank

G = GG;

Ptt0_ = Ptt0(indfc_notzero);
Ptt1_ = Ptt1(indfc_notzero);

% Sectors for fc=0 are excluded:
fc_        = fc(indfc_notzero);
V_         = V(indfc_notzero);
StrengthG_ = StrengthG(indfc_notzero);
GAMs_      = GAMs(indfc_notzero);
OMGs_      = OMGs(indfc_notzero);
G_         = G(indfc_notzero,indfc_notzero);

GV_ = G_*V_;
U   = springRank(G);
U_  = U(indfc_notzero);
% U_   = springRank(G_);

save("Result_run06_.mat", "U" ,"-append")

filetitle     = 'table_run06_regress.tex';
tablabel      = 'tab:regress_passthrough';
%table_regression(Ptt0_,Ptt1_,fc_, OMGs_, GAMs_, GV_, StrengthG_, U_, filetitle, tablabel)

rmpath Utils/Spring_Rank
rmpath Utils
