%% run dose-response matrix of selected readouts

%% step 1: load a drug target list (revised version 2)
% [drug target list]
drugtargets = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);
DrugNames = drugtargets.Inhibitor;
DrugTargetNames = drugtargets.Target;
TargetParameters = table2array(drugtargets(:,3:end));
readouts = drugtargets.Target;



%% step 2: load a ic50 data
% [load ic50 values]
listfile = {
    'single_drug_ic50_STEP1.csv';
    'single_drug_ic50_STEP3-n100.csv';
    'single_drug_ic50_STEP3-n150.csv';
    'single_drug_ic50_STEP3-n50.csv';
    };
[ jobID ] = readInput( listfile );
ic50_tbl = readtable(listfile{jobID},'ReadRowNames',true);

% check
if ~all(strcmp(DrugNames,ic50_tbl.Properties.RowNames))
    error('mismatch between [drug name] and [target param]')
end

ic50_matrix = table2array(ic50_tbl);


%% step 3: load the best-fitted parameter sets
% [choose mode of parameter estimation]
listfile = {    
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv';
    'fitted_paramsets_rev2_STEP3.csv'
    };
[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});
% note: the first column is the fit score
bestfit_params(:,1) = [];

% (run the top 50 param sets)
bestfit_params = bestfit_params(1:size(ic50_matrix,2),:);



%% step 5: an icx range
icx_range1 = 2.^[-5 -2 -1 0 1 2 5];
icx_range2 = 2.^[-5 -2 -1 0 1 2 5];

% drug combinations
Comb = nchoosek(1:size(TargetParameters,1),2);

% (FGFR4i + X)
Comb = Comb(1:19,:);
% DrugNames(Comb)



%% step 5: parfor - simulation (purbation X targets X paramters)

nd1 = length(icx_range1); % drug 1 (FGFR4i)
nd2 = length(icx_range2); % drug 2 (drug X)
nd3 = size(Comb,1); % combinations
nd4 = size(bestfit_params,1); % parameters/models

tic
parfor masterIDX = 1:nd1*nd2*nd3*nd4

    [idx1,idx2,idx3,idx4] = ind2sub([nd1,nd2,nd3,nd4],masterIDX);

    % renaming the array variables for parfor
    Comb_par = Comb;
    ic50_matrix_par = ic50_matrix;
    TargetParameters_par = TargetParameters ;
    DrugTargetNames_par = DrugTargetNames;
    bestfit_params_par = bestfit_params;
    icx_range1_par = icx_range1;
    icx_range2_par = icx_range2;

    % simulation conditions
    % drug pairs
    dcomb = Comb_par(idx3,:);
    % doses

    dose_1 = ic50_matrix_par(dcomb(1),idx4)*icx_range1_par(idx1);
    dose_2 = ic50_matrix_par(dcomb(2),idx4)*icx_range2_par(idx2);

    % targets
    target_param1 = TargetParameters_par(dcomb(1),:); %targets
    target_param2 = TargetParameters_par(dcomb(2),:); %targets

    target_name1 = DrugTargetNames_par(dcomb(1),:); %targets
    target_name2 = DrugTargetNames_par(dcomb(2),:); %targets


    % parameters
    param  = bestfit_params_par(idx4,:); % parameter (model)
    maxsteps = 10000;

    % MEX
    try
        [mex_out] = sim_module_step3(param_names,X0,[dose_1,dose_2],{target_param1,target_param2},param,maxsteps,model);

        target_idx = ismember(upper(mex_out.states),upper(readouts));

        % main code
        stateval = mex_out.statevalues(end,target_idx);
        resp_mat_par(:,masterIDX) = stateval;
        drugtargets_par(:,masterIDX) = [target_name1; target_name2];

    catch ME

        resp_mat_par(:,masterIDX) = NaN;
        drugtargets_par(:,masterIDX) = {'NaN','NaN'};

        disp(ME.message)
    end

    disp(strcat(num2str(masterIDX/(nd1*nd2*nd3*nd4)*100),' % done'))


end

disp(strcat('elapsed time:',num2str(toc/60),'[min]'))


%% step 6: data re-formating

[nrow,~] = size(resp_mat_par);
resp_mat = reshape(resp_mat_par,[nrow,nd1,nd2,nd3,nd4]);
% d1: readouts
% d2: drug 1 (FGFR4i)
% d3: drug 2 (drug X)
% d4: combinations
% d5: parameters/models
drugtargets_x = reshape(drugtargets_par,[2,nd1,nd2,nd3,nd4]);

% readouts
Readouts = state_names(ismember(upper(state_names),upper(readouts)));


%% step 4: save the data
% save the result
dose_response_matrix.data = resp_mat;
dose_response_matrix.data_info = {'readouts','drug_1','drug_2','comb','param_model'};
dose_response_matrix.DrugNames = DrugNames;
dose_response_matrix.DrugTargetNames = DrugTargetNames;
dose_response_matrix.DrugTargets = drugtargets_x;
dose_response_matrix.TargetParameters = TargetParameters;
dose_response_matrix.DrugRange1 = icx_range1;
dose_response_matrix.DrugRange2 = icx_range2;
dose_response_matrix.Combinations = Comb;
dose_response_matrix.Readouts = Readouts;


save(strcat(workdir,'\Outcome\','dose_response_matrix_XXX_XXX.mat'),'dose_response_matrix');


