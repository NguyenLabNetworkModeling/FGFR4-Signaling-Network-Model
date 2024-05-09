%% parameter landscape

param_names = FGFR4_model_rev2a_mex('parameters');
readouts = {'Figure S32/S33A/D/G','Figure S32/S33B/E/H','Figure S32/S33C/F/I'};
figure_number = readouts{readInput( readouts )};

switch figure_number

    case 'Figure S32/S33A/D/G'

        bestfit_params = readmatrix('BestFittedParamSets_Rev2_Step1.csv');


    case 'Figure S32/S33B/E/H'

        bestfit_params = readmatrix('BestFittedParamSets_Rev2_Step2.csv');

    case 'Figure S32/S33C/F/I'
        bestfit_params = readmatrix('BestFittedParamSets_Rev2_Step3.csv');
end

% note: the first column is the fit score
bestfit_params(:,1) = [];
bestfit_params = bestfit_params(1:50,:);

%% a landscape of parameter values

par_val = log10(bestfit_params(:,[1:102 104:106]));
par_name = param_names([1:102 104:106]);
null_row_name = cell(size(par_name));
null_row_name(:) = {''};
null_col_name = cell(size(bestfit_params,1),1);
null_col_name(:) = {''};

cgo = clustergram(par_val',...
    'RowLabels',null_row_name,...
    'ColumnLabels',null_col_name,...
    'Colormap',redbluecmap);
addXLabel(cgo, 'Best-fitted models (n=50)')
addYLabel(cgo, 'Parameters (n=105)')
addTitle(cgo, 'parameter landscape')



fig = figure('Position',[682   568   330   270]);
plt = plot(cgo,fig);
pbaspect([1 1 1])



%% histogram of parameter types
figure('Position',[724   512   311   277])
key_prefix = {'kc','Vm','ki','Km'};


for ii = 1:length(key_prefix)
    key_idx = contains(par_name,key_prefix{ii});
    val = par_val(:,key_idx);

    histogram(val(:),30)
    hold on
    box off
end
hold off

legend(key_prefix)
ylabel('counts')
xlabel('parameter value (log10)')


%% calculate CV values

par_val_act = 10.^par_val;
cv_vals = std(par_val_act)./mean(par_val_act);

[BB, II] = sort(cv_vals);

% display the top 5 robust parameters
par_name(II(1:5))


figure('Position',[720   583   279   193])
bar(BB)
xlabel('Parameter (n=105)')
ylabel('Coefficient of variance')
pbaspect([4 3 1])
box off



figure('Position',[720   583   279   193])
plot(1:length(par_val),par_val(:,II),'Color','blue')
xlabel('Parameter (n=105)')
ylabel('Parameter value (log10)')
pbaspect([4 3 1])
box off
axis tight

figure('Position',[720   583   279   193])
histogram(par_val,20)
ylabel('Number of parameter')
xlabel('Parameter value (log10)')
pbaspect([4 3 1])
box off
