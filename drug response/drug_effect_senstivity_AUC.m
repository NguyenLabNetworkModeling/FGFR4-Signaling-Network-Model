function [BB_cut,II_cut,BB,II] = drug_effect_senstivity_AUC(resp_profile)

for ii = 1:size(resp_profile,2)
    auc_diff(ii) = sum(resp_profile(:,ii,1) - resp_profile(:,ii,2)) ;
end

    
auc_pc = abs(auc_diff)./auc_diff(end);
auc_log2 = log2(abs(auc_pc));
[BB,II]= sort(auc_log2,'ascend');

cut_idx = abs(BB) > quantile(abs(BB),0.25);
BB_cut = BB(cut_idx);
II_cut = II(cut_idx);
