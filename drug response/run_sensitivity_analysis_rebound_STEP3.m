%%  Sensitivity Analysis of Rebound Mechanism

% * algorithm
% 1. load IC50 values (for FGFR4i and others)
% 2. load the drug target parameter table
% 2. load the best-fitted parameter sets
% 3. load the target parameter and annotation file
% 4. simulation settings


%% 1. Load IC50 values
listfile = {
    'single_drug_ic50_STEP1.csv'
    'single_drug_ic50_STEP3-n50.csv'
    };

[ jobID ] = readInput( listfile );
ic50_table = readtable(listfile{jobID});
ic50_table.Properties.VariableNames(1) = {'drug'};


%% 2. Load the drug target parameters

drugtargets_0 = readtable('drug_target_param_list_rev2.csv','ReadVariableNames',true);


%% 3. Load the best-fitted parameter sets

listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    };
[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});

% note: the first column is the fit score
bestfit_params(:,1) = [];

%  (NOTE) Number of parameters used for simulation
NofParam = 50;
bestfit_params = bestfit_params(1:NofParam,:);
%bestfit_params = bestfit_params(1:size(ic50_table,2)-1,:);
ic50_table = ic50_table(:,1:NofParam+1);


%% 4. Load the target parameter and annotation file


listfile = {
    'parameter annotation (targets for KO).xlsx'
    'parameter annotation_rev2a.xlsx'
    'parameter annotation_rev2a_kinase_only.xlsx'    
    };
[ jobID ] = readInput( listfile );
my_option = listfile{jobID};


tbl_target_param = readtable(my_option,...
    'ReadVariableNames',true);
target_parms = tbl_target_param.Param;
link_symbol = tbl_target_param.Symbol;
target_parms{end+1} = 'Control';
link_symbol{end+1} = 'Control';

%% 5. Simulation settings

% MEX options
mex_options.maxnumsteps = 2000;
mex_options.abstol = 1e-5; %Absolute tolerance
mex_options.reltol = 1e-6; % Relative tolerance


% simulation time frame
% [0: 5000] --> [0: 5000] --> [0:24*60]
star_tspan= linspace(0,5000,100);
stim_tspan = linspace(0,5000,100);
drug_tspan=[0:10:1440]; % UMIT: min
t_frame = simulation_time_frame(star_tspan,stim_tspan,drug_tspan);

% % drug: FGFR4i
% inhibitor =  'FGFR4i';
% ICx = 10;
ptr_size = 0.75;
% drugTargetIdx = ismember(drugtargets_0.Inhibitor,inhibitor);
% drugTargetParam = table2array(drugtargets_0(drugTargetIdx,3:end));
%
% drugIC50Idx = ismember(ic50_table.drug,inhibitor);
% drugIC50 = table2array(ic50_table(drugIC50Idx,2:end));

% readouts
readOutIdx = ismember(state_names,{'pAkt','pERBB','pIGFR','pIRS'});
readout = state_names(readOutIdx);



%% Run the model (parfor)

% FOR PARALLEL COMP
nd1 = length(target_parms); % parameters (n=75 including Control)
nd2 = size(bestfit_params,1); % models (n=50)

tic
parfor masterIDX = 1:nd1*nd2

    disp(strcat(num2str(masterIDX/(nd1*nd2)*100),'% done'))
    [idx1,idx2]=ind2sub([nd1,nd2],masterIDX);
    % idx1 : target parameter
    % idx2 : model


    bestfit_params0 = bestfit_params;
    target_parms0 = target_parms;
    % drugIC50_0 = drugIC50;

    % FGFR4i treatment
    tmp_param_vals0 = bestfit_params0(idx2,:);
    tmp_param_vals0(strcmp(param_names,'inh_on')) = 10000;

    % tmp_val = tmp_param_vals0(ismember(param_names,drugTargetParam));
    % tmp_param_vals0(ismember(param_names,drugTargetParam)) = tmp_val * (1/(1 + drugIC50_0(idx2)*ICx));
    tmp_param_vals0(ismember(param_names,{'FGFR4i_0'})) = 10;

    % parameter KO
    tar_param_idx=find(strcmp(param_names,target_parms0{idx1}));
    tmp_param_vals0(tar_param_idx)= tmp_param_vals0(tar_param_idx) * (1 - ptr_size);

    try
        % % MEX output
        mex_output = FGFR4_model_rev2a_mex(t_frame.tspan,X0,tmp_param_vals0,mex_options);
        mex_state_val(:,:,masterIDX)=mex_output.statevalues(t_frame.ti_drug,readOutIdx);

    catch ME
        disp(ME.message)
        mex_state_val(:,:,masterIDX)=NaN;
    end
