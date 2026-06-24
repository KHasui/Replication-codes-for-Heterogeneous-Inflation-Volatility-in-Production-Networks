clc
close all
clear
% PREAMBLE:
% This code makes the database for model and estimation
% Kohei Hasui (Aichi University)

Ixlsx = 0; % If produce xlsx file


%% 1. Access data folder and make fundamental Database

% Remember current folder
oldFolder = cd;

% define database name

dataname_stickiness_1 = 'Database_PPI_freq.xlsx';
dataname_stickiness_2 = 'Database_Match_ELI_NIPA.xlsx';

dataname_IO    = 'Database_IO_After_Redefinitions.xlsx';
dataname_Est_1 = 'Database_macrovar.xlsx';
dataname_Est_2 = 'Database_estim_PPIdata_BLS.xlsx';
dataname_Est_3 = 'Database_PCE.xlsx';
dataname_Est_4 = 'Database_indSige.xlsx';

writedataname1 = 'Database_estim.xlsx';
writedataname2 = 'Database_model_param.xlsx';

% load data

% (1) load IO data
cd DATA/IO
MAKEmat = readmatrix(dataname_IO,'Sheet',1);
USEmat  = readmatrix(dataname_IO,'Sheet',2);

% Size of network
S = size(MAKEmat,1);

if size(MAKEmat,1) ~= size(USEmat,1)
    error('Size of MAKEmat differs from that of USEmat.')
elseif size(MAKEmat,2) ~= size(USEmat,2)
    error('Size of MAKEmat differs from that of USEmat.')
elseif size(MAKEmat,1)~=size(MAKEmat,2)
    error('MAKEmat is not square.')
elseif size(USEmat,1)~=size(USEmat,2)
    error('USEmat is not square.')
end

% (2) load Macro data
cd(oldFolder)
cd DATA/Macro_data
std_data_macrovar  = readmatrix(dataname_Est_1,'Sheet',1);
name_macrovar      =   readcell(dataname_Est_1,'Sheet',3);

% (3-1) load price data (sectoral output price and PPI price stickiness)
cd(oldFolder)
cd DATA/PPI
% std_data_ptilde    = readmatrix(dataname_Est_2,'Sheet',8);
std_data_ppi       = readmatrix(dataname_Est_2,'Sheet',8);
PPI_stickiness     = readmatrix(dataname_stickiness_1,'Sheet',1);
PPI_stickiness     = PPI_stickiness(2:S+1,5);

% (3-2) load price data (sectoral PCE price and PC price stickiness)
cd(oldFolder)
cd DATA/PCE
std_data_pce        = readmatrix(dataname_Est_3,'Sheet',6);
pce_index           = readmatrix(dataname_Est_3,'Sheet',7);
PCE_data_stickiness = readmatrix(dataname_stickiness_2,'Sheet',5);

PCE_stickiness = PCE_data_stickiness(2:S+1,5);
fcdata         = PCE_data_stickiness(2:S+1,6);
indfc_notzero  = fcdata~=0;
fcdata = fcdata/sum(fcdata);

% (4) load grouping index
cd(oldFolder)
cd DATA/GroupIndex
ind_x_to_sige_group_order = readmatrix(dataname_Est_4,'Sheet',3);
ind_x_to_sige             = readmatrix(dataname_Est_4,'Sheet',4);
groupdata                 = readmatrix(dataname_Est_4,'Sheet',1);
Elim_index                = readmatrix(dataname_Est_4,'Sheet',5);
WeightLSQ                 = readmatrix(dataname_Est_4,'Sheet',6);
sector_code_name          =   readcell(dataname_Est_4,'Sheet',1);

sector_code       = sector_code_name(2:end,4);
sector_name       = sector_code_name(2:end,5);
ind_group_kmean   = groupdata(:,3);

cd(oldFolder)



% MAKE database for estimation

if Ixlsx==1 % produce xlsx data if Ixlsx==1

    writematrix(std_data_macrovar, writedataname1, 'Sheet', 1) % stdevs: growth of GDP, growth of wage, labor
    writematrix(std_data_ppi,      writedataname1, 'Sheet', 2) % stdevs: sectoral input prices inflation
    writematrix(std_data_pce,      writedataname1, 'Sheet', 3) % stdevs: sectoral PCE inflation
    writematrix(ind_x_to_sige_group_order,...
                                   writedataname1, 'Sheet', 4)
    writematrix(ind_x_to_sige,     writedataname1, 'Sheet', 5)
    
    writematrix(PPI_stickiness,       writedataname2, 'Sheet', 3, 'Range',['A2:A',num2str(S+1)])
    writematrix(PCE_stickiness,       writedataname2, 'Sheet', 3, 'Range',['B2:B',num2str(S+1)])
    writematrix(fcdata,               writedataname2, 'Sheet', 3, 'Range',['C2:C',num2str(S+1)])
    writematrix(double(indfc_notzero),writedataname2, 'Sheet', 3, 'Range',['D2:D',num2str(S+1)])

