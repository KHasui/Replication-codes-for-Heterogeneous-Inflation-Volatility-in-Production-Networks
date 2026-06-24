function [Range_Macro,Range_PPI,Range_PCE] = range_data(name_Macro_data,name_PPI_data,name_PCE_data,std_data)
% This function derives range in std_data for marcovar, PPI, and PCE.
% Code author: K. Hasui (Aichi University)

% Size of data
nMacro = numel(name_Macro_data);
nPPI   = numel(name_PPI_data);
nmPCE  = numel(name_PCE_data);

if nargin < 4
    Sdata = nMacro+nPPI+nmPCE;
else
    Sdata  = numel(std_data);
    if nMacro+nPPI+nmPCE ~= Sdata
        warning('Size of data name differs from size of data.')
    end
end
flag_Macro = 1;
flag_PPI   = 2;
flag_PCE   = 3;

flag_std_data = [flag_Macro*ones(nMacro,1); flag_PPI*ones(nPPI,1); flag_PCE*ones(nmPCE,1)];
index_var = (1:Sdata)';
Range_Macro = index_var(flag_std_data==flag_Macro);
Range_PPI   = index_var(flag_std_data==flag_PPI);
Range_PCE   = index_var(flag_std_data==flag_PCE);