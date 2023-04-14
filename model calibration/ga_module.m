function [fval1, ga_param_out, exitflag] = ga_module(galg)

global param_names X0


target_params     =  param_names(galg.parm_index);

if size(galg.parm_in,1) < 2
    target_parm_vals  = log10(galg.parm_in(:,galg.parm_index));
else
    target_parm_vals  = log10(galg.parm_in);
end

% PARAMETERIZED OBJECT FUNCTION
objfun  = @(PX0) ga_user_code(PX0,galg.estimdata,galg.parm_index);

% UPPER AND LOWER BOUNDARY for GA
LB      = ones(1,length(galg.parm_index))*-6;
UB      = ones(1,length(galg.parm_index))*4;

ligands_idx = find(ismember(target_params,{'IGF0','HRG0','FGF0'}));
LB(ligands_idx)   = 0;
UB(ligands_idx)   = 4;


% GA OPTIONS
options_ga  = gaoptimset(...
    'PlotFcns',{@gaplotbestf,@gaplotbestindiv},...
    'InitialPopulation',target_parm_vals,...
    'Generations',galg.gen,...
    'PopulationSize',galg.pop,...
    'Display','iter',...
    'UseParallel',true,...
    'FitnessLimit',galg.fscore,...
    'MutationFcn',{@mutationadaptfeasible,0.1}); %default is 0.01


% CALL GA FUNCTION
[x1,fval1,exitflag,output,population,scores] = ga(objfun,size(target_parm_vals,2),[],[],[],[],LB,UB,[],options_ga);




if size(galg.parm_in,1) < 2
    % UPDATE THE BEST-FITTED PARAMS
    ga_param_out = galg.parm_in;
    ga_param_out(galg.parm_index) = 10.^x1;
    
else
    % UPDATE THE BEST-FITTED PARAMS
    ga_param_out = galg.parm_in;
    ga_param_out = 10.^x1;
    
end


