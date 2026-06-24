function [modfile_name, folder_name, loadmat_name, savemat_name]...
    = gen_mod_chain(ALPHA_,paramsvec,matscell,G,CHI_,indCHI,U,length_,stdevvals)
% This function produces dynare modfile given model parametwer and IO matrix.
% Inputs: 
%  ALPHA_: labor share in product function
%  paramsvec: vector of deep params (not sectoral parameters)
%  matscell:  vector of sectoral params (sectoral stickness, IO matrix, etc...)
%  stdevvals: standard deviations for ez(s) and ep(s). 
%             stdevvals = [sigz,sige].
%  G:         IO network
%  CHI_:      degree of chain (vector)
%  indCHI:    index of CHI_
%  U:         upstreamness from spring rank
% Output:
%  modfile_name: string of dynare modfile name.
%  This function produces dynare modfile with modfile_name.
%
%  Code author: Kohei Hasui (Aichi University)

% if nargin < 4, Gtype = NaN; end % Network is benchmark case.
if nargin < 9, stdevvals = ones(paramsvec(6),2); end % stderr 1 for e_z(s) and e_ep(s).

% Extract deep params
% paramsvec = [BETA_,NU_,SIGMA_,RHOZ,RHOEP,S,k_upper];

BETA_   = paramsvec(1);
NU_     = paramsvec(2);
SIGMA_  = paramsvec(3);
RHOZ    = paramsvec(4);
RHOEP   = paramsvec(5);
S       = paramsvec(6);
k_upper = paramsvec(7);

% stdevvals = [sigz,sige];
sigz = stdevvals(:,1);
sige = stdevvals(:,2);

% Extract matrices
% matscell = {OMGs,GAMs,GG,GGT,fc,Igg,ind_PCE_1};

OMGs = matscell{1};
GAMs = matscell{2};

CHI_i = CHI_(indCHI);

[~, ind_descend] = sort(U,'descend');

data_index = 1:S;
Nstage = 4;
[data_stage, ~] = discretize(data_index, Nstage);

[~, ind_for_stage] = sort(ind_descend,'ascend');
stage_ = data_stage(ind_for_stage)';

W = zeros(S,S);
if length_ == 1
    for ii = 1:S
        for jj = 1:S
            if stage_(jj) == stage_(ii)+1
            % W(ii,jj) = exp(CHI_i*(stage_(jj)-stage_(ii)));
                W(ii,jj) = 1;
            end
        end
    end
else
    for ii = 1:S
        for jj = 1:S
            if stage_(jj)==4 && stage_(ii)==1
            % W(ii,jj) = exp(CHI_i*(stage_(jj)-stage_(ii)));
                W(ii,jj) = 1;
            end
        end
    end

end

GG_ = G.*exp(CHI_i*W);
GG  = GG_./sum(GG_,1);
GGT = GG';

    % if Gtype == 1 % Complete Graph
    %     GG = 1/S*ones(S,S);
    %     GGT = GG';
    % elseif Gtype == 2 % Isolated Graph
    %     GG = eye(S,S);
    %     GGT = GG';
    % elseif Gtype == 3 % Star Graph
    %     [~,index_maximum_strength] = max(sum(matscell{3},2));
    %     GG = zeros(S,S);
    %     GG(index_maximum_strength,:) = ones(1,S);
    %     GGT = GG';
    % elseif Gtype == 4 % Line (Cycle) Graph
    %     GG = circshift(eye(S), -1);
    %     GGT = GG';
    % else % BENCHMARK!!
    %     GG   = matscell{3};
    %     GGT  = matscell{4};
    % end

fc   = matscell{5};
Igg  = matscell{6};
ind_PCE_1 = matscell{7};

V    = ALPHA_*(  ( (Igg - (1-ALPHA_)*GG) )\fc  );
VTGT = (V')*(GG');