end

disp('-------------------------------')
disp(strcat(num2str(toc/60),' [min]'))

% RE-shaping
[nrow1,ncol1,~]=size(mex_state_val);
compiled_outputs = reshape(mex_state_val,[nrow1,ncol1,nd1,nd2]);
% data(time,readouts,target params,models)

clear mex_state_val


% check the simulation outcome

figure
for ii = 1:length(readout)
    
    yout(:,:) = compiled_outputs(:,ii,end,:);
    
    nexttile

    plot(t_frame.tspan_drug/60,data_normalization(yout,2))
    xlabel('time (hr)')
    ylabel(readout{ii})
    axis tight
    box off
end




%% Plot - averaged response profile (perutbation)

[indx,tf] = listdlg('ListString',readout);
rd_name = readout(indx);

dat_profile(:,:,:) = compiled_outputs(:,ismember(readout,rd_name),:,:);



% data normalization option
listoptions = {
    'normalized to basal'
    'no normalizion'
    };

[ jobID ] = readInput( listoptions );
my_choice = listoptions{jobID};


figure('position',[680   799   215   179])


for ii = 1:nd1

    dat = [];
    dat(:,:) = dat_profile(:,ii,:);

    switch my_choice

        case 'normalized to basal'

            dat = data_normalization(dat,2);

        case 'no normalizion'
            % do nothing
    end

    y_data = mean(dat,2,'omitnan');
    x_range = t_frame.tspan_drug/60;

    plot(x_range,y_data,'LineWidth',1)

    if ii == nd1 % for control
        plot(x_range,y_data,'k','LineWidth',3)
    end

    xlabel('time (hr)')
    ylabel(strcat(rd_name,'(norm.)'))
    box off
    hold on

    dat_profile_avg(:,ii) = y_data;
    dat_profile_std(:,ii) = std(dat,[],2,'omitnan');
end

pbaspect([4 3 1])
hold off

