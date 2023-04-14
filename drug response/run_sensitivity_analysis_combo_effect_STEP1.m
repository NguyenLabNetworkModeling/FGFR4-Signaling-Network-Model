%% Sensitivity analysis - different drug effect between PI3Ki and AKTi
%% Load the data
%%
% * the IC50 table
% * the best fitted parameter sets
% * the drug target parameter list
% * the the target parameters for the senstivity analysis

% [load the estimated IC50 values]
listfile = {
    'single_drug_ic50_STEP1.csv'
    'single_drug_ic50_STEP3-n50.csv'
    };

[ jobID ] = readInput( listfile );
ic50_table = readtable(listfile{jobID});
ic50_table.Properties.VariableNames(1) = {'drug'};


% [load the best-fitted parameter sets]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    'fitted_paramsets_rev2_STEP3-trim.csv'
    };
[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});

% note: the first column is the fit score
bestfit_params(:,1) = [];
%bestfit_params = bestfit_params(1:size(ic50_table,2)-1,:);

%  (NOTE) Number of parameters used for simulation
NofParam = 50;
bestfit_params = bestfit_params(1:NofParam,:);
ic50_table = ic50_table(:,1:NofParam+1);

% % [drug target parameters table]
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
        % input a list of drugs
        tgt_idx = ismember(drugtargets_0.Inhibitor,{'FGFR4i','PI3Ki','Akti'});
        % {'FGFR4i','ERBBi','Akti','MEKi'}
        drugtargets = drugtargets_0(tgt_idx,:);

    case 'all inhibitors'

        drugtargets = drugtargets_0;
end


% [mapping the selected drugs  ==> the drug target parameters]
for ii = 1:length(ic50_table.drug)
    idx = ismember(drugtargets.Inhibitor,ic50_table.drug(ii));
    drug_ic50_values(ii,:) = table2array(ic50_table(idx,2:end));
    drug_names{ii} = drugtargets.Inhibitor{idx};
    drug_target_params{ii} = drugtargets(idx,3:end);
end



% [drug combination]
drugs_combs = ...
    {{'FGFR4i','PI3Ki'},...
    {'FGFR4i','AKTi'}};
drugs_combos_icx = [20,2];


%% Algorithm
%%
% # change the target parameter value
% # read the IC50 values corresponding to the selected model

% % [select a SA mode]
listoptions = {
    'conventional SA'
    'pathway based SA (test)'
    };
[ optid ] = readInput( listoptions );
opt_sa = listoptions{optid}; % Selected



switch opt_sa

    case  'conventional SA'
        % % [conventional SA]
        target_parameters = readtable('target_parameter_SA.xlsx','ReadVariableNames',true);
        % target_parameters = target_parameters(end,:); 

        param_ptr_size = 1 - 0.75; % [0.99 0.75]

        nd1 = length(target_parameters.mechanism); % targets for SA
        nd2 = size(bestfit_params,1); % models


        parfor masterIDX = 1:nd1*nd2

            disp(strcat(num2str(masterIDX/(nd1*nd2)*100),' % done'));
            [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);


            % step 1: change the target parameter value (n = 55)
            param_val = bestfit_params(idx2,:);
            tgt_idx = ismember(param_names,target_parameters.Parameter{idx1});

            if any(tgt_idx)
                param_val(tgt_idx) = param_val(tgt_idx)*(param_ptr_size);
            end


            % step 2: read the IC50 values corresponding to the selected model
            drug_ic50 = drug_ic50_values(:,idx2);

            [respc(:,:,masterIDX),time_par(:,masterIDX)] = sensitivity_analysis_module...
                (param_val,drug_ic50,drug_names,drug_target_params,drugs_combs,drugs_combos_icx,model,state_names,param_names,X0);
            %     disp(masterIDX)
        end

    case 'pathway based SA (test)'
        % % [pathwya based SA]
        target_parameters = readtable('target_parameter_SA_pathway.xlsx','ReadVariableNames',true);

        % assign parameter values to new mechanims
        new_params = {'kc09f1','ki33f','kc08f1'};
        % note: kc09f1(ERK->mTORC1), ki33f(S6K1-|mTORC2), kc08f1(mTORC2->AKT)
        new_vals = [100,100,100];

        for ii = 1:length(new_params)
            bestfit_params(:,ismember(param_names,new_params{ii})) = new_vals(ii);
        end

        % parallel simulation
        param_ptr_size = 2; %

        nd1 = length(target_parameters.pathway); % targets for SA
        nd2 = size(bestfit_params,1); % models


        parfor masterIDX = 1:nd1*nd2

            disp(strcat(num2str(masterIDX/(nd1*nd2)*100),' % done'));
            [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);


            % step 1: change the target parameter value (n = 55)
            param_val = bestfit_params(idx2,:);
            tgt_params = table2array(target_parameters(idx1,3:end));

            tgt_idx = ismember(param_names,tgt_params);

            if any(tgt_idx)
                param_val(tgt_idx) = param_val(tgt_idx)*(param_ptr_size);
            end


            % step 2: read the IC50 values corresponding to the selected model
            drug_ic50 = drug_ic50_values(:,idx2);

            [respc(:,:,masterIDX),time_par(:,masterIDX)] = sensitivity_analysis_module...
                (param_val,drug_ic50,drug_names,drug_target_params,drugs_combs,drugs_combos_icx,model,state_names,param_names,X0);
            %     disp(masterIDX)
        end
