function table_estim_result(filename, estim_result_mat,estim_result_cell,...
    tablabel,capname,subtablabel,subcapname,derive_subtable)

% estim_result_mat  = [sect_index_ascend,ind_ascend,group_ascend,sigez_ascend,SEz_ascend,sigep_ascend,SEp_ascend,OMGs_ascend];
sect_index_ascend = estim_result_mat(:,1);
ind_ascend        = estim_result_mat(:,2);
group_ascend      = estim_result_mat(:,3);
sigez_ascend      = estim_result_mat(:,4);
SEz_ascend        = estim_result_mat(:,5);
sigep_ascend      = estim_result_mat(:,6);
SEp_ascend        = estim_result_mat(:,7);
OMGs_ascend       = estim_result_mat(:,8);

% estim_result_cell = [sector_code_ascend,sector_name_ascend];
sector_code_ascend = estim_result_cell(:,1);
sector_name_ascend = estim_result_cell(:,2);

nj = size(ind_ascend,1);
% group_ascend_old = 1;


formatSpec_   = '%.2f';

oddsvec = 1:2:19;

txtfilename = fopen(filename,'w');
%tabname  =   fopen('Result_run03_estimation_table_tex.txt','w');
    fprintf(txtfilename,'%% NOTE: This table file is produced automatically by run04_figs05_and_06_estimation.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    fprintf(txtfilename,'\n    \\fontsize{8pt}{8pt}\\selectfont');
    fprintf(txtfilename,'\n    %% \\scriptsize');
    fprintf(txtfilename,'\n    \\begin{tabular}{crlcc}');
    fprintf(txtfilename,'\n        \\toprule');
    fprintf(txtfilename,'\n        Group & BEA code & Sector Name & $\\sigma_{z(s)}$ \\ (S.E.) & $\\sigma_{e(s)}$ \\ (S.E.) \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = 1:nj
        % if group_ascend(j)-group_ascend_old > 0
        %     fprintf(txtfilename,'\n        \\hline');
        % end
        % if group_ascend(j) == any([1:2:11])
        if sum(oddsvec==group_ascend(j)) == 1
            textc = '\\rowcolor{mygray}';
        else
            textc =  '                 ';
        end

        fprintf(txtfilename,['\n        ',textc,'    ',num2str(group_ascend(j)),' & ',char(sector_code_ascend(j)), ' & ', char(sector_name_ascend(j)),...
            ' & ',...
            '$',num2str(sigez_ascend(j),formatSpec_),'\\ (',num2str(SEz_ascend(j),formatSpec_),')$',...
            ...'$\underset{(',num2str(sigez_ascend(j)),')}{',num2str(SEz_ascend(j)),'}$',...
            ' & ',...
            '$',num2str(sigep_ascend(j),formatSpec_),'\\ (',num2str(SEp_ascend(j),formatSpec_),')$',...
            ...'$\underset{(',num2str(sigep_ascend(j)),')}{',num2str(SEp_ascend(j)),'}$',...
            '\\\\']);
        % group_ascend_old = group_ascend(j);
    end
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    fprintf(txtfilename,['\n    \\caption{',capname,'}']);
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    fprintf(txtfilename,'\n\\end{table}');
fclose('all');
disp(['  ',filename,' was produced successfully.'])





if derive_subtable == 1

    subfilename = 'Result_run02_subtable_tex.txt';
    txtsubfilename = fopen(subfilename,'w');
    %tabname  =   fopen('Result_run03_estimation_table_tex.txt','w');
        fprintf(txtsubfilename,'%% NOTE: This txt file is produced automatically by run04_figs05_and_06_estimation.');
        fprintf(txtsubfilename,['\n','%% Date: ',char(datetime('now'))]);
        
        fprintf(txtsubfilename,'\n');
        fprintf(txtsubfilename,['\n','\\begin{table}[t]']);
        fprintf(txtsubfilename,'\n    \\centering');
        fprintf(txtsubfilename,'\n    \\scriptsize');
        fprintf(txtsubfilename,'\n    \\begin{tabular}{ccrlccc}');
        fprintf(txtsubfilename,'\n        \\toprule');
        fprintf(txtsubfilename,'\n        Index & Group & BEA code & Sector Name & $\\sigma_z(s)$ \\ (S.E.) & $\\sigma_e(s)$ \\ (S.E.) & $\\omega(s)$ \\\\');
        fprintf(txtsubfilename,'\n        \\hline');
        for j = 1:nj
            % if group_ascend(j)-group_ascend_old > 0
            %     fprintf(txtfilename,'\n        \\hline');
            % end
            % if group_ascend(j) == any([1:2:11])
            if sum(oddsvec==group_ascend(j)) == 1
                textc = '\\rowcolor{mygray}';
            else
                textc =  '                 ';
            end
            fprintf(txtsubfilename,['\n        ',textc,'    ',num2str(sect_index_ascend(j)),' & ',num2str(group_ascend(j)),' & ',char(sector_code_ascend(j)), ' & ', char(sector_name_ascend(j)),...
                ' & ',...
                '$',num2str(sigez_ascend(j),formatSpec_),'\\ (',num2str(SEp_ascend(j),formatSpec_),')$',...
                ' & ',...
                '$',num2str(sigep_ascend(j),formatSpec_),'\\ (',num2str(SEp_ascend(j),formatSpec_),')$',...
                ...'$\underset{(',num2str(sigez_ascend(j)),')}{',num2str(SEz_ascend(j)),'}$',...
                ' & ',...
                '$',num2str(OMGs_ascend(j),formatSpec_),'$',...
                ...'$\underset{(',num2str(sigep_ascend(j)),')}{',num2str(SEp_ascend(j)),'}$',...
                '\\\\']);
            % group_ascend_old = group_ascend(j);
        end
        fprintf(txtsubfilename,'\n        \\bottomrule');
        fprintf(txtsubfilename,'\n    \\end{tabular}');
        fprintf(txtsubfilename,['\n    \\caption{',subcapname,'}']);
        fprintf(txtsubfilename,['\n    \\label{',subtablabel,'}']);
        fprintf(txtsubfilename,'\n\\end{table}');
    
    
    
    
    
    
    
    fprintf(txtsubfilename,'\n\n\n\n');
    
    [OMGs_omgascend,ind_omgs] = sort(OMGs_ascend,'ascend');
    sect_index_omgascend  = sect_index_ascend(ind_omgs);
    group_omgascend       = group_ascend(ind_omgs);
    sector_code_omgascend = sector_code_ascend(ind_omgs);
    sector_name_omgascend = sector_name_ascend(ind_omgs);
    sigez_omgascend = sigez_ascend(ind_omgs);
    sigep_omgascend = sigep_ascend(ind_omgs);
    % std_ppi_omgascend     = std_ppi_ascend(ind_omgs);
        fprintf(txtsubfilename,'%% NOTE: This txt file is produced automatically by run04_figs05_and_06_estimation.');
        fprintf(txtsubfilename,['\n','%% Date: ',char(datetime('now'))]);
        
        fprintf(txtsubfilename,'\n');
        fprintf(txtsubfilename,['\n','\\begin{table}[t]']);
        fprintf(txtsubfilename,'\n    \\centering');
        fprintf(txtsubfilename,'\n    \\scriptsize');
        fprintf(txtsubfilename,'\n    \\begin{tabular}{ccrlccc}');
        fprintf(txtsubfilename,'\n        \\toprule');
        fprintf(txtsubfilename,'\n        Index & Group & BEA code & Sector Name & $\\sigma_z(s)$ \\ (S.E.) & $\\sigma_e(s)$ \\ (S.E.) & $\\omega(s)$ \\\\');
        fprintf(txtsubfilename,'\n        \\hline');
        for j = 1:nj
            % if group_ascend(j)-group_ascend_old > 0
            %     fprintf(txtfilename,'\n        \\hline');
            % end
            % if group_ascend(j) == any([1:2:11])
            % if sum(oddsvec==group_ascend(j)) == 1
            %     textc = '\\rowcolor{mygray}';
            % else
            %     textc =  '                 ';
            % end
            fprintf(txtsubfilename,['\n        ',textc,'    ',num2str(sect_index_omgascend(j)),' & ',num2str(group_omgascend(j)),' & ',char(sector_code_omgascend(j)), ' & ', char(sector_name_omgascend(j)),...
                ' & ',...
                '$',num2str(sigez_omgascend(j),formatSpec_),'\\ (',num2str(SEz_ascend(j),formatSpec_),')$',...
                ' & ',...
                '$',num2str(sigep_omgascend(j),formatSpec_),'\\ (',num2str(SEp_ascend(j),formatSpec_),')$',...
                ...'$\underset{(',num2str(sigez_ascend(j)),')}{',num2str(SEz_ascend(j)),'}$',...
                ' & ',...
                '$',num2str(OMGs_omgascend(j),formatSpec_),'$',...
                ...'$\underset{(',num2str(sigep_ascend(j)),')}{',num2str(SEp_ascend(j)),'}$',...
                '\\\\']);
            % group_ascend_old = group_ascend(j);
        end
        fprintf(txtsubfilename,'\n        \\bottomrule');
        fprintf(txtsubfilename,'\n    \\end{tabular}');
        fprintf(txtsubfilename,['\n    \\caption{',subcapname,'}']);
        fprintf(txtsubfilename,['\n    \\label{',subtablabel,'}']);
        fprintf(txtsubfilename,'\n\\end{table}');
    
    fclose('all');
    %disp('  Result_run02_subtable_tex.txt was produced successfully.')

end