% save data
row_name = arrayfun(@num2str, t_frame.tspan_drug'/60, 'UniformOutput', 0);
tbl_profile_avg = array2table(dat_profile_avg,...
    'RowNames',row_name,...
    'VariableNames',target_parms');


%% Walterfall Plot

% sorting the data
wf_dat = dat_profile_avg;
[~,cii]=sort(max(wf_dat));
wf_dat_sort = wf_dat(:,cii);
wf_par_sort = target_parms(cii);


% time resampling
wf_time_sampling = t_frame.tspan_drug/60;
nw_wf_time = [0 0.5 1 2 4 6 12 24];
wf_dat_sampled = wf_dat_sort(ismember(wf_time_sampling,nw_wf_time),:);


figure('position',[680   754   328   224])
wp = waterfall(wf_dat_sampled');

xlabel('time (hr)','FontName','Roboto','Rotation',20)
xticks(1:length(nw_wf_time))
xticklabels(num2str(nw_wf_time'))
%yticks(1:length(wf_par_sort))

yticklabels({})
ylabel('Parameters','FontName','Roboto','Rotation',-30)

zlabel(strcat(rd_name,'(norm.)'))

set(gca,'FontName','Roboto')
% axis([-inf inf -inf inf -inf 250])
wp.LineWidth = 1.5;
wp.FaceAlpha = 0.75;
wp.Selected  = 'on';

pbaspect([1 1 1])
% fpath = strcat(pwd,'\data.outcome\pAkt_rebound_SA_avg.csv');
% writetable(tbl_pAkt_rebound_SA_avg,fpath,'WriteRowNames',true)
%
% fpath = strcat(pwd,'\fig.outcome\waterfall.pdf');
% saveas(gcf,fpath)



%% Rebound Metrics (RB and EDE)

% 1. calculate the rebound metrics over all prameter sets (n=50)
% 2. take an average of the rebound metrics

for jj = 1:size(dat_profile,3)

    for ii = 1:size(dat_profile_avg,2)

        dat = dat_profile(:,ii,jj);

        rebound_metrics_raw(ii,1,jj) = (dat(end) -  min(dat)) / dat(1); % RB
        rebound_metrics_raw(ii,2,jj) = (dat(1) - min(dat)) / dat(1); % Early Drug Effect (EDE)
    end
end
rb_metrics = {'RB'};

rebound_metrics_avg = mean(rebound_metrics_raw,3,'omitnan');
rebound_metrics_std = std(rebound_metrics_raw,0,3,'omitnan');



%% plot Bar graph of RB and EDE

% the effect of parameter perturbation is normalized by control
RM_control = repmat(rebound_metrics_avg(end,:),size(rebound_metrics_avg,1),1);
Rebound_score_norm = rebound_metrics_avg./RM_control;

% remove the control
Rebound_score_norm = (Rebound_score_norm(1:end-1,:));
param_lab = target_parms(1:end-1);
symbol_lab = link_symbol(1:end-1);

% sorting with RS1 as a reference
[~,iid]=sort(Rebound_score_norm(:,1),'descend');

% y-ticklabel remaning
%re_param_lab = param_lab(iid);
re_param_lab = symbol_lab(iid);

% eve_iid = ~logical(rem(1:length(re_param_lab), 2));
% re_param_lab(eve_iid) = {''};

for ii = 1:length(rb_metrics)

    figure('Position',[687   200   284   736]),

    % bar graph
    tmp_bg = barh(Rebound_score_norm(iid,ii));
    xline(1)
    %set(gca,'yscale','log')
    axis([-inf inf 0.1 inf ])
    yticks(1:length(param_lab))
    yticklabels(re_param_lab)    
    xlabel(strcat(rb_metrics{ii},' (norm.)'),'FontName','Roboto')    
    set(gca,'FontName','Roboto','TickDir','out')
    box off

    % color
    num_lines = length(param_lab);
    cmap =colormap('jet');
    stepcol = floor(size(cmap,1)/num_lines);
    newcolor=cmap([1:num_lines]*stepcol,:);
    tmp_bg.FaceColor = 'flat';
    tmp_bg.CData = newcolor;
end


% exportgraphics(gcf,strcat('bar-graph_',ROUNDSCORE{8}{ii},'.eps'))
tbl_scores_norm = [array2table(Rebound_score_norm(iid,:),'VariableNames',...
    {'RB','EDE'})...
    array2table(param_lab(iid),'VariableNames',{'param'}),...
    array2table(link_symbol(iid),'VariableNames',{'symbol'})];

fpath = strcat(workdir,'\Outcome\','SA_STEP3_',rd_name{1},'.csv');
% save the norm. reboundscore
writetable(tbl_scores_norm, fpath,...
    'WriteVariableNames',true,...
    'WriteRowNames',true)
%
% fpath = strcat(pwd,'\fig.outcome\multi-bargraph-RS.pdf');
% saveas(gcf,fpath);

%% plot time course (average curve)

cut_off = 30;
top10(:,:) = dat_profile_avg(:,iid(1:cut_off));
bottom10(:,:) = dat_profile_avg(:,iid(end-cut_off-1:end));
% middleDat(:,:) = dat_profile_avg(:,iid(cut_off+1:end-cut_off));



figure('Position',[681   805   282   174])
plot(t_frame.tspan_drug/60,data_normalization(top10,2),'b','LineWidth',1)
hold on
plot(t_frame.tspan_drug/60,data_normalization(bottom10,2),'r','LineWidth',1)
% hold on
% plot(t_frame.tspan_drug/60,middleDat,'k','LineWidth',2)






%% *****************************
% Scatter plot (correlation)

cmap = colormap('jet');
stepcol = floor(size(cmap,1)/6);

figure('position',[680   759   290   219])

x_dat = tbl_scores_norm.RB;
y_dat = tbl_scores_norm.EDE;

% top 20 params
[~,xii]=sort(x_dat);
xii_top = xii(1:20);

[r1,Pv] = corr(x_dat(xii_top),y_dat(xii_top));

scatter(x_dat(xii_top),y_dat(xii_top),'LineWidth',1,...
    'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',cmap(43,:));
xlabel('RB');
ylabel('EDE');
title({strcat('Coeff. = ',num2str(r1))});
pbaspect([1 1 1]/4);






% scatter plot (correlation between RB and EDE)
RB(:,1) = rebound_metrics_raw(end,1,:);
EDE(:,1) = rebound_metrics_raw(end,2,:);

figure('position',[680   759   290   219])
[r1,Pv] = corr(RB(:),EDE(:));

scatter(RB/max(RB),EDE/max(EDE),'LineWidth',1,...
    'MarkerEdgeColor',rgb('Black'),'MarkerFaceColor',cmap(43,:));
xlabel('RB');
ylabel('EDE');
title({strcat('Coeff. = ',num2str(r1))});
pbaspect([1 1 1]/4);




% fpath = strcat(pwd,'\fig.outcome\correlation of RS.pdf');
% saveas(gcf,fpath);


%%
% Note:
%%
% * parameter KD -> biological context (function is down-regulated)
% * in some contexts, pAkt rebound significantly decreased e.g., Vm, Vm, Vm,
% ....
% * but in other context, RS decreas while B0 and Yss increase, which means
% that in these context pAkt rebound is weak but basal and the steay state pAkt
% increase at same time. which means it is related to denovo resisance.
%% plot a heatmap of the rebound scores
%

%% heatmap

% tbl_scores_norm.rs_avg = mean([tbl_scores_norm.RS1 tbl_scores_norm.RS2 tbl_scores_norm.RS3],2);
%
% tbl_scores_norm = sortrows(tbl_scores_norm,'RS1')


idex_int = ismember(tbl_scores_norm.Properties.VariableNames,{'RB','EDE'});

dat = [];
dat = table2array(tbl_scores_norm(:,idex_int));
%normalization
dat = dat./repmat(mean(dat,1),size(dat,1),1);
dat_exp = log2(dat);
col_labels = tbl_scores_norm.Properties.VariableNames(idex_int);
row_labels = tbl_scores_norm.param;

hmo = clustergram(dat_exp,...
    'Cluster','Column',...
    'Linkage','average',...
    'RowPDist','squaredeuclidean',...
    'Standardize',0,...
    'RowLabels',row_labels,...
    'ColumnLabels',col_labels,...
    'ColumnLabelsRotate',45);


%hmo_fg = hmo.plot();
%get(hmo)
RowLabels = hmo.RowLabels;
ColumnLabels = hmo.ColumnLabels;


% tree = linkage(dat_exp, 'complete');
% H = dendrogram(tree)
% T = cluster(tree,'maxclust',7);

[~,Locb1]=ismember(RowLabels,row_labels);
chk = [RowLabels row_labels(Locb1)];

[~,Locb2]=ismember(ColumnLabels,col_labels);
chk = [ColumnLabels' col_labels(Locb2)'];

tbl_rebound_heatmap = array2table(dat_exp(Locb1,Locb2),...
    'VariableNames',ColumnLabels,...
    'RowNames',RowLabels');

[~,Locb3]=ismember(RowLabels,param_lab);
chk = [RowLabels param_lab(Locb3) link_symbol(Locb3)];
tbl_rebound_heatmap.Link = link_symbol(Locb3);


%% Clustering of pAkt rebound to BLU

rm = struct('GroupNumber',{65,60,54,66,69},'Annotation',{'B','B','B','A','A'},...
    'Color',{'r','r','r','b','b'});
set(hmo,'RowGroupMarker',rm)

cgroup_65 = clusterGroup(hmo,65,'row');
cgroup_60 = clusterGroup(hmo,60,'row');
cgroup_54 = clusterGroup(hmo,54,'row');
cgroup_66 = clusterGroup(hmo,66,'row');
cgroup_69 = clusterGroup(hmo,69,'row');


gcluster{1} = cat(1,cgroup_65.RowLabels,cgroup_60.RowLabels,cgroup_54.RowLabels);

plot(hmo);
% fpath = strcat(pwd,'\fig.outcome\clustering heatmap.pdf');
% saveas(gcf,fpath);

tbl_rebound_heatmap.Grp = cell(size(tbl_rebound_heatmap,1),1)
grp_a = ismember(tbl_rebound_heatmap.Properties.RowNames,gcluster{1});
tbl_rebound_heatmap.Grp(grp_a) = {'A'}

gcluster{2} = cat(1,cgroup_54.RowLabels,cgroup_66.RowLabels,cgroup_69.RowLabels);

grp_b = ismember(tbl_rebound_heatmap.Properties.RowNames,gcluster{2});
tbl_rebound_heatmap.Grp(grp_b) = {'B'}


% fpath = strcat(pwd,'\data.outcome\','rebound_score_heatmap.xlsx');
% % save the norm. reboundscore
% writetable(tbl_rebound_heatmap,fpath,...
%     'WriteVariableNames',true,...
%     'WriteRowNames',true,...
%     'Sheet','combined')


figure;

tmp_cl = gcluster{1}';
tmp_cl_idx = ismember(tbl_profile_avg.Properties.VariableNames,tmp_cl);
tmp_cl_dat = table2array(tbl_profile_avg(:,tmp_cl_idx));
errorbar(t_frame.tspan_drug'/60,mean(tmp_cl_dat,2),std(tmp_cl_dat,[],2)/sqrt(4),'b')



hold on
tmp_cl = gcluster{2}';
tmp_cl_idx = ismember(tbl_profile_avg.Properties.VariableNames,tmp_cl);
tmp_cl_dat = table2array(tbl_profile_avg(:,tmp_cl_idx));
errorbar(t_frame.tspan_drug'/60,mean(tmp_cl_dat,2),std(tmp_cl_dat,[],2)/sqrt(4),'r')

hold on
plot(t_frame.tspan_drug'/60,tbl_profile_avg.Control,'--k')

xlabel('time(hr)')
ylabel('pAkt')
box off
axis([-1 inf -1 inf])
% end


%%


%% Plot pAkt profiles (individual model)

% a readout (pAkt) - drug response section



cl1_pAkt(:,:) = mean(compiled_outputs(:,ismember(readout,rd_name),ismember(target_parms,gcluster{1}'),:),4);
cl2_pAkt(:,:) = mean(compiled_outputs(:,ismember(readout,rd_name),ismember(target_parms,gcluster{2}'),:),4);
cl0_pAkt(:,:) = mean(compiled_outputs(:,ismember(readout,rd_name),ismember(target_parms,'Control'),:),4);

close;
figure('Position',[681   805   282   174])
plot(t_frame.tspan_drug/60,cl1_pAkt,'b','LineWidth',1)
hold on
plot(t_frame.tspan_drug/60,cl2_pAkt,'r','LineWidth',1)
hold on
plot(t_frame.tspan_drug/60,cl0_pAkt,'k','LineWidth',2)

xlabel('time (hr)')
ylabel('pAkt')
box off
axis tight
pbaspect([4 3 1]/4)
fpath = strcat(pwd,'\fig.outcome\pAkt time profile to SA.pdf');
saveas(gcf,fpath);



%%