end






%% Processing results

[nrow,ncol,~] = size(respc);
respc_reshpae = reshape(respc,nrow,ncol,nd1,nd2);

%isnan(respc_reshpae)
respc_reshpae_avg = nanmean(respc_reshpae,4);

resp_profile(:,:,1) = respc_reshpae_avg(:,1,:); % FGFR4i + PI3Ki
resp_profile(:,:,2) = respc_reshpae_avg(:,2,:); % FGFR4i + AKTi

% time
time(1,:) = time_par(:,1);


%% plot


% % [select inhibitors]
listoptions = {
    'AUC-based'
    'difference'
    };
[ optid ] = readInput( listoptions );
opt = listoptions{optid}; % Selected


switch opt

    case 'AUC-based'
        [BB_cut_log2,II_cut,BB_log2,II] = drug_effect_senstivity_AUC(resp_profile);

        % [ranking.ii,ranking.bb] = sort(II);
        % tbl_ranking = array2table([ranking.ii' ranking.bb'],'VariableNames',{'ranking','idx'});
        % tbl_auc = sortrows(tbl_ranking,{'idx'});

    case 'difference'
        [BB_cut_log2,II_cut,BB_log2,II] = drug_effect_senstivity_difference(resp_profile);

        % [ranking.ii,ranking.bb] = sort(II);
        % tbl_ranking = array2table([ranking.ii' ranking.bb'],'VariableNames',{'ranking','idx'});
        % tbl_rat = sortrows(tbl_ranking,{'idx'});

end

figure('Position',[420   634   945   245])
bar(2.^BB_cut_log2)
xticks(1:length(BB_cut_log2))
xticklabels(target_parameters.mechanism(II_cut))
xtickangle(45)
ylabel({'Difference in pAKT';'by AKTi vs PI3Ki (norm.)'})
yline(1)
box off

%% Plot (time profiles) - sorted by difference

figure('Position',[620    50   717   946])
for ii = 1:size(resp_profile,2)

    dat(:,1) = resp_profile(:,II(ii),1); % FGFR4i + PI3Ki (perturbation)
    dat(:,2) = resp_profile(:,II(ii),2); % FGFR4i + AKTi (perturbation)
    dat(:,3) = resp_profile(:,end,1); % FGFR4i + PI3Ki (control)
    dat(:,4) = resp_profile(:,end,2); % FGFR4i + PI3Ki (control)


    % calculation of reboundness
    for jj = 1:2
        BB =  1;
        CC = min(dat(:,jj));
        YY = dat(end,jj);       
        rebundness(ii,jj) = (YY - CC)/BB;
    end

    subplot(8,7,ii),
    pl = plot((dat),'LineWidth',2);
    set(pl(3),'LineWidth',0.5,'Color',[0 0 0]);
    set(pl(4),'LineWidth',0.5,'Color',[0.650980392156863 0.650980392156863 0.650980392156863]);

%     if ii == size(resp_profile,2)
%         xlabel('time (hr)')
%     end


xtic = [1 5 8];
xticks(xtic)
xticklabels(time(xtic)/60)
xtickangle(30)
%ylabel('pAKT (norm.)')

title(deblank(target_parameters.mechanism{II(ii)}))
box off


end

%% rebound-ness

rebness_log2 = log2(mean(rebundness,2));
figure('Position',[757   795   251   141])
sc = scatter(rebness_log2,BB_log2,50,...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor','flat');

ylabel('difference (log2)')
xlabel('reboundness(log2)')
rho = corr(rebness_log2(:),BB_log2(:));
title(strcat('corr. = ',num2str(rho)))
pbaspect([1,1,1])

