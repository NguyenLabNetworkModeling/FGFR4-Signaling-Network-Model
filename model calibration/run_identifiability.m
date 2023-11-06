%% run Identifiability

%% step 1: choose mode of parameter estimation
listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    'fitted_paramsets_rev2_STEP3 - partB.csv'
    'Best_Fit_Identifiability_Step1.csv'
    'Best_Fit_Identifiability_Step2.csv'
    'Best_Fit_Identifiability_Step3.csv'
    }; % just for repeat of the run-ga

[ jobID ] = readInput( listfile );
fname = listfile{jobID}; % Selected

% load best fitted param_set
bf_params = readmatrix(fname);

param_id = 1;
fscore = bf_params(param_id,1);
ga_param_p0 = bf_params(param_id,2:end);



%% Simulation Settings 

% for STEP3: [1 2 4 6 8 9 10]
% for STEP2: [1 2 3 4 5]
% for STEP1: [1 2]

STEP{1}.set = [1 2];
STEP{1}.lab = 'STEP1';
STEP{2}.set = [1 2 3 4 5];
STEP{2}.lab = 'STEP2';
STEP{3}.set = [1 2 4 6 8 9 10];
STEP{3}.lab = 'STEP3';


listfile = {
    'identifiability: STEP1'
    'identifiability: STEP2'
    'identifiability: STEP3'
    }; % just for repeat of the run-ga
[ jobID ] = readInput( listfile );

EstimData.sim.TraningData = STEP{jobID}.set;
         
% choose a group of parameters to be calibrated
kin_params   = param_names(1:find(ismember(param_names,'PTEN'))-1);% (1:95)
lig_names   = param_names(ismember(param_names,{'IGF0','HRG0','FGF0'}));
target_index = find(ismember(param_names,unique([kin_params;lig_names])));
    
% parameter perturbaito range
prt_range  = 10.^[-6 -4 -2 0 2 4 6];

%% Simulation

for ii = 1:length(target_index)
    disp(strcat('--',num2str(ii),'----------------------------------'))
    
    for jj = 1:length(prt_range)
        
        % takine one parameter set
        % ga_param_p0 = bf_params(1,:);
        
        % choose a parameter to be tested (be fixed)
        target_index_loop  = target_index;
        target_index_loop(ismember(target_index,ii))    = [];
        % change the parameter values of the target apram
        ga_param_p0(target_index(ii)) = ga_param_p0(target_index(ii)) * prt_range(jj);
 
        
        % Genetic Algorithm module
        % input arguments
        galg.parm_in = ga_param_p0; % a nominal parameter values
        galg.parm_index = target_index; % a list of target param index
        galg.estimdata = EstimData;
        galg.gen = 200; % generation
        galg.pop= 100; % population
        galg.fscore = ceil(fscore(1)*1000)/1000;
        
        
        %clc
        [fval1, ga_param_p0, exitflag(ii,jj)] = ga_module(galg);

        PL_score(ii,1) = target_index(ii);
        PL_score(ii,jj+1) = fval1;
        % data structure
        % 1d: parameters
        % 1d: perturbation range
        % 3d: models(parameters, n = 77)
    end

    % % save the PL score
    fname = strcat(fullfile(workdir,'Outcome'),'\PL_profile_',STEP{jobID}.lab,'.csv');
    tbl= array2table(PL_score);
    writetable(tbl,fname)

end

    

