function [ssm,  nnv] = checking_steadystate_negative(state_vals_NR,state_vals_FR)

ssm     = 0;
nnv     = 0;
% check if the steady state of the natural response
% 1) y(t) > 1e-3
natural_response    = state_vals_NR(:,abs(state_vals_NR(end,:))>1e-2);
del_steadystate     = abs(natural_response(end-1,:) - natural_response(end,:))./natural_response(end,:);

% 2) (ys(end-1)-ys(end))/ys(end)
del_steadystate_sum = sum(del_steadystate(del_steadystate>0.05));

if del_steadystate_sum
    ssm     = sum(1./(0.5 + del_steadystate_sum))*100;
end

% check if non-negative value
state_vals_FR_min   = min(state_vals_FR);
state_vals_FR_min_sum         = sum(state_vals_FR_min(state_vals_FR_min <-1e-8));

if state_vals_FR_min_sum    
    nnv     = sum(1./(0.5 + state_vals_FR_min_sum))*100;
end