% save Result_run01_IO_data Igg G GG GGT fc OMGs GAMs VG
% save("Database_model.mat", "Igg","G","GG","GGT","fc","OMGs","GAMs","VG" ,"-append")


%% Writing DYNARE MOD file

modfile_name = ['model_network_L_',num2str(length_),'_chi_',num2str(indCHI),'.mod'];
folder_name  = ['model_network_L_',num2str(length_),'_chi_',num2str(indCHI),'/Output'];
loadmat_name = ['model_network_L_',num2str(length_),'_chi_',num2str(indCHI),'_results.mat'];
savemat_name = ['result_model_network_L_',num2str(length_),'_chi_',num2str(indCHI),'.mat'];


% % Generate dynare mod file automatically.
% if ALPHA_ == 1 % Without network case
%     modfile_name = 'model_wo_network.mod';
% elseif Gtype == 0 % Complete Graph
%     modfile_name = 'model_network_emp.mod';
% elseif Gtype == 1 % Complete Graph
%     modfile_name = 'model_network_comp.mod';
% elseif Gtype == 2 % Isolated Graph
%     if nargin < 5
%         modfile_name = 'model_network_iso1.mod';
%     else
%         modfile_name = 'model_network_iso.mod';
%     end
% elseif Gtype == 3 % Star Graph
%     modfile_name = 'model_network_star.mod';
% elseif Gtype == 4 % Line (Cycle) Graph
%     modfile_name = 'model_network_line.mod';
% else % BENCHMARK!!
%     modfile_name = 'model_network.mod';
% end

    diary(modfile_name)
    diary off
    modname = fopen(modfile_name,'w');

 
fprintf(modname,'// NOTE: This mod file is produced automatically.');
fprintf(modname,['\n','// Date: ',char(datetime('now'))]);

%% Declare Endogenous variables
fprintf(modname,['\n\n','var mbar c dc y r ell dell wc w dw']);

str_mc = '\n';
for s = 1:S,str_mc = append(str_mc,['mc',num2str(s),' ']); end
fprintf(modname,str_mc);

fprintf(modname,['\n','pc p pv']);

str_pc = '\n';
for s = 1:S,str_pc = append(str_pc,['pc',num2str(s),' ']); end
fprintf(modname,str_pc);

str_p = '\n';
for s = 1:S,str_p = append(str_p,['p',num2str(s),' ']); end
fprintf(modname,str_p);

fprintf(modname,['\n','pf pcf']);

str_pf_k = '\n';
for k = 0:k_upper,str_pf_k = append(str_pf_k,['pf_k',num2str(k),' ']); end
fprintf(modname,str_pf_k);

str_pcf_k = '\n';
for k = 0:k_upper,str_pcf_k = append(str_pcf_k,['pcf_k',num2str(k),' ']); end
fprintf(modname,str_pcf_k);

str_paicf_k = '\n';
for k = 0:k_upper,str_paicf_k = append(str_paicf_k,['paicf_k',num2str(k),' ']); end
fprintf(modname,str_paicf_k);


fprintf(modname,['\n','paic pai paiv']);

str_paic = '\n';
for s = 1:S,str_paic = append(str_paic,['paic',num2str(s),' ']); end
fprintf(modname,str_paic);

str_pai = '\n';
for s = 1:S,str_pai = append(str_pai,['pai',num2str(s),' ']); end
fprintf(modname,str_pai);

str_ptilde = '\n';
for s = 1:S,str_ptilde = append(str_ptilde,['ptilde',num2str(s),' ']); end
fprintf(modname,str_ptilde);

str_paitilde = '\n';
for s = 1:S,str_paitilde = append(str_paitilde,['paitilde',num2str(s),' ']); end
fprintf(modname,str_paitilde);

str_ptildec = '\n';
for s = 1:S,str_ptildec = append(str_ptildec,['ptildec',num2str(s),' ']); end
fprintf(modname,str_ptildec);

str_z = '\n';
for s = 1:S,str_z = append(str_z,['z',num2str(s),' ']); end
fprintf(modname,str_z);

