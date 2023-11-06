
% [choose mode of parameter estimation]
listfile = {
    'CV Matrix-Summation-STEP3-n100.mat'
    'CV Matrix-Weighted-STEP3-n100.mat'
    'CV Matrix-Weighted-STEP3-n150.mat'
    'CV Matrix-Weighted-STEP3-n50.mat'
    'CV Matrix-Weighted-STEP3-n50-Rd3.mat'
    'CV Matrix-Summation-STEP3-n50-Rd3.mat'
    'CV Matrix-Summation-STEP3-n50-Rd6.mat'
    'CV Matrix-Weighted-XXXX.mat'
    'CV Matrix-Summation-XXXX.mat'
    };

[ jobID ] = readInput( listfile );
load(listfile{jobID});

effect = dr_cv_matrix.effect;
drug_pairs = dr_cv_matrix.combo;
cv_method = dr_cv_matrix.method;
drugrange = dr_cv_matrix.drungrange;
marker_proteins= dr_cv_matrix.cv_components;


disp('Readouts : ')
disp(marker_proteins)

disp(strcat('method = ',cv_method))

disp('-----press any key ------------')

pause()


% IC50
ic50_loc_fgfr4i = find(drugrange ==4);
ic50_loc_x = find(drugrange ==32);

for ii = 1:size(effect,3) % drug combinations

    for jj = 1:size(effect,4) % params/models

        %         syn_score(ii,jj) = effect(ic50_loc,ic50_loc,ii,jj);

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

% % sorting the socre of the CDI score
% hsa = mean(HSA_score,2,'omitnan');
% [BB,II]=sort(hsa,'descend');


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

Score_tbl = [array2table(drug_pairs(:,2),'VariableNames',{'Drug_X'}) array2table(Score_ranking,'VariableNames',{'CDI_log2','HSA','BI'})];

fpath = strcat(workdir,'\Outcome\','Synergy_Score_ranking_',cv_method(1:5),'_XXX_XXX','.xlsx');
writetable(Score_tbl,fpath,...
    'WriteVariableNames',true,...
    'WriteRowNames',false)



%% Plot data integrity (not for figure)

drug_effect{1} = 1-E1;
drug_effect{2} = 1-E2;
drug_effect{3} = 1-E12;

title_lab = {'Single:FGFR4i','Single:Drug-X','Combo:FGFR4i + X'};
figure('position',[303         621        1260         264])
tiledlayout(1,3)
for ii = 1:length(drug_effect)
    nexttile
    xvalues = 1:size(drug_effect{ii},2);
    if ii == 1
        yvalues = strcat(drug_pairs(:,1),'-',num2str([1:length(drug_pairs(:,1))]'));
    else
        yvalues = drug_pairs(:,2);
    end
    h1= heatmap(xvalues,yvalues,drug_effect{ii});
    colormap('turbo')
    h1.Title = title_lab{ii};
    % colormapeditor
end

%% Synergy Score HeatMap

figure
xvalues = 1:size(drug_effect{1},2);
yvalues = drug_pairs(:,2);

h1= heatmap(xvalues,yvalues,synergy_scres{1});
colormap('turbo')
h1.Title = 'synergy score';


%% synergy ranking (heatmap)

figure
synergy_ranking = ones(size(synergy_scres{1}))*NaN;

for ii = 1:size(synergy_scres{1},2)

    dat1 = synergy_scres{1}(:,ii);
    [bb_rank,ii_rank]=sort(dat1,'descend');

    [loc_ii,rank_ii] = sort(ii_rank(~isnan(bb_rank)));
    synergy_ranking(loc_ii,ii) = rank_ii;
end

h1= heatmap(xvalues,yvalues,synergy_ranking);
colormap('turbo')
h1.Title = 'synergy score (ranking)';



% ranking average
Rank_avg = mean(synergy_ranking','omitnan');
Rank_std = std(synergy_ranking','omitnan');

% synergy ranking (bargraph)

figure('Position',[425   679   474   160])
errorbar(1:length(Rank_avg),Rank_avg(II),Rank_std(II),'.')
hold on
bar(Rank_avg(II))
xticks(1:length(drug_pairs(:,1)))
xticklabels(drug_pairs(II,2))
xtickangle(45)
box off



%% Drug effect (optional figure)

figure('Position',[ 689   782   357   136])
%680   821   431   157

dat_mn  = [mean((1-E1),2,"omitnan") mean((1-E2),2,"omitnan") mean((1-E12),2,"omitnan")];

dat_std  = [std((1-E1),0,2,"omitnan")./sqrt(sum(~isnan(E1),2)) ...
    std((1-E2),0,2,"omitnan")./sqrt(sum(~isnan(E2),2))...
    std((1-E12),0,2,"omitnan")./sqrt(sum(~isnan(E12),2))];

% figure('position',[680   743   468   235])
grouped_bar_with_errorbar(dat_mn(II,:)',dat_std(II,:)')
xticks(1:length(drug_pairs(:,2)))
xticklabels(drug_pairs(II,2))
xtickangle(45)
ylabel('Drug effect')
legend('FGFR4i','Drug-X','Combo')
box off


%% select parameter sets

% % [bb,idx]=sort(sum(isnan(E12),1));
% % pidx = idx(1:50);
% % tmp_params = readmatrix('fitted_paramsets_rev2_STEP3.csv');
% % writematrix(tmp_params([pidx 151:size(tmp_params,1)],:),'fitted_paramsets_rev2_STEP3_trimm.csv')

