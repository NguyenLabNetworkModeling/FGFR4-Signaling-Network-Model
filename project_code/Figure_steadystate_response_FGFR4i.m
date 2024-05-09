%% Dose-responses of the 50 individual param sets to FGFR4i
%% readouts: pIGFR, pERBB, pIRS, pAKT, pERK
%% Figure S14

load('steadystate_response_FGFR4i.mat')


%% generate plots

dat_avg = nanmean(readout_norm,3);
dat_std = nanstd(readout_norm,0,3);

figure('position',[313         597        1182         211])

for ii = 1:5
    
    tmp_dat1(:,:) = readout_norm(ii,:,:);

    subplot(1,5,ii),plot(tmp_dat1,'Color',[0.65,0.65,0.65])
    hold on

    subplot(1,5,ii),errorbar(dat_avg(ii,:),dat_std(ii,:)/sqrt(50),...
        'LineWidth',2,...
        'Color',[0.00,0.45,0.74],...
        'Marker','o','MarkerSize',6)
    ylabel(strcat(readouts{ii},'(norm.)'))
    xticks(1:length(DrugRange));
    xticklabels(DrugRange)
    xlabel('BLU (a.u.)')
    axis([-inf inf 0 max(dat_avg(ii,:))*1.3])
    pbaspect([4 3 1])
    box off


end


