clc
close all
clear
% This code plots Figures 5 and 6.
%
% PREAMBLE:
% This code estimate model stdev of disturbance terms for productivity z and cost-push shock for indermediate goods ep.
% This codes requires lsqnonlin to solve quadratic distance between data and the model.
%
% SYSTEM REQUIREMENTS:
%   Dynare: 6.0 or 6.1 (Recommended)
%   MATLAB: 2023a (does not work after 2025a)
%
% ** NOTE: This code requires substantial computation time. **
% 
% Code author: K. Hasui (Aichi University)

%% 1. Get policy function by running dynare

% 'modnam_1' indicates the case of alpha = 0.5
% 'modnam_2' indicates the case of alpha = 1 (i.e., no network effects)

Load_result_only    = 0;  % Default is 0: if 1, only loading result.
Run_dynare_modfile  = 1;  % Default is 1: if 1, run dynare mod file.
Save_tab_Latex      = 1;  % Default is 1: if 1, results are saved as Latex table formats. 
Plot_tab_comwindow  = 1;  % Default is 1: if 1, estimation result is plotted on command window.
Save_fig            = 1;  % Default is 1: if 1, figures are saved

% run dynare
if Run_dynare_modfile == 1 % Run Dynare
    load Database_model.mat modfile_name
    dynare(modfile_name)
end


%% 2. Estimation

% Load data:
addpath model_network/Output
    load model_network_results M_ options_ oo_
load Database_model.mat fc OMGs indfc_notzero
load Database_estim.mat
std_data  = [std_data_macrovar;std_data_ppi;std_data_pce];

% nx = max(ind_x_to_sige);
nx = numel(unique(ind_x_to_sige));
ng = numel(unique(ind_x_to_sige_group_order)); % # of groups
Nd = numel(std_data);
dr = oo_.dr;

% Extract variable names
for ind_endo = 1:M_.endo_nbr
    eval(['ind_',M_.endo_names{ind_endo},' = ind_endo;',])
end
for ind_exo = 1:M_.exo_nbr
    eval(['ind_',M_.exo_names{ind_exo,:},' = ind_exo;',])
end

S = numel(OMGs);

ind_paitilde_end = eval(['ind_paitilde',num2str(S)]);
ind_pai_end      = eval(['ind_pai',num2str(S)]);
ind_paic_end     = eval(['ind_paic',num2str(S)]);

% make index
ind_paitildeall = (ind_paitilde1:ind_paitilde_end)';
ind_paipall = (ind_pai1:ind_pai_end)';
ind_paicall = (ind_paic1:ind_paic_end)';
ind_fczero=fc==0;
ind_paicall_elimfczero = ind_paicall(logical(1-ind_fczero));

% model index
ind_std_model = [ind_dc; ind_dw; ind_dell; ind_paipall; ind_paicall_elimfczero];

% check size of data and model
size_data  = numel(std_data);
size_model = numel(ind_std_model);
if size_data>size_model
    warning('The size of data is greater than the size of model.')
elseif size_data<size_model
    warning('The size of model is greater than the size of data.')
end

% indices of disturbance term to be estimated
ind_e_z_end = eval(['ind_e_z',num2str(S)]);
ind_e_ep_end = eval(['ind_e_ep',num2str(S)]);

ind_e_zall  = (ind_e_z1:ind_e_z_end)';
ind_e_epall = (ind_e_ep1:ind_e_ep_end)';
% ind_e_ecall = (ind_e_ec1:ind_e_ec_end)';
ind_e_all = [ind_e_zall;ind_e_epall];

% init val for model_std
x = 5*ones(nx, 1);
Weights_ = ones(numel(ind_std_model) ,1);


% Estimate params with lsqnonlin:

lb = zeros(nx, 1);
ub = []; A=[]; b=[]; Aeq=[]; beq=[]; nonlcon=[];
optionslsq = optimoptions('lsqnonlin','Display','iter',...
    'MaxIterations',4000,...
    'MaxFunctionEvaluations',2000*nx,...
    'FunctionTolerance',1e-010);

if Load_result_only==1
    load Result_run04_xopt xopt jacob
