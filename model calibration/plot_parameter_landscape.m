%% parameter landscape

% [choose mode of parameter estimation]
listfile = {
    'fitted_paramsets_rev2_STEP1.csv'
    'fitted_paramsets_rev2_STEP2.csv'
    'fitted_paramsets_rev2_STEP3.csv'
    };

[ jobID ] = readInput( listfile );
bestfit_params = readmatrix(listfile{jobID});

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



%% parallel plot 
% par_tbl = array2table(par_val,'VariableNames',par_name);
% [par_bb,par_ii]=sort(par_tbl.Properties.VariableNames)
% p = parallelplot(par_tbl(:,par_ii),'DataNormalization','none')
% 
% origState = warning('query', 'MATLAB:structOnObject');
% cleanup = onCleanup(@()warning(origState)); 
% warning('off','MATLAB:structOnObject')
% S = struct(p); 
% clear('cleanup')

% drawnow() % make sure labels are written first
% set(S.YRulers(3:end), 'TickLabels', '')
% % set(S.YRulers(3:end), 'Ticks', '')

S.AutoListeners__{1}.Enabled = false;



% key_idx = contains(par_name,{'Vm12r'});
%     val = par_val(:,key_idx);
% 
%     histogram(val(:),30)
%     hold on
%     box off
