%% Dose response combo simulation

% [choose the estimated IC50 values]
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

% note: the first column is the fit score
bestfit_params(:,1) = [];
% bestfit_params = bestfit_params(1:size(ic50_table,2)-1,:);



% % [drug target parameters table]
drugtargets = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);


%  Number of parameters used for simulation
NofParam = 50;
bestfit_params = bestfit_params(1:NofParam,:);
ic50_table = ic50_table(:,1:NofParam+1);



% [mapping the ic50 value and the drug target parameters]
for ii = 1:length(ic50_table.drug)

    idx = ismember(drugtargets.Inhibitor,ic50_table.drug(ii));

    ic50.value(ii,:) = table2array(ic50_table(ii,2:end));
    ic50.drug{ii} = drugtargets.Inhibitor{idx};
    ic50.param{ii} = drugtargets(idx,3:end);

end

% simulation (multiple-readouts )
% my_reads = {'pAkt','pERK','pFGFR4','pFRS2','pERBB','pIGFR','aPI3K','PTP','aGAB1','aGAB2'};


% [user can choose drugs to be tested in combination]
drugs = {'FGFR4i'};
drugs_icx = [50];



% example for single
% drugs = {'MEKi'};
% drugs_icx = [1 5 10 25 50];



nd1 = length(drugs_icx);
nd2 = size(bestfit_params,1);


parfor  masterIDX = 1:nd1*nd2

    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);

    disp(masterIDX)
    % input arguments
    param_val  = bestfit_params(idx2,:); % a list of target param index



    d1 = ismember(upper(ic50.drug),upper(drugs{1}));
    target_param{1} = table2array(ic50.param{d1});
    target_dose{1} =   ic50.value(d1,idx2)*drugs_icx(idx1);



    try

        [mex_out] = sim_module_par(param_val,target_param,target_dose,model,param_names,X0);

        %         rd_idx = ismember(mex_out.states,:);
        %         rd_name = mex_out.states(rd_idx);
        rd_time = mex_out.time;

        % cell viability
        % check the order
        % [vf_weight.Protein,rd_name']
        % cv_value(ii,jj)  = sum(mex_out.statevalues(end,rd_idx).*vf_weight.Weight');
        % network responses
        respc(:,:,masterIDX) = data_normalization(mex_out.statevalues(:,:),2);

    catch

        target_param = 'NaN';
        target_dose = 0;

        [mex_out] = sim_module_par(param_val,target_param,target_dose,model,param_names,X0);
        %         rd_idx = ismember(mex_out.states,:);
        respc(:,:,masterIDX) = data_normalization(mex_out.statevalues(:,:),2)*NaN;
    end
end


%%

[nrow,ncol,~]=size(respc);
dr_resp_mat = reshape(respc,[nrow,ncol,nd1,nd2]);
% d1: time
% d2: states
% d3: dose
% d4: models



listJob = {
    'time/dose response analysis';
    'correlation btw RB and EDE'
    };

[ jobID ] = readInput( listJob );
my_choice = listJob{jobID}; % Selected


switch my_choice

    case 'time/dose response analysis'

        readout = 'pAKT';

        rd_idx = ismember(upper(state_names),upper({readout}));
        resp_prof(:,:) = dr_resp_mat(end,rd_idx,:,:);

        dose_profile_avg = nanmean(resp_prof,2);
        dose_profile_std = nanstd(resp_prof,0,2);

        [~,pval]=ttest2(ones(1,50),resp_prof(end,:))



        figure(100)
        errorbar(drugs_icx,dose_profile_avg,dose_profile_std/sqrt(size(resp_prof,2)))


        dr_tbl = array2table([[0 drugs_icx]' ...
            [1;dose_profile_avg] ...
            [0;dose_profile_std]...
            [ones(size([1;dose_profile_avg]))*NofParam]],'VariableNames',{'dose','Mean','SD','N'});


    case  'correlation btw RB and EDE'


        readout = 'pAKT';

        rd_idx = ismember(upper(state_names),upper({readout}));
        resp_prof(:,:) = dr_resp_mat(:,rd_idx,1,:);


        % calculation of EDE and RB
        for ii = 1:size(resp_prof,2)

            tmp1 = resp_prof(:,ii);

            EDE(ii) = 1 - min(tmp1);
            RB(ii) = tmp1(end) - min(tmp1);

        end

             % remove EDE = 0
            ede_0 = (EDE == 0);
            EDE(ede_0) = [];
            RB(ede_0) = [];


            figure('Position',[680   794   307   184])

            dat_tbl = array2table([EDE' RB'],'VariableNames',{'EDE','RB'});
            mdl = fitlm(dat_tbl,'RB ~ EDE');

            plot(mdl,...
                'MarkerFaceColor',[0 0.447058823529412 0.741176470588235],...
                'MarkerEdgeColor',[0 0 0],...
                'MarkerSize',6,...
                'Marker','o',...
                'LineStyle','none',...
                'Color',[0 0 1]);
            legend off
            box off

            xlabel('EDE')
            ylabel('RB')
            title(strcat('Corr. = ',num2str(corr(RB',EDE'))))
            pbaspect([1,1,1])

            [rho,pval]=corr(RB',EDE');



end

%
%
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
% clear drug_response drugs drugs_icx yavg ystd mex_out sim ic50_table