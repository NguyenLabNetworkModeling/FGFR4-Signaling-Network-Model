function [mex_output_s2] = sim_module_par(param_val,target_param,target_dose,model,param_names,X0)

mex_options.maxnumsteps = 10000;

%% Step 1: simulation of Q-stimulation
Q_On = param_val(strcmp(param_names,'FGF_on'));

starv = linspace(0,Q_On,1000);
qstim = starv(end) + linspace(0,Q_On,1000);

tspan_s1 = sort(unique([starv qstim]));


% MEX output
try
    mex_output_s1=eval(strcat(model,"(tspan_s1,X0,param_val,mex_options)"));
    x0_s2=mex_output_s1.statevalues(end,:);

catch msg
    funCallStack = dbstack;
    methodName = funCallStack(1).name;
    disp(strcat(msg.message,'==>',methodName))

    mex_output_s1=eval(strcat(model,"(tspan_s1)"));
    x0_s2=mex_output_s1.statevalues(end,:);
end

%% Step 2: Drug response simulation

% simulation time
param_s2  = param_val;
tspan_2=[0 1 2 4 6 12 18 24]*60;%[0:0.1:24]*60; % for 24 hrs

% Note: Q-stimulation done in step 1 (no stimulation required)
param_s2(strcmp(param_names,'IGF_on')) = 0;
param_s2(strcmp(param_names,'FGF_on')) = 0;
param_s2(strcmp(param_names,'HRG_on')) = 0;

% Note: Drug on at t = 0
param_s2(strcmp(param_names,'inh_on')) = 0;

% Warning: input order and return oder may be different

for ii = 1:length(target_param)

    if ismember(target_param{ii},{'FGFR4i_0','PI3Ki_0','ERBBi_0','AKTi_0','MEKi_0'})
        param_s2(ismember(param_names,target_param{ii})) = target_dose{ii};
    else
        % Drug treatment
        tmp_val = param_s2(ismember(param_names,target_param{ii}));
        param_s2(ismember(param_names,target_param{ii})) = tmp_val * (1/(1 + target_dose{ii}));
    end
end


% MEX output
% mex_output_s2=FGFR4_model_mex(tspan_2,x0_s2,param_s2,mex_options);
try 
    mex_output_s2=eval(strcat(model,"(tspan_2,x0_s2,param_s2,mex_options)"));
catch msg
    funCallStack = dbstack;
    methodName = funCallStack(1).name;
    disp(strcat(msg.message,'==>',methodName))

    mex_output_s2=eval(strcat(model,"(tspan_2)"));
    mex_output_s2.statevalues = mex_output_s2.statevalues * NaN;
end


end






