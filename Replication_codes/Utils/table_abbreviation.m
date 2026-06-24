function table_abbreviation(sector_labels,tablabel,txtfilename,tabtype)

% capname1  = 'Correspondence between NIPA categories and ELI categories';
% capname2  = '(Continued from previous page)';
% formatSpec_   = '%.3f';

nsec = size(sector_labels,1);
Original_format_ = sector_labels(:,2);
Abbreviation_ = sector_labels(:,1);

if tabtype == 1
    fprintf(txtfilename,'%% NOTE: This txt file is produced automatically by run_appendix.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    fprintf(txtfilename,'\n \\begin{table}[t]');
    fprintf(txtfilename,'\n     \\centering');
    fprintf(txtfilename,'\n     \\fontsize{7pt}{7pt}\\selectfont');
    fprintf(txtfilename,'\n     \\caption{Abbreviation of sector labels}');
    fprintf(txtfilename,'\n     %% \\tiny');
    fprintf(txtfilename,'\n     %% \\renewcommand{\\arraystretch}{1.2}');
    fprintf(txtfilename,'\n     \\begin{tabular}{|c|>{\\raggedleft }p{80mm}|p{65mm}|}');
    fprintf(txtfilename,'\n     \\hline ');
    fprintf(txtfilename,'\n     Index & \\multicolumn{2}{c|}{Sector label }  \\\\');
    fprintf(txtfilename,'\n     \\cline{2-3}');
    fprintf(txtfilename,'\n      & \\multicolumn{1}{c|}{Original format} & \\multicolumn{1}{c|}{Abbreviation}  \\\\');
    fprintf(txtfilename,'\n     \\hline');
    for j = 1:nsec
        fprintf(txtfilename,['\n     ',num2str(j),' & ',char(Original_format_(j)),' & ',char(Abbreviation_(j)),' \\\\']);
    end
    fprintf(txtfilename,'\n     \\hline');
    fprintf(txtfilename,'\n     \\end{tabular}');
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    % fprintf(txtfilename,'    \\label{tab:abb}'); 
    fprintf(txtfilename,'\n \\end{table}');

elseif tabtype == 2

    fprintf(txtfilename,'%% NOTE: This txt file is produced automatically by run_appendix.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    fprintf(txtfilename,'\n \\begin{table}[t]');
    fprintf(txtfilename,'\n     \\centering');
    fprintf(txtfilename,'\n     \\fontsize{7pt}{7pt}\\selectfont');
    fprintf(txtfilename,'\n     \\caption{Abbreviation of sector labels}');
    fprintf(txtfilename,'\n     %% \\tiny');
    fprintf(txtfilename,'\n     %% \\renewcommand{\\arraystretch}{1.2}');
    fprintf(txtfilename,'\n     %% \\begin{tabular}{|c|>{\\raggedleft }p{80mm}|p{65mm}|}');
    fprintf(txtfilename,'\n     \\begin{tabular}{|rcp{70mm}|}');
    fprintf(txtfilename,'\n     \\hline ');
    fprintf(txtfilename,'\n     %% \\multicolumn{3}{|c|}{Sector label }  \\\\');
    fprintf(txtfilename,'\n     %% \\cline{1-3}');
    fprintf(txtfilename,'\n     \\multicolumn{1}{|c}{Original format} & & \\multicolumn{1}{c|}{Abbreviation}  \\\\');
    fprintf(txtfilename,'\n     \\hline');
    for j = 1:nsec
        fprintf(txtfilename,['\n     ',char(Original_format_(j)),' & ',num2str(j),' & ',char(Abbreviation_(j)),' \\\\']);
    end
    fprintf(txtfilename,'\n     \\hline');
    fprintf(txtfilename,'\n     \\end{tabular}');
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    % fprintf(txtfilename,'    \\label{tab:abb}'); 
    fprintf(txtfilename,'\n \\end{table}');

else

    fprintf(txtfilename,'%% NOTE: This txt file is produced automatically by run_appendix.');
    fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    fprintf(txtfilename,'\n \\begin{table}[t]');
    fprintf(txtfilename,'\n     \\centering');
    fprintf(txtfilename,'\n     \\fontsize{7pt}{7pt}\\selectfont');
    fprintf(txtfilename,'\n     \\caption{Abbreviation of sector labels}');
    fprintf(txtfilename,'\n     \\tiny');
    fprintf(txtfilename,'\n     %% \\renewcommand{\\arraystretch}{1.2}');
    fprintf(txtfilename,'\n     \\begin{tabular}{|c|>{\\raggedleft }p{80mm}|p{65mm}|}');
    fprintf(txtfilename,'\n     \\hline ');
    fprintf(txtfilename,'\n     Index & \\multicolumn{2}{c|}{Sector label }  \\\\');
    fprintf(txtfilename,'\n     \\cline{2-3}');
    fprintf(txtfilename,'\n      & \\multicolumn{1}{c|}{Original format} & \\multicolumn{1}{c|}{Abbreviation}  \\\\');
    fprintf(txtfilename,'\n     \\hline');
    for j = 1:nsec
        fprintf(txtfilename,['\n     ',num2str(j),' & ',char(Original_format_(j)),' & ',char(Abbreviation_(j)),' \\\\']);
    end
    fprintf(txtfilename,'\n     \\hline');
    fprintf(txtfilename,'\n     \\end{tabular}');
    fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
    % fprintf(txtfilename,'    \\label{tab:abb}'); 
    fprintf(txtfilename,'\n \\end{table}');

end


