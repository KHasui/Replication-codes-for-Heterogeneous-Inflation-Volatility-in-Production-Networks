clc
close all
clear

% This code makes group of sector withrespect to PPI stdev by k-means.
rng("default"); % For reproducibility
% rng(54); % For reproducibility

k=9;
k1 = 3;
k2 = 5;

kmean_ppi  = 1;
weightcalc = 0;

% Memorize current folder
oldFolder = cd;

dataname_stickiness_2 = 'Database_Match_ELI_NIPA.xlsx';

dataname_Est_2 = 'Database_estim_PPIdata_BLS.xlsx';
dataname_Est_3 = 'Database_PCE.xlsx';

cd PPI
% std_data_ptilde    = readmatrix(dataname_Est_2,'Sheet',8);
std_data_ppi    = readmatrix(dataname_Est_2,'Sheet',8);
S = size(std_data_ppi,1);


cd(oldFolder)
cd PCE
std_data_pce     = readmatrix(dataname_Est_3,'Sheet',5);
PCE_data_stickiness = readmatrix(dataname_stickiness_2,'Sheet',5);

std_data_pce  = std_data_pce(2:S+1,4);
fcdata = PCE_data_stickiness(2:S+1,6);
indfc_notzero = fcdata~=0;
indfc_zero = fcdata==0;


cd(oldFolder)
% There are 66 sectors as follows:
% 1	    111CA	Farms
% 2	    113FF	Forestry, fishing, and related activities
% 3	    211	    Oil and gas extraction
% 4	    212	    Mining, except oil and gas
% 5	    213	    Support activities for mining
% 6	    22	    Utilities
% 7	    23	    Construction
% 8	    321	    Wood products
% 9	    327	    Nonmetallic mineral products
% 10	331	    Primary metals
% 11	332	    Fabricated metal products
% 12	333	    Machinery
% 13	334	    Computer and electronic products
% 14	335	    Electrical equipment, appliances, and components
% 15	3361MV	Motor vehicles, bodies and trailers, and parts
% 16	3364OT	Other transportation equipment
% 17	337	    Furniture and related products
% 18	339	    Miscellaneous manufacturing
% 19	311FT	Food and beverage and tobacco products
% 20	313TT	Textile mills and textile product mills
% 21	315AL	Apparel and leather and allied products
% 22	322	    Paper products
% 23	323	    Printing and related support activities
% 24	324	    Petroleum and coal products
% 25	325	    Chemical products
% 26	326	    Plastics and rubber products
% 27	42	    Wholesale trade
% 28	441	    Motor vehicle and parts dealers
% 29	445	    Food and beverage stores
% 30	452	    General merchandise stores
% 31	4A0	    Other retail
% 32	481	    Air transportation
% 33	482	    Rail transportation
% 34	483	    Water transportation
% 35	484	    Truck transportation
% 36	485	    Transit and ground passenger transportation
% 37	486	    Pipeline transportation
% 38	487OS	Other transportation and support activities
% 39	493	    Warehousing and storage
% 40	511	    Publishing industries, except internet (includes software)
% 41	512	    Motion picture and sound recording industries
% 42	513	    Broadcasting and telecommunications
% 43	514	    Data processing, internet publishing, and other information services
% 44	521CI	Federal Reserve banks, credit intermediation, and related activities
% 45	523	    Securities, commodity contracts, and investments
% 46	524	    Insurance carriers and related activities
% 47	525	    Funds, trusts, and other financial vehicles
% 48	HS	    Housing
% 49	ORE	    Other real estate
% 50	532RL	Rental and leasing services and lessors of intangible assets
% 51	5411	Legal services
% 52	5415	Computer systems design and related services
% 53	5412OP	Miscellaneous professional, scientific, and technical services
% 54	55	    Management of companies and enterprises
% 55	561	    Administrative and support services
% 56	562	    Waste management and remediation services
% 57	61	    Educational services
% 58	621	    Ambulatory health care services
% 59	622	    Hospitals
% 60	623	    Nursing and residential care facilities
% 61	624	    Social assistance
% 62	711AS	Performing arts, spectator sports, museums, and related activities
% 63	713	    Amusements, gambling, and recreation industries
% 64	721	    Accommodation
% 65	722	    Food services and drinking places
% 66	81	    Other services, except government

