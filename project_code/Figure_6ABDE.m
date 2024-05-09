% Code for reprodudcing Figure 6ABDE

load('workSpace_Figure6.mat')


%% Figure 6A

rd_name = {'pAkt'};
dat_profile(:,:,:) = compiled_outputs(:,ismember(readout,rd_name),:,:);

for ii = 1:nd1
    dat = [];
    dat(:,:) = dat_profile(:,ii,:);

    y_data = mean(dat,2,'omitnan');
    x_range = t_frame.tspan_drug/60;

    dat_profile_avg(:,ii) = y_data;
    dat_profile_std(:,ii) = std(dat,[],2,'omitnan');
end

% sorting the data
wf_dat = dat_profile_avg;
[~,cii]=sort(max(wf_dat));
wf_dat_sort = wf_dat(:,(cii));
wf_par_sort = target_parms((cii));


% time resampling
wf_time_sampling = t_frame.tspan_drug/60;
nw_wf_time = ([0 0.5 1 2 4 6 12 24]);
wf_dat_sampled = wf_dat_sort(ismember(wf_time_sampling,nw_wf_time),:);


figure('position',[680   754   328   224])
wp = waterfall(wf_dat_sampled');

xlabel('time (hr)','FontName','Roboto')
xticks(1:length(nw_wf_time))
xticklabels(num2str(nw_wf_time'))
%yticks(1:length(wf_par_sort))

yticklabels({})
ylabel('Parameters','FontName','Roboto')

zlabel(strcat(rd_name,'(norm.)'))

set(gca,'FontName','Roboto')
% axis([-inf inf -inf inf -inf 250])
wp.LineWidth = 2.5;
wp.FaceAlpha = 0.75;
wp.Selected  = 'on';

view([43.450434782608689,34.612758623847583])



%% Figure 6B


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


% the effect of parameter perturbation is normalized by control
RM_control = repmat(rebound_metrics_avg(end,:),size(rebound_metrics_avg,1),1);
Rebound_score_norm = rebound_metrics_avg./RM_control;

% remove the control
Rebound_score_norm = (Rebound_score_norm(1:end-1,:));
param_lab = target_parms(1:end-1);
symbol_lab = link_symbol(1:end-1);

% sorting with RS1 as a reference
[~,iid]=sort(Rebound_score_norm(:,1),'descend');

re_param_lab = symbol_lab(iid);


for ii = 1:length(rb_metrics)

    figure('Position',[687   200   284   736]),

    % bar graph
    tmp_bg = barh(Rebound_score_norm(iid,ii));
    xline(1)
    %set(gca,'yscale','log')
    axis([-inf inf 0.1 inf ])
    yticks(1:length(param_lab))
    yticklabels(re_param_lab)
    xlabel('Sensitivity Score','FontName','Roboto')
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


%% Figure 6D


rd_name = {'pERBB'};
dat_profile(:,:,:) = compiled_outputs(:,ismember(readout,rd_name),:,:);

for ii = 1:nd1
    dat = [];
    dat(:,:) = dat_profile(:,ii,:);

    y_data = mean(dat,2,'omitnan');
    x_range = t_frame.tspan_drug/60;

    dat_profile_avg(:,ii) = y_data;
    dat_profile_std(:,ii) = std(dat,[],2,'omitnan');
end

% sorting the data
wf_dat = dat_profile_avg;
[~,cii]=sort(max(wf_dat));
wf_dat_sort = wf_dat(:,(cii));
wf_par_sort = target_parms((cii));


% time resampling
wf_time_sampling = t_frame.tspan_drug/60;
nw_wf_time = ([0 0.5 1 2 4 6 12 24]);
wf_dat_sampled = wf_dat_sort(ismember(wf_time_sampling,nw_wf_time),:);


figure('position',[680   754   328   224])
wp = waterfall(wf_dat_sampled');

xlabel('time (hr)','FontName','Roboto')
xticks(1:length(nw_wf_time))
xticklabels(num2str(nw_wf_time'))
%yticks(1:length(wf_par_sort))

yticklabels({})
ylabel('Parameters','FontName','Roboto')

zlabel(strcat(rd_name,'(norm.)'))

set(gca,'FontName','Roboto')
% axis([-inf inf -inf inf -inf 250])
wp.LineWidth = 2.5;
wp.FaceAlpha = 0.75;
wp.Selected  = 'on';

view([-30.562875321920949,9.522328486160816])

%% Figure 6E


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


% the effect of parameter perturbation is normalized by control
RM_control = repmat(rebound_metrics_avg(end,:),size(rebound_metrics_avg,1),1);
Rebound_score_norm = rebound_metrics_avg./RM_control;

% remove the control
Rebound_score_norm = (Rebound_score_norm(1:end-1,:));
param_lab = target_parms(1:end-1);
symbol_lab = link_symbol(1:end-1);

% sorting with RS1 as a reference
[~,iid]=sort(Rebound_score_norm(:,1),'descend');

re_param_lab = symbol_lab(iid);


for ii = 1:length(rb_metrics)

    figure('Position',[687   200   284   736]),

    % bar graph
    tmp_bg = barh(Rebound_score_norm(iid,ii));
    xline(1)
    %set(gca,'yscale','log')
    axis([-inf inf 0.1 inf ])
    yticks(1:length(param_lab))
    yticklabels(re_param_lab)
    xlabel('Sensitivity Score','FontName','Roboto')
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