str_ep = '\n';
for s = 1:S,str_ep = append(str_ep,['ep',num2str(s),' ']); end
fprintf(modname,str_ep);

fprintf(modname,['\n','rn cn chat']);
% phat - phatc
str_rphat = '\n';
for s = 1:S,str_rphat = append(str_rphat,['rphat',num2str(s),' ']); end
fprintf(modname,str_rphat);
fprintf(modname,';\n');


%% Declare disturbances
fprintf(modname,['\n','varexo e_m']);

str_ez = '\n';
for s = 1:S,str_ez = append(str_ez,['e_z',num2str(s),' ']); end
fprintf(modname,str_ez);

str_eep = '\n';
for s = 1:S,str_eep = append(str_eep,['e_ep',num2str(s),' ']); end
fprintf(modname,str_eep);
 
fprintf(modname,';\n');

%% Declare params
fprintf(modname,['\n','parameters ALPHA_ BETA_ NU_ SIGMA_ SIGMAE']);

str_RHOZ = '\n';
for s = 1:S,str_RHOZ = append(str_RHOZ,['RHOZ',num2str(s),' ']); end
fprintf(modname,str_RHOZ);

str_RHOEP = '\n';
for s = 1:S,str_RHOEP = append(str_RHOEP,['RHOEP',num2str(s),' ']); end
fprintf(modname,str_RHOEP);

str_OMG = '\n';
for s = 1:S,str_OMG = append(str_OMG,['OMG',num2str(s),' ']); end
fprintf(modname,str_OMG);

str_GAM = '\n';
for s = 1:S,str_GAM = append(str_GAM,['GAM',num2str(s),' ']); end
fprintf(modname,str_GAM);

str_V = '\n';
for s = 1:S,str_V = append(str_V,['V',num2str(s),' ']); end
fprintf(modname,str_V);

str_Fc = '\n';
for s = 1:S,str_Fc = append(str_Fc,['Fc',num2str(s),' ']); end
fprintf(modname,str_Fc);


for s = 1:S
    str_GT = '\n';
    for k = 1:S
        str_GT = append(str_GT,['GT',num2str(s),'_',num2str(k),' ']);
    end
    fprintf(modname,str_GT);
end

str_VtGt = '\n';
for s = 1:S,str_VtGt = append(str_VtGt,['VtGt',num2str(s),' ']); end
fprintf(modname,str_VtGt);

%% Declare param values

fprintf(modname,';\n');

% fprintf(modname,'ALPHA_  = %2.8f;   // Labor share \n',                ALPHA_);
% fprintf(modname,'BETA_   = %2.8f;   // Subjective discount factor \n', BETA_);
% fprintf(modname,'SIGMA_  = %2.8f;   // Relative risk aversion \n',     SIGMA_);
% fprintf(modname,'SIGMAE  = %2.8f;   // Cost shock std param \n',       1);
% fprintf(modname,'NU_     = %2.8f;   // Labor supply disutility \n',    NU_);

fprintf(modname,['\n','ALPHA_  = ',num2str(ALPHA_),';    // Labor share'],' ');
fprintf(modname,['\n','BETA_   = ',num2str(BETA_),';     // Subjective discount factor'],' ');
fprintf(modname,['\n','SIGMA_  = ',num2str(SIGMA_),';    // Relative risk aversion'],' ');
fprintf(modname,['\n','SIGMAE  = ',num2str(1),';         // Cost shock std param'],' ');
fprintf(modname,['\n','NU_     = ',num2str(NU_),';       // Labor supply disutility'],' ');

% RHOZ1 ... RHOZN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','RHOZ',num2str(s),' = ',num2str(RHOZ),';         // AR1 Persistence of Z',num2str(s)]);
end

% RHOEP1 ... RHOEPN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','RHOEP',num2str(s),' = ',num2str(RHOEP),';         // AR1 Persistence of U',num2str(s)]);
end


