%% plot the fitting result for Prism


% [choose mode of parameter estimation]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    };

[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});

% note: the first column is the fit score
bestfit_params(:,1) = [];
bestfit_params = bestfit_params(1:50,:);


%%

% [select exp data used for calibration]
expdata_title = EstimData.expt.title;

[indx,tf] = listdlg('ListString',expdata_title);
EstimData.sim.TraningData = indx;
% (old) EstimData.sim.TraningData = [1 2 3 4 5 6];
mul_idx = contains(expdata_title(indx),'Multi-');



for kk = 1:size(bestfit_params,1) % models
    disp(kk)
    EstimData.model.bestfit = bestfit_params(kk,:);
    EstimData.model.maxnumsteps     = 1000;
    [~,EstimData] = ga_user_code([],EstimData,[]);

    for ii = 1:length(indx)% group

        sim_dat = EstimData.sim.resampled{indx(ii)}; % sim data
        exp_dat = EstimData.expt.data{indx(ii)}; % train data

        for jj = 1:length(sim_dat)% data

            num_readouts(ii) = size(sim_dat,2);

            if size(sim_dat{jj},2) < 2

                dat_fit_l1_sim{jj,ii,kk} = sim_dat{jj}/max(sim_dat{jj});
                dat_fit_l1_exp{jj,ii,kk} = exp_dat{jj}/max(exp_dat{jj});

            else % for multi-dose

                dat_fit_l1_sim{jj,ii,kk} = sim_dat{jj}/max(sim_dat{jj}(:,end));
                dat_fit_l1_exp{jj,ii,kk} = exp_dat{jj}/max(exp_dat{jj}(:,end));
            end
        end
    end
end



%% Re-arrangement of data

for jj = 1:length(indx) % group

    for ii = 1:num_readouts(jj) % data

        d1 = size(dat_fit_l1_sim{ii,jj,1},1);
        d2 = size(dat_fit_l1_sim{ii,jj,1},2);
        d3 = size(dat_fit_l1_sim,3);


        if mul_idx(jj)

            dat_fit_l2_sim{ii,jj}.avg =  nanmean(reshape([dat_fit_l1_sim{ii,jj,:}],d1,d2,d3),3);
            dat_fit_l2_sim{ii,jj}.std = nanstd(reshape([dat_fit_l1_sim{ii,jj,:}],d1,d2,d3),0,3);
            dat_fit_l2_sim{ii,jj}.num = ones(size(dat_fit_l2_sim{ii,jj}.avg,1),1)*size(reshape([dat_fit_l1_sim{ii,jj,:}],d1,d2,d3),3);

            dat_fit_l2_exp{ii,jj}.avg =  nanmean(reshape([dat_fit_l1_exp{ii,jj,:}],d1,d2,d3),3);
            dat_fit_l2_exp{ii,jj}.std = ones(size(dat_fit_l2_sim{ii,jj}.std))*0;
            dat_fit_l2_exp{ii,jj}.num = ones(size(dat_fit_l2_sim{ii,jj}.num));


        else % single dose time course

            dat_fit_l2_sim{ii,jj}.avg = nanmean([dat_fit_l1_sim{ii,jj,:}],2);
            dat_fit_l2_sim{ii,jj}.std = nanstd([dat_fit_l1_sim{ii,jj,:}],0,2);
            dat_fit_l2_sim{ii,jj}.num = ones(size(dat_fit_l2_sim{ii,jj}.avg))*size([dat_fit_l1_sim{ii,jj,:}],2);

            dat_fit_l2_exp{ii,jj}.avg = nanmean([dat_fit_l1_exp{ii,jj,:}],2);
            dat_fit_l2_exp{ii,jj}.std = ones(size(dat_fit_l2_sim{ii,jj}.std))*0;
            dat_fit_l2_exp{ii,jj}.num = ones(size( dat_fit_l2_sim{ii,jj}.num));

        end

    end
end



%% save the data for Prisim

% [choose mode of parameter estimation]
listfile = {
    'save simulation data'
    'save experimental data'
    };

[ jobID ] = readInput( listfile );
my_choice = (listfile{jobID});


switch my_choice

    case 'save simulation data'

        prismdata = dat_fit_l2_sim;
        head_letter = 'prism(sim)';

    case 'save experimental data'
        prismdata = dat_fit_l2_exp;
        head_letter = 'prism(exp)';
end


for ii = 1:length(indx)

    for jj = 1:size(prismdata,1)

        data_grp = prismdata{jj,ii};

        if ~isempty(data_grp)

            rd_lab = EstimData.expt.names{indx(ii)}{jj};

            
            if mul_idx(ii) % multi-dose time course
                
                aprism_sim = array2table([data_grp.avg(:,1) data_grp.std(:,1) data_grp.num data_grp.avg(:,2) data_grp.std(:,2) data_grp.num],...
                    'VariableNames',{'avg(10nM BLU)','std(10nM BLU)','num(10nM BLU)','avg(100nM BLU)','std(100nM BLU)','num(100nM BLU)'});
                writetable(aprism_sim,strcat(workdir,'\Outcome\',head_letter,'_',num2str(indx(ii)),'.xlsx'),'Sheet',rd_lab)                

            else % for single dose time course
                
                aprism_sim = array2table([data_grp.avg data_grp.std data_grp.num],'VariableNames',{'avg','std','num'});
                writetable(aprism_sim,strcat(workdir,'\Outcome\',head_letter,'_',num2str(indx(ii)),'.xlsx'),'Sheet',rd_lab)
                
            end
        end
    end

end



