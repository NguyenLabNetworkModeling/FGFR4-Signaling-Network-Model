% Figure S45. Isobolograms analysis of drug synergism

load('isobolograms_analysis.mat')

combo_opt = {
    'FGFR4i + ERBBi'
    'FGFR4i + AKTi'
    'FGFR4i + ERKi'
    };

combo_no = readInput( combo_opt );

drug_combo = drug_interest(Comb);
model_no = 23;
dat(:,:) = resp_mat(:,:,combo_no,model_no);
dat_norm = 1 - dat/dat(1,1);

figure('Position',[699   530   358   239])
contourHandle = contour(icx_range2,icx_range1,dat_norm,'LineWidth',2) ;
clabel(contourHandle);
ylabel(strcat(drug_combo{combo_no,1},'(a.u.)'))
xlabel(strcat(drug_combo{combo_no,2},'(a.u.)'))
box off
pbaspect([4 3 1])
colorbar