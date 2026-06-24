function table_stickiness_weight(sector_code,sector_name,OMGs_tab,GAMs_tab,fc_tab,V_tab,filetitle,tablabel)

txtfilename  =   fopen(filetitle,'w');
formatSpec_   = '%.2f';
formatSpecfc_ = '%.2f';
formatSpecv_  = '%.2f';


S = size(fc_tab,1);


%tabname  =   fopen('Result_run03_estimation_table_tex.txt','w');
    fprintf(txtfilename,'%% NOTE: This table is produced automatically by run_appendix.m.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    fprintf(txtfilename,'\n    \\caption{Sectoral price stickiness, consumption share, and sales share}');
    fprintf(txtfilename,'\n    \\fontsize{8pt}{8pt}\\selectfont');
    fprintf(txtfilename,'\n    %%\\scriptsize');
    fprintf(txtfilename,'\n    %%\\renewcommand{\\arraystretch}{1.2}');
    fprintf(txtfilename,'\n    \\begin{tabular}{crp{55mm}cccc}');
    fprintf(txtfilename,'\n        \\toprule');
    fprintf(txtfilename,'\n        %% \\hline');
    fprintf(txtfilename,'\n        \\multicolumn{1}{c}{Sector} & \\multicolumn{2}{l}{\\hspace{8mm} IO matrix \\hspace{8mm} }  & \\multicolumn{2}{c}{Stickiness} &  Consumption &  Sales share \\\\');
    fprintf(txtfilename,'\n        \\multicolumn{1}{c}{Index}  & \\multicolumn{1}{c}{Code} & Sector label  &  $\\omega_s$ & $\\gamma_s$ &  share $f_s^{\\rm c}$ &  $v_s$ \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = 1:S
        if isnan(GAMs_tab(j))
            fprintf(txtfilename,['\n        ',num2str(j),...
            ' & ',char(sector_code(j)),...
            ' & ',char(sector_name(j)),...
            ' & $', num2str(   OMGs_tab(j),formatSpec_),'$ ',...
            ' & -- ',...
            ' & -- ',...
            ' & $', num2str(  V_tab(j),formatSpec_),'$ ',...
            '\\\\']);
        else
        fprintf(txtfilename,['\n        ',num2str(j),...
            ' & ',char(sector_code(j)),...
            ' & ',char(sector_name(j)),...
            ' & $', num2str(  OMGs_tab(j),formatSpec_ ),'$ ',...
            ' & $', num2str(  GAMs_tab(j),formatSpec_ ),'$ ',...
            ' & $', num2str(  fc_tab(j),formatSpecfc_),'$ ',...
            ' & $', num2str(  V_tab(j),formatSpecv_ ),'$ ',...
            '\\\\']);
        end
    end
    fprintf(txtfilename,'\n        %% \\hline');
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    fprintf(txtfilename,'\n\\end{table}');
    %disp('  Result_run01_top5_table.txt was produced successfully.')

fclose('all');