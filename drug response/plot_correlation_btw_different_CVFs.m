SS{1} = readtable('Synergy_Score_ranking_Summa_STEP3_n50_Rd6.xlsx');
SS{2} = readtable('Synergy_Score_ranking_Weigh_STEP3_n50_Rd3.xlsx');
SS{3} = readtable('Synergy_Score_ranking_Summa_STEP3_n50_Rd3.xlsx');
option_lab = {'Option 1','Option 2','Option 3'};

% drug combinations
Comb = nchoosek(1:3,2);

for ii = 1:size(Comb,1)
    comb = Comb(ii,:);
    figure('Position',[757   726   361   210])


    dat1 = SS{comb(1)}.CDI_log2;
    dat2 = SS{comb(2)}.CDI_log2;

dat_tbl = array2table([dat1 dat2],'VariableNames',{'Opt1','Opt2'});

mdl = fitlm(dat_tbl,'Opt1 ~ Opt2');
plot(mdl,...
    'MarkerFaceColor',[0 0.447058823529412 0.741176470588235],...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerSize',10,...
    'Marker','o',...
    'LineStyle','none',...
    'Color',[0 0 1]);
legend off
box off

xlabel(option_lab{comb(1)})
ylabel(option_lab{comb(2)})
title(strcat('Corr. = ',num2str(corr(dat1,dat2))))
pbaspect([1,1,1])

end



