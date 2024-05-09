% Figure 5A/S21: Model prediction of synergistic drug combinations

load('CV Matrix-Weighted-STEP3-n50-Rd3.mat');

effect = dr_cv_matrix.effect;
drug_pairs = dr_cv_matrix.combo;
cv_method = dr_cv_matrix.method;
drugrange = dr_cv_matrix.drungrange;
marker_proteins= dr_cv_matrix.cv_components;

% IC50
ic50_loc_fgfr4i = find(drugrange ==4);
ic50_loc_x = find(drugrange ==32);

for ii = 1:size(effect,3) % drug combinations
    for jj = 1:size(effect,4) % params/models

        E1(ii,jj) = effect(ic50_loc_fgfr4i,1,ii,jj);
        E2(ii,jj) = effect(1,ic50_loc_x,ii,jj);
        E12(ii,jj) = effect(ic50_loc_fgfr4i,ic50_loc_x,ii,jj);

        if any([E12(ii,jj) > 1 E1(ii,jj) > 1 E2(ii,jj) > 1])

            CDI_score(ii,jj) = NaN;
            BI_score(ii,jj) = NaN;
            HSA_score(ii,jj) = NaN;

            E12(ii,jj) = NaN;
            E1(ii,jj) = NaN;
            E2(ii,jj) = NaN;

        else

            CDI_score(ii,jj) = -log2(E12(ii,jj)/(E1(ii,jj)*E2(ii,jj)));
            BI_score(ii,jj) = (1-E12(ii,jj)) - ((1-E1(ii,jj)) + (1-E2(ii,jj)) - (1-E1(ii,jj)) * (1-E2(ii,jj)));
            HSA_score(ii,jj) = (1 -E12(ii,jj)) - max([(1-E1(ii,jj)), (1-E2(ii,jj))]);
        end
    end
end

synergy_scres{1} = CDI_score;
synergy_scres{2} = HSA_score;
synergy_scres{3} = BI_score;

%% remove parameters
CDI_score(:,[29,30]) = NaN;
BI_score(:,[29,30]) = NaN;
HSA_score(:,[29,30]) = NaN;

synergy_scres{1} = CDI_score;
synergy_scres{2} = HSA_score;
synergy_scres{3} = BI_score;

%% bar graph of synergy scores

metrics_lab = {'CDI(-log2)','HSA','BI'};

% sorting the socre of the CDI score
cdi = mean(CDI_score,2,'omitnan');
[BB,II]=sort(cdi,'descend');

figure('Position',[680   490   355   488])

colorcode = [0.00,0.45,0.74;
    1.00,0.41,0.16;
    0.47,0.67,0.19];

for ii = 1:3
    subplot(3,1,ii),

    dat_mn = mean(synergy_scres{ii},2,'omitnan');
    dat_std = std(synergy_scres{ii},0,2,'omitnan')./...
        sqrt(sum(~isnan(synergy_scres{ii}),2));

    grouped_bar_with_errorbar(dat_mn(II,:)',dat_std(II,:)',colorcode(ii,:))

    % bar(dat_mn(II),'FaceColor',colorcode(ii,:))
    xticks(1:length(drug_pairs(:,1)))
    xticklabels(drug_pairs(II,2))
    xtickangle(45)
    ylabel(metrics_lab{ii})
    box off

    [sd,rnk1]=sort(dat_mn,'descend');

    Score_ranking(:,ii) = rnk1;
end