end

sector_code_PCE = sector_code(pce_index);
sector_name_PCE = sector_name(pce_index);
sector_code_PPI = sector_code;
sector_name_PPI = sector_name;

% save Database_estim std_data_macrovar std_data_ppi std_data_pce pce_index name_macrovar...
%     ind_x_to_sige_group_order ind_x_to_sige...
%     sector_code_PCE sector_name_PCE sector_code_PPI sector_name_PPI WeightLSQ
% 
% save Database_model PPI_stickiness PCE_stickiness fcdata indfc_notzero MAKEmat USEmat


%% 2. Eliminate some sectors from fundamental Database (OPTIONAL)

if isempty(Elim_index)
    % There are not sectors to be removed:
    
    save Database_estim std_data_macrovar std_data_ppi std_data_pce pce_index name_macrovar...
        ind_x_to_sige_group_order ind_x_to_sige...
        sector_code_PCE sector_name_PCE sector_code_PPI sector_name_PPI sector_code sector_name WeightLSQ
    save Database_model PPI_stickiness PCE_stickiness fcdata indfc_notzero MAKEmat USEmat

    disp('Database_estim.mat and Database_model.mat have been generated. ')
    disp(' -- There are no sectors removed. ')
    
else
    % There are sectors to be removed:

    index_PPI_G = (1:S)';
    index_PCE   = pce_index;
    
    index_PPI_G(Elim_index)=0;
    index_PPI_G = index_PPI_G~=0;
    
    for j=1:numel(Elim_index)
        index_PCE(index_PCE==Elim_index(j))=0;
    end
    index_PCE = index_PCE~=0;
    
    % IO
    MAKEmat = MAKEmat(index_PPI_G,index_PPI_G');
    USEmat  = USEmat(index_PPI_G,index_PPI_G');
    
    % PPI stickiness and Ptilde STDEV
    PPI_stickiness = PPI_stickiness(index_PPI_G);
    std_data_ppi = std_data_ppi(index_PPI_G);
    
    % PCE stickiness and PCE STDEV
    PCE_stickiness = PCE_stickiness(index_PPI_G);
    std_data_pce = std_data_pce(index_PCE);
    fcdata = fcdata(index_PPI_G);
    
    fcdata = fcdata/sum(fcdata); % Normalization (do not forget)
    
    indfc_notzero = indfc_notzero(index_PPI_G);
    
    
    % Important
    % ind Sige: Remaking index of grouping
    GroupElim = ind_group_kmean(index_PPI_G);
    Gunique  = unique(GroupElim);
    nGunique = numel(Gunique);
    nG =numel(GroupElim);
    indexzgroup1 = zeros(nG,1);
    for k = 1:nGunique
        indexzgroup1(GroupElim==Gunique(k)) = k;
    end
    
    indexzgroup2 = indexzgroup1 + max(indexzgroup1);
    indexzgroup  = [indexzgroup1;indexzgroup2];
    % indexzgroup3 = indexzgroup1 + max(indexzgroup2);
    % indexzgroup  = [indexzgroup1;indexzgroup2;indexzgroup3];
    
    
    ind_x_to_sige_group_order = indexzgroup1;
    ind_x_to_sige = indexzgroup;
    
    sector_code_PCE = sector_code_PCE(index_PCE);
    sector_name_PCE = sector_name_PCE(index_PCE);
    sector_code_PPI = sector_code_PPI(index_PPI_G);
    sector_name_PPI = sector_name_PPI(index_PPI_G);

    save Database_estim std_data_macrovar std_data_ppi std_data_pce pce_index index_PCE name_macrovar...
        ind_x_to_sige_group_order ind_x_to_sige...
        sector_code_PCE sector_name_PCE sector_code_PPI sector_name_PPI sector_code sector_name WeightLSQ
    save Database_model PPI_stickiness PCE_stickiness fcdata indfc_notzero MAKEmat USEmat

    disp('Database_estim.mat and Database_model.mat have been generated. ')
    disp(' -- The following sectors are removed:  ')
    for es = 1:numel(Elim_index)
        disp(['    ',num2str(Elim_index(es)),': ',char(sector_name(Elim_index(es)))])
    end
    
end

