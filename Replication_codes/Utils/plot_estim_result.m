function plot_estim_result(j,estim_result_mat,estim_result_cell)
% This function plots estimation results on command window
% Code author: K. Hasui (Aichi University)


formatSpec_   = '%.2f';

% estim_result_mat  = [sect_index_ascend,ind_ascend,group_ascend,sigez_ascend,SEz_ascend,sigep_ascend,SEp_ascend,OMGs_ascend];
group_ascend      = estim_result_mat(:,3);
sigez_ascend      = estim_result_mat(:,4);
SEz_ascend        = estim_result_mat(:,5);
sigep_ascend      = estim_result_mat(:,6);
SEp_ascend        = estim_result_mat(:,7);

% estim_result_cell = [sector_code_ascend,sector_name_ascend];
sector_code_ascend = estim_result_cell(:,1);
sector_name_ascend = estim_result_cell(:,2);

fprintf('%s %8s %9s %40s %12s (%s) %12s (%s)\n',...
        '  ',...
        num2str(group_ascend(j)),...
        char(sector_code_ascend(j)),...
        char(sector_name_ascend(j)),...
        num2str(sigez_ascend(j),formatSpec_),...
        num2str(SEz_ascend(j),formatSpec_),...
        num2str(sigep_ascend(j),formatSpec_),...
        num2str(SEp_ascend(j),formatSpec_) );