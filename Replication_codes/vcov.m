function v = vcov(dr,M_,options_)
% This code calculates the variance-covariance matrix given the decision rule derived from DYNARE.
% Inputs:
%  dr:       Reduced form solution of the DSGE model  (decisions rules)
%  M_:       Global dynare's structure, description of the DSGE model.
%  options_: Global dynare's structure.
% Output:
%  v:        Covariance matrix.
%
% NOTES: 
% This code is a partial copy of function th_autocovariance.m in dynare. 
% This code also requires the following functions in dynare:
%  * kalman_transition_matrix.m
%  * lyapunov_symm.m
% Kohei Hasui (Aichi University) May 20, 2024.

% Extract decision rule from dr.
ghx = dr.ghx;
ghu = dr.ghu;
% nspred  = M_.nspred;
% nstatic = M_.nstatic;
% nx = size(ghx,2);
% ipred = nstatic+(1:nspred)';
ipred = M_.nstatic+(1:M_.nspred)';

if options_.block == 0
    %order_var = dr.order_var;
    inv_order_var = dr.inv_order_var;
    kstate = dr.kstate;
    % ikx = [nstatic+1:nstatic+nspred];
    %ikx = nstatic+1:nstatic+nspred;
    % k0 = kstate(find(kstate(:,2) <= M_.maximum_lag+1),:);
    k0 = kstate(kstate(:,2) <= M_.maximum_lag+1,:);
    i0 = find(k0(:,2) == M_.maximum_lag+1);
    i00 = i0;
    %n0 = length(i0);
    AS = ghx(:,i0);
    %ghu1 = zeros(nx,M_.exo_nbr);
    %ghu1(i0,:) = ghu(ikx,:);
    for i=M_.maximum_lag:-1:2
        i1 = find(k0(:,2) == i);
        n1 = size(i1,1);
        j1 = zeros(n1,1);
        for k1 = 1:n1
            j1(k1) = find(k0(i00,1)==k0(i1(k1),1));
        end
        AS(:,j1) = AS(:,j1)+ghx(:,i1);
        %i0 = i1;
    end
else
    %ghu1 = zeros(nx,M_.exo_nbr);
    trend = 1:M_.endo_nbr;
    inv_order_var = trend(M_.block_structure.variable_reordered);
    %ghu1(1:length(dr.state_var),:) = ghu(dr.state_var,:);
end

local_order = options_.order;
ivar = (1:M_.endo_nbr)';
nvar = size(ivar,1);

% state space representation for state variables only:
% [A,B] = kalman_transition_matrix(dr,ipred,1:nx,M_.exo_nbr); % Dynare 4.5.0
[A,B] = kalman_transition_matrix(dr,ipred,1:M_.nspred); % Dynare 6.1

% Compute stationary variables (before HP filtering), 
%  and compute 2nd order mean correction on stationary variables (in case of
%  HP filtering, this mean correction is computed *before* filtering)

if local_order == 2 || options_.hp_filter == 0
    [vx,u] = lyapunov_symm(A,B*M_.Sigma_e*B',options_.lyapunov_fixed_point_tol,options_.qz_criterium,options_.lyapunov_complex_threshold,[],options_.debug);
    if options_.block == 0
        iky = inv_order_var(ivar);
    else
        iky = ivar;
    end
    stationary_vars = (1:length(ivar))';
    if ~isempty(u)
        x = abs(ghx*u);
        % iky = iky(find(all(x(iky,:) < options_.Schur_vec_tol,2)));

        % Dynare 4.5.0
        % iky = iky(all(x(iky,:) < options_.Schur_vec_tol,2)); 
        % stationary_vars = find(all(x(inv_order_var(ivar(stationary_vars)),:) < options_.Schur_vec_tol,2));

        % Dynare 6.1
        iky = iky(all(x(iky,:) < options_.schur_vec_tol,2));
        stationary_vars = find(all(x(inv_order_var(ivar(stationary_vars)),:) < options_.schur_vec_tol,2));
    end
    aa = ghx(iky,:);
    bb = ghu(iky,:);
end

v = NaN*ones(nvar,nvar);
v(stationary_vars,stationary_vars) = aa*vx*aa'+ bb*M_.Sigma_e*bb';
k = abs(v) < 1e-12;
v(k) = 0;
% k = find(abs(v) < 1e-12);
% v(k) = 0;
% Gamma_y{1} = v;
