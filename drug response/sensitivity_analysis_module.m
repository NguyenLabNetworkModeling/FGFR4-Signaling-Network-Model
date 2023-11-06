function [respc,rd_time] = sensitivity_analysis_module(param_val,drug_ic50,drug_names,drug_target_params,drugs_combs,drugs_combs_icx,model,state_names,param_names,X0)

% drug combo (FGFR4i + PI3Ki)
% drugs_combs = ...
%     {{'FGFR4i','PI3Ki'},...
%     {'FGFR4i','AKTi'}};
% drugs_combs_icx = [20,2];

%sim_maxsteps = 10000;

for ii = 1:size(drugs_combs,2)

    drugs = drugs_combs{ii};

    for kk = 1:length(drugs)
        d_idx = ismember(upper(drug_names),upper(drugs{kk}));
        target_param{kk} = table2array(drug_target_params{d_idx});
        target_dose{kk} =   drug_ic50(d_idx)*drugs_combs_icx(kk);
    end

    %     [mex_out] = sim_module_combo(sim,model);
    [mex_out] = sim_module_par(param_val,target_param,target_dose,model,param_names,X0);

    rd_time = mex_out.time;
    rd_idx = ismember(upper(state_names),upper({'pAKT'}));
    respc(:,ii) = data_normalization(mex_out.statevalues(:,rd_idx),2);

end




