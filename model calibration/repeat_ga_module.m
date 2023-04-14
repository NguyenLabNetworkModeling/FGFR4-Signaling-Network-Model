for kk = 1:length(Order)

    EstimData.sim.TraningData = Order{kk};


    % Genetic Algorithm module
    % input arguments
    galg.parm_in = ga_param_p0; % a nominal parameter values
    galg.parm_index = target_index; % a list of target param index
    galg.estimdata = EstimData;
    galg.gen = 2; % generation
    galg.pop = 2; % population
    galg.fscore = 0.0;

    [fval1, ga_param_out, exitflag] = ga_module(galg);

    if size(galg.parm_in,1) < 2
        % UPDATE THE BEST-FITTED PARAMS
        fit_score = [fval1  ga_param_out];
        ga_param_p0 = ga_param_out;
    else
        % UPDATE THE BEST-FITTED PARAMS
        out1 = bf_params(1,:);
        out1(target_index) = ga_param_out;
        fit_score = [fval1  out1];
        ga_param_p0 = out1;
    end
end



