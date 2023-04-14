%% drug response profiles (time course)


%% load parameter sets, IC50 table, drug-target table

listfile = {
    'single_drug_ic50_STEP1.csv'
    'single_drug_ic50_STEP1_full.csv'
    'single_drug_ic50_STEP3-n50.csv'
    };

[ jobID ] = readInput( listfile );
ic50_table = readtable(listfile{jobID});
ic50_table.Properties.VariableNames(1) = {'drug'};


% [choose mode of parameter estimation]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv';
    'fitted_paramsets_rev2_STEP3.csv';
    };


[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});
bestfit_params(:,1) = []; % note: the first column is the fit score


% [drug-target parameters table]
drugtargets = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);


%  Number of parameters used for simulation
NofParam = 50;
bestfit_params = bestfit_params(1:NofParam,:);
ic50_table = ic50_table(:,1:NofParam+1);





%%  [mapping the ic50 table to the drug target parameters]
for ii = 1:length(ic50_table.drug)

    idx = ismember(drugtargets.Inhibitor,ic50_table.drug(ii));

    ic50.value(ii,:) = table2array(ic50_table(ii,2:end));
    ic50.drug{ii} = drugtargets.Inhibitor{idx};
    ic50.param{ii} = drugtargets(idx,3:end);

end




%% drug treatment settings

drugs = {'FGFR4i','PI3Ki'};
drugs_icx = [40,0];


% example for combo:
% drugs = {'FGFR4i','PI3Ki'};
%drugs_icx = [40,5]; % ICx value (folds)

% drugs = {'FGFR4i','AKTi'};
%drugs_icx = [40,5]; % ICx value (folds)

% example for mono:
% drugs = {'MEKi'};
%drugs_icx = [50]; % ICx value (folds)




%% simulation

sim. maxsteps = 1000;

for jj = 1:size(bestfit_params,1)

    disp(jj)

    % input arguments
    sim.param  = bestfit_params(jj,:); % a list of target param index


    for kk = 1:length(drugs)
        d1 = ismember(upper(ic50.drug),upper(drugs{kk}));
        sim.target{kk} = table2array(ic50.param{d1});
        sim.dose{kk} =   ic50.value(d1,jj)*drugs_icx(kk);
    end


    try

        [mex_out] = sim_module_combo(sim,model);
        rd_time = mex_out.time;
        respc(:,:,jj) = data_normalization(mex_out.statevalues(:,:),2);

    catch


        for kk = 1:length(drugs)
            sim.target{kk} = 'NaN';
            sim.dose{kk} =   0;
        end

        [mex_out] = sim_module_combo(sim,model);
        respc(:,:,jj) = data_normalization(mex_out.statevalues(:,:),2)*NaN;
    end
end





%% choose readouts 

readout = 'pAKT';
rd_idx = ismember(upper(state_names),upper({readout}));
drug_response(:,:) = respc(:,rd_idx,:);



yavg = mean(drug_response,2);
ystd = std(drug_response,[],2);

[~,pval]=ttest2(drug_response(1,:),drug_response(end,:))

figure(100)
errorbar(rd_time/60,yavg,ystd/sqrt(size(drug_response,2)))
hold on


dr_tbl = array2table([rd_time'/60 yavg ystd ones(size(yavg))*NofParam],'VariableNames',{'time','Mean','SD','N'});




% if length(drugs) == 2
% 
%     writetable(dr_tbl,strcat(workdir,'\Outcome\',strcat('drug_response_combo_',strcat(drugs{1},'-',drugs{2},'_',num2str(NofParam)),'.xlsx')))
%     save(strcat(workdir,'\Outcome\',strcat('drug_response_',strcat(drugs{1},'-',drugs{2})),'_',num2str(NofParam),'.mat'),'drug_response','-mat')
% 
% elseif length(drugs) == 1
%     writetable(dr_tbl,strcat(workdir,'\Outcome\',strcat('drug_response_combo_',strcat(drugs{1},'- single','_',num2str(NofParam)),'.xlsx')))
%     save(strcat(workdir,'\Outcome\',strcat('drug_response_',strcat(drugs{1},'-','single'),'_',num2str(NofParam)),'.mat'),'drug_response','-mat')
% 
% end
% 
% 
