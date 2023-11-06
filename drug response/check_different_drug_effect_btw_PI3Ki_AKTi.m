FGFR4i_AKTi = readmatrix('drug_response_combo_FGFR4i-AKTi.xlsx');
FGFR4i_PI3Ki = readmatrix('drug_response_combo_FGFR4i-PI3Ki.xlsx');
FGFR4i_single = readmatrix('drug_response_combo_FGFR4i- single.xlsx');

%% ttest
[h,p] = ttest2(FGFR4i_AKTi(end,:),FGFR4i_PI3Ki(end,:));
[h,p] = ttest2(FGFR4i_single(end,:),FGFR4i_PI3Ki(end,:));


prism = [[mean(FGFR4i_single,2) std(FGFR4i_single,[],2) size(FGFR4i_single,2)*ones(size(FGFR4i_single,1),1)] ...
[mean(FGFR4i_PI3Ki,2) std(FGFR4i_PI3Ki,[],2) size(FGFR4i_PI3Ki,2)*ones(size(FGFR4i_PI3Ki,1),1)] ...
[mean(FGFR4i_AKTi,2) std(FGFR4i_AKTi,[],2) size(FGFR4i_AKTi,2)*ones(size(FGFR4i_AKTi,1),1)]]


dff_resp = FGFR4i_PI3Ki(end,:) - FGFR4i_AKTi(end,:);

dff_idx = find(dff_resp > 1);
% parameters [8    13    23    38    47] causing big difference between
% PI3Ki and AKTi

figure
for ii = 1:length(dff_idx)
    dat = [FGFR4i_PI3Ki(:,dff_idx(ii)) FGFR4i_AKTi(:,dff_idx(ii))];

    subplot(1,length(dff_idx),ii), plot(dat/max(dat(:)))
end
