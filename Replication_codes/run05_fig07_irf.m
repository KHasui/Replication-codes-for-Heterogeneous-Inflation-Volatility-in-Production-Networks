clc
close all
clear
% This code plots Figure 7.
%
% PREAMBLE:
% This code plots impulse responses to one-stdev shocks.
%  Table for 5 sectors of IRFs.
%  Figures of IRFs.
% Code author: K. Hasui (Aichi University)

Save_fig = 1;
figformat = 'svg';
labelplot = 1; % figure is plot with xy labels if labelplot == 1

%% 1: PLOT Table for 5 sectors of IRFs.

addpath Utils

load Database_estim.mat sector_code sector_name
load Database_model.mat fc V GAMs OMGs StrengthG indfc_notzero ind_irf_sector S
load Result_run04_xopt xopt ng ind_x_to_sige_group_order

[fc_descend, ind_fc_descend] = sort(fc,'descend');

xoptez = xopt(1:ng);
xoptep = xopt(ng+1:end);
sigez  = xoptez(ind_x_to_sige_group_order);
sigep  = xoptep(ind_x_to_sige_group_order);
sigmat = [sigez,sigep];
group_index = ind_x_to_sige_group_order;

N_irf = size(ind_irf_sector,1);

filetitle     = 'table_02_irf.tex';
tablabel      = 'tab:table_for_IRF';

table_irf_sector(ind_irf_sector,group_index,sigmat,fc,V,GAMs,OMGs,StrengthG,sector_name,filetitle,tablabel)

%% 2: Common Figure Overview Controls

% Common Figure Appearance Control:
MainFontSize = 14;
SubFontSize  = 15;
MainFontName = 'Times';
SubFontName  = 'Arial';

