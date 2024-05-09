% Figure S8. Differential impact of combined FGFR4 with AKT vs.PI3K 
% targeting on pAKT rebound dynamics analysed via model simulations
% Figure S9. Time-course simulations of pAKT dynamics for the sensitivity analysis

load('Different_effect_PI3Ki_AKTi_on_pAKT_rebound.mat')


%% bar-graph

figure('Position',[664   209   389   678])
tmp_bg = barh(flip(2.^BB_cut_log2));
yticks(1:length(BB_cut_log2))
yticklabels(flip(target_parameters.mechanism(II_cut)))
%ytickangle(45)
xlabel({'Difference in pAKT';'by AKTi vs PI3Ki (norm.)'})
xline(1)
box off

% color
num_lines = length(II_cut);
cmap =colormap('jet');
stepcol = floor(size(cmap,1)/num_lines);
newcolor=cmap([1:num_lines]*stepcol,:);
tmp_bg.FaceColor = 'flat';
tmp_bg.CData = newcolor;



%% Bounded lines

% respc_reshpae
% d1: time (8)
% d2: inhibitors (1: FGFR4i+PI3Ki, 2:FGFR4i+PI3Ki)
% d3: target params (55)
% d4: models


figure('Position',[620    50   717   946])
for ii = 1:size(resp_profile,2)

YY = [];
XX = 1:size(respc_reshpae,1);
YY(:,:,1) = respc_reshpae(:,1,II(ii),:); % FGFR4i + PI3Ki (perturbation)
YY(:,:,2) = respc_reshpae(:,2,II(ii),:); % FGFR4i + PI3Ki (perturbation)
YY(:,:,3) = respc_reshpae(:,1,end,:); % FGFR4i + PI3Ki (control)
YY(:,:,4) = respc_reshpae(:,2,end,:); % FGFR4i + PI3Ki (control)

subplot(8,7,ii),
plot_distribution(XX,YY(:,:,1)','Alpha',0.15,'Color',[0.00,0.45,0.74])
hold on
plot_distribution(XX,YY(:,:,2)','Alpha',0.25,'Color',[0.85,0.33,0.10])
hold on
plot_distribution(XX,YY(:,:,3)','Alpha',0.15,'Color',[0.00,0.00,0.00],'LineWidth',1)
hold on
plot_distribution(XX,YY(:,:,4)','Alpha',0.15,'Color',[0.65,0.65,0.65],'LineWidth',1)
xtic = [1 5 8];
xticks(xtic)
xticklabels(time(xtic)/60)
xtickangle(30)
title(deblank(target_parameters.mechanism{II(ii)}))
box off

end

%% calculation of the reboundness

rebness_log2 = log2(mean(rebundness,2));
figure('Position',[757   795   251   141])
sc = scatter(rebness_log2,BB_log2,50,...
    'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor','flat');

ylabel('difference (log2)')
xlabel('reboundness(log2)')
rho = corr(rebness_log2(:),BB_log2(:));
title(strcat('corr. = ',num2str(rho)))
pbaspect([1,1,1])

