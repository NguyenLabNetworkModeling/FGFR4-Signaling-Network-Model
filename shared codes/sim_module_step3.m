function [mex_output_s2] = sim_module_step3(param_names,X0,dose,target,param,maxsteps,model)

mex_options.maxnumsteps = maxsteps;


%% Step 1: simulation of Q-stimulation
Q_On = param(strcmp(param_names,'FGF_on'));

starv = linspace(0,Q_On,1000);
qstim = starv(end) + linspace(0,Q_On,1000);

tspan_s1 = sort(unique([starv qstim]));

% MEX output
mex_output_s1 = eval(strcat(model,"(tspan_s1,X0,param,mex_options)"));
x0_s2=mex_output_s1.statevalues(end,:);
% FGFR4_model_rev2a_mex(tspan_s1,X0,param,mex_options)
%% Step 2: Drug response simulation

% simulation time
param_s2  = param;
tspan_2=[0 1 2 4 6 12 18 24]*60;%[0:0.1:24]*60; % for 24 hrs

% Note: Q-stimulation done in step 1 (no stimulation required)
param_s2(strcmp(param_names,'IGF_on')) = 0;
param_s2(strcmp(param_names,'FGF_on')) = 0;
param_s2(strcmp(param_names,'HRG_on')) = 0;

% Note: Drug on at t = 0
param_s2(strcmp(param_names,'inh_on')) = 0;

% Warning: input order and return oder may be different

for jj = 1:length(target)
    
    for ii = 1:length(target{jj})
        % Drug treatment
        if ismember(target{jj}{ii},{'FGFR4i_0','PI3Ki_0','ERBBi_0','AKTi_0','MEKi_0'})
            param_s2(ismember(param_names,target{jj}{ii})) = dose(jj);
        else
            tmp_val = param_s2(ismember(param_names,target{jj}{ii}));
            param_s2(ismember(param_names,target{jj}{ii})) = tmp_val * (1/(1+dose(jj)));
        end
    end

end

% MEX output
mex_output_s2 = eval(strcat(model,"(tspan_2,x0_s2,param_s2,mex_options)"));


end


