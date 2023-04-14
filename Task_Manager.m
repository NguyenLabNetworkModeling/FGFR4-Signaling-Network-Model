%% Task Manager code

switch jobcode

    %% making an ODE model
    case 'making odes'

        workdir = strcat(rootwd,'\making ODEs');
        mkdir(workdir,'Outcome')
        addpath((workdir));

        % run the code
        make_mex_file

    %% Model Calibration
    case 'model calibration'

        workdir = strcat(rootwd,'\model calibration');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        % data formatting
        Data_Format_VER2

        JobList = {
            'model calibration';
            'plot parameter landscape'
            'run identifiability'
            };

        Job = JobList{readInput(JobList)};

        % Sub-tasks of the model calibration
        switch Job
            case 'model calibration'
                % run GA algorithm
                run_genetic_algorithm            

            case 'plot parameter landscape'
                plot_parameter_landscape

            case 'run identifiability'
                % 
                JobList = {
                    'run identifiability'
                    'data processing (analysis)'
                    };

                Job = JobList{readInput(JobList)};

                switch Job
                    case 'run identifiability'
                        run_Identifiability

                    case 'data processing (analysis)'
                        analyze_identifiability
                end
        end

    %% Drug Response Simulation
    case 'drug response'

        workdir = strcat(rootwd,'\drug response');
        mkdir(workdir,'Outcome')
        addpath(workdir);
        addpath(strcat(workdir,'\Outcome'));

        JobList = {
            'run drug response profiles (STEP1-3)';
            'run sensitivity analysis (STEP1,3)'
            'run dose response to FGFR4i (STEP2)'
            'run dose response matrix (STEP3)'
            'run synergy score (STEP3)'
            };
        [ jobID ] = readInput( JobList );
        Job = JobList{jobID}; % Selected

        switch Job

            case 'run drug response profiles (STEP1-3)'

                JobList = {
                    'run single drug response time profiles'
                    'run single drug response time/dose profiles'
                    'run drug response profile (single/combo)- Step1'
                    };

                Job = JobList{readInput(JobList)};

                switch Job

                    case 'run single drug response time profiles'
                        run_drug_responses_profiles

                    case 'run single drug response time/dose profiles'
                        run_single_drug_responses_profiles_time_dose

                    case 'run drug response profile (single/combo)- Step1'
                        run_drug_response_PI3Ki_AKTi_STEP1

                end




            case 'run dose response to FGFR4i (STEP2)'
                run_dose_response_to_FGFR4i_Step2


            case 'run sensitivity analysis (STEP1,3)'
                % 1. different drug effect between PI3Ki and AKTi
                % 2. pAKT rebound mechanism
                % 3. pERBB rebound mechanism

                JobList = {
                    'different combo effect between PI3Ki and AKTi with FGFR4i'
                    'pAKT/pERBB rebound mechanism'
                    };

                [ jobID ] = readInput( JobList );
                Job = JobList{jobID}; % Selected

                switch Job

                    case 'different combo effect between PI3Ki and AKTi with FGFR4i'
                        run_sensitivity_analysis_combo_effect_STEP1

                    case 'pAKT/pERBB rebound mechanism'
                        run_sensitivity_analysis_rebound_STEP3

                end

            case 'run dose response matrix (STEP3)'
                run_DR_matrix

            case 'run synergy score (STEP3)'

                JobList = {
                    'run drug response cell viability'
                    'analyse synergy score (plots)'
                    };
                [ jobID ] = readInput( JobList );
                Job = JobList{jobID}; % Selected

                switch Job

                    case 'run drug response cell viability'
                        run_DR_cell_viability_matrix

                    case 'analyse synergy score (plots)'
                        analyse_synergy_score
                end

        end

    %% Screeing a single dose-response and Estimate IC50
    case 'screening/estimating ic50'

        workdir = strcat(rootwd,'\calculate ic50');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        JobList = {
            'run screening single dose response'
            'run estimating ic50'
            };
        [ jobID ] = readInput( JobList );
        Job = JobList{jobID}; % Selected

        switch Job
            case 'run screening single dose response'
                run_screening_single_dose_response
            case 'run estimating ic50'
                run_estimate_ic50
        end
end



