function [nbegins, nends, flag] = n_for(nn_,nupper_)

flag=0;

step_ = round(nupper_/nn_);
nbegins = zeros(nn_,1);
nends   = zeros(nn_,1);

nbegins(1) = 1;
nends(1)   = step_;
nends(nn_) = nupper_;
for ni = 2:nn_-1
    nbegins(ni) = nends(ni-1)+1;
    nends(ni)   = nends(ni-1) + step_;
end
nbegins(nn_) = nends(nn_-1)+1;

if nbegins(nn_) >= nends(nn_)
    nn_ = nn_-1;
    nbegins = nbegins(1:nn_);
    nends   = nends(1:nn_);
    nends(nn_) = nupper_;
    flag=1;
end

% step_ = 60;
% n1=step_; n2=n1+step_; n3=n2+step_; n4=n3+step_; n5=nj;
% nbegins = [1,n1+1,n2+1,n3+1,n4+1];
% nends   = [n1,n2,n3,n4,n5];
