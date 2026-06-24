function [p,q]=get_pq(dr_,nstatic,nfwrd)
%
% This function is clone of get_pq.m in Occbin Toolbox by Guerrieri and Iacoviello (2013).
% This function derive the following solution form given as ghx and ghu from dynare.
% X(t) = P*X(t-1) + Q*Shock(t)
%
% This code is copied by Kohei Hasui (Aichi University).

nvars = size(dr_.ghx,1);
nshocks = size(dr_.ghu,2);
statevar_pos = (nstatic +1):(nvars-nfwrd);

p = zeros(nvars);
% interlace matrix
nnotzero = length(statevar_pos);
for i=1:nnotzero
    p(:,statevar_pos(i)) = dr_.ghx(:,i);
end

% reorder p matrix according to order in lgy_
inverse_order = zeros(nvars,1);
for i=1:nvars
    inverse_order(i) = find(i==dr_.order_var);
end

p_reordered = zeros(nvars);
q = zeros(nvars,nshocks);
for i=1:nvars
    for j=1:nvars
        p_reordered(i,j)=p(inverse_order(i),inverse_order(j)); 
    end
    q(i,:)=dr_.ghu(inverse_order(i),:); 
end
p=p_reordered;