function f = objlsq(x,ind_x_to_sige,ind_std_model,ind_e_all,std_data,dr,M_,options_,Weights_)
% objective function for lsqnonlin
% lsqnonlin minimize f'f with this function: 
% INPUTS:
%  x: stds for disturbances in intermediate sector cost-push shock
%  ind_std_model: indices of stds for model variables
%  ind_e_upall:   indices of stds for disturbances in intermediate sector cost-push shock
%  std_data:      data of stds (target)
%  dr,M_,options_: decision rule, model structure, model options derived from Dynare
% OUTPUT:
%  f = std_data-std_model(ind_std_model); distance between data stds and model stds.
% code author: K. Hasui (Aichi University)

Sigma_e_vec=diag(M_.Sigma_e);
% update std for disturbances in intermediate sector cost-push shock
Sigma_e_vec(ind_e_all) = ( x(ind_x_to_sige) ).^2;
Sigma_e = diag(Sigma_e_vec);

% insert updated std for disturbances in intermediate sector cost-push shock
M_.Sigma_e = Sigma_e;

% params = M_.params;
% params(indRHOZ)  = r1;
% params(indRHOEP) = r2;
% M_.params = params;
% [dr, ~, M_, options_, ~] = resol(0,M_,options_,oo_);

% recall vcoc: variance-covariance 
v = vcov(dr,M_,options_);
std_model = sqrt(diag(v));

% distance between data stds and model stds.
f_unweighted = std_data-std_model(ind_std_model);
f = f_unweighted.*Weights_;

% disp(f'*f)