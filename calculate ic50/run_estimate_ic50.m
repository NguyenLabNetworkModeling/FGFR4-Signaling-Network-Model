%% process
%% run_single_drug_dose_response_STEP1_screening
%% Estimate the IC50 value for Step 3

% [choose mode of parameter estimation]
listfile = {
    'single_drug_response_screening_STEP1.mat';
    'single_drug_response_screening_STEP1_full.mat';
    'single_drug_response_screening_STEP3-n100.mat'
    'single_drug_response_screening_STEP3-n150.mat'
    'single_drug_response_screening_STEP3-n50.mat'
    };
[ jobID ] = readInput( listfile );
load(listfile{jobID});


data = single_drug_response_screening.data;
DrugNames = single_drug_response_screening.DrugNames;
DrugRange = single_drug_response_screening.DrugRange;
DrugTargetNames = single_drug_response_screening.DrugTargetNames;

% data summary
[sz1,sz2,sz3] = size(data);
disp([{strcat('num of dose (d1 - range) = ',num2str(sz1))};
    {strcat('num of drug (d2 - drug names) = ',num2str(sz2))};
    {strcat('num of param (d2 - param)= ', num2str(sz3))}])

disp([DrugNames DrugTargetNames])
disp('-------press any key -------------')
pause
% check code
% AAA(:,:) = data(:,ismember(DrugNames,'PI3Ki'),:);
% DrugNames = {'PI3Ki'};
% data = AAA;

%% plot dose-response

tiledlayout(ceil(length(DrugNames)/4),4);

for ss = 1:length(DrugNames)

    doses = DrugRange;
    resps(:,:) = data(:,ss,:);
    

    % [data normalization to the basal]
    resps_nl = data_normalization(resps,2);   
    mu = nanmean(resps_nl,2);
    sigma = nanstd(resps_nl,1,2);

    nexttile
    errorbar(doses,mu,sigma);
    set(gca,'XScale','log');
    xlabel(strcat(DrugNames{ss},' (a.u.)'));
    ylabel(strcat(DrugTargetNames{ss},' (norm.)'));
    pbaspect([4 3 1])
    box off
end


%% estimate IC50

nd1 = length(DrugNames); % drugs
nd2 = size(data,3); % parameters

tic
parfor masterIDX = 1:nd1*nd2

    disp(strcat(num2str(masterIDX/(nd1*nd2)*100),' % done'))

    [idx1,idx2] = ind2sub([nd1,nd2],masterIDX);


    % renaming the array data for parfor
    DrugRange_par = DrugRange;
    data_par = data;


    dose2 = DrugRange_par;
    resp2 = data_par(:,idx1,idx2);

    % remove a NaN value
    dose2(isnan(resp2)) = [];
    resp2(isnan(resp2)) = [];



    % convert it to a log value
    log_dose2 = log10(dose2);
    inf_idx = ~isinf(log_dose2);

    % right shifting
    rsh = 3;

    try
        [fitobject1,gof1] = calculate_ic50(log_dose2(inf_idx)+rsh,resp2(inf_idx));
        ic50_par(masterIDX) = 10^(fitobject1.IC50-rsh);
        hillslope_par(masterIDX) = fitobject1.HillSlop;

        if gof1.rsquare > 0.8
            rsquare(masterIDX)= gof1.rsquare;
        else
            ic50_par(masterIDX)= NaN;
            hillslope_par(masterIDX) = NaN;
%                         plot(log_dose2(inf_idx)+rsh,resp2(inf_idx))
%                         hold on
%                         plot(fitobject1)
        end
    catch
        ic50_par(masterIDX)= NaN;
        hillslope_par(masterIDX) = NaN;
    end
end

disp('------------------------- done')
disp(strcat('running time (min): ',num2str(toc/60)))
disp('-------------------------')


ic50.data = reshape(ic50_par,[nd1,nd2]);
ic50.avg = nanmean(ic50.data,2);
ic50.std = nanstd(ic50.data,0,2);
ic50.count = sum(~isnan(ic50.data),2);

figure
boxplot(log10(ic50.data)')
xticklabels(DrugNames)
xtickangle(45)
ylabel('IC50 (log10)')
axis([-inf inf -2 2])
box off


hillslope.data = reshape(hillslope_par,[nd1,nd2]);
hillslope.avg = nanmean(hillslope.data,2);
hillslope.std = nanstd(hillslope.data,0,2);
hillslope.count = sum(~isnan(hillslope.data),2);

tbl_ic50 = array2table(ic50.data,"RowNames",DrugNames);
writetable(tbl_ic50,strcat(workdir,'\Outcome\','single_drug_ic50_XXX_XXX.csv'),'WriteRowNames',true)