% OMG1 ... OMGN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','OMG',num2str(s),' = ',num2str(OMGs(s)),';          // Price stickiness of PPI for sector',num2str(s)]);
end

% GAM1 ... GAMN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','GAM',num2str(s),' = ',num2str(GAMs(s)),';          // Price stickiness of CPI for sector',num2str(s)]);
end

% LAMDA1 ... LAMDAN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','V',num2str(s),' = ',num2str(V(s)),';        // sales vector',num2str(s)]);
end

% Fc1 ... FcN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','Fc',num2str(s),' = ',num2str(fc(s)),';          // CPI weight of sector',num2str(s)]);
end

% GT
fprintf(modname,'\n');
fprintf(modname,'// GT(s,s)\n');
for j = 1:S
    for k = 1:S
        fprintf(modname,['\n','GT',num2str(j),'_',num2str(k),' = ',num2str(GGT(j,k)),';']);
    end
end

% Fc1 ... FcN
fprintf(modname,'\n');
for s = 1:S
    fprintf(modname,['\n','VtGt',num2str(s),' = ',num2str(VTGT(s)),';          // CPI weight of sector',num2str(s)]);
end

fprintf(modname,'\n\n');
%% Declare model equations

% model(linear)
fprintf(modname,'model(linear);');


fprintf(modname,'\n');
% Slope
fprintf(modname,'// Slope (PPI) \n');
for s = 1:S
    fprintf(modname,['\n','#KAPPAOMG',num2str(s),' = (1-OMG',num2str(s),')*(1-OMG',num2str(s),'*BETA_)/OMG',num2str(s),';']);
end

fprintf(modname,'\n\n');
fprintf(modname,'// Slope (CPI)');
for s = 1:S
    fprintf(modname,['\n','#KAPPAGAM',num2str(s),' = (1-GAM',num2str(s),')*(1-GAM',num2str(s),'*BETA_)/GAM',num2str(s),';']);
end

% VG1 ... VGN
fprintf(modname,'\n\n');
for s = 1:S
    VGs = ['#VG',num2str(s),' =  (  V1*GT1_',num2str(s)];
    for j = 2:S
        VGs_j = [' + V',num2str(j),'*GT',num2str(j),'_',num2str(s)];
        VGs = append(VGs,VGs_j);
    end
    VGs = append(VGs,');');
    fprintf(modname,['\n',VGs]);
end


% IS
fprintf(modname,'\n\n');
fprintf(modname,'// Euler');
fprintf(modname,['\n','c = c(+1)- 1/SIGMA_*( r - paic(+1) );']);

% C growth
fprintf(modname,'\n\n');
fprintf(modname,'// output growth');
fprintf(modname,['\n','dc = c-c(-1);']);

% Labor supply
fprintf(modname,'\n\n');
fprintf(modname,'// Labor supply');
fprintf(modname,['\n','wc = NU_*ell+SIGMA_*c;']);
fprintf(modname,['\n','wc = w - pc;']);

% Labor growth
fprintf(modname,'\n\n');
fprintf(modname,'// Labor growth');
fprintf(modname,['\n','dell = ell-ell(-1);']);

% Wage growth
fprintf(modname,'\n\n');
fprintf(modname,'// Wage growth');
fprintf(modname,['\n','dw = w - w(-1);']);


% Sectoral marginal cost
fprintf(modname,'\n\n');
fprintf(modname,'// Sectoral marginal cost');
for s = 1:S
    fprintf(modname,['\n','mc',num2str(s),' = ALPHA_*w - z',num2str(s),' + (1-ALPHA_)*ptilde',num2str(s),';']);
end


% Production
fprintf(modname,'\n\n');
fprintf(modname,'// Production');
str_y_produc = '\ny = ell + (1-ALPHA_)*(w-p)';
for s = 1:S
    str_y_produc_s = [' + V',num2str(s),'*z',num2str(s)];
    str_y_produc   = append(str_y_produc,str_y_produc_s);
