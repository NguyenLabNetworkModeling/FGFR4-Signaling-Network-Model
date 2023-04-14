function h1 = heatmap_dose_response(drugrange1,synergy_matrix,drug_pairs,code_cvoption)


if nargin == 3
    code_cvoption = '';
end



% heatmap for the dose-response matrix (ICx)
h1 = heatmap(string(log2(drugrange1)),string(log2(drugrange1)),synergy_matrix);
h1.Title = code_cvoption;
h1.XLabel = strcat(drug_pairs{2},' (IC50,log2)');
h1.YLabel = strcat(drug_pairs{1},' (IC50,log2)');


% figname = strcat('dose-resp-matrix-',code_cvoption,'-(',comb_name{ii},')-param-',num2str(param_id),'.jpg');
% saveas(h1,strcat(workdir,'\Outcome\DR-matrix(CV)\',figname))



% h2 = heatmap(string(log2(drugrange1)),string(log2(drugrange1)),cdi);
% h2.Title = code_cvoption;
% h2.XLabel = strcat(drug_pairs{ii,2},' (IC50,log2)');
% h2.YLabel = strcat(drug_pairs{ii,1},' (IC50,log2)');

% figname = strcat('Synergy-Score-',code_cvoption,'-(',comb_name{ii},')-param-',num2str(param_id),'.jpg');
% saveas(h2,strcat(workdir,'\Outcome\DR-matrix(synergy)\',figname))