% Make eliminating sectors
% Elim_index = [34;45;54];
% Elim_index = [34;45;54;58;59;60;61]; % Choose eliminating sector
% Elim_index = [28;29;30;31;47;58;59;60;61;62;63;65;66];
% Elim_index = [58;59;60;61];
Elim_index = [];

% non grouping sectors:
NGSindex = [3;24];


% S = size(fcdata,1);
index_sec   = (1:S)';
index_PPI_G = index_sec;
index_PPI_G(Elim_index)=0;
index_PPI_G = index_PPI_G~=0;

%dataX = readmatrix('Ptilde_PCE.xlsx','Sheet',1);
dataX1 = std_data_ppi;
dataX2 = std_data_pce;
dataX2(indfc_zero) = NaN;
dataX = [dataX1,dataX2];

dataX(Elim_index,:) = NaN;
dataX(NGSindex,:) = NaN;

dataX1 = dataX(:,1);
dataX2 = dataX(:,2);

indnan    = isnan(dataX2);
indnotnan = logical(1-indnan);

dataX1nan = dataX1;
dataX1nan(indnotnan) = NaN;

% [dataX1sort, index] = sort(dataX1,'descend')
% [G,ID] = findgroups(dataX1)


% dataX2(indnan) = 0;
% dataX = [dataX1 dataX2];

 
% if kmean_ppi == 1

    % idxppi    = kmeans(dataX1,k);

    idxppi = NaN*ones(S,1);

    indnotNaNX1 = logical(1-isnan(dataX1));

    % not NaN sectors in dataX1
    dataX1notNaN    =    dataX1(indnotNaNX1);
    index_secnotNaN = index_sec(indnotNaNX1);
    
    % Grouping not NaN sectors in dataX1 with kmeans:
    idxppinotNaN    = kmeans(dataX1notNaN,k);
    idxppi(index_secnotNaN) = idxppinotNaN; % insert group
    
    % Group 1 is not grouped sector with kmeans
    idxppi = idxppi+1;
    idxppi(NGSindex) = 1;

    %
    % Re-define group number:
    % - ordering mean std of group
    %
    idxppi_uniq   = unique(idxppi);
    n_idxppi_uniq = numel(idxppi_uniq);

    % mean std for group
    ppi_std_mean          = zeros(n_idxppi_uniq,1);
    for ig = 1:n_idxppi_uniq
        ppi_std_mean(ig) = mean( std_data_ppi(idxppi==idxppi_uniq(ig)) );
    end

    % sorting higher order for mean std for group
    [ppi_std_mean_descend, ind_ppi_descend]  = sort(ppi_std_mean,'descend');
    idxppi_uniq_descend = idxppi_uniq(ind_ppi_descend);
    
    idxppi_redefine = zeros(S,1);
    % REDEFINE the group numbers!!
    for ig = 1:n_idxppi_uniq
        idxppi_redefine(idxppi==idxppi_uniq_descend(ig))=ig;
    end
    % CHECK concordance:
    % [idxppi_uniq_descend,(1:n_idxppi_uniq)']
    % [idxppi,idxppi_redefine]

    idx = [idxppi_redefine;NaN*ones(S,1)];
    % idx = [idxppi;NaN*ones(S,1)];


% else
%     idxb    = kmeans(dataX,k1);
%     idx1nan = max(idxb)+kmeans(dataX1nan,k2);
%     idx = idxb;
%     idx(indnan) = idx1nan(indnan);
% end


oldFolder = cd;
cd GroupIndex
dataname_Est_4 = 'Database_indSige.xlsx';
writematrix(idx,dataname_Est_4,'Sheet',1,'Range',['C2:C',num2str(S+1)]);


nElim  = numel(Elim_index);
vecNaN = NaN*ones(S-nElim,1);

vecElim = [Elim_index;vecNaN];
writematrix(vecElim,dataname_Est_4,'Sheet',5);

if weightcalc == 1
    
    invdataX1 = (1./dataX1);
    dataX2n = dataX2(indnotnan);
    invdataX2 = (1./dataX2n);
    invdataX = [invdataX1;invdataX2;NaN*ones(S,1)];
else
    invdataX1 = (1./dataX1);
    dataX2n = dataX2(indnotnan);
    invdataX2 = (1./dataX2n);
    invdataX = [ones(size([invdataX1;invdataX2]));NaN*ones(S,1)];
end
    
writematrix(invdataX,dataname_Est_4,'Sheet',6);

% cd(oldFolder)


