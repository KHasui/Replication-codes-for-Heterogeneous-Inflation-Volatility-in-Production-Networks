function table_regression(Ptt0_,Ptt1_, fc_, OMGs_, GAMs_, GV_, StrengthG_, U_, filetitle, tablabel)
% This code derives latex-formed table for regression results of pass-through.
% Code author: K. Hasui (Aichi University)

ifc  = 2;
% iomg = 3;
igam = 4;
iGVU = 5;

% REGRESSION with MATLAB ROUTINE fitlm:
% (1) Weighted
mdl_case1_t0 = fitlm([fc_, OMGs_, GAMs_, GV_], Ptt0_); % for Pmathcal(t,t)
mdl_case1_t1 = fitlm([fc_, OMGs_, GAMs_, GV_], Ptt1_); % for Pmathcal(t,t+1)

% (2) Unweighted
mdl_case2_t0 = fitlm([fc_, OMGs_, GAMs_, StrengthG_],Ptt0_);
mdl_case2_t1 = fitlm([fc_, OMGs_, GAMs_, StrengthG_],Ptt1_);

% (3) Upstramnessns
mdl_case3_t0 = fitlm([fc_, OMGs_, GAMs_, U_],Ptt0_);
mdl_case3_t1 = fitlm([fc_, OMGs_, GAMs_, U_],Ptt1_);


% Extract results and re-construct:
% Coefficient
EstCoeffmat_t0 = [mdl_case1_t0.Coefficients.Estimate,  mdl_case2_t0.Coefficients.Estimate,  mdl_case3_t0.Coefficients.Estimate];
EstCoeffmat_t1 = [mdl_case1_t1.Coefficients.Estimate,  mdl_case2_t1.Coefficients.Estimate,  mdl_case3_t1.Coefficients.Estimate];
EstCoeffmat = [EstCoeffmat_t0(ifc:igam,:),EstCoeffmat_t1(ifc:igam,:);diag(EstCoeffmat_t0(iGVU,:)), diag(EstCoeffmat_t1(iGVU,:))];

% S.E.
SEmat_t0 = [mdl_case1_t0.Coefficients.SE,  mdl_case2_t0.Coefficients.SE,  mdl_case3_t0.Coefficients.SE];
SEmat_t1 = [mdl_case1_t1.Coefficients.SE,  mdl_case2_t1.Coefficients.SE,  mdl_case3_t1.Coefficients.SE];
SEmat = [SEmat_t0(ifc:igam,:),SEmat_t1(ifc:igam,:);diag(SEmat_t0(iGVU,:)), diag(SEmat_t1(iGVU,:))];

% pValue
pValmat_t0 = [mdl_case1_t0.Coefficients.pValue,  mdl_case2_t0.Coefficients.pValue,  mdl_case3_t0.Coefficients.pValue];
pValmat_t1 = [mdl_case1_t1.Coefficients.pValue,  mdl_case2_t1.Coefficients.pValue,  mdl_case3_t1.Coefficients.pValue];
    nt0 = numel(pValmat_t0(iGVU,:)); % diagonal size of G GV U
    nt1 = numel(pValmat_t1(iGVU,:)); % diagonal size of G GV U
    % To identify significance exactly, insert NaN for off diagonals:
    dpValmat_t0 = NaN*ones(nt0,nt0);
    dpValmat_t1 = NaN*ones(nt1,nt1);
    for it0 = 1:nt0
        dpValmat_t0(it0,it0) = pValmat_t0(iGVU,it0);
    end
    for it1 = 1:nt1
        dpValmat_t1(it1,it1) = pValmat_t1(iGVU,it1);
    end
pvalmat = [pValmat_t0(ifc:igam,:),pValmat_t1(ifc:igam,:);dpValmat_t0, dpValmat_t1];

significmat = zeros(size(pvalmat));
significmat(pvalmat < 0.1)  = 3; % insert 3 for 10 percent-significance.
significmat(pvalmat < 0.05) = 2; % insert 2 for  5 percent-significance.
significmat(pvalmat < 0.01) = 1; % insert 1 for  1 percent-significance.

significcell = cell(size(significmat));
for ii = 1:size(significmat,1)
    for jj = 1:size(significmat,2)
        if     significmat(ii,jj) == 1 % insert 3 for 10 percent-significance.
            significcell{ii,jj} = '^{\\ast\\ast\\ast}'; 
        elseif significmat(ii,jj) == 2 % insert 2 for  5 percent-significance.
            significcell{ii,jj} = '^{\\ast\\ast}';
        elseif significmat(ii,jj) == 3 % insert 1 for  1 percent-significance.
            significcell{ii,jj} = '^{\\ast}';
        else
            significcell{ii,jj} = ' ';
        end
    end
end

