function X = irfunc(P,Q,T,shockval,ind_shock)
% This function derive impulse responses given duration, value of exogenous shocks,
% and index of exogenous shocks.
%
% Inputs:
%  P and Q: X=P*X(-1)+Q*shock
%  T: Upper horizon of impulse responses
%  shockval: value of exogenous shock
%  ind_shock: index of exogenous shock
%
% Outputs:
%  X: Inpulse responses of all variables. 
%
% Code author: Kohei Hasui (Aichi University)

[nendo,nexo] = size(Q);
Xt = zeros(nendo,1);

Et = zeros(nexo,1);
Et(ind_shock) = shockval;

X = zeros(nendo,T+1);
for t = 1:T+1
    Xt = P*Xt + Q*Et;
    Et = 0*Et;
    X(:,t) = Xt;
end