end 
str_y_produc = append(str_y_produc,' ;');
fprintf(modname,str_y_produc);



% Market clearing
fprintf(modname,'\n\n');
fprintf(modname,'// Market clearing');
str_p_y = '\ny =  ALPHA_*c ';
str_p_y = append(str_p_y,' + (1-ALPHA_)*(w - p + ell ');
str_p_y = append(str_p_y,');');
fprintf(modname,str_p_y);

% CPI
fprintf(modname,'\n\n');
fprintf(modname,'// CPI');
str_pc = ['\n','pc = Fc1*pc1'];
for s = 2:S
    str_pc_s = [' + Fc',num2str(s),'*pc',num2str(s)];
    str_pc = append(str_pc,str_pc_s);
end
str_pc = append(str_pc,';');
fprintf(modname,str_pc);


% PPI (vg)
fprintf(modname,'\n\n');
fprintf(modname,'// PPI (vg)');
str_pvg = ['\n','p = VtGt1*p1'];
for s = 2:S
    str_pvg_s = [' + VtGt',num2str(s),'*p',num2str(s)];
    str_pvg = append(str_pvg,str_pvg_s);
end
str_pvg = append(str_pvg,';');
fprintf(modname,str_pvg);

% PPI
fprintf(modname,'\n\n');
fprintf(modname,'// PPI');
str_p = ['\n','pv = V1*p1'];
for s = 2:S
    str_p_s = [' + V',num2str(s),'*p',num2str(s)];
    str_p = append(str_p,str_p_s);
end
str_p = append(str_p,';');
fprintf(modname,str_p);


% Sectoral producer cost
fprintf(modname,'\n\n');
fprintf(modname,'// Sectoral producer cost');
% for s = 1:ns
%     disp(['ptilde',num2str(s),' = G',num2str(s),'_1*p1 +  G',num2str(s),'_2*p2 ... + G',num2str(s),'_',num2str(ns),'*p',num2str(ns),';'])
% end
% disp(['ptilde',num2str(s),' = G',num2str(s),'_1*p1 + G',num2str(s),'_2*p2  + G',num2str(s),'_3*p3  + G',num2str(s),'_4*p4  + G',num2str(s),'_5*p5;'])
for s = 1:S
    Sector_producer_cost = ['\n','ptilde',num2str(s),' = GT',num2str(s),'_1*p1'];
    for j = 2:S
        Sector_producer_cost_j = [' + GT',num2str(s),'_',num2str(j),'*p',num2str(j)];
        Sector_producer_cost = append(Sector_producer_cost,Sector_producer_cost_j);
    end
    Sector_producer_cost = append(Sector_producer_cost,';');
    fprintf(modname,Sector_producer_cost);
end


% Sectoral producer cost
fprintf(modname,'\n\n');
fprintf(modname,'// Sectoral pc cost');
% for s = 1:ns
%     disp(['ptilde',num2str(s),' = G',num2str(s),'_1*p1 +  G',num2str(s),'_2*p2 ... + G',num2str(s),'_',num2str(ns),'*p',num2str(ns),';'])
% end
% disp(['ptilde',num2str(s),' = G',num2str(s),'_1*p1 + G',num2str(s),'_2*p2  + G',num2str(s),'_3*p3  + G',num2str(s),'_4*p4  + G',num2str(s),'_5*p5;'])
for s = 1:S
    Sector_pc_cost = ['\n','ptildec',num2str(s),' = GT',num2str(s),'_1*pc1'];
    for j = 2:S
        Sector_pc_cost_j = [' + GT',num2str(s),'_',num2str(j),'*pc',num2str(j)];
        Sector_pc_cost = append(Sector_pc_cost,Sector_pc_cost_j);
    end
    Sector_pc_cost = append(Sector_pc_cost,';');
    fprintf(modname,Sector_pc_cost);
end

 



