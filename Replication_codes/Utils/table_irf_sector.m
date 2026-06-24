function table_irf_sector(ind_sec_order,group_index,sigmat,fc,V,GAMs,OMGs,StrengthG,sector_name,filetitle,tablabel)

sigez = sigmat(:,1);
sigep = sigmat(:,2);

fc_sort          =          fc(ind_sec_order);
group_index_sort = group_index(ind_sec_order);

sigez_sort      =        sigez(ind_sec_order);
sigep_sort      =        sigep(ind_sec_order);
V_sort           =           V(ind_sec_order);
GAMs_sort        =        GAMs(ind_sec_order);
OMGs_sort        =        OMGs(ind_sec_order);
StrengthG_sort   =   StrengthG(ind_sec_order);

sector_name_sort = sector_name(ind_sec_order);
N = size(ind_sec_order,1);

txtfilename  =   fopen(filetitle,'w');
formatSpec_     = '%.2f';
formatSpec_fc   = '%.3f';
formatSpec_v    = '%.3f';

%tabname  =   fopen('Result_run05_estimation_table_tex.txt','w');
    fprintf(txtfilename,'%% NOTE: This table is produced automatically by run05_fig07_irf.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    
    fprintf(txtfilename,'\n');
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    fprintf(txtfilename,'\n    \\small');
    fprintf(txtfilename,'\n    \\begin{tabular}{clccccccc}');
    fprintf(txtfilename,'\n        \\toprule');
    %fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n        Group & Sector & $f_s^{\\rm c}$ & $v_s$ & $\\gamma_s$ & $\\omega_s$ & $\\sigma_{e(s)}$ & $\\sigma_{z(s)}$ & Strength \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = 1:N
        if fc_sort(j)==0
            fc_sortj_string = '---';
            GAMs_sortj_string = '---';
        else
            fc_sortj_string   = num2str(fc_sort(j),  formatSpec_fc);
            GAMs_sortj_string = num2str(GAMs_sort(j),formatSpec_);
        end
        fprintf(txtfilename,['\n        ',...
                  num2str(group_index_sort(j)),...
            ' & ',char(sector_name_sort(j)),...
            ' & ', fc_sortj_string,...
            ' & ', num2str(   V_sort(j),formatSpec_v     ),...
            ' & ', GAMs_sortj_string,...
            ' & ', num2str(   OMGs_sort(j),formatSpec_      ),...
            ' & ', num2str(   sigep_sort(j),formatSpec_      ),...
            ' & ', num2str(   sigez_sort(j),formatSpec_      ),...
            ' & ', num2str(   StrengthG_sort(j),formatSpec_ ),...
            '\\\\']);
    end
    %fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    % fprintf(txtfilename,['\n    \\caption{',capname,'}']);
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    fprintf(txtfilename,'\n\\end{table}');
    disp(['  ',filetitle,' was generated.'])
    fclose('all');