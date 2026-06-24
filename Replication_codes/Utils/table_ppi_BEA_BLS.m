function table_ppi_BEA_BLS(sector_code_name,stdev_BEA_BLS,txtfilename,txttitle,tablabel)

Code  = sector_code_name(:,2);
Name  = sector_code_name(:,3);

Index  = stdev_BEA_BLS(:,1);
ppiBEA = stdev_BEA_BLS(:,4);
ppiBLS = stdev_BEA_BLS(:,5);

N = numel(ppiBLS);

formatSpec_     = '%.2f';
% formatSpec_fc   = '%.3f';
% formatSpec_v    = '%.3f';

%tabname  =   fopen('Result_run03_estimation_table_tex.txt','w');
    fprintf(txtfilename,'%% NOTE: This table is produced automatically by run_appendix.m.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    fprintf(txtfilename,'\n    \\caption{Stdev of data for sectoral producer price inflation in BLS and BEA}');
    fprintf(txtfilename,'\n    \\fontsize{8pt}{8pt}\\selectfont');
    fprintf(txtfilename,'\n    \\begin{tabular}{crlrr}');
    fprintf(txtfilename,'\n        \\toprule');
    %fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n              &          &        & \\multicolumn{2}{c}{${\\rm Stdev}[\\pi_t(s)|_{\\rm data}]$} \\\\');
    fprintf(txtfilename,'\n        Index & BEA code & Sector label & \\multicolumn{1}{c}{BLS} & \\multicolumn{1}{c}{BEA} \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = 1:N
        if isnan(ppiBLS(j))
            fprintf(txtfilename,['\n        ',...
                  num2str(Index(j)),...
            ' & ',Code{j},...
            ' & ', Name{j},...
            ' & -- ',...
            ' & ', num2str(   ppiBEA(j),formatSpec_     ),...
            '\\\\']);
        else
            fprintf(txtfilename,['\n        ',...
                  num2str(Index(j)),...
            ' & ',Code{j},...
            ' & ', Name{j},...
            ' & ', num2str(   ppiBLS(j),formatSpec_     ),...
            ' & ', num2str(   ppiBEA(j),formatSpec_     ),...
            '\\\\']);
        end
        
    end
    %fprintf(txtfilename,'\n        \\hline');
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    % fprintf(txtfilename,['\n    \\caption{',capname,'}']);
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    fprintf(txtfilename,'\n\\end{table}');
    disp(['   ',txttitle,' was generated.'])
