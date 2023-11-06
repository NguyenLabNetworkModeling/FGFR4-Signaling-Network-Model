%% Analysis of the identifiability result
%% Steps:
% load the PL files
% load the best-fitted sets



close all;
clc;


% [select a PL-file to analyse ]
myfolder = strcat(workdir,'\Outcome\identifability test\PL_*.csv');
myfile=dir(myfolder);
file_list = {myfile.name};

[indx,~] = listdlg('ListString',file_list);
pl_score = readtable(file_list{indx});

% [load the best-fitted parameter sets (used for the identifiability)]
myfolder = strcat(workdir,'\Outcome\identifability test\Best_Fit_*.csv');
myfile=dir(myfolder);
file_list = {myfile.name};

[indx,~] = listdlg('ListString',file_list);
param_score = readtable(file_list{indx});
fit_score = table2array(param_score(:,1));



%% Cut-off
%% threshold = mu + z*sigma/(sqrt(N))
% note that taking the top 50

NN = 50;
ranked_scpre = fit_score(1:NN);
% Inverse cumulative distribution function
alpha = 0.01;
mu = mean(ranked_scpre); % mean
sigma = std(ranked_scpre); % standard deviation
zscore= icdf('Normal',1-alpha,mu,sigma);
% cut-off threshold
crit = mu + zscore*sigma/(sqrt(NN));


% the perturbation range
prt_range  = 10.^[-6 -4 -2 0 2 4 6];
prt_range_resample = sort([1 logspace(-6,6,50)]);

pl_param = param_names(table2array(pl_score(:,1)));
pl_data = table2array(pl_score(:,2:end));

% manual adjustment of x-lable
xtick0 = [13 26 39];
xticklabel0 = {'-3', '0', '3'};




%% calculation

for ii = 1:size(pl_data,1)

    % PL-data interplation
    pl_data_resample(ii,:) = interp1(prt_range,pl_data(ii,:),prt_range_resample);


    % divide the PL data into two part
    pl_idx = pl_data_resample(ii,:) > crit;

    % location of the control (no perturbation)
    ref_loc = find(prt_range_resample == 1);

    % left-hand side
    % if the PL values >= threshold
    ar1 = find(pl_idx(1:ref_loc)==1);
    if  ~isempty(ar1)
        bnd(ii,1) = log10(prt_range_resample(ar1(end)));
    else
        bnd(ii,1) =  -inf;
    end


    % righ-hand side
    % if the PL values >= threshold
    ar2 = find(pl_idx(ref_loc+1:end)==1);
    if ~isempty(ar2)
        bnd(ii,2) = log10(prt_range_resample(ar2(1)+ref_loc));
    else
        bnd(ii,2) = inf;
    end


    if sum(isinf(bnd(ii,:))) == 0
        % identifiable: red
        color_code=[0.85,0.33,0.10];
    elseif sum(isinf(bnd(ii,:))) == 1
        % practical non-identifiable: blue
        color_code=[0.00,0.45,0.74];
    elseif sum(isinf(bnd(ii,:))) == 2
        % structural non-identifiable: black
        color_code=[0.00,0.00,0.00];
    end



    if mod(ii-1,54)+1 == 1
        figure('position',[590    42   631   954])
    end

    subplot(9,6,mod(ii-1,54)+1)
    plt = plot(pl_data_resample(ii,:),'LineWidth',1,'Color',color_code);
    hold on
    plot(26,min(pl_data_resample(ii,26)),'*r')
    xticks(xtick0)
    xticklabels(xticklabel0)
    set(gca,'LineWidth',1)
    yline(crit,'--k','LineWidth',1,'FontSize',8)
    % axis([-inf inf 0 2.2])
    box off
    xlabel(pl_param{ii})
    hold off


end



tbl_bnd = array2table(string(bnd),'VariableNames',{'lower','upper'},'RowNames',pl_param);
% note: Excel converts Inf values to 65535
% bnd -> string array

% % save the PL score
fname = strcat(fullfile(workdir,'Outcome'),'\identifability test\confidence_interval_table_XXX_XXX.xlsx');
writetable(tbl_bnd,fname,'WriteRowNames',true,'Sheet','confidence interval')


% identifiable
Ident = sum(sum(isinf(bnd),2) == 0)/length(pl_param)*100;
% practially nonientifiable
PNIdent = sum(sum(isinf(bnd),2) == 1)/length(pl_param)*100;
% structually nonientifiable
SNIdent = sum(sum(isinf(bnd),2) == 2)/length(pl_param)*100;

reult_summ = array2table([Ident PNIdent SNIdent],'VariableNames',{'Identifiable','Practically Non-identifiable','Structurally Non-identifiable'});
writetable(reult_summ,fname,'WriteVariableNames',true,'Sheet','summary')