% CPI inflation
fprintf(modname,'\n\n');
fprintf(modname,'// Sectoral CPI inflation');

% Marginal cost expression
for s = 1:S
    fprintf(modname,['\n','paic',num2str(s),' = ',num2str(ind_PCE_1(s)),'*KAPPAGAM',num2str(s),'*(mc',num2str(s),' - pc',num2str(s),' ) + ',num2str(ind_PCE_1(s)),'*BETA_*paic',num2str(s),'(+1);']);
end


% PPI inflation
fprintf(modname,'\n\n');
fprintf(modname,'// Sectoral PPI inflation');
for s = 1:S
    fprintf(modname,['\n','pai',num2str(s),' = KAPPAOMG',num2str(s),'*(mc',num2str(s),' - p',num2str(s),') + ep',num2str(s),' + BETA_*pai',num2str(s),'(+1);']);
end


% CPI inflation
fprintf(modname,'\n\n');
fprintf(modname,'// CPI inflation');
str_paic = ['\n','paic = Fc1*paic1'];
for s = 2:S
    str_paic_s = [' + Fc',num2str(s),'*paic',num2str(s)];
    str_paic = append(str_paic,str_paic_s);
end
str_paic = append(str_paic,';');
fprintf(modname,str_paic);


% PPI inflation (vg)
fprintf(modname,'\n\n');
fprintf(modname,'// PPI inflation (vg)');
str_paivg = ['\n','pai = VtGt1*pai1'];
for s = 2:S
    str_paivg_s = [' + VtGt',num2str(s),'*pai',num2str(s)];
    str_paivg = append(str_paivg,str_paivg_s);
end
str_paivg = append(str_paivg,';');
fprintf(modname,str_paivg);

% PPI inflation
fprintf(modname,'\n\n');
fprintf(modname,'// PPI inflation');
str_pai = ['\n','paiv = V1*pai1'];
for s = 2:S
    str_pai_s = [' + V',num2str(s),'*pai',num2str(s)];
    str_pai = append(str_pai,str_pai_s);
end
str_pai = append(str_pai,';');
fprintf(modname,str_pai);



% Price-Inflation: CPI
fprintf(modname,'\n\n');
fprintf(modname,'// Price-Inflation: CPI');
for s = 1:S
    fprintf(modname,['\n','paic',num2str(s),' = pc',num2str(s),' - pc',num2str(s),'(-1);']);
end

% Price-Inflation: PPI
fprintf(modname,'\n\n');
fprintf(modname,'// Price-Inflation: PPI');
for s = 1:S
    fprintf(modname,['\n','pai',num2str(s),' = p',num2str(s),' - p',num2str(s),'(-1);']);
end

% Price-Inflation: PPI
fprintf(modname,'\n\n');
fprintf(modname,'// Input Price-Inflation: IPI');
for s = 1:S
    fprintf(modname,['\n','paitilde',num2str(s),' = ptilde',num2str(s),' - ptilde',num2str(s),'(-1);']);
end

% Productivity
fprintf(modname,'\n\n');
fprintf(modname,'// Productivity');
for s = 1:S
    fprintf(modname,['\n','z',num2str(s),' = RHOZ',num2str(s),'*z',num2str(s),'(-1) + e_z',num2str(s),';']);
end


% Adhoc Cost push shock: pai
fprintf(modname,'\n\n');
fprintf(modname,'// Cost push shock');
for s = 1:S
    fprintf(modname,['\n','ep',num2str(s),' = RHOEP',num2str(s),'*ep',num2str(s),'(-1) + e_ep',num2str(s),';']);
end


% aux expected variables
fprintf(modname,'\n\n');
fprintf(modname,'// aux expected variables');
fprintf(modname,['\n','pf  = p(+1);']);
fprintf(modname,['\n','pcf = pc(+1);']);
fprintf(modname,'\n');
fprintf(modname,['\n','pf_k0 = p;']);
for k = 1:k_upper
    fprintf(modname,['\n','pf_k',num2str(k),' = p(+',num2str(k),');']);
