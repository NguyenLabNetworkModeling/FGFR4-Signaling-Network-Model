%% rung single drug dose-response

% [choose mode of parameter estimation]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv';
    'fitted_paramsets_rev2_STEP2.csv';    
    'fitted_paramsets_rev2_STEP3.csv'
    'fitted_paramsets_rev2_STEP3_trim.csv'
    }; 
[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});
% note: the first column is the fit score
bestfit_params(:,1) = [];

% run the top 50 parameters
bestfit_params = bestfit_params(1:50,:);

% (test code-----)
% par_idx = ismember(param_names,'kc12f2');
% bestfit_params(:,par_idx) = bestfit_params(:,par_idx)*10000;



% % [drug target parameters]
drugtargets_0 = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);



% % [select inhibitors]
listoptions = {
    'selected inhibitors (only Step1)';
    'all inhibitors'
    }; 
[ optid ] = readInput( listoptions );
opt = listoptions{optid}; % Selected

switch opt
    case 'selected inhibitors (only Step1)'
        % the option just for STEP1/2
        tgt_idx = ismember(drugtargets_0.Inhibitor,{'FGFR4i','PI3Ki','Akti'});        
        drugtargets = drugtargets_0(tgt_idx,:);

    case 'all inhibitors'
        % the option just for STEP3
        drugtargets = drugtargets_0;
end

DrugNames = drugtargets.Inhibitor;
DrugTargetNames = drugtargets.Target;
TargetParameters = table2array(drugtargets(:,3:end));


% % [drug rane]
numsamples = 7;
DrugRange = [0 0.001 0.01 logspace(0,4,numsamples) 1e5];


% % [run parallel simulation] 

nd1 = length(DrugRange);
nd2 = length(DrugNames); % targets
nd3 = size(bestfit_params,1); % parameters

tic
parfor masterIDX = 1:nd1*nd2*nd3

    disp(strcat(num2str(masterIDX/(nd1*nd2*nd3)*100),' % done'))

    [idx1,idx2,idx3] = ind2sub([nd1,nd2,nd3],masterIDX);

    % renaming the array variables for parfor
    DrugRange_par = DrugRange;
    TargetParameters_par = TargetParameters ;
    bestfit_params_par = bestfit_params;
    DrugTargetNames_par = DrugTargetNames;


    % simulation conditions
    dose = DrugRange_par(idx1); % perturbation
    target = TargetParameters_par(idx2,:); %targets
    param  = bestfit_params_par(idx3,:); % parameter (model)
    maxsteps = 1000;


    % MEX
    try
        [mex_out] = sim_module_step3(param_names,X0,[dose],{target},param,maxsteps,model);

        target_idx = ismember(upper(mex_out.states),upper(DrugTargetNames_par{idx2}));
        % response at 24 hr
        resp_mat_dr_par(masterIDX) = mex_out.statevalues(end,target_idx);        

    catch ME
        
        resp_mat_dr_par(masterIDX) = NaN;
        disp(ME.message)

    end

end


disp('------------------------- done')
disp(strcat('running time (min): ',num2str(toc/60)))
disp('-------------------------')

% reshpae of dose response data
dr_resp_mat = reshape(resp_mat_dr_par,[nd1,nd2,nd3]);


% save the result
single_drug_response_screening.data = dr_resp_mat;
single_drug_response_screening.DrugNames = DrugNames;
single_drug_response_screening.DrugTargetNames = DrugTargetNames;
single_drug_response_screening.TargetParameters = TargetParameters;
single_drug_response_screening.DrugRange = DrugRange;
single_drug_response_screening.ParamSet = listfile{jobID};

save(strcat(workdir,'\Outcome\','single_drug_response_screening_XXX_XXX.mat'),'single_drug_response_screening');