else
    [xopt,resnorm,residual,exitflag,output,lambda,jacob] = lsqnonlin(@objlsq,x,lb,ub,optionslsq,ind_x_to_sige,ind_std_model,ind_e_all,std_data,dr,M_,options_,Weights_);
    save Result_run04_xopt xopt jacob ind_e_all ind_x_to_sige ind_x_to_sige_group_order ng
    % xopt is a vector of estimated params.
end
Sigma_e_vec=diag(M_.Sigma_e);





%% 3. Write estimation results:

% update std for disturbances in intermediate sector cost-push shock
Sigma_e_vec(ind_e_all) = xopt(ind_x_to_sige).^2;
Sigma_e = diag(Sigma_e_vec);

xoptez = xopt(1:ng);
xoptep = xopt(ng+1:end);

sigez = xoptez(ind_x_to_sige_group_order);
sigep = xoptep(ind_x_to_sige_group_order);

% insert updated std for disturbances in intermediate sector cost-push shock
M_.Sigma_e = Sigma_e;

% recall vcoc: variance-covariance 
v = vcov(dr,M_,options_);
std_model = sqrt(diag(v));
std_model = std_model(ind_std_model);

% Standard Error
invJacob = inv(jacob'*jacob);
SE = (diag(invJacob)).^0.5;

SEz_group = SE(1:ng);
SEp_group = SE(ng+1:end);
SEz = SEz_group(ind_x_to_sige_group_order);
SEp = SEp_group(ind_x_to_sige_group_order);

SEz=full(SEz);
SEp=full(SEp);

% p-value
% C = invJacob;
% [~, pval]=corrcovpval(C,Nd);
% df=numDataPoints-length(par);
t = (xopt-0)./(SE/sqrt(nx)); % t-value
pval = 1-tcdf(t,nx-1); % p-value
% pval=2*tcdf(-abs(xopt)./SE,Nd);
pvalz_group = pval(1:ng);
pvalp_group = pval(ng+1:end);
pvalz = pvalz_group(ind_x_to_sige_group_order);
pvalp = pvalp_group(ind_x_to_sige_group_order);

% write data xlsx file:
savefilenamexlsx = 'Result_run04_estimation.xlsx';
writecell(sector_code_PPI,savefilenamexlsx,'Sheet',1,'Range','B2:B67')
writecell(sector_name_PPI,savefilenamexlsx,'Sheet',1,'Range','C2:C67')

headlabel={'estval: sigz','estval: sige','S.E.: sigz', 'S.E.: sige', 'pval: sigz', 'pval: sige'};
writecell(headlabel,savefilenamexlsx,'Sheet',1,'Range','D1:I1')

writematrix([sigez,sigep],             savefilenamexlsx,'Sheet',1,'Range','D2:E67')
writematrix([full(SEz),full(SEp)],     savefilenamexlsx,'Sheet',1,'Range','F2:G67')
writematrix([pvalz,pvalp],             savefilenamexlsx,'Sheet',1,'Range','H2:I67')
writematrix(ind_x_to_sige_group_order, savefilenamexlsx,'Sheet',1,'Range','A2:A67')


Data_name = [name_macrovar;sector_name_PPI;sector_name_PCE];
name_Macro_data = cell(size(name_macrovar));
name_PPI_data = cell(size(sector_name_PPI));
name_PCE_data = cell(size(sector_name_PCE));

name_Macro_data(:) = {'Macro data'};
name_PPI_data(:) = {'PPI data'};
name_PCE_data(:) = {'PCE data'};

Data_type = [name_Macro_data; name_PPI_data; name_PCE_data];
writecell(Data_type,  savefilenamexlsx, 'Sheet', 3, 'Range', 'A2:A128')
writecell(Data_name,  savefilenamexlsx, 'Sheet', 3, 'Range', 'B2:B128')
writematrix(std_model,savefilenamexlsx, 'Sheet', 3, 'Range', 'C2:C128')
writematrix(std_data, savefilenamexlsx, 'Sheet', 3, 'Range', 'D2:D128')

resid_model_data=abs(std_data-std_model);
bigresid = double(resid_model_data>1.5);
writematrix(resid_model_data,savefilenamexlsx, 'Sheet', 3, 'Range', 'E2:E128')
writematrix(bigresid, savefilenamexlsx, 'Sheet', 3, 'Range', 'F2:F128')



%% 4. Produce result table as Latex format (Optional)

addpath Utils

[group_ascend, ind_ascend] = sort(ind_x_to_sige_group_order,'ascend');
sect_index = (1:S)';
sect_index_ascend  = sect_index(ind_ascend);
sector_name_ascend = sector_name_PPI(ind_ascend);
sector_code_ascend = sector_code_PPI(ind_ascend);
sigez_ascend       = sigez(ind_ascend);
sigep_ascend       = sigep(ind_ascend);
SEz_ascend         = SEz(ind_ascend);
SEp_ascend         = SEp(ind_ascend);

std_ppi_ascend = std_data_ppi(ind_ascend);
OMGs_ascend    = OMGs(ind_ascend);

nj = size(ind_ascend,1);
group_ascend_old = 1;

filename  =  'table_append_H5_estimation_result.tex';
tablabel  =  'tab: Estim_stdev';
capname   =  'Estimation results';
subtablabel =  'subtab: Estim_stdev';
subcapname  =  'PPI stdevs and Stickiness';

estim_result_mat  = [sect_index_ascend,ind_ascend,group_ascend,sigez_ascend,SEz_ascend,sigep_ascend,SEp_ascend,OMGs_ascend];
estim_result_cell = [sector_code_ascend,sector_name_ascend];

% Save as Latex file
if Save_tab_Latex == 1
    derive_subtable = 0;
    table_estim_result_group(filename, estim_result_mat,estim_result_cell,tablabel,capname,subtablabel,subcapname,derive_subtable);
end

fprintf('\n');disp('  ---')


%% 5. PLOT Estimation result COMMAND WINDOW (Optional)

if Plot_tab_comwindow == 1
    fprintf('\n')
    fprintf('%s %8s %-9s %40s %12s (%s) %12s (%s)\n',...
        '  ', 'GROUP', ' BEA CODE', 'SECTOR NAME', 'sigma_z(s)', 'S.E.', 'sigma_e(s)', 'S.E.')
    for j = 1:nj
        plot_estim_result(j,estim_result_mat,estim_result_cell)
    end
end


%% BEFORE Plotting Results:

% Common Figure Appearance Control:
MainFontSize = 12;
SubFontSize  = 15;
MainFontName = 'Times';
SubFontName  = 'Arial';

% FN: Font mame,  FS: Font size
[Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
[Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);

xyFontSize = [xLabel_FS,yLabel_FS];
xyFontName = {xLabel_FN,yLabel_FN};

fPosition1 = [550 400 600 500];
AxisBoxRatio = [1, 0.8761, 0.8761];
% AxisBoxRatio = [1, 0.876075731497418, 0.876075731497418];

figformat = 'svg';
% figformat = 'fig';
% figformat = 'png';
% figformat = 'eps';

iplot = 0;

%% PLOT Figure 5(a): Estimation results
iplot = iplot + 1;

ngroup = size(xoptez,1);
tname = cell(ngroup,1);
for k = 1:ngroup
    tname{k} = ['Group ',num2str(k)];
end

f=figure(iplot);
f.Position = fPosition1;
    % 45 degree
    plot(0:18,0:18,'LineWidth',1,'Color',[0,0,0],'LineStyle',':'); hold on
    % Estimated sigz sige
    scatter(xoptez,xoptep,50,'marker','o','MarkerEdgeColor',[0.1,0.2,1],'MarkerFaceColor','none','LineWidth',1.2)
        f_h_axe(Axis_FN,Axis_FS)
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        hold on
        %xlim([0 17]);ylim([0 17])
        xylabel({'$\widehat{\sigma}_{z(s)}$','$\widehat{\sigma}_{e(s)}$'},xyFontSize,xyFontName,1.3,1)
        title('(a)','FontSize',SubFontSize,'FontName',SubFontName)
        if Save_fig == 1
            figname = 'fig05a';
            saveas(f,figname,figformat)
        end
        text(xoptez, xoptep, tname,'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters
        


%% PLOT Figure 5(b): Model-Data Fitting
iplot = iplot + 1;

% Data_type = [name_Macro_data; name_PPI_data; name_PCE_data];
[Range_Macro,Range_PPI,Range_PCE] = range_data(name_Macro_data,name_PPI_data,name_PCE_data,std_data);
Range_PPI_PCE = cell(2,1);
Range_PPI_PCE{1}=Range_PPI;
Range_PPI_PCE{2}=Range_PCE; 

Color_PPI_PCE = cell(2,1);
Color_PPI_PCE{1} = [0 ,0 ,0];
Color_PPI_PCE{2} = [0.2,0.3,1];

f=figure(iplot);
f.Position = fPosition1;
    % 45 degree
    plot(0:0.025:12,0:0.025:12,'LineWidth',1,'Color',[0,0,0],'LineStyle',':');
    set(gca,'xscale','log')
    set(gca,'yscale','log')
    hold on

    % PPI PCE
    Marker_PPI_PCE = {'o','^'};
    for kp = 1:size(Range_PPI_PCE,1)
    scatter(std_model(Range_PPI_PCE{kp}),std_data(Range_PPI_PCE{kp}),...
        40,'marker',Marker_PPI_PCE{kp},'MarkerEdgeColor',Color_PPI_PCE{kp},'MarkerFaceColor','none','LineWidth',1.2); hold on
    end
    set(gca,'xscale','log')
    set(gca,'yscale','log')

    % Macro var
    scatsymsize = [120,70,70]; scatsymb = {'x','+','s'};
    for k=1:numel(Range_Macro)
        scatter(std_model(Range_Macro(k)),std_data(Range_Macro(k)),...
            scatsymsize(k),'marker',scatsymb{k},'MarkerEdgeColor',[1,0,0],'MarkerFaceColor','none','LineWidth',1.5); hold on
    end

    % Contral figure appearance.
        xlim([0 12]);ylim([0 12])
        f_h_axe(Axis_FN,Axis_FS)
        legend('','Sectoral producer price inflation','Sectoral consumer price inflation','Growth rate of output','Growth rate of wage','Growth rate of labor hours',...
            'EdgeColor','n','FontSize',Legend_FS,'FontName',Legend_FN,'Location','NorthWest')
        xylabel({'Stdev, model','Stdev, data'},xyFontSize,{SubFontName,SubFontName})
        title('(b)','FontSize',SubFontSize,'FontName',SubFontName)
        if Save_fig == 1
            figname = 'fig05b';
            saveas(f,figname,figformat)
        end



%% PLOT Figure 6: model stdpic/stdpi vs sigma_e/sigma_z

aggregate_model = 1;

iplot = iplot + 1;
Plot_comwindow = 0;

% ind_irf_sector = [24,3,1,2,10,32]';
ind_irf_sector = [24,3,1,2,10]';
log_ind_irf_sector = zeros(S,1);
log_ind_irf_sector(ind_irf_sector) = 1;

std_pi_s  = std_model(Range_PPI);
std_pi_s  = std_pi_s(indfc_notzero);
std_pic_s = std_model(Range_PCE);

log_ind_irf_sector    = logical(log_ind_irf_sector(indfc_notzero));
log_ind_notirf_sector = logical(1-log_ind_irf_sector);

rel_sigep_sigez = sigep(indfc_notzero)./sigez(indfc_notzero);
rel_pics_pis    = std_pic_s./std_pi_s;

xdata=rel_sigep_sigez;     ydata = rel_pics_pis;
writematrix([xdata,ydata],'fig6_data.csv')
xmin=min(rel_sigep_sigez); xmax=max(rel_sigep_sigez);
% PLOT Scatter: model stdpic/stdpi vs sigma_e/sigma_z
f=figure(iplot);
f.Position = 1.039*fPosition1;
    % plotting approximate curve
        approx_xgrid = linspace(xmin,xmax,50)';
        approx_coeff = polyfit(xdata,ydata,2);
        approx_ygrid = polyval(approx_coeff, approx_xgrid);
        resultmdl = fitlm(xdata,ydata, 'poly2');
        Coeff = resultmdl.Coefficients.Estimate;
        SEs   = resultmdl.Coefficients.SE;
        pVals = resultmdl.Coefficients.pValue;
        R2ad  = resultmdl.Rsquared.Adjusted;
        
    if aggregate_model == 1
        load Result_run03_1.mat plot_xvals_cell_1 plot_yvals_cell_1
        model_xvals = plot_xvals_cell_1{1};
        model_yvals = plot_yvals_cell_1{1};
        plot(model_xvals, model_yvals,'Color',[0,0,0],'LineWidth',3.5,'LineStyle','-'); 
        hold on
        %plot(approx_xgrid, approx_ygrid,'Color',[0.4,0.65,1],'LineWidth',3.5,'LineStyle',':');
        plot(approx_xgrid, approx_ygrid,'Color',[0.4,0.65,1],'LineWidth',4,'LineStyle',':');
        hold on
    else
        plot(approx_xgrid, approx_ygrid,'Color',[0,0,0],'LineWidth',3.5); 
        hold on
    end    
    scatter(rel_sigep_sigez(log_ind_notirf_sector), rel_pics_pis(log_ind_notirf_sector),...
            90,'marker','x','MarkerEdgeColor',[0.58,0.58,0.58],'MarkerFaceColor','none','LineWidth',2); % [0.4,0.65,1]
        hold on
    scatter(rel_sigep_sigez(log_ind_irf_sector), rel_pics_pis(log_ind_irf_sector),...
            110,'marker','x','MarkerEdgeColor',[0.2,0.4,0.8],'MarkerFaceColor','none','LineWidth',2);% [1,0.6,0]
        hold on
    xlim([0 6])
    f_h_axe(Axis_FN,Axis_FS,AxisBoxRatio)
    xylabel({'$\displaystyle \widehat{\sigma}_{e(s)}/\widehat{\sigma}_{z(s)}$','$\displaystyle \frac{{\rm Stdev}[\pi^{\rm c}(s)]}{{\rm Stdev}[\pi(s)]}$'},xyFontSize,xyFontName,1,1,1)
    formatSpec_   = '%.2f';
    % legend('Model',['$ y = ',num2str(approx_coeff(3),formatSpec_),'  ',num2str(approx_coeff(2),formatSpec_),'x + ',num2str(approx_coeff(1),formatSpec_),'x^2$'],...
    %     'Interpreter','Latex','FontSize',1.18*Legend_FS,'EdgeColor','none','color','none')
     legend('Model, aggregate','Quadratic fit','FontName','Arial','FontSize',1.18*Legend_FS,'EdgeColor','none','color','none')
        if Save_fig == 1
            figname = 'fig06';
            saveas(f,figname,figformat)
        end
    sector_name_irf = sector_name(indfc_notzero);
    sector_name_irf = sector_name_irf(log_ind_irf_sector);
    text(rel_sigep_sigez(log_ind_irf_sector), rel_pics_pis(log_ind_irf_sector),sector_name_irf ,'Vert','bottom', 'Horiz','left','FontName', Textbox_FN, 'FontSize',Textbox_FS); % labels on scatters
        
    
    % Plot table command-window (Optional)
    if Plot_comwindow == 1

        stdmat      = [std_pic_s,std_pi_s];
        sigemat     = [sigez,sigep]; 
        sector_cell = {sector_code_PPI,sector_name_PPI};
        
        fprintf('\n')
        fprintf('%s %8s %-9s %40s %12s %12s %20s %12s\n',...
            '  ', 'GROUP', ' BEA CODE', 'SECTOR NAME', 'sigma_z(s)', 'sigma_e(s)', 'sigma_e(s)/sigma_z(s)', 'Data rel std')
        for j = 1:sum(indfc_notzero)
            plot_estim_modelstd(j,sigemat,stdmat,sector_cell,ind_x_to_sige_group_order,indfc_notzero)
        end
    end

save("Database_model.mat", "ind_irf_sector" ,"-append")

    

rmpath Utils

