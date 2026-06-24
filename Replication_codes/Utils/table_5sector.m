function table_5sector(ind_sec_order,fc,V,GAMs,OMGs,StrengthG,sector_name,filetitle,tablabel)

fc_sort               = fc(ind_sec_order);
V_sort                 = V(ind_sec_order);
GAMs_sort           = GAMs(ind_sec_order);
OMGs_sort           = OMGs(ind_sec_order);
StrengthG_sort = StrengthG(ind_sec_order);

sector_name_sort = sector_name(ind_sec_order);
N = size(ind_sec_order,1);

txtfilename  =   fopen(filetitle,'w');
formatSpec_   = '%.2f';

%tabname  =   fopen('Result_run03_estimation_table_tex.txt','w');
    fprintf(txtfilename,'%% NOTE: This txt file is produced automatically by run_03_plot_irf.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    
    fprintf(txtfilename,'\n');
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    fprintf(txtfilename,'\n    \\small');
    fprintf(txtfilename,'\n    \\begin{tabular}{clccccc}');
    fprintf(txtfilename,'\n        %% \\toprule');
    fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n        Index & Sector & $f_s^{\\rm c}$ & $v_s$ & $\\gamma_s$ & $\\omega_s$ & Strength \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = 1:N
        fprintf(txtfilename,['\n        ',num2str(ind_sec_order(j)),...
            ' & ',char(sector_name_sort(j)),...
            ' & ', num2str(   fc_sort(j),formatSpec_        ),...
            ' & ', num2str(   V_sort(j),formatSpec_         ),...
            ' & ', num2str(   GAMs_sort(j),formatSpec_      ),...
            ' & ', num2str(   OMGs_sort(j),formatSpec_      ),...
            ' & ', num2str(   StrengthG_sort(j),formatSpec_ ),...
            '\\\\']);
    end
    fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n        %% \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    % fprintf(txtfilename,['\n    \\caption{',capname,'}']);
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    fprintf(txtfilename,'\n\\end{table}');
    disp('  Result_run03_top5_table.txt was produced successfully.')