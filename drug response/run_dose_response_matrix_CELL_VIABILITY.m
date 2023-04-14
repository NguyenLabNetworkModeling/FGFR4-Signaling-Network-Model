%% calculation of cell viability to single(s) and combo
%% input: dose-response matrix against readouts
%% outcome: dose-response matrix on the cell viability


% make folds to save figures
mkdir(strcat(workdir,'\Outcome\DR-matrix(readouts)'))
mkdir(strcat(workdir,'\Outcome\DR-matrix(CV)'))
mkdir(strcat(workdir,'\Outcome\DR-matrix(synergy)'))



%% Step 1: load a dose-response-matrix

% [load dose-respponse matrix]
listfile = {
    'dose_response_matrix_STEP3-n100.mat'
    'dose_response_matrix_STEP3-n150.mat'    
    'dose_response_matrix_STEP3-n50.mat'  % the latest one for the figure   
    };
[ jobID ] = readInput( listfile );
load(listfile{jobID});


dr_matrix = dose_response_matrix.data;
dr_matrix_info = dose_response_matrix.data_info;
drugnames = dose_response_matrix.DrugNames;
drugrange1 = dose_response_matrix.DrugRange1;
drugtargetnames = dose_response_matrix.DrugTargetNames;
drugtargets = dose_response_matrix.DrugTargets;
drugrange2 = dose_response_matrix.DrugRange2;
modelReadouts = dose_response_matrix.Readouts;
combos = dose_response_matrix.Combinations;



%% step 2: load the maximal effect and weight table
% [load drug effects]
cv_wieight = readtable('CV_weight_table.csv');
head(cv_wieight)

% shorten the dr matrix 
matched_id = ismember(modelReadouts,cv_wieight.Readout);
cv_proteins = modelReadouts(matched_id);
dr_matrix_shortened = dr_matrix(matched_id,:,:,:,:);

% for ii = 1:length(cv_proteins)
%     idx = ismember(upper(cv_wieight.Readout),upper(cv_proteins(ii)));
%     readouts_wieght(ii,1) = cv_wieight.Estimate(idx);
% 
% end



%% step 3: calculate the cell viability (options: summation and weighted)
% workflow
% 1) select the proteins/components of the CV function, 
% 2) calculate the cell viability e.g., CV = f(pERK, pAKT, pS6K)


[sz1,sz2,sz3,sz4,sz5] = size(dr_matrix_shortened);

disp('--------------------------------------')
disp('choose readouts for the cell viability')
disp('--------------------------------------')

% select marker proteins (e.g., pERK, pAKT, pS6K)
[indx,~] = listdlg('ListString',modelReadouts);
marker_proteins = modelReadouts(indx);

listJob = {
    'Summation'
    'Weighted'
    };

[ jobID ] = readInput( listJob );
cv_method = listJob{jobID}; % Selected


listJob = {
    'heatmap [OFF]';
    'heatmap [ON]';
    };
heatmpa_opt = readInput( listJob );


switch cv_method

    case 'Summation'

        for param_jj = 1:size(dr_matrix,5) % for the models
            for ii = 1:size(combos,1) 

                rd_idx = (ismember(modelReadouts,marker_proteins));

                % the CV of the individual models
                Combo_3d(:,:,:) = dr_matrix(rd_idx,:,:,ii,param_jj); % drug-X

                % e.g., ICV = [pERBB] + [pAKT] + [pERK]
                CV_Matrix(:,:) = sum(Combo_3d,1);
                % normalization
                CV_Matrix = CV_Matrix/CV_Matrix(1);

                if heatmpa_opt == 2
                    % plot a heatmap
                    h1 = heatmap_dose_response(drugrange1,CV_Matrix,combos(ii,:));
                    h1.Title = strcat('CV Matrix (Summation)','-param ID:',num2str(param_jj));
                    colormap('turbo')
                    pause()
                end

                dr_cv_matrix.effect(:,:,ii,param_jj) = CV_Matrix;
                dr_cv_matrix.combo = drugnames(combos);
                dr_cv_matrix.method = cv_method;
                dr_cv_matrix.drungrange = drugrange1;
                dr_cv_matrix.cv_components = marker_proteins;

            end
        end



    case 'Weighted'

        for param_jj = 1:size(dr_matrix,5)

            for ii = 1:size(combos,1)

                % intersection
                rd1 = modelReadouts(ismember(modelReadouts,marker_proteins));
                rd2 = cv_wieight.Readout(ismember(cv_wieight.Readout,marker_proteins));
                comm_marker_proteins = intersect(rd1,rd2);

                % step 1: select readouts for the viability function
                rd_idx_1 = (ismember(modelReadouts,comm_marker_proteins));
                rd_idx_2 = (ismember(cv_wieight.Readout,comm_marker_proteins));       

                % check the order
                if ~all(strcmp(modelReadouts(rd_idx_1),cv_wieight.Readout(rd_idx_2)))
                    error('the order is not matched')
                end

                Combo_3d(:,:,:) = dr_matrix(rd_idx_1,:,:,ii,param_jj); % drug-X

                % the weight of the CV
                [sz1,sz2,sz3]=size(Combo_3d);
                weights = repmat(cv_wieight.Weight(rd_idx_2),1,sz2,sz3);

                % ICV = weigth*(targets)readouts
                CV_Matrix(:,:) = sum(Combo_3d.*weights,1);
                % normalization
                CV_Matrix = CV_Matrix/CV_Matrix(1);

                if heatmpa_opt == 2
                    % plot a heatmap
                    h1 = heatmap_dose_response(drugrange1,CV_Matrix,combos(ii,:));
                    h1.Title = strcat('CV Matrix (Weighted)','-param ID:',num2str(param_jj));
                    colormap('turbo')
                    pause()
                end

                dr_cv_matrix.effect(:,:,ii,param_jj) = CV_Matrix;
                dr_cv_matrix.combo = drugnames(combos);
                dr_cv_matrix.method = cv_method;
                dr_cv_matrix.drungrange = drugrange1;
                dr_cv_matrix.cv_components = marker_proteins;
            end
        end
end



save(strcat(workdir,'\Outcome\','CV Matrix-',cv_method,'-XXXX','.mat'),'dr_cv_matrix');

clear CV_Matrix Combo_3d



