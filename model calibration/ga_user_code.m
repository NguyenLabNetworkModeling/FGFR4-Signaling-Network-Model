function [Obj,EstimData]=ga_user_code(PX0,EstimData,target_param_index)

% PARAM <-- BEST-FITTED PARAM
tmp_paramvals=EstimData.model.bestfit;

% UPDATE TARGETED PARAM VALUES
if ~isempty(target_param_index)
    tmp_paramvals(target_param_index)= 10.^round(PX0,3);
    EstimData.model.paramvals=tmp_paramvals;
else % IF THERE IS NO TARGETED PARAM (FOR POST-PROCESSING)
    EstimData.model.paramvals=EstimData.model.bestfit;
end


%% this cost function managing part
% to initialize variables
EstimData.sim.J=[];
EstimData.sim.Jb=[];
EstimData.sim.resampled=[];

for ii=EstimData.sim.TraningData%1:length(EstimData.expt.title)

    % dose response data
    EstimData=Cost_Function(EstimData,ii);

end


%% weighting J Jw(i)= J(i)^2/sum(J)

% find the simulated data
jindex = find(~cellfun(@isempty,EstimData.sim.J));

try
    for ii = 1:length(jindex)
        kk = jindex(ii);
        % sum up J
        obj_subtotal=sum(cellfun(@sum,EstimData.sim.J{kk}));

        for jj = 1:length(EstimData.sim.J{kk})
            % % to excelerate the training
            obj_scaled{kk}{jj} = EstimData.sim.J{kk}{jj};
        end

        if cellfun(@sum,EstimData.sim.J{kk})<0
            disp(cellfun(@sum,EstimData.sim.J{kk}))
        end

        obj_total = sum(cellfun(@sum,obj_scaled{kk}));

        J_ii(kk) = obj_total*EstimData.sim.Jweight{kk};
        Jb_ii(ii) = sum(cellfun(@sum,EstimData.sim.Jb{kk}));

    end

    % to excelerate the training
    J = sum(J_ii);
    Jb = sum(Jb_ii);

catch ME

    disp(ME.message)

    J = NaN;
    Jb = NaN;
end

if (J < 0) || (Jb < 0)
    Obj = NaN;
else
    Obj = J+Jb*1000;
end

