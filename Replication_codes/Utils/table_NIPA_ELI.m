function table_NIPA_ELI(n1,n2,nupper_,data_Freq_Weight,name_ELI_NIPA,tablabel,txtfilename)

capname1  = 'Correspondence between NIPA categories and ELI categories';
capname2  = '(Continued from previous page)';

% Extract data:
% index
indNIPA = data_Freq_Weight(:,1);
indELI  = name_ELI_NIPA(:,2);
% name
nameNIPA = name_ELI_NIPA(:,4);
nameELI  = name_ELI_NIPA(:,1);
% weight
weightELI = data_Freq_Weight(:,6);

formatSpec_   = '%.3f';
indNIPAold = 0;

indNIPA_unique = unique(indNIPA);
ind_odd = 1:2:numel(indNIPA_unique);
oddsvec = indNIPA_unique(ind_odd);
%oddsvec = 1:2:201;


    if n1 == 1
        fprintf(txtfilename,'%% NOTE: This table is produced automatically by run_appendix.');
        fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    else
        fprintf(txtfilename,'%% Continued from previous table.');
    end
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    if n1 == 1
        fprintf(txtfilename,['\n    \\caption{',capname1,'}']);
    else
        fprintf(txtfilename,['\n    {Table \\ref{',tablabel,'} ',capname2,'}']);
    end
    fprintf(txtfilename,'\n    \\fontsize{7pt}{7pt}\\selectfont');
    fprintf(txtfilename,'\n    %%\\scriptsize');
    fprintf(txtfilename,'\n    \\begin{tabular}{cp{45mm}lp{65mm}c}');
    fprintf(txtfilename,'\n        \\toprule');
    fprintf(txtfilename,'\n        \\multicolumn{2}{l}{\\hspace{4mm}NIPA Category}  & \\multicolumn{2}{l}{\\hspace{4mm}ELI Category} & Weights \\\\');
    fprintf(txtfilename,'\n        Code & Category label & Code & Category label & \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = n1:n2
        if sum(oddsvec==indNIPA(j)) == 1
            textc = '\\rowcolor{mygray}';
        else
            textc =  '                 ';
        end
        indNIPAj = indNIPA(j);
        if indNIPAj-indNIPAold>0
            fprintf(txtfilename,['\n        ',textc,'    ',num2str(indNIPAj),' & ',char(nameNIPA(j)), ' & ', char(indELI(j)),...
                ' & ', char(nameELI(j)), ' & ', num2str(weightELI(j),formatSpec_),...
                '\\\\']);
        else
            fprintf(txtfilename,['\n        ',textc,'        &                 & ', char(indELI(j)),...
                ' & ', char(nameELI(j)), ' & ', num2str(weightELI(j),formatSpec_),...
                '\\\\']);
        end
        indNIPAold = indNIPAj;
    end
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    if n1 == 1
        fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
        fprintf(txtfilename,'\n    \\normalsize');
        fprintf(txtfilename,'\n    \\\\(\\emph{Continued})');
    elseif n2 ~= nupper_
        fprintf(txtfilename,'\n    \\normalsize');
        fprintf(txtfilename,'\n    \\\\(\\emph{Continued})');
    end
    fprintf(txtfilename,'\n\\end{table}');
    if n2 == nupper_
        fprintf(txtfilename,'\n %%%% End Table');
        fprintf(txtfilename,'\n\n\n');
    else
        fprintf(txtfilename,'\n\n');
    end

