function [LWcell,LCcell,LScell] = figure_Line_control(MainLS,SubLS,MainLC,SubLC,MainLW,SubLW,nline)

if nargin < 7
    nline = 5;
end

LWcell = cell(nline,1);
LCcell = cell(nline,1);
LScell = cell(nline,1);

LWcell{1} = MainLW; LWcell{2} = SubLW;
LCcell{1} = MainLC; LCcell{2} = SubLC;
LScell{1} = MainLS; LScell{2} = SubLS;

grid0to1 = linspace(0,1,nline+10)';
[ndmat1,ndmat2,ndmat3] = ndgrid(grid0to1,grid0to1,grid0to1);
ndvec1 = ndmat1(:); ndvec2 = ndmat2(:); ndvec3 = ndmat3(:);
clear ndmat1 ndmat2 ndmat3


if strcmp(MainLS,SubLS)
    LSvec = {SubLS,SubLS,SubLS};
else
    if strcmp(SubLS,'-')
    elseif strcmp(MainLS,'-') && strcmp(SubLS,'--')
        LSvec = {':','-','--'};
    elseif strcmp(MainLS,'-') && strcmp(SubLS,':')
        LSvec = {'--','-',':'};
    elseif strcmp(MainLS,'--') && strcmp(SubLS,'-')
        LSvec = {':','--','-'};
    elseif strcmp(MainLS,'--') && strcmp(SubLS,':')
        LSvec = {'-','--',':'};
    elseif strcmp(MainLS,':') && strcmp(SubLS,'-')
        LSvec = {'--',':','-'};
    elseif strcmp(MainLS,':') && strcmp(SubLS,'--')
        LSvec = {'-',':','--'};
    end
end

iLS = 1;
for il = 3:nline
    if iLS==3
        iLS = 1;
    end
    LWcell{il} = SubLW;
    LCcell{il} = [ndvec1(il),ndvec2(il),ndvec3(il)];
    LScell{il} = LSvec{iLS};
    iLS = iLS+1;
end


