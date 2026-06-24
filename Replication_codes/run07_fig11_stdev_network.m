clc
close all
clear
% This code plots Figures 11.
%
% PREAMBLE:
% This code plots inflation volatility across different network structures.
% Figures 11: Simulated inflation volatility across different network structures
%  Graph:     types of network graph.
%             0 for emprical graph (Benchmark),
%             1 for complete graph,
%             2 for isolated graph,
%             3 for star graph.
%
% ** NOTE: This code requires substantial computation time. **
%
% Code author: K. Hasui (Aichi University)


Run_dynare_modfile = 1; % Dynare is run if 1.
Save_fig  = 1;
figformat = 'svg';


%% 0: Load results

load Database_model.mat ALPHA_ paramsvec matscell S indfc_notzero V fc
load Database_estim.mat sector_name
load Result_run04_xopt.mat

addpath Utils

xoptez = xopt(1:ng);
xoptep = xopt(ng+1:end);
sigez = xoptez(ind_x_to_sige_group_order);
sigep = xoptep(ind_x_to_sige_group_order);
stdevvals = [sigez,sigep];

ind_omgvec = 1;
ind_gamvec = 2;

OMGs = matscell{ind_omgvec};
GAMs = matscell{ind_gamvec};

% (b) omegabar = sum_s v(s)*omega(s)
OMGbarvec = (V'*OMGs)*ones(S,1);

% (c) gammabar = sum_s fc(s)*gamma(s)
GAMbarvec_ = (fc'*GAMs)*ones(S,1);
GAMbarvec  = ones(S,1);
GAMbarvec(indfc_notzero) = GAMbarvec_(indfc_notzero);

oldcd = cd;

cd model_network/Output/
    load model_network_results.mat M_
    for im = 1:M_.endo_nbr
        eval(['ind_',M_.endo_names{im,:}, ' = im;']);
    end
cd(oldcd)
clear M_
    

%  Gtype:     types of network graph.
%             0 for emprical graph (Benchmark),
%             1 for complete graph,
%             2 for isolated graph,
%             3 for star graph.

%% (a) Benchmark

if Run_dynare_modfile == 1 % Run Dynare
    for Gtype = 0:3
        modfile_name = gen_mod(ALPHA_,paramsvec,matscell,Gtype,stdevvals);
        dynare(modfile_name)
    end
    stdev_pc_case_a = stdev_extract(oldcd,ind_pc,'a');
    stdev_paic_case_a = stdev_extract(oldcd,ind_paic,'a');
    stdev_pai_case_a = stdev_extract(oldcd,ind_pai,'a');
    stdev_p_case_a = stdev_extract(oldcd,ind_p,'a');
end

%% (b) for any omega(s) = omegabar

matscell_b = matscell;
matscell_b{ind_omgvec} = OMGbarvec;

if Run_dynare_modfile == 1
    for Gtype = 0:3
        modfile_name = gen_mod(ALPHA_,paramsvec,matscell_b,Gtype,stdevvals);
        dynare(modfile_name)
    end
    stdev_pc_case_b = stdev_extract(oldcd,ind_pc,'b');
    stdev_paic_case_b = stdev_extract(oldcd,ind_paic,'b');
    stdev_pai_case_b = stdev_extract(oldcd,ind_pai,'b');
    stdev_p_case_b = stdev_extract(oldcd,ind_p,'b');
end

%% (c) for any gamma(s) = gammabar

matscell_c = matscell;
matscell_c{ind_gamvec} = GAMbarvec;

if Run_dynare_modfile == 1 % Run Dynare
    for Gtype = 0:3
        modfile_name = gen_mod(ALPHA_,paramsvec,matscell_c,Gtype,stdevvals);
        dynare(modfile_name)
    end
    stdev_pc_case_c = stdev_extract(oldcd,ind_pc,'c');
    stdev_paic_case_c = stdev_extract(oldcd,ind_paic,'c');
    stdev_pai_case_c = stdev_extract(oldcd,ind_pai,'c');
    stdev_p_case_c = stdev_extract(oldcd,ind_p,'c');
end

%% (d) for any any omega(s) = omegabar && gamma(s) = gammabar

matscell_d = matscell;
matscell_d{ind_omgvec} = OMGbarvec;
matscell_d{ind_gamvec} = GAMbarvec;
if Run_dynare_modfile == 1
    for Gtype = 0:3
        modfile_name = gen_mod(ALPHA_,paramsvec,matscell_d,Gtype,stdevvals);
        dynare(modfile_name)
    end
    stdev_pc_case_d = stdev_extract(oldcd,ind_pc,'d');
    stdev_paic_case_d = stdev_extract(oldcd,ind_paic,'d');
    stdev_pai_case_d = stdev_extract(oldcd,ind_pai,'d');
    stdev_p_case_d = stdev_extract(oldcd,ind_p,'d');
end


%% save result
if Run_dynare_modfile == 1
    save Result_run07_ stdev_pc_case_a stdev_pc_case_b stdev_pc_case_c stdev_pc_case_d...
        stdev_paic_case_a stdev_paic_case_b stdev_paic_case_c stdev_paic_case_d...
        stdev_pai_case_a stdev_pai_case_b stdev_pai_case_c stdev_pai_case_d...
        stdev_p_case_a stdev_p_case_b stdev_p_case_c stdev_p_case_d
end


%% Figure Appearance Control:

iplot = 0;

figname_var = {'paic';'pai';'pc';'p'};

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
fPosition2 = [250 400 1600 500];
fPosition3 = [150 200 1400 350];
fPosition4 = [150 200 500 370];
fPosition5 = [150 200 430 370];

colorcell = cell(4,1);
colorcell{1} = [0.5,0.5,0.5];
colorcell{2} = [0.92,0.45,0.45];
colorcell{3} = [0.9,0.7,0];
colorcell{4} = [0.3,0.55,1];


load Result_run07_ stdev_pc_case_a stdev_pc_case_b stdev_pc_case_c stdev_pc_case_d...
    stdev_paic_case_a stdev_paic_case_b stdev_paic_case_c stdev_paic_case_d...
    stdev_pai_case_a stdev_pai_case_b stdev_pai_case_c stdev_pai_case_d...
    stdev_p_case_a stdev_p_case_b stdev_p_case_c stdev_p_case_d

ncase = numel(stdev_pc_case_a);
xlimupper = 2.6;
% xlimupperpai = 3;

   %% PLOT FIGURE: pi^c
iplot = iplot + 1;
f=figure('Name',['iplot = ',num2str(iplot),': ',figname_var{iplot}]);
f.Position = fPosition4;
    
    % Benchmark
    %subplot(1,3,1) 
    bcell = cell(ncase,1);
    for ip = 1:ncase
        b=barh(ip,stdev_paic_case_a(ip)/stdev_paic_case_a(2),0.65);
        hold on
        bcell{ip} = b;
    end
    xlim([0 xlimupper])
    f_h_axe(Axis_FN,Axis_FS)
    h_axes = gca;
    h_axes.YAxis.FontSize = 1.4*Axis_FS;
    h_axes.XAxis.FontSize = 1.1*Axis_FS;
    yticks([1,2,3,4])
    yticklabels({'Empirical graph','Complete graph','Isolated','Star graph'})
    for ip=1:ncase
        b = bcell{ip};
        set(b(1),"EdgeColor",colorcell{ip},'FaceColor',colorcell{ip})
        text(b(1).YEndPoints+xlimupper/35, b(1).XEndPoints, string(round(b(1).YData, 2)),...
            'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',1.2*Textbox_FS)
    end
    title('(a)','FontSize',SubFontSize,'FontName',SubFontName)
    xlabel('Stdev[$\pi^\mathrm{c}$], normalized','Interpreter','Latex','FontSize',1.2*SubFontSize)

    if Save_fig == 1
        figname = 'fig11a';
        saveas(f,figname,figformat)
    end


    %% PLOT FIGURE: pi
iplot = iplot + 1;
f=figure('Name',['iplot = ',num2str(iplot),': ',figname_var{iplot}]);
f.Position = fPosition5;

    % Benchmark
    %subplot(1,1,1)
    bcell = cell(ncase,1);
    for ip = 1:ncase
        b=barh(ip,stdev_pai_case_a(ip)/stdev_pai_case_a(2),0.65);
        hold on
        bcell{ip} = b;
    end
    xlim([0 xlimupper])
    f_h_axe(Axis_FN,Axis_FS)
    h_axes = gca;
    h_axes.YAxis.FontSize = 1.4*Axis_FS;
    h_axes.XAxis.FontSize = 1.1*Axis_FS;
    yticks([1,2,3,4])
    % yticklabels({'Empirical graph','Complete graph','Isolated','Star graph'})
    yticklabels({'               ','              ','        ','          '})
    for ip=1:ncase
        b = bcell{ip};
        set(b(1),"EdgeColor",colorcell{ip},'FaceColor',colorcell{ip})
        text(b(1).YEndPoints+xlimupper/35, b(1).XEndPoints, string(round(b(1).YData, 2)),...
            'VerticalAlignment','middle','FontName',Textbox_FN,'FontSize',1.2*Textbox_FS)
    end
    title('(b)','FontSize',SubFontSize,'FontName',SubFontName)
    xlabel('Stdev[$\pi$], normalized','Interpreter','Latex','FontSize',1.2*SubFontSize)

    if Save_fig == 1
        figname = 'fig11b';
        saveas(f,figname,figformat)
    end

