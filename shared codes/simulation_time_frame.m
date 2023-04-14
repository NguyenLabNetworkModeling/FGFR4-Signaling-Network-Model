function t_frame = simulation_time_frame(star_tspan,stim_tspan,drug_tspan)


tp_starv = star_tspan;
tp_stim = tp_starv(end) + stim_tspan  ;
tp_drug=  tp_stim(end) + drug_tspan ;

t_frame.tspan = sort(unique([tp_starv tp_stim tp_drug]));


% time point index
t_frame.ti_starv = ismember(t_frame.tspan,tp_starv);
t_frame.ti_stim = ismember(t_frame.tspan,tp_stim);
t_frame.ti_drug = ismember(t_frame.tspan,tp_drug);



% stim and drug time sampling points (actual simmulation time)
t_frame.ts_starv = t_frame.tspan(t_frame.ti_starv);
t_frame.ts_stim = t_frame.tspan(t_frame.ti_stim);
t_frame.tspan_stim = t_frame.ts_stim - tp_stim(1);
t_frame.ts_drug = t_frame.tspan(t_frame.ti_drug);
t_frame.tspan_drug = t_frame.ts_drug - tp_drug(1);