end

fprintf(modname,'\n');
fprintf(modname,['\n','pcf_k0 = pc;']);
for k = 1:k_upper
    fprintf(modname,['\n','pcf_k',num2str(k),' = pc(+',num2str(k),');']);
end

% aux expected variables
fprintf(modname,'\n');
fprintf(modname,['\n','paicf_k0 = paic;']);
for k = 1:k_upper
    fprintf(modname,['\n','paicf_k',num2str(k),' = paic(+',num2str(k),');']);
end

% Natural real interest
fprintf(modname,'\n\n');
fprintf(modname,'// Natural rate of r');
fprintf(modname,['\n','rn = SIGMA_*( cn(+1) - cn );']);

% Natural GDP
fprintf(modname,'\n\n');
fprintf(modname,'// Natural rate of c');
str_cnc = ['\n','cn = ( (1+NU_ )/(ALPHA_*(NU_+SIGMA_)) )*( ( V1*z1'];
for s = 2:S
    str_cn_s = [' + V',num2str(s),'*z',num2str(s)];
    str_cnc   = append(str_cnc,str_cn_s);
end
str_cnc   = append(str_cnc,' ) );');
fprintf(modname,str_cnc);


% GDP GAP
fprintf(modname,'\n\n');
fprintf(modname,'// GDP gap : chat');
fprintf(modname,['\n','chat = c - cn;']);

% p - pc - eps + epsc
fprintf(modname,'\n\n');
fprintf(modname,'// p - pc: phat - phatc');
for s = 1:S
    fprintf(modname,['\n','rphat',num2str(s),' = p',num2str(s),' - pc',num2str(s),';']);
end

% money rule
fprintf(modname,'\n\n');
fprintf(modname,'// money shock');
fprintf(modname,['\n','mbar = pc + c;']);
fprintf(modname,['\n','mbar = e_m;']);


fprintf(modname,'\n\n');
fprintf(modname,'end;');

%% Declare var stderr 

fprintf(modname,'\n\n');
fprintf(modname,'shocks;');
fprintf(modname,['\n','var e_m;  stderr 0;']);
for s = 1:S
    fprintf(modname,['\n','var e_z',num2str(s),';   stderr ',num2str(sigz(s)),';']);
end
for s = 1:S
    fprintf(modname,['\n','var e_ep',num2str(s),';  stderr ',num2str(sige(s)),';']);
end
fprintf(modname,['\n','end;']);

fprintf(modname,'\n\n');
fprintf(modname,'//resid(1);');
fprintf(modname,['\n','options_.qz_criterium = 1+(1e-6); // necessary!!']);
fprintf(modname,['\n','steady;']);
fprintf(modname,['\n','check;']);


fprintf(modname,'\n');
fprintf(modname,['\n','stoch_simul(nograph);']);

fclose(modname);


% Display
disp([' Dynare mod file is produced with a chain degree: chi_ = ',num2str(CHI_i)])

% if Gtype == 1 % Complete Graph
%     disp(' Dynare mod file is produced with a complete graph:')
% elseif Gtype == 2 % Isolated Graph
%     disp(' Dynare mod file is produced with a isolated graph:')
% elseif Gtype == 3 % Star Graph
%     disp(' Dynare mod file is produced with a star graph:')
%     [~,index_maximum_strength] = max(sum(matscell{3},2));
%     load Database_estim.mat sector_name
%     disp(['  The sector, ',sector_name{index_maximum_strength},' (',num2str(index_maximum_strength),'), is selected as the hub sector for the star graph.'])
%     clear sector_name
% elseif Gtype == 4 % Line (Cycle) Graph
%     disp(' Dynare mod file is produced with a line (cycle) graph:')
% else % BENCHMARK!!
%     disp(' Dynare mod file is produced with a emprical graph (benchmark case):')
% end

% close all
% clear