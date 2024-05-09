% Figure 3A-B: Model prediction of phosphorylated AKT (pAKT) dynamics in response 
% to FGFR4 inhibitor BLU9931 and PI3Kα inhibitor BYL719 
% in single or combination treatment. 
% Figure 3D: Model prediction of pAKT dynamics in response 
% to FGFR4 and AKT inhibitors in single or combination treatments. 

filename = 'coinhibition_FGFR4i_AKTi_PI3Ki.xlsx';
sheets = sheetnames(filename);

for ii = 1:length(sheets)
    sim_data{ii} = readtable(filename,'Sheet',sheets{ii});
end

% Figure 3A
figure('Position',[680   639   282   239])
errorbar(sim_data{1}.avg,sim_data{1}.std/sqrt(sim_data{1}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
hold on
errorbar(sim_data{2}.avg,sim_data{2}.std/sqrt(sim_data{2}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
box off
legend('FGFR4i (high)','FGFR4i (low)')
xlabel('time (hr)')
ylabel('pAKT(norm.)')
pbaspect([4 3 1])


% Figure 3B
figure('Position',[680   639   282   239])
errorbar(sim_data{4}.avg,sim_data{4}.std/sqrt(sim_data{4}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
hold on
errorbar(sim_data{5}.avg,sim_data{5}.std/sqrt(sim_data{5}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
box off
legend('FGFR4i (low) + PI3Ki','FGFR4i (high) + PI3Ki')
xlabel('time (hr)')
ylabel('pAKT(norm.)')
pbaspect([4 3 1])


% Figure 3D
figure('Position',[680   639   282   239])
errorbar(sim_data{1}.avg,sim_data{1}.std/sqrt(sim_data{1}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
hold on
errorbar(sim_data{2}.avg,sim_data{2}.std/sqrt(sim_data{2}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
hold on
errorbar(sim_data{6}.avg,sim_data{6}.std/sqrt(sim_data{6}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
hold on
errorbar(sim_data{3}.avg,sim_data{3}.std/sqrt(sim_data{3}.num),'Marker','s','MarkerSize',10,'MarkerEdgeColor','auto','MarkerFaceColor','auto')
box off
legend('FGFR4i (high)','FGFR4i (low)','FGFR4i (high) + AKTi','FGFR4i (low) + AKTi')
xlabel('time (hr)')
ylabel('pAKT(norm.)')
pbaspect([4 3 1])

