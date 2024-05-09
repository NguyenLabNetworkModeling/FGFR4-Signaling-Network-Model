% Figure S34. Individual parameter sets' predictions of responses of 
% selective model readouts to various drug treatments.

load('prediction_variation.mat')

% select a treatment option
comb_opt = {
    'Figure S34B/C/D'
    'Figure S34A'
    };
[ jobID ] = readInput( comb_opt );
combopt = comb_opt{jobID};



for ii = 1:50 % for the top 50 best-fitted parameters

    paramvals = bestfit_paramsets(ii,:);

    switch combopt

        case 'Figure S34A'
            % simulation setting for the drug treatment
            drug_names = {'FGFR4i_0';'PI3Ki_0'};
            drug_dose = [10, 500]; % nM {10nMBLU + 500nMBYL; 100nMBLU}

        case 'Figure S34B/C/D'
            drug_names = {'FGFR4i_0';'PI3Ki_0'};
            drug_dose = [100, 0]; % nM {10nMBLU + 500nMBYL; 100nMBLU}

    end
    % drug treatment (drug 1 and 2)
    paramvals(strcmp(paramnames,'inh_on')) = Time_qstim_section(end);
    if ~all(strcmp(paramnames(ismember(paramnames,drug_names)),drug_names))
        error('=> param names are not matched to given drug names')
    end
    paramvals(ismember(paramnames,drug_names)) = drug_dose;


    % run ODE solver (MEX)
    % MEX output
    MEX_output=eval(strcat(model,"(tspan,x0s,paramvals',options)"));
    statevalues=MEX_output.statevalues;

    % readout variable and state variables
    state_vals_strv     = statevalues(Tindex_starv,:);
    state_vals_qstim    = statevalues(Tindex_qstim,:);
    state_vals_drug     = statevalues(Tindex_drug,:);

    % resampled readouts
    state_vals(:,:,ii)=state_vals_drug(:,readout_idx);

end



%% add noise to the simulation data

% save the simulation results


switch combopt
    case 'Figure S34A'
        sel_rdd = 1;
    case 'Figure S34B/C/D'
        sel_rdd = [2 3 4];
end

data = [];
for ii = sel_rdd

    figure('Position',[680   661   277   217])
    data(:,:) = state_vals(:,ii,:);
    data = data_normalization(data,2);

    plot(data)
    xlabel('time (hr)')
    ylabel(strcat(readout{ii},'(norm)'))
    box off
    set(gca,'xticklabels',cellstr(string(drug_response_time/60)));
    pbaspect([4 3 1])
    axis tight

    % save the averaged value
    tbl= array2table(data);
    drug_response_time_str = cellstr(string(drug_response_time));
    tbl.Properties.RowNames = drug_response_time_str;

end



%% heatmap


file_name = 'Model2_predictions_combo.xlsx';
sheets = sheetnames(file_name);

for ii = sel_rdd
    disp(sheets{ii})

    data = readtable(file_name,'Sheet',sheets{ii},'ReadRowNames',true);

    dat1 = table2array(data);
    time = cellfun(@str2num,data.Properties.RowNames);
    % hierachical clustering
    hmg = clustergram(dat1','Cluster','column',...
        'Standardize','row',...
        'ColumnLabels',time/60,'ColumnLabelsRotate',45); 
    title = addTitle(hmg,strcat('Predictions of responses(',sheets{ii},')'));
    addXLabel(hmg,'time (hr)','FontSize',12);
    addYLabel(hmg,'models (n=50)','FontSize',12);


 
end