% Construct table including coefficient (SE) or ----- for NaN.
tablecell = cell(size(significcell));
formatSpec_   = '%.3f';
formatSpec_R   = '%.2f';
for ii=1:size(tablecell,1)
    for jj=1:size(tablecell,2)
        if isnan(pvalmat(ii,jj))
            tablecell{ii,jj} = ' ------ ';
        else
            tablecell{ii,jj} = ['$\\displaystyle \\underset{\\text{\\small (',num2str(SEmat(ii,jj),formatSpec_),')}}{{ ',num2str(EstCoeffmat(ii,jj),formatSpec_),'}}',significcell{ii,jj},'$'];
        end
    end
end

% Extract adjsuted Rsquared:
Rvec = [mdl_case1_t0.Rsquared.Adjusted, mdl_case2_t0.Rsquared.Adjusted, mdl_case3_t0.Rsquared.Adjusted,...
        mdl_case1_t1.Rsquared.Adjusted, mdl_case2_t1.Rsquared.Adjusted, mdl_case3_t1.Rsquared.Adjusted];

% Insert Name of explanatory variables
varcell1 = {'$\\vecfc$','$\\boldsymbol{\\omega}$','$\\boldsymbol{\\gamma}$','$\\vecG \\vecsales $','$\\vecG\\mathbf{1}$','$\\boldsymbol{u}$'};
% varcell2 = {'$\\vecG \\vecsales $','$\\vecG\\mathbf{1}$','$\\boldsymbol{u}$ &'};


%% WRITE TABLE:

txtfilename  =   fopen(filetitle,'w');

fprintf(txtfilename,'%% NOTE: This table is produced automatically by run06_figs09_and_10_passthrough.');
fprintf(txtfilename,['\n','%% Date: ',char(datetime('now'))]);

fprintf(txtfilename,'\n\\begin{table}[tb]');
fprintf(txtfilename,'\n    \\centering');
fprintf(txtfilename,'\n    \\caption{Determinants of the degree of cost-shock-induced pass-through.}');
fprintf(txtfilename,'\n    \\begin{tabular}{clllclll}');
fprintf(txtfilename,'\n    \\hline');
fprintf(txtfilename,'\n    \\hline');
fprintf(txtfilename,'\n        & \\multicolumn{3}{c}{$\\boldsymbol{\\mathcal{P}}_{t,t}$}  & & \\multicolumn{3}{c}{$\\boldsymbol{\\mathcal{P}}_{t,t+1}$}    \\\\ \\cline{2-4} \\cline{6-8}');
fprintf(txtfilename,'\n        & Weighted   & Unweighted & Upstreamness&  & Weighted    & Unweighted  & Upstreamness \\\\');
fprintf(txtfilename,'\n        \\hline');
% Insert results to Latex Table:
for ii=1:size(tablecell,1)
    fprintf(txtfilename,['\n        ',varcell1{ii},' &']);
    for jj=1:size(tablecell,2)
        if jj == 3
            fprintf(txtfilename,[' ',tablecell{ii,jj},' & &']);
        elseif jj==size(tablecell,2)
            fprintf(txtfilename,[' ',tablecell{ii,jj},' \\\\']);
        else
            fprintf(txtfilename,[' ',tablecell{ii,jj},' &']);
        end
    end
end
fprintf(txtfilename,'\n        $\\bar{R}^2$ &');
for kk=1:numel(Rvec)
    if kk==3
        fprintf(txtfilename,[' $\\text{ ',num2str(Rvec(kk),formatSpec_R),'}$ & &']);
    elseif kk==numel(Rvec)
        fprintf(txtfilename,[' $\\text{ ',num2str(Rvec(kk),formatSpec_R),'}$ \\\\']);
    else
        fprintf(txtfilename,[' $\\text{ ',num2str(Rvec(kk),formatSpec_R),'}$ &']);
    end
end
fprintf(txtfilename,'\n        \\hline');
fprintf(txtfilename,'\n    \\end{tabular}\\\\');
fprintf(txtfilename,'\n    \\flushleft{');
fprintf(txtfilename,'\n    \\footnotesize{');
fprintf(txtfilename,'\n    NOTE:     The coefficients in \\eqref{eq:reg_Gv} are estimated using OLS. ');
fprintf(txtfilename,['\n    The number of sectors used in the regression is ',num2str(numel(Ptt0_)),' (the sectors for which $\\fcs=0$ are excluded). ']);
fprintf(txtfilename,'\n    The (un)weighted and strengths are calculated based on the full 66-sector data to capture the importance of sectors in the producer market.');
fprintf(txtfilename,'\n    Standard errors in parentheses.');
fprintf(txtfilename,'\n    $^\\ast~p<0.1$, $^{\\ast\\ast}~p<0.05$, $^{\\ast\\ast\\ast}~p<0.01$.');
fprintf(txtfilename,'\n    }  }');
fprintf(txtfilename,['\n    \\label{',tablabel,'}']);
fprintf(txtfilename,'\n\\end{table}');

fopen('all');