% FN: Font mame,  FS: Font size
[Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
[Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);
fPosition1 = [550 400 600 500];
fPosition2 = [250 400 1800 500];
fPosition3 = [250 400 1600 220];
fPosition4 = [550 400 600 500];

LabelFontName =  'Times';
LabelFontSize =  12;
% LabelFontName =  'Arial';
% LabelFontName =  'Calibri';

titleFontName  = 'Times';
titleFontSize  = yLabel_FS;

% Lines
LW = [2.5, 3.5, 3.5, 3.5, 3.5];
LS = {'-','--',':','--'};
c1 = [0,0,0]; c2 =  [0.3,0.3,1]; c3 =[0,0,1]; c4 = [1,0,0]; %c3 = [1,0.7,0]; c4 = [0,0.7,0.2];
LC = [c1;c2;c3;c4];
MK = {'n','n','n','n'};

FaceColor1 = [1,0.2,0.1];
FaceColor2 = [0,0.2,1];
FaceColor3 = [1,0.5,0];
FaceColor4 = [0,0.75,0.55];
FaceColor5 = [0.45,0.65,0.9];
FaceColor6 = [0.45,0.45,0.45];

alphabets = 'abcdefghijklmnopqrstuvwxyz';


%% 3 PLOT IRF



% 3-1: derive IRF

% Load data:
addpath model_network/Output
load model_network_results M_ options_ oo_
dr = oo_.dr;

% X = P*X(-1) + Q*E
[P,Q]=get_pq(oo_.dr,M_.nstatic,M_.nfwrd);

% Extract variable names
% for ind_endo = 1:M_.endo_nbr
%     eval(['ind_',M_.endo_names(ind_endo,:),' = ind_endo;',])
% end
% for ind_exo = 1:M_.exo_nbr
%     eval(['ind_',M_.exo_names(ind_exo,:),' = ind_exo;',])
% end
for ind_endo = 1:M_.endo_nbr
    eval(['ind_',M_.endo_names{ind_endo},' = ind_endo;',])
end
for ind_exo = 1:M_.exo_nbr
    eval(['ind_',M_.exo_names{ind_exo},' = ind_exo;',])
end

T = 20;
% shockval = 0.01;

load Result_run04_xopt xopt ind_e_all ind_x_to_sige ind_x_to_sige_group_order
% update std for disturbances in intermediate sector cost-push shock
Sigmamat_ = diag( sqrt(M_.Sigma_e) );
Stdev_exo_vec = zeros(size(Sigmamat_));
Stdev_exo_vec(ind_e_all) = xopt(ind_x_to_sige); % note: not square.

ind_group = ind_x_to_sige_group_order(ind_irf_sector);
ind_no_pcs = indfc_notzero(ind_irf_sector);
OMGs_ind_sec = OMGs(ind_irf_sector);
sec_index = ind_irf_sector;

indvec_shockz = zeros(N_irf,1);
indvec_shocke = zeros(N_irf,1);

indvec_p  = zeros(N_irf,1);
indvec_pc = zeros(N_irf,1);

for k = 1:N_irf
    indvec_shockz(k) = eval(['ind_e_z',num2str(sec_index(k))]);
    indvec_shocke(k) = eval(['ind_e_ep',num2str(sec_index(k))]);

    indvec_pc(k) = eval(['ind_pc',num2str(sec_index(k))]);
    indvec_p(k)  = eval(['ind_p', num2str(sec_index(k))]);
end

% for productivity shock
IRFcellz = cell(N_irf,1);
for k = 1:N_irf
    indshockz_k = indvec_shockz(k);
    X = irfunc(P,Q,T,Stdev_exo_vec(indshockz_k),indshockz_k);
    IRFcellz{k} = X;
end

% for cost-push shock
IRFcelle = cell(N_irf,1);
for k = 1:N_irf
    indshocke_k = indvec_shocke(k);
    X = irfunc(P,Q,T,Stdev_exo_vec(indshocke_k),indshocke_k);
    IRFcelle{k} = X;
end




% 3-2: PLOT FIGURE IRF

iplot = 1;
f=figure(iplot);
f.Position = fPosition3;

xgrid = 0:T;

n1 = 1;
n2 = round(n1*N_irf/n1,0);

formatSpec_   = '%.2f';

b = 0;
for ip = 1:N_irf
    X = IRFcellz{ip};
    subplot(n1,n2,b+ip)
    if ind_no_pcs(ip)==0
        h=plot(xgrid,X(indvec_p(ip),:),xgrid,NaN*X(indvec_pc(ip),:));
    else
        h=plot(xgrid,X(indvec_p(ip),:),xgrid,X(indvec_pc(ip),:));
    end
    for k = 1:2
        set(h(k),'LineWidth',LW(k),'LineStyle',LS{k},'Color',LC(k,:),'Marker',MK{k},'MarkerSize',4,'MarkerFaceColor',LC(k,:))
    end
    f_h_axe(Axis_FN,Axis_FS)
    if labelplot == 1
        title(['(',alphabets(ip),') ',char(sector_name{sec_index(ip)})],'FontName','arial','FontSize',1.2*titleFontSize)
    end
    xticks([0,5,10,15,20]);
    if ip == 1
        ylim([-11 0])
        if labelplot == 1
            xlabel('Quarter','FontName','arial','FontSize',xLabel_FS)
            ylabel('Response to $z_t(s)$','Interpreter','Latex')
        end
    elseif ip == 2
        ylim([-11 0])
    else
        ylim([-3 0])
    end
end
if Save_fig == 1
    figname = 'fig07a2e';
    saveas(f,figname,figformat)
end


iplot = iplot+ 1;
f=figure(iplot);
f.Position = fPosition3;
b = ip;
for ip = 1:N_irf
    X = IRFcelle{ip};
    subplot(n1,n2,ip)
    if ind_no_pcs(ip)==0
        h=plot(xgrid,X(indvec_p(ip),:),xgrid,NaN*X(indvec_pc(ip),:));
    else
        h=plot(xgrid,X(indvec_p(ip),:),xgrid,X(indvec_pc(ip),:));
    end
    for k = 1:2
        set(h(k),'LineWidth',LW(k),'LineStyle',LS{k},'Color',LC(k,:),'Marker',MK{k},'MarkerSize',4,'MarkerFaceColor',LC(k,:))
    end
    f_h_axe(Axis_FN,Axis_FS)
    xticks([0,5,10,15,20]);
    if labelplot == 1
        title(['(',alphabets(b+ip),') ',char(sector_name{sec_index(ip)})],'FontName','arial','FontSize',1.2*titleFontSize)
    end
    if ip == 1
        ylim([0 8])
        legend('$p_t(s)$','$p_t^{\rm c}(s)$',...
            'interpreter','Latex','EdgeColor','n','Color','n','FontSize',1.15*Legend_FS,'Location','NorthEast')
        if labelplot == 1
            xlabel('Quarter','FontName','arial','FontSize',xLabel_FS)
            ylabel('Response to $e_t(s)$','Interpreter','Latex')
        end
    elseif ip == 2
        ylim([0 8])
    else
        ylim([0 4.5])
    end
end
if Save_fig == 1
    figname = 'fig07f2j';
    saveas(f,figname,figformat)
end


