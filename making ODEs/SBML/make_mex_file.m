%% This is a first cell that clears workspace and memory
% Press Ctrl+enter to evaluate it
clear; clc;

% modify the directory that contain IQMtools 
run('C:\IQMtools V1.2.2.2\installIQMtools.m')

%% Load the CellCycle.txt model
model = IQMmodel('FGFR4_model.txtbc')
model=IQMeditBC(model);

%% export SBML
IQMexportSBML(model)

%% Import SBML
model = IQMmodel('Integrated_FGFR4_model.xml',1);
IQMedit(model)



%% Create a MATLAB ODE m-file from the IQMmodel
IQMcreateODEfile(model,'FGFR4_model_r1_ode')


%% Create MEX simulation function
IQMmakeMEXmodel(model,'FGFR4_model_r1_mex')

%% Simulate the ODE file (no conversion overhead due to creation of ODE file)

tic;
[t,x] = ode15s(@FGFR4_model_ode,0:2880,FGFR4_model_mex);
TIMEODE15S = toc
subplot(1,2,1),semilogy(t,x)
% it generate an error messange, i don't know reason why. you can just skip
% this part




%% Simulate the ODE file (no conversion overhead due to compilation of MEX files)
tic;
output = FGFR4_model_mex(linspace(0,2880,100));
TIMEMEX = toc
subplot(1,2,2),semilogy(output.time,output.statevalues)

%% speed test


TIMEODE15S/TIMEMEX


%% extract initials, state variables, parabmers, 
output=FGFR4_model_mex(0:10000);
x0s=output.statevalues(end,:);
states=FGFR4_model_mex('states');
modelparams=FGFR4_model_mex('parameters');
modelparamvals=FGFR4_model_mex('parametervalues');

%% output table
param_table=table(modelparams,modelparamvals);
state_table=table(states,round(x0s',4));

%% Demo simulation (input test)

modelparamvals0=FGFR4_model_mex('parametervalues');
modelparams=FGFR4_model_mex('parameters');
modelparamvals=modelparamvals0;

modelparamvals(ismember(modelparams,{'IGF_on'}))=100;
modelparamvals(ismember(modelparams,{'FGF_on'}))=200;
modelparamvals(ismember(modelparams,{'HRG_on'}))=300;
modelparamvals(ismember(modelparams,{'IGF0'}))=100;
modelparamvals(ismember(modelparams,{'FGF0'}))=200;
modelparamvals(ismember(modelparams,{'HRG0'}))=300;


modelparamvals(ismember(modelparams,{'inh_on'}))=600;
modelparamvals(ismember(modelparams,{'FGFR4i_0'}))=250;
modelparamvals(ismember(modelparams,{'PI3Ki_0'}))=150;
% initial guess
x0s=FGFR4_model_mex;

% simulate
output=FGFR4_model_mex(0:1000,x0s,modelparamvals);

plot(output.variablevalues)
legend(output.variables)












