function plot_estim_modelstd(j,sigemat,stdmat,sector_cell,group_ind,indfc_notzero)
% This function plots estimation results on command window
% Code author: K. Hasui (Aichi University)


formatSpec_   = '%.2f';

% sector_name_PPI
% sector_code_PPI
% index = 1:numel(sigez);

% stdmat = [std_pic_s,std_pi_s];
% sigemat = [sigez,sigep]; 
% sector_cell = {sector_code_PPI,sector_name_PPI};

std_pic_s = stdmat(:,1);
std_pi_s = stdmat(:,2);

sigez=sigemat(:,1);
sigep=sigemat(:,2);

sigez_fc=sigez(indfc_notzero);
sigep_fc=sigep(indfc_notzero);

sector_code_PPI=sector_cell{1};
sector_name_PPI=sector_cell{2};

group_fc = group_ind(indfc_notzero);

relsig_fc = sigep_fc./sigez_fc;
sector_code_PPI_fc = sector_code_PPI(indfc_notzero);
sector_name_PPI_fc = sector_name_PPI(indfc_notzero);
relstd_fc = std_pic_s./std_pi_s;

% % if Plot_tab_comwindow == 1
    % formatSpec_   = '%.2f';
    % fprintf('\n')
    % fprintf('%s %8s %-9s %40s %12s %12s %20s %12s\n',...
    %     '  ', 'GROUP', ' BEA CODE', 'SECTOR NAME', 'sigma_z(s)', 'sigma_e(s)', 'sigma_e(s)/sigma_z(s)', 'Data rel std')
    % for j = 1:numel(sigez_fc)
        fprintf('%s %8s %9s %40s %12s %12s %20s %12s\n',...
        '  ',...
        num2str(group_fc(j)),...
        char(sector_code_PPI_fc(j)),...
        char(sector_name_PPI_fc(j)),...
        num2str(sigez_fc(j),formatSpec_),...
        num2str(sigep_fc(j),formatSpec_),...
        num2str(relsig_fc(j),formatSpec_),...
        num2str(relstd_fc(j),formatSpec_) );
    % end
% % end
