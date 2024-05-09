% Integrative Modelling of Signalling Network Dynamics Identifies Cell Type-selective 
% Therapeutic Strategies for FGFR4-driven Cancers
% 
% Sung-Young Shin1,2,*, Nicole J Chew1,2,*, Milad Ghomlaghi1,2, Anderly C Chüeh1,2, 
% Yunhui Jeong1,2, Lan K. Nguyen1,2,# and Roger J Daly1,2,#
%
% 1Cancer Program, Biomedicine Discovery Institute, Monash University, Melbourne, VIC 3800, Australia. 
% 2Department of Biochemistry and Molecular Biology, Monash University, Melbourne, VIC 9 3800, Australia.

clear; close all; clc;

% Include dependencies
addpath(genpath('./project_code'));
addpath(genpath('./project_data'));

RootDirerctory = pwd;

plots = {
    'Figure 2B/S14/S17/S43' % Calibration result of the Model-1/-2/-3, and reduced model
    'Figure 3A-B-D' % Model prediciton of pAKT to FGFR4 inhibitor
    'Figure 5A/S21' % Model prediction of drug combination effects'
    'Figure 6A-B-D-E' % Waterall plot againt parameter perturbation for of pAKT
    'Figure S3-4/S12-13/S18-19/S43' % Parameter identifiability analysis (Model-1/2/3/reduced model)
    'Figure S8B/S9' % Bar graph of the sensitivity score for different effect by AKT and PI3K inhibitors    
    'Figure S14' % Model simulation of various network components to FGFR4 inhibitor    
    'Figure S32/S33' % Variability and robustness analyses of the estimated model parameters across top 50 best-fitted sets
    'Figure S34' % Individual parameter sets' predictions of responses of selective model readouts to various drug treatments.
    'Figure S35/S36/S37/S38' % Model calibration results based on synthetic data with noise data
    'Figure S45' % Isobolograms analysis of drug synergism.    
    };

figure_number = plots{readInput(plots)}; % Selected



switch figure_number

    case 'Figure 2B/S14/S17/S43'
        % Model calibration results of Model-1,2,3, and reduced model

        Figure_model_calibration

    case 'Figure 3A-B-D'
        % Co-inhibition of FGFR4 and AKT, but not PI3K, significantly reduces 
        % pAKT rebound and suppresses MDA-MB-453 cell proliferation

        Figure_coinhibition_FGFR4i_AKTi_PI3Ki

    case 'Figure 5A/S21'
        % Model prediction of synergistic drug combinations

        Figure_Model_prediction_synergistic_combinations 

    case 'Figure 6A-B-D-E'
        % Model-based sensitivity analysis and identification of network architecture

        Figure_Sensitivity_Analysis_pAKT_pERBB_Rebound

    case 'Figure S3-4/S12-13/S18-19/S43'
        % Practical identifiability analysis (Model-1/-2/-3, ReducedModel)

        Figure_Practical_identifiability_analysis

    case 'Figure S8B/S9'
        % Differential impact of combined FGFR4 with AKT vs. PI3K
        % Time-course simulations of pAKT dynamics for the sensitivity analysis

        Figure_Different_effect_PI3Ki_AKTi_on_pAKT_rebound

    case 'Figure S14'
        % Model simulation of the steady-state response of various network components to increasing BLU9931 treatmen
        
        Figure_steadystate_response_FGFR4i

    case 'Figure S32/S33'
        % Variability and robustness analyses of the estimated model parameters across top 50 best-fitted sets
        
        Figure_ParameterLandscape

    case 'Figure S34'
        % Individual parameter sets' predictions of responses of selective model readouts to various drug treatments.
        Figure_prediction_variations


    case 'Figure S35/S36/S37/S38'
        % Model calibration results based on synthetic data with no noise 

        Figure_synthetic_study_validation


    case 'Figure S45'
        % Isobolograms analysis of drug synergism
        
        Figure_analyze_Isobolograms
end








