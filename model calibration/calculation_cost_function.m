function J = calculation_cost_function(sim_data,exp_data,exp_time,mask_size)

if size(sim_data,2)==1
    
    sim_data_row(1,:)   = sim_data;
    sim_data_norm     = sim_data/max(sim_data_row);
    
    exp_data_row(1,:)   = exp_data;
    exp_data_norm       = exp_data/max(exp_data_row);
    
else
    
    sim_data_norm=sim_data/max(sim_data(:));
    exp_data_norm=exp_data/max(exp_data(:));
end


% confidence interval
ci_mask = abs(sim_data_norm-exp_data_norm)./exp_data_norm > mask_size;


% calculate error between exp. and sim.
if isempty(exp_time)
    time_scale  = 1;
else
    exp_time(1,:)   = exp_time;
    time_scale_tmp = exp_time./(exp_time(end)/4+exp_time);
    time_scale  = time_scale_tmp + (1-max(time_scale_tmp));
end

j_time_scale    = sqrt(((sim_data_norm - exp_data_norm).^2))./time_scale;
j_mask          = abs(j_time_scale).*ci_mask;
J               = sum(j_mask(:))/length(sim_data_norm);

% imaginary number penalty
sim_data_imag = sum(imag(sim_data(:)));

if sim_data_imag > 0
    J   = J*100;
end

end