%% pAKT rebound to FGFR4i,PI3Ki,AKTi for single and combo
%% Figure 3A-D



%% load files

% [load the estimated IC50 values]
listfile = {
    'single_drug_ic50_STEP1.csv'
    };

[ jobID ] = readInput( listfile );
ic50_table = readtable(listfile{jobID});
ic50_table.Properties.VariableNames(1) = {'drug'};


% [load the best-fitted parameter sets]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    };
[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});
bestfit_params(:,1) = []; % note: the first column is the fit score


%  (NOTE) Number of parameters used for simulation
NofParam = 50;
bestfit_params = bestfit_params(1:NofParam,:);
ic50_table = ic50_table(:,1:NofParam+1);

% % [drug target parameters table]
drugtargets_0 = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);


% % [select inhibitors]

% input a list of drugs
tgt_idx = ismember(drugtargets_0.Inhibitor,{'FGFR4i','PI3Ki','Akti'});
% {'FGFR4i','ERBBi','Akti','MEKi'}
drugtargets = drugtargets_0(tgt_idx,:);



% [mapping the selected drugs  ==> the drug target parameters]
for ii = 1:length(ic50_table.drug)
    idx = ismember(drugtargets.Inhibitor,ic50_table.drug(ii));
    drug_ic50_values(ii,:) = table2array(ic50_table(idx,2:end));
    drug_names{ii} = drugtargets.Inhibitor{idx};
    drug_target_params{ii} = drugtargets(idx,3:end);
end



%% drug treatment settings

drugs_combs = ...
    {{'FGFR4i','PI3Ki'}};
drugs_combos_icx = [10,0];

% example: 
% drugs_combs = ...
%     {{'FGFR4i','AKTi'}};
% drugs_combos_icx = [20,2];

%% Algorithm
%%
% # change the target parameter value
% # read the IC50 values corresponding to the selected model



nd1 = size(bestfit_params,1); % models


for ii = 1:nd1

    disp(strcat(num2str(ii/(nd1)*100),' % done'));
    [idx2] = ind2sub([nd1,nd1],ii);


    % step 1: change the target parameter value (n = 55)
    param_val = bestfit_params(idx2,:);



    % step 2: read the IC50 values corresponding to the selected model
    drug_ic50 = drug_ic50_values(:,idx2);

    [respc(:,:,ii),time_par(:,ii)] = sensitivity_analysis_module...
        (param_val,drug_ic50,drug_names,drug_target_params,drugs_combs,drugs_combos_icx,model,state_names,param_names,X0);
    %     disp(masterIDX)
end


%%

[nrow,~] = size(respc);
respc_reshpae = reshape(respc,nrow,nd1);
time(1,:) = time_par(:,1);


% %isnan(respc_reshpae)
% respc_reshpae_avg = nanmean(respc_reshpae,2);
% % time
% 
% pl = plot(respc_reshpae_avg,'LineWidth',2);
% 
% hold on



% processing the resulting data

yavg = nanmean(respc_reshpae,2);
ystd = nanstd(respc_reshpae,[],2);

figure(100)
errorbar(time/60,yavg,ystd/sqrt(size(respc_reshpae,2)))
hold on


dr_tbl = array2table([time'/60 yavg ystd ones(size(yavg))*NofParam],'VariableNames',{'time','Mean','SD','N'});


if length(drugs_combs{1}) == 2

    writetable(dr_tbl,strcat(workdir,'\Outcome\',strcat('drug_response_PI3Ki_AKTi_Step1','_num=(',num2str(NofParam),')'),'.xlsx'),...
        'Sheet',strcat(drugs_combs{1}{1},'-',drugs_combs{1}{2}));

elseif length(drugs_combs{1}) == 1
    writetable(dr_tbl,strcat(workdir,'\Outcome\',strcat('drug_response_PI3Ki_AKTi_Step1','_num=(',num2str(NofParam),')'),'.xlsx'),...
        'Sheet',strcat(drugs_combs{1}{1},'- single'));

end


clear drug_response drugs drugs_icx yavg ystd mex_out respc sim ic50_table


