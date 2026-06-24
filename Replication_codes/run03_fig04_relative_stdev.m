clc
close all
clear
% This code plots Figure 4: sigma_pi/sigma_pi^c with respect to stde/stdz.
%
% SYSTEM REQUIREMENTS:
%   Dynare: 6.0 or 6.1 (Recommended)
%   MATLAB: 2023a (does not work after 2025a)
%
% 
% Code author: K. Hasui (Aichi University)

Save_fig = 1;

run_dynare_all = 1;


if run_dynare_all == 1

    % LOADING DATA
    oldFolder = cd;
    
    cd DATA/Aggregate_PCE_PPI
    dataname_PCE_PPI = 'Aggregate_PPI_PCE.xlsx';
    data_stdpic_over_stdpi = readmatrix(dataname_PCE_PPI,'Sheet',1,'Range','C2:C9');
    stage_name_PPI         =   readcell(dataname_PCE_PPI,'Sheet',1,'Range','A2:A9');
    cd(oldFolder)
    
    actual_rel_std_stage1 = data_stdpic_over_stdpi(1);
    actual_rel_std_stage4 = data_stdpic_over_stdpi(4);
    
    %% EXTRACT DYNARE RESULTS
    
    addpath Utils
    
    modnam_1  = 'model_network';

        dynare(modnam_1)
        addpath model_network/Output
        load model_network_results.mat M_ oo_
    
    % Extract variable names
    for ind_endo = 1:M_.endo_nbr
        eval(['ind_',M_.endo_names{ind_endo},' = ind_endo;',])
    end
    for ind_exo = 1:M_.exo_nbr
        eval(['ind_',M_.exo_names{ind_exo},' = ind_exo;',])
    end
    
    
    gridstep = 0.1;
    endgrid  = 10;
    
    sigep_grid = 0:gridstep:endgrid;
    % sigz_grid  = 0:gridstep:endgrid;
    
    % [sigep_mat,sigz_mat] = ndgrid(sigep_grid,sigz_grid);
    % sigep_vec = sigep_mat(:);
    % sigz_vec  = sigz_mat(:);
    
    
    
    sigz = 1;
    % Sigma_e_vec(ind_e_z1:ind_e_z66,:) = sigz^2;
    sigep_vec = sigep_grid;
    np = numel(sigep_vec);
    sigz_vec  = sigz*ones(1,np);
    
    rel_std_vec = zeros(size(sigep_vec));
    dr = oo_.dr;
    ne=size(diag(M_.Sigma_e),1);
    Sigma_e_vec = zeros(ne,1);
    for ip = 1:np
        sigep = sigep_vec(ip);
        sigz  = sigz_vec(ip);
        Sigma_e_vec(ind_e_ep1:ind_e_ep66,:) = sigep^2;
        Sigma_e_vec(ind_e_z1:ind_e_z66,:)   = sigz^2;
        M_.Sigma_e = diag(Sigma_e_vec);
        v = vcov(dr,M_,options_);
    
        std_paic = sqrt( v(ind_paic,ind_paic) );
        std_pai = sqrt( v(ind_pai,ind_pai) );
        % std_pai = sqrt( v(ind_paivg,ind_paivg) );
    
        rel_std_paic_over_pai = std_paic/std_pai;
        rel_std_vec(ip) = rel_std_paic_over_pai;
    end
    
    [rel_sigep_sigz, ind_descend] = sort(sigep_vec./sigz_vec,'descend');
    rel_std_vec = rel_std_vec(ind_descend);
    
    [Idx_stage1,~] = knnsearch(rel_std_vec',actual_rel_std_stage1);
    [Idx_stage4,~] = knnsearch(rel_std_vec',actual_rel_std_stage4);
    scat_vals_mat_1  = [rel_sigep_sigz(Idx_stage1),actual_rel_std_stage1; rel_sigep_sigz(Idx_stage4),actual_rel_std_stage4];
    
    plot_yvals_cell_1 = cell(5,1);
    plot_yvals_cell_1{1} = rel_std_vec;
    plot_yvals_cell_1{2} = actual_rel_std_stage1*ones(size(rel_sigep_sigz(Idx_stage1:end)));
    plot_yvals_cell_1{3} = actual_rel_std_stage4*ones(size(rel_sigep_sigz(Idx_stage4:end)));
    plot_yvals_cell_1{4} = linspace(0.1,actual_rel_std_stage1,size(rel_sigep_sigz(Idx_stage1:end),2));
    plot_yvals_cell_1{5} = linspace(0.1,actual_rel_std_stage4,size(rel_sigep_sigz(Idx_stage4:end),2));
    
    
    plot_xvals_cell_1 = cell(5,1);
    plot_xvals_cell_1{1} = rel_sigep_sigz;
    plot_xvals_cell_1{2} = rel_sigep_sigz(Idx_stage1:end);
    plot_xvals_cell_1{3} = rel_sigep_sigz(Idx_stage4:end);
    plot_xvals_cell_1{4} = rel_sigep_sigz(Idx_stage1)*ones(size(rel_sigep_sigz(Idx_stage1:end)));
    plot_xvals_cell_1{5} = rel_sigep_sigz(Idx_stage4)*ones(size(rel_sigep_sigz(Idx_stage4:end)));
    
    save Result_run03_1 plot_xvals_cell_1 plot_yvals_cell_1 scat_vals_mat_1
    clear rel_std_vec Idx_stage1 Idx_stage4 rel_sigep_sigz ind_descend
    


end



%% PLOT FIGURE

load Result_run03_1 plot_xvals_cell_1 plot_yvals_cell_1 scat_vals_mat_1
% load Result_run03_2 plot_xvals_cell_2 plot_yvals_cell_2 scat_vals_mat_2

iplot = 0;

% Figure Appearance Control:

    MainFontSize = 12;
    SubFontSize  = 15;
    MainFontName = 'Times';
    SubFontName  = 'Arial';
    
    % FN: Font mame,  FS: Font size
    [Axis_FN,Textbox_FN,xLabel_FN,yLabel_FN,Legend_FN] = figure_FN_control(MainFontName,SubFontName);
    [Axis_FS,Textbox_FS,xLabel_FS,yLabel_FS,Legend_FS] = figure_FS_control(MainFontSize,SubFontSize);
    xyFontSize = [1.15*xLabel_FS,1.15*yLabel_FS];
    xyFontName = {xLabel_FN,yLabel_FN};
    fPosition1 = [550 400 600 500];
    
    % LS: LineStyle, LC: LineColor, LW: LineWidth
    MainLS = '-';      SubLS  = ':';
    MainLC = [0,0,0];  SubLC  = [0,0,1];
    MainLW = 1.5;      SubLW = MainLW-0.1;
    nline  = size(plot_yvals_cell_1,1);
    [LWcell,LCcell,LScell] = figure_Line_control(MainLS,SubLS,MainLC,SubLC,MainLW,SubLW,nline);
        LCcell{3} = [0,0,1]; LCcell{4} = [0,0,1]; LCcell{5} = [0,0,1];
        LScell{3} = ':'; LScell{4} = ':'; LScell{5} = ':';
    figformat = 'svg';
    % figformat = 'fig';
    % figformat = 'png';
    % figformat = 'eps';


% Plot figure
iplot = iplot + 1;
f=figure(iplot);
f.Position = fPosition1;
for iplot = 1:nline
    plot(plot_xvals_cell_1{iplot}, plot_yvals_cell_1{iplot},'Color',LCcell{iplot},'LineStyle',LScell{iplot},'LineWidth',LWcell{iplot})
    hold on
end
for imkplot = 1:size(scat_vals_mat_1,1)
    plot(scat_vals_mat_1(imkplot,1), scat_vals_mat_1(imkplot,2),'Color',[0,0,1],'LineStyle','n','Marker','o','MarkerFaceColor',[0,0,1],'MarkerSize',15)
    hold on
end

    %scatter(scat_vals_mat_1(:,1),scat_vals_mat_1(:,2),85,'MarkerFaceColor',[0,0,0],'MarkerEdgeColor',[0,0,0]);
    f_h_axe(Axis_FN,Axis_FS)
    xylabel({'$\displaystyle \sigma_e/\sigma_z$','$\displaystyle \frac{\mathrm{Stdev}[\pi^{\mathrm{c}}]}{\mathrm{Stdev}[\pi]}$'},...
        0.85*xyFontSize,xyFontName,1.3,1,1)
    legend('Model, empirical network','FontName',Legend_FN,'FontSize',1.25*Legend_FS,'EdgeColor','none','Color','none')
    % xlim([0,10])
    if Save_fig == 1
        figname = 'fig04';
        saveas(f,figname,figformat)
    end


model_xvals = plot_xvals_cell_1{1}';
model_yvals = plot_yvals_cell_1{1}';

% Clear large sized variables:
clear rel_sigep_sigz sigep_vec sigz_vec rel_std_vec plot_yvals_cell_1
