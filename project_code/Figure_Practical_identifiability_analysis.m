% Figure S3-4: Practical identifiability analysis (Model-1)
% Figure S12-13: Practical identifiability analysis (Model-2)
% Figure S18-19: Practical identifiability analysis (Model-3)
% Figure S43: Practical identifiability analysis (Reduced model)

param_names = FGFR4_model_rev2a_mex('parameters');

readouts = {'Figure S3-4 (Model-1)','Figure S12-13 (Model-2)','Figure S18-19 (Model-3)',...
    'Figure S43 (Reduced Model)'};
figure_number = readouts{readInput( readouts )};

switch figure_number

    case 'Figure S3-4 (Model-1)'
        pl_score = readtable('PL_profile_STEP1_NLM5.csv');
        fit_score = 30.7; % Model-1;

    case 'Figure S12-13 (Model-2)'
        pl_score = readtable('PL_profile_STEP2_NLM3.csv');
        fit_score = 49.3; % Model-2;


    case 'Figure S18-19 (Model-3)'

        pl_score = readtable('PL_profile_STEP3_NLM5.csv');
        fit_score = 49.5; % Model-3;

    case 'Figure S43 (Reduced Model)'
        pl_score = readtable('PL_profile_SimpleModel.csv');
        fit_score = 1410; % SimpleModel;
end


% the perturbation range
prt_range  = 10.^[-6 -4 -2 0 2 4 6];
prt_range_resample = sort([1 logspace(-6,6,50)]);

pl_param = param_names(table2array(pl_score(:,1)));
pl_data = table2array(pl_score(:,2:end));

%
pl_data(pl_data < mean(pl_data(:,4))) = mean(pl_data(:,4));

crit = 3.841 + pl_data(:,4);

% manual adjustment of x-lable
xtick0 = [13 26 39];
xticklabel0 = {'-3', '0', '3'};

%% calculation
for ii = 1:size(pl_data,1)

    disp(ii)

    % PL-data interplation
    pl_data_resample(ii,:) = interp1(prt_range,pl_data(ii,:),prt_range_resample);


    % divide the PL data into two part
    pl_idx = pl_data_resample(ii,:) > crit(ii);

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
    plot(pl_data_resample(ii,:),'LineWidth',1,'Color',color_code);
    hold on
    plot(26,min(pl_data_resample(ii,26)),'*r')
    xticks(xtick0)
    xticklabels(xticklabel0)
    set(gca,'LineWidth',1)
    % axis([-inf inf crit(ii)*0.9 crit(ii)*1.5])
    yline(crit(ii),'--k','LineWidth',1,'FontSize',8)
    % axis([-inf inf 0 2.2])
    box off
    xlabel(pl_param{ii})
    hold off

end

tbl_bnd = array2table(string(bnd),'VariableNames',{'lower','upper'},'RowNames',pl_param);
% identifiable
Ident = sum(sum(isinf(bnd),2) == 0)/length(pl_param)*100;
% practially nonientifiable
PNIdent = sum(sum(isinf(bnd),2) == 1)/length(pl_param)*100;
% structually nonientifiable
SNIdent = sum(sum(isinf(bnd),2) == 2)/length(pl_param)*100;
reult_summ = array2table([Ident PNIdent SNIdent],'VariableNames',{'Identifiable','Practically Non-identifiable','Structurally Non-identifiable'});



