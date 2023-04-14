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




% the option just for STEP2
tgt_idx = ismember(drugtargets_0.Inhibitor,{'FGFR4i'});
drugtargets = drugtargets_0(tgt_idx,:);


DrugNames = drugtargets.Inhibitor;
DrugTargetNames = drugtargets.Target;
TargetParameters = table2array(drugtargets(:,3:end));


% % [drug rane]
numsamples = 6;
DrugRange = [0 1 5 10 50];


nd1 = length(DrugRange);
nd3 = size(bestfit_params,1); % parameters

tic
parfor masterIDX = 1:nd1*nd3

    disp(strcat(num2str(masterIDX/(nd1*nd3)*100),' % done'))

    [idx1,idx3] = ind2sub([nd1,nd3],masterIDX);

    % renaming the array variables for parfor
    DrugRange_par = DrugRange;
    TargetParameters_par = TargetParameters ;
    bestfit_params_par = bestfit_params;
    DrugTargetNames_par = DrugTargetNames;


    % simulation conditions
    dose = DrugRange_par(idx1); % perturbation
    target = TargetParameters_par; %targets
    param  = bestfit_params_par(idx3,:); % parameter (model)
    maxsteps = 1000;


    % MEX
    try
        [mex_out] = sim_module_step3(param_names,X0,[dose],{target},param,maxsteps,model);

        target_idx = ismember(upper(mex_out.states),upper(DrugTargetNames_par));
        % response at 24 hr
        resp_mat_dr_par(:,masterIDX) = mex_out.statevalues(end,:);

    catch ME

        resp_mat_dr_par(:,masterIDX) = NaN;
        disp(ME.message)

    end

end


disp('------------------------- done')
disp(strcat('running time (min): ',num2str(toc/60)))
disp('-------------------------')

[nrow,~]=size(resp_mat_dr_par);
% reshpae of dose response data
dr_resp_mat = reshape(resp_mat_dr_par,[nrow,nd1,nd3]);



rd_idx = ismember(state_names,{'pAkt','pERK','pIGFR','pIRS','pERBB'});
readouts = state_names(rd_idx);

readouts_3d = dr_resp_mat(rd_idx,:,:);

for ii = 1:50
    tmp_dat(:,:) = readouts_3d(:,:,ii);

    readout_norm(:,:,ii) = data_normalization(tmp_dat,1);

end



%% generate plots

dat_avg = nanmean(readout_norm,3);
dat_std = nanstd(readout_norm,0,3);

figure('position',[330 534 1182  413])

for ii = 1:5
    
    tmp_dat1(:,:) = readout_norm(ii,:,:);

    subplot(1,5,ii),plot(tmp_dat1,'Color',[0.65,0.65,0.65])
    hold on

    subplot(1,5,ii),errorbar(dat_avg(ii,:),dat_std(ii,:)/sqrt(50),...
        'LineWidth',2,...
        'Color',[0.00,0.45,0.74],...
        'Marker','o','MarkerSize',6)
    ylabel(strcat(readouts{ii},'(norm.)'))
    xticks(1:length(DrugRange));
    xticklabels(DrugRange)
    xlabel('BLU (a.u.)')
    axis([-inf inf 0 max(dat_avg(ii,:))*1.3])
    pbaspect([4 3 1])
    box off


end




%
%
% % save the result
% single_drug_response_screening.data = dr_resp_mat;
% single_drug_response_screening.DrugNames = DrugNames;
% single_drug_response_screening.DrugTargetNames = DrugTargetNames;
% single_drug_response_screening.TargetParameters = TargetParameters;
% single_drug_response_screening.DrugRange = DrugRange;
% single_drug_response_screening.ParamSet = listfile{jobID};
%
% save(strcat(workdir,'\Outcome\','single_drug_response_screening_XXX_XXX.mat'),'single_drug_response_screening');
%
%
