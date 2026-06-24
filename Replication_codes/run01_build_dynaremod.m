% clc
close all
clear
% PREAMBLE:
% This code produces dynare mod file automatically (running function gen_mod.m).
% Procedures of this code are given as follows:
%
% 1 Load data and network matrix:
% 1-1 Generate G matrix by loading MAKE and USE data:
%     MAKE and USE data are down loaded from BEA 2021. 71 sectors are redueced to 66 sectors. 
% 1-2 Load price stickiness of PCE (54 sectors) and PPI (66 sectors).
%
% 2 Write dynare mod file automatically.
%
% Code author: Kohei Hasui (Aichi University)


%% 1: LOAD DATA and MAKING IO MATRIX G:



% 1-1 IO matrix (G)

% import data
load Database_model MAKEmat USEmat PCE_stickiness PPI_stickiness fcdata indfc_notzero
% MAKE = readmatrix('Database_model_param.xlsx','Sheet',1);
% USE  = readmatrix('Database_model_param.xlsx','Sheet',2);
MAKE = MAKEmat;
USE  = USEmat;

% check size
[ni,nj] = size(MAKE);
[n1_make, n2_make] = size(MAKE);
[n1_use,  n2_use]  = size(USE);
if n1_make ~= n2_make
    warning('MAKE is not square matrix.')
elseif n1_use ~= n2_use
    warning('USE is not square matrix.')
elseif n1_make>n1_use
    warning('The size of MAKE is greater than the size of USE.')
elseif n1_make<n1_use
    warning('The size of USE is greater than the size of MAKE.')
end

% making IO matrix G
II = ones(ni,nj);
SHARE     = MAKE./(II*MAKE);  % share of industry i in a commodity 
USHARE    = USE./(USE*II);    % use share of commodity i in a industry  (commodity by industry)   

REVSHARE  = SHARE*USE;
IOmatrix  = REVSHARE./(II*REVSHARE);



% 1-2 Load price stickiness of CPI (29 sectors) and PPI (53 sectors).

% Model deep parameters
ALPHA_  = 0.5; % with network structure
% ALFA  = 1; % without network structure
BETA_   = 0.99;
NU_     = 2; % Pasten et al (2020)
SIGMA_  = 1; % Pasten et al (2020)
% NU_     = 1; % Ferrante et al (2023)
% SIGMA_  = 2; % Ferrante et al (2023)
RHOZ  = 0.7; % Persistence for productivity.    cf: 0.95 in Ferrante et al (2023)
RHOEP = 0.7; % Persistence for cost-push shock. cf: 0.95 for labor supply shock in Ferrante et al (2023)

% Stickiness and IO matrix
OMGs  = PPI_stickiness;
GAMs  = PCE_stickiness;
GG    = IOmatrix;
GGT   = GG';
fc    = fcdata;

Igg   = eye(size(GG));
V     = ALPHA_*(  ( (Igg - (1-ALPHA_)*GG) )\fc  );
VG    = (V')*(GG');

StrengthG = sum(GG,2);
S = size(GG,1); % S in paper (size of sectors)

% upper bound of expectation horizon
k_upper = 12; % upper bound of expectation horizon

filename = 'Result_run01_G_V_ppi.xlsx';
%filename2 = 'data_G_and_V.csv';
writematrix(IOmatrix,filename,'Sheet',1)
writematrix(V,filename,'Sheet',2)
% writematrix(IOmatrix,filename2)
% G = GG;
% save data_G G

% indices for obtained sector of PCE stickiness 
% ind_PCE_1 = omgPPI_gamPCE_fc(:,4);
ind_PCE_1 = indfc_notzero;

% Packing deep pamams
paramsvec = [BETA_,NU_,SIGMA_,RHOZ,RHOEP,S,k_upper];

% Packing matrices
matscell = {OMGs,GAMs,GG,GGT,fc,Igg,ind_PCE_1};


%% 2. WRITE DYNARE MOD FILE AUTOMATICALLY.


% 2-1 baseline model

disp('run01_gen_dynare_mod_file_sect66: ')
% Make dynare code:
modfile_name = gen_mod(ALPHA_,paramsvec,matscell);
% disp(['  Dynare mod file ',modfile_name,' has been produced successfully.'])

save("Database_model.mat", "ALPHA_", "paramsvec", "matscell", "Igg","GG","GGT","fc","OMGs","GAMs","V","VG", "StrengthG", "S", "modfile_name", "-append")


% 2-2 isolated model
Gtype = 2;
modfile_name_iso = gen_mod(ALPHA_,paramsvec,matscell,Gtype);


