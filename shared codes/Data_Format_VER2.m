%% Data Formatting for Model Calibration

%% to load training data set
file_name = 'Calibre_Data_FGFR4_NetworkModel.xlsx';
sheets = sheetnames(file_name);

for ii = 1:length(sheets)
    
    sheet_name = sheets{ii};
    EstimData.expt.title{ii}        = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B1:B1'));
    EstimData.expt.description{ii}  = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B2:B2'));
    EstimData.expt.source{ii}       = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B3:B3'));
    EstimData.expt.type{ii}         = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B4:B4'));
    EstimData.expt.drug{ii}{1}       = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B5:B5'));
    EstimData.expt.drug{ii}{2}       = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','B6:B6'));
    
    dat_mat = readcell(file_name,'Sheet',sheet_name,'Range','A7');
    rm_idx = find(cellfun(@ismissing,dat_mat(end,:)));
    dat_mat(:,rm_idx) = [];
    
 
    EstimData.expt.names{ii}        = dat_mat(1,2:end);
    
    dose2_value   = readcell(file_name,'Sheet',sheet_name,'Range','C6:C6');
    
    if ismissing(dose2_value{1})
        dose2_value = 0;
    else
        dose2_value = cell2mat(dose2_value);
    end
    
    
    if strcmp(EstimData.expt.type{ii},'dose')

        EstimData.expt.dose{ii}{1}     = cell2mat(dat_mat(2:end,1));
        EstimData.expt.dose{ii}{2}     = dose2_value;
        EstimData.expt.time{ii}     = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','C4:C4')); % min
        
        dat_exp = dat_mat(2:end,2:end);
        
        for jj = 1:size(dat_exp,2)
            EstimData.expt.data{ii}{jj}  = cell2mat(dat_exp(:,jj));
        end
        
        
    elseif strcmp(EstimData.expt.type{ii},'time')

        EstimData.expt.time{ii}     = cell2mat(dat_mat(2:end,1));
        EstimData.expt.dose{ii}{1}     = cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','C4:C4')); % min
        EstimData.expt.dose{ii}{2}     = dose2_value;
        
        dat_exp = dat_mat(2:end,2:end);
        
        for jj = 1:size(dat_exp,2)
            EstimData.expt.data{ii}{jj}  = cell2mat(dat_exp(:,jj));
        end
        
        
    elseif strcmp(EstimData.expt.type{ii},'multi')

        EstimData.expt.time{ii}     = cell2mat(dat_mat(2:end,1));
        EstimData.expt.dose{ii}{1}     = [cell2mat(readcell(file_name,'Sheet',sheet_name,'Range','C4:C4'));dose2_value]; % min
        EstimData.expt.dose{ii}{2}     = 0;
        dat_exp = dat_mat(2:end,2:end);
        
        for jj = 1:size(dat_exp,2)/2
            EstimData.expt.data{ii}{jj}  = [cell2mat(dat_exp(:,jj)) cell2mat(dat_exp(:,jj+size(dat_exp,2)/2))];
        end
    end
    
end


%% model parameters
EstimData.model.paramnames          = eval(strcat("deblank(",model,"('Parameters'))"));
EstimData.model.paramvals           = []; % 
EstimData.model.initialparamvals    = eval(strcat(model,"('parametervalues')"));
EstimData.model.bestfit             = eval(strcat(model,"('parametervalues')"));
EstimData.model.statenames          = eval(strcat("deblank(",model,"('States'))"));
EstimData.model.initials            = eval(model); % y0 <= ode model
EstimData.model.varnames            = eval(strcat("deblank(",model,"('VariableNames'))"));
EstimData.model.maxnumsteps         = 700; 
EstimData.model.TraningMode         = 1;
EstimData.model.UseParallel         = 1;
EstimData.model.Display             = 'iter';
EstimData.model.Name               = model;

%% simulation data
EstimData.sim.statevalues           = [];
EstimData.sim.varvalues             = [];
EstimData.sim.resampled             = [];
EstimData.sim.simulation            = [];
EstimData.sim.J                     = [];
EstimData.sim.Jb                    = [];
EstimData.sim.ci_mask_size          = 0.25;


EstimData.sim.Jth = cell(1,length(sheets));
EstimData.sim.Jth(:) = {0};
EstimData.sim.Jweight = {1 1 1 2 1 2 1 5 1 1 1 1 1 1 1};
