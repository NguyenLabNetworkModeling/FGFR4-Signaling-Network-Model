FGFR_AKT= load('drug_response_FGFR4i-AKTi_100.mat','-mat');
FGFR_PI3K = load('drug_response_FGFR4i-PI3Ki_100.mat','-mat');
FGFR = load('drug_response_FGFR4i-single_100.mat','-mat');


time = [0 60 120 240 360 720 1080 1440]/60;


for ii = 1:50

    p1 = FGFR.drug_response(:,ii);
    p2 = FGFR_PI3K.drug_response(:,ii);
    p3 = FGFR_AKT.drug_response(:,ii);

    subplot(5,10,ii), plot([p1 p2 p3],'LineWidth',2)
    xticks(1:length(time))
    xticklabels(time)
    xtickangle(45)
    title(strcat('param ID: ',num2str(ii)))
    box off

    if ii == 50
        legend('FGFR4i','FGFR4i+PI3Ki','FGFR4i+AKTi')
    end
end


Mean(:,1) = mean(FGFR.drug_response,2); % FGFR4 single
Mean(:,2) = mean(FGFR_PI3K.drug_response,2); % FGFR4i + PI3Ki
Mean(:,3) = mean(FGFR_AKT.drug_response,2);% FGFR4i + AKTi

Std(:,1) = std(FGFR.drug_response,0,2); % FGFR4 single
Std(:,2) = std(FGFR_PI3K.drug_response,0,2); % FGFR4i + PI3Ki
Std(:,3) = std(FGFR_AKT.drug_response,0,2);% FGFR4i +



figure
errorbar(Mean,Std/sqrt(size(FGFR.drug_response,2)))
xticks(1:length(time))
xticklabels(time)
xtickangle(45)
xlabel('time (hr)')
ylabel('pAKT (norm.)')
pbaspect([4 3 1])
legend('FGFR4i','FGFR4i+PI3Ki','FGFR4i+AKTi')
box off





