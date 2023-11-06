function [BB_cut,II_cut,BB,II] = drug_effect_senstivity_difference(resp_profile)

% y(t) = [(PI3Ki(end) – ATKi(end)]ptr / [(PI3Ki(end) – ATKi(end)]cont


% percent change
for ii = 1:size(resp_profile,2)
    diff(:,ii) = (resp_profile(:,ii,1) - resp_profile(:,ii,2)) ;
end


% normalized to the control
diff_norm = diff./repmat(diff(:,end),1,size(diff,2));

% sum
diff_tss = diff_norm(end,:);


auc_log2 = log2(abs(diff_tss));
[BB,II]= sort(auc_log2,'ascend');

cut_idx = abs(BB) > quantile(abs(BB),0.25);
BB_cut = BB(cut_idx);
II_cut = II(cut_idx);