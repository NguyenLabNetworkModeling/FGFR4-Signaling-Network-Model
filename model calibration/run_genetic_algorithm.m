%% We have best-fitted parameter sets used for initial guesses
FileList = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    }; 
FName = FileList{readInput(FileList)};

if exist(FName,'file')
    % load best fitted param_set
    BF_params = readmatrix(FName);
    % note: the first column is the fit score
    BF_params(:,1) = [];
    % array2table(BF_params','RowNames',param_names)
end

%% Choose the parameters to be calibrated
% kinetic parameters
kin_params   = param_names(1:find(ismember(param_names,'PTEN'))-1);% (1:95)
% inputs
lig_names   = param_names(ismember(param_names,{'IGF0','HRG0','FGF0'}));
target_index = find(ismember(param_names,unique([kin_params;lig_names])));


%% MEX simulaiton options
EstimData.model.maxnumsteps = 1000;

%% Ways of model calibration
JobList = {
    'sequential';
    'all data';
    };
Job = JobList{readInput(JobList)};

switch Job
    case 'sequential'

        Order = {
            [1 2 4 6 8], ...
            [1 2 4 6 8 9 10]...
            };

    case 'all data'

        STEP{1}.set = [1 4];
        STEP{1}.lab = 'STEP1';
        STEP{2}.set = [1 2 3 4 5];
        STEP{2}.lab = 'STEP2';
        STEP{3}.set = [1 2 4 6 8 9 10];
        STEP{3}.lab = 'STEP3';

        StepList = {
            'STEP1'
            'STEP2'
            'STEP3'
            };

        Order = {STEP{readInput(StepList)}.set};
end

%% Model Calibration Mode
ModeList = {
    'best-fitted params';
    'nominal values';
    'random params';
    }; 

Mode = ModeList{readInput(ModeList)};

switch Mode

    case 'best-fitted params'

        for ii = 1%:size(BF_params,1)
            ga_param_p0 = BF_params(ii,:);
            repeat_ga_module
        end

    case 'nominal values'

        P0 = [];
        if isempty(P0)
            P0 = p0;
        end
        ga_param_p0(1,:) = P0;
        repeat_ga_module

    case 'random params'
        % [choose mode of parameter estimation]
        listJob = {
            'paramer augmentation';
            'full random';
            }; % just for repeat of the run-ga

        [ jobID ] = readInput( listJob );
        randmode = listJob{jobID}; % Selected

        switch randmode
            case 'paramer augmentation'

                for ii = 1:1
                    
                    ub  = 0.1;
                    lb  = -0.1;
                    ga_param_p0 = BF_params(1,:);
                    param_p0 = ga_param_p0(target_index);
                    param_rand = param_p0.*(10.^(ub-(ub-lb)*rand(size(param_p0))));
                    ga_param_p0(target_index) = param_rand;

                    repeat_ga_module

                end

            case 'full random'

                for ii = 1:1

                    ub  = 5;
                    lb  = -5;
                    ga_param_p0(1:end) = p0;
                    param_p0 = ga_param_p0(target_index);
                    param_rand = (10.^(ub-(ub-lb)*rand(size(param_p0))));
                    ga_param_p0(target_index) = param_rand;

                    repeat_ga_module

                end
        end
end
