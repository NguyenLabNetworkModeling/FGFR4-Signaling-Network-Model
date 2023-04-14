%% cost-function

function EstimData=Cost_Function(EstimData,irt)

% load all related values (information)
paramnames  = EstimData.model.paramnames;
paramvals   = EstimData.model.paramvals;
StimOn      = paramvals(strcmp(paramnames,'FGF_on'));
x0s         = EstimData.model.initials;
options.maxnumsteps = EstimData.model.maxnumsteps;
dose_range  = EstimData.expt.dose{irt}{1};
model       = EstimData.model.Name;

% sampling time point, simulation time, dosage

% simulation time frame
Time_starv_section  = linspace(0,StimOn,1000);
Time_qstim_section  = Time_starv_section(end) + linspace(0,StimOn,1000)  ;
Time_drug_section   = Time_qstim_section(end) + reshape(EstimData.expt.time{irt},1,[]);
tspan               = sort(unique([Time_starv_section Time_qstim_section Time_drug_section]));

Tindex_starv        = ismember(tspan,Time_starv_section);
Tindex_qstim        = ismember(tspan,Time_qstim_section);
Tindex_drug         = ismember(tspan,Time_drug_section);

Time_starv          = tspan(Tindex_starv);
Time_qstim          = tspan(Tindex_qstim) - Time_starv_section(end);
Time_drug           = tspan(Tindex_drug) - Time_qstim_section(end);


% readouts (e.g., pp_ERK, pp_AKT)
for ii=1:length(EstimData.expt.names{irt})
    readout         = EstimData.expt.names{irt}{ii};
    readout_idx(ii) = find(ismember(EstimData.model.statenames,readout));
end




%% ODE solver (MEX)
for ii=1:length(dose_range)
    
    % drug treatment (drug 1 and 2)
    paramvals(strcmp(paramnames,'inh_on')) = Time_qstim_section(end);
    paramvals(strcmp(paramnames,EstimData.expt.drug{irt}{1}))   = dose_range(ii);
    paramvals(strcmp(paramnames,EstimData.expt.drug{irt}{2}))   = EstimData.expt.dose{irt}{2};
   

    try
        % MEX output
        MEX_output=eval(strcat(model,"(tspan,x0s,paramvals',options)"));
        statevalues=MEX_output.statevalues;        
        
        % FGFR4_model_rev2a_mex(tspan,x0s,paramvals,options)

    catch
        MEX_output  = eval(strcat(model,"(tspan)"));
        statevalues     = MEX_output.statevalues * NaN;
        variablevalues  = MEX_output.variablevalues * NaN;
        
    end
    
    % readout variable and state variables
    state_vals_strv     = statevalues(Tindex_starv,:);
    state_vals_qstim    = statevalues(Tindex_qstim,:);
    state_vals_drug     = statevalues(Tindex_drug,:);
    
    % resampled readouts
    state_vals_resampled(:,:,ii)=state_vals_drug(:,readout_idx);
    
end


% initialize variables
EstimData.sim.J{irt}    = [];
EstimData.sim.resampled{irt} = [];



%% RESAMPLING AND CALCULATION OF ERROR

% FOR EACH READOUT
for ii=1:length(EstimData.expt.data{irt})
    
    if strcmp(EstimData.expt.type{irt},'dose')
        Sim_Data(:,1)=state_vals_resampled(1,ii,:);
        processing_cost_function
        
        
    elseif strcmp(EstimData.expt.type{irt},'time')
        
        Sim_Data(:,1)=state_vals_resampled(:,ii,1);
        processing_cost_function
        
    elseif strcmp(EstimData.expt.type{irt},'multi')
        
        
        Sim_Data(:,1)=  state_vals_resampled(:,ii,1); 
        Sim_Data(:,2) = state_vals_resampled(:,ii+size(EstimData.expt.data{irt},2),2);
     
        
        %% modify this part for multi
        processing_cost_function
        
        
    end
    
end




