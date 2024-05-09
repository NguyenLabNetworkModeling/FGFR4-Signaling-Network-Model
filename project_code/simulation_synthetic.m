function [drug_response_time, state_vals] = simulation_synthetic(model,paramvals)

X0 = eval(model);
param_names = eval(strcat(model,"('parameters')"));
% settings for the simulation
StimOn      = paramvals(strcmp(param_names,'FGF_on'));
options.maxnumsteps = 2000;

% time frames for the simulation
% 5000 (starvation) --> 5000 (q-stimulation) --> drug response time
drug_response_time = [0 0.5 1 2 3 6 12 18 24]*60; % [min]

Time_starv_section  = linspace(0,StimOn,1000);
Time_qstim_section  = Time_starv_section(end) + linspace(0,StimOn,1000)  ;
Time_drug_section   = Time_qstim_section(end) + reshape(drug_response_time,1,[]);
tspan               = sort(unique([Time_starv_section Time_qstim_section Time_drug_section]));

Tindex_starv        = ismember(tspan,Time_starv_section);
Tindex_qstim        = ismember(tspan,Time_qstim_section);
Tindex_drug         = ismember(tspan,Time_drug_section);

Time_starv          = tspan(Tindex_starv);
Time_qstim          = tspan(Tindex_qstim) - Time_starv_section(end);
Time_drug           = tspan(Tindex_drug) - Time_qstim_section(end);


% simulation setting for the drug treatment
drug_names = {'FGFR4i_0';'AKTi_0'};
drug_dose = [10, 0]; % nM
% drug treatment (drug 1 and 2)
paramvals(strcmp(param_names,'inh_on')) = Time_qstim_section(end);
if ~all(strcmp(param_names(ismember(param_names,drug_names)),drug_names))
    error('=> param names are not matched to given drug names')
end
paramvals(ismember(param_names,drug_names)) = drug_dose;



%% run ODE solver (MEX)

try
    % MEX output
    MEX_output=eval(strcat(model,"(tspan,X0,paramvals',options)"));
    statevalues=MEX_output.statevalues;

    % readout variable and state variables
    state_vals_strv     = statevalues(Tindex_starv,:);
    state_vals_qstim    = statevalues(Tindex_qstim,:);
    state_vals_drug     = statevalues(Tindex_drug,:);

    % resampled readouts
    state_vals = state_vals_drug;
catch
    state_vals = ones(length(drug_response_time),length(X0))*NaN;
end

end