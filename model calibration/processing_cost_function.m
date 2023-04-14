Exp_Data    = EstimData.expt.data{irt}{ii};
Mask    = EstimData.sim.ci_mask_size;

% save simulaiton results
EstimData.sim.resampled{irt}{ii}    = Sim_Data;
mean_squared_error = calculation_cost_function(Sim_Data,Exp_Data,[],Mask);

[ssm, nnv]  = checking_steadystate_negative(state_vals_strv,state_vals_qstim);
error_sum   = mean_squared_error + (ssm + nnv) * EstimData.model.TraningMode;
bio_error_sum   = biological_condition(Sim_Data) * EstimData.model.TraningMode;

EstimData.sim.J{irt}{ii} = error_sum + 1e-5;
EstimData.sim.Jb{irt}{ii} = bio_error_sum;

if error_sum < 0
    EstimData.sim.J{irt}{ii} = 1/eps;
else
    EstimData.sim.J{irt}{ii} = error_sum + 1e-5;
end

if bio_error_sum < 0
    EstimData.sim.Jb{irt}{ii} = 1/eps;
else
    EstimData.sim.Jb{irt}{ii} = bio_error_sum;
end
