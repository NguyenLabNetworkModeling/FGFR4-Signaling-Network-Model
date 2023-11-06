%% validation of dose-response matrix

load 'dose_response_matrix_STEP3.mat'

dr_matrix = dose_response_matrix.data;
dr_matrix_info = dose_response_matrix.data_info;
drugnames = dose_response_matrix.DrugNames;
drugrange1 = dose_response_matrix.DrugRange1;
drugtargetnames = dose_response_matrix.DrugTargetNames;
drugtargets = dose_response_matrix.DrugTargets;
drugrange2 = dose_response_matrix.DrugRange2;
combos = dose_response_matrix.Combinations;
readouts = dose_response_matrix.Readouts;


[sz1,sz2,sz3,sz4,sz5] = size(dr_matrix);
drug_pairs = drugnames(combos);

%% Display a single dose-response (FGFR4i, drug X)


% specify time points
[indx,tf] = listdlg('ListString',readouts);


param_id =1;


for ii = 1:size(drug_pairs,1)
    for jj = 1:length(indx)

        dat_mat(:,:) = dr_matrix(indx(jj),:,:,ii,param_id);
        dat_mat = dat_mat/dat_mat(1);

        h1 = heatmap_dose_response(drugrange1,dat_mat,drug_pairs(ii,:));
        h1.Title =   readouts{indx(jj)};
        pause()

        % figname = strcat('dose-resp-matrix','-',cv_proteins{jj},'-(',comb_name{ii},')-param-',num2str(param_id),'.jpg');
        % saveas(h1,strcat(workdir,'\Outcome\DR-matrix(readouts)\',figname))

    end

end


