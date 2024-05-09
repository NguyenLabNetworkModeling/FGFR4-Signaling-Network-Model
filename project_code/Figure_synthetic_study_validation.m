% Figure S35. Model calibration results based on synthetic data with no noise (0%)
% Figure S36. Model calibration results based on synthetic data with no noise (10%)
% Figure S37. Model calibration results based on synthetic data with no noise (30%).
% Figure S38. Model calibration results based on synthetic data with no noise (50%)

model = 'FGFR4_model_rev2a_mex';
state_names = FGFR4_model_rev2a_mex('states');

validation_opt = {
    'Figure S35 (noise 00%)'
    'Figure S36 (noise 10%)'
    'Figure S35 (noise 30%)'
    'Figure S35 (noise 50%)'
    };

validation_opt = validation_opt{readInput( validation_opt )}; % Selected


switch validation_opt
    case 'Figure S35 (noise 00%)'
        file1 = 'Calibre_synthetic_data_00_percent.xlsx';
        file2 = 'validation_Best_fit_synthetic_00%.xlsx';
    case 'Figure S36 (noise 10%)'
        file1 = 'Calibre_synthetic_data_10_percent.xlsx';
        file2 = 'validation_Best_fit_synthetic_10%.xlsx';
    case 'Figure S35 (noise 30%)'
        file1 = 'Calibre_synthetic_data_30_percent.xlsx';
        file2 = 'validation_Best_fit_synthetic_30%.xlsx';
    case 'Figure S35 (noise 50%)'
        file1 = 'Calibre_synthetic_data_50_percent.xlsx';
        file2 = 'validation_Best_fit_synthetic_50%.xlsx';
end


cal_data = readtable(file1);
% measured variable = 15
xtime = cellfun(@str2double, cal_data.Type);
calibr_max = max(table2array(cal_data(:,2:16)));
% normalized to max
calibr_avg = table2array(cal_data(:,2:16))./calibr_max;
calibr_std = table2array(cal_data(:,17:end))./calibr_max;
calibr_var = cal_data.Properties.VariableNames(2:16);

if strcmp(validation_opt,'noise 00%')
    calibr_std = calibr_std*0;
end


% Load Validation data (with different noise level)
% .../SyntheticStudy_CRRevision/Outcome
% validation_Best_fit_synthetic_50%_xxx.xlsx
val_data = readtable(file2);
data_normalization(val_data(:,2:27),4)



% ground truth data
bestfit_paramsets = readmatrix('BestFittedParamSets_Rev2_Step3.csv');
% note: the first column is the fit score
bestfit_paramsets(:,1) = [];
% the first parameter used for this synthetic study
paramvals = bestfit_paramsets(1,:);

% simulate a ODE model
[sim_time, state_ground_truth] = simulation_synthetic(model,paramvals);
state_ground_truth_norm = data_normalization(state_ground_truth,4);


% all variable = 26
val_avg = table2array(data_normalization(val_data(:,2:27),4));
val_std = table2array(data_normalization(val_data(:,28:end),4));
val_var = val_data.Properties.VariableNames(2:27);


% divide variables into measured (trained) and unmeasured (predicted)

measured_avg = val_avg(:,ismember(val_var,calibr_var));
measured_std = val_std(:,ismember(val_var,calibr_var));
measured_var = val_var(ismember(val_var,calibr_var));
% check the order of variables
[calibr_var' measured_var']


unmeasured_avg = val_avg(:,~ismember(val_var,calibr_var));
unmeasured_std = val_std(:,~ismember(val_var,calibr_var));
unmeasured_var = val_var(~ismember(val_var,calibr_var));

% check the order of variables
[state_names(ismember(state_names,unmeasured_var)) unmeasured_var']




%% Measured data / training data

figure('Position',[569   407   485   472])
for ii = 1:length(calibr_var)

    subplot(4,4,ii)
    idx1 = find(ismember(calibr_var,calibr_var{ii}));
    idx2 = find(ismember(measured_var,calibr_var{ii}));
    ylab = calibr_var{ismember(calibr_var,calibr_var{ii})};

    shade_errorbar(xtime/60,calibr_avg(:,idx1),calibr_std(:,idx1),'Alpha',0.7,'Color',[0.00,0.45,0.74],'LineWidth',1)
    hold on
    shade_errorbar(xtime/60,measured_avg(:,idx2),measured_std(:,idx2)/sqrt(10),'Alpha',0.7,'Color',[0.85,0.33,0.10],'LineWidth',1)

    xlabel('time (hr)')
    ylabel(strcat(ylab,'(norm.)'))
    box off
    axis([0 inf 0 inf])
    pbaspect([4 3 1])

end




%% Unmeasured data / predicted data

figure('Position',[653   395   357   476])
for ii = 1:length(unmeasured_var)

    idx1 = find(ismember(state_names,unmeasured_var{ii}));
    idx2 = find(ismember(unmeasured_var,unmeasured_var{ii}));
    subplot(4,3,ii)    
    
    shade_errorbar(xtime/60,unmeasured_avg(:,idx2),unmeasured_std(:,idx2)/sqrt(10),'Alpha',0.7,'Color',[0.85,0.33,0.10],'LineWidth',1)
    hold on
    shade_errorbar(xtime/60,state_ground_truth_norm(:,idx1),zeros(size(xtime)),'Alpha',0.7,'Color',[0.00,0.45,0.74],'LineWidth',2)


    xlabel('time (hr)')
    ylabel(strcat(unmeasured_var{ii},'(norm.)'))
    box off
    axis([0 inf 0 inf])
    pbaspect([4 3 1])


    % 
    % plot(xtime/60,state_ground_truth_norm(:,idx1))
    % hold on
    % errorbar(xtime/60,unmeasured_avg(:,idx2),unmeasured_std(:,idx2)/sqrt(10))
    % xlabel('time (hr)')
    % ylabel(strcat(unmeasured_var{ii},'(norm.)'))
    % box off
    % axis([0 inf 0 inf])
    % pbaspect([4 3 1])

end


% plot (time, synthetic variable,
%

