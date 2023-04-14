%% Parameter landscape

% [choose mode of parameter estimation]
FileList = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    };

[ jobID ] = readInput( FileList );
bestfit_params = readmatrix(FileList{jobID});

% note: the first column is the fit score
bestfit_params(:,1) = [];
bestfit_params = bestfit_params(1:50,:);

%% a landscape of parameter values
par_val = log10(bestfit_params(:,1:102));
par_name = param_names(1:102);
null_row_name = cell(size(par_name));
null_row_name(:) = {''};
null_col_name = cell(size(bestfit_params,1),1);
null_col_name(:) = {''};

cgo = clustergram(par_val',...
    'RowLabels',null_row_name,...    
    'ColumnLabels',null_col_name,...
    'Colormap',redbluecmap);
addXLabel(cgo, 'Best-fitted models (n=50)')
addYLabel(cgo, 'Parameters (n=102)')
addTitle(cgo, 'parameter landscape')
disp('-------------press any key ----------------')
pause()

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