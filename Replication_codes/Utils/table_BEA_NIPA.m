function table_BEA_NIPA(n1,n2,nupper_,data_flag_Weight,name_NIPA_BEA,tablabel,txtfilename)
capname1  = 'Correspondence between IO sectors and NIPA categories';
capname2  = '(Continued from previous page)';

% To make gray shaded area, redefine indices:
s = data_flag_Weight(:,4);
nbea = size(s,1);
indvec = zeros(nbea,1);
ind = 1;
sb_old = 1;
for b=1:nbea
    sb = s(b);
    if sb-sb_old > 0
        ind = ind + 1;
    end
    indvec(b) = ind;
    sb_old = sb;
end

% EXTRACT DATA
% index
BEAcode  = name_NIPA_BEA(:,3);
BEAname  = name_NIPA_BEA(:,5);
% name
NIPAcode = data_flag_Weight(:,1);
NIPAname = name_NIPA_BEA(:,2);
weightNIPA = data_flag_Weight(:,9);

flag = logical(data_flag_Weight(:,7));

% Re-define:
BEAcode  = BEAcode(flag);
BEAname  = BEAname(flag);

NIPAcode = NIPAcode(flag);
NIPAname = NIPAname(flag);
weightNIPA = weightNIPA(flag);
indvec = indvec(flag);


formatSpec_   = '%.3f';
indBEAold = 0;
oddsvec = 1:2:107;

    if n1 == 1
        fprintf(txtfilename,'%% NOTE: This table file is produced automatically by run_appendix.');
        fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);
    else
        fprintf(txtfilename,'%% Continued from previous table.');
    end
    fprintf(txtfilename,'\n');
    fprintf(txtfilename,['\n','\\begin{table}[t]']);
    fprintf(txtfilename,'\n    \\centering');
    if n1 == 1
        fprintf(txtfilename,['\n    \\caption{',capname1,'}']);
    else
        fprintf(txtfilename,['\n    {Table \\ref{',tablabel,'} ',capname2,'}']);
    end
    fprintf(txtfilename,'\n    \\fontsize{7pt}{7pt}\\selectfont');
    fprintf(txtfilename,'\n    %%\\scriptsize');
    fprintf(txtfilename,'\n    \\begin{tabular}{lp{40mm}lp{65mm}c}');
    fprintf(txtfilename,'\n        \\toprule');
    %fprintf(txtfilename,'\n        IO code & IO sector name & NIPA line & NIPA name & Weight \\\\');
    fprintf(txtfilename,'\n        \\multicolumn{2}{l}{\\hspace{4mm}IO matrix}  & \\multicolumn{2}{l}{\\hspace{4mm}NIPA Category} & Weights \\\\');
    fprintf(txtfilename,'\n        Code & Sector label & Code & Category label & \\\\');
    fprintf(txtfilename,'\n        \\hline');
    for j = n1:n2
        if sum(oddsvec==indvec(j)) == 1
            textc = '\\rowcolor{mygray}';
        else
            textc =  '                 ';
        end
        indBEAj = indvec(j);
        if indBEAj-indBEAold>0
            fprintf(txtfilename,['\n        ',textc,'    ',char(BEAcode(j)),' & ',char(BEAname(j)), ' & ', num2str(NIPAcode(j)),...
                ' & ', char(NIPAname(j)), ' & ', num2str(weightNIPA(j),formatSpec_),...
                '\\\\']);
        else
            fprintf(txtfilename,['\n        ',textc,'        &                 & ', num2str(NIPAcode(j)),...
                ' & ', char(NIPAname(j)), ' & ', num2str(weightNIPA(j),formatSpec_),...
                '\\\\']);
        end
        indBEAold = indBEAj;
    end
    fprintf(txtfilename,'\n        \\bottomrule');
    fprintf(txtfilename,'\n    \\end{tabular}');
    if n1 == 1
        fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
        fprintf(txtfilename,'\n    \\normalsize');
        fprintf(txtfilename,'\n    \\\\(\\emph{Continued})');
    elseif n2~=nupper_
        fprintf(txtfilename,'\n    \\normalsize');
        fprintf(txtfilename,'\n    \\\\(\\emph{Continued})');
    end
    fprintf(txtfilename,'\n\\end{table}');
    if n2==nupper_
        fprintf(txtfilename,'\n %%%%%% End table');
        fprintf(txtfilename,'\n\n\n\n\n');
    else
        fprintf(txtfilename,'\n\n');
    end
    
