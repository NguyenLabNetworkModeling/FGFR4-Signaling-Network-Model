
% Please note that "IQMtools" should be replaced with the actual name of the directory containing IQMtools.
run('C:\IQMtools V1.2.2.2\installIQMtools.m')

% Load the IQM modell and edit it
mdl = IQMmdl('FGFR4_mdl_rev2a.txtbc');
mdl = IQMeditBC(mdl);

%% Create a MATLAB ODE m-file
IQMcreateODEfile(mdl,'FGFR4_mdl_rev2a_ode')

%% Create MEX simulation function
IQMmakeMEXmdl(mdl,'FGFR4_mdl_rev2a_mex')

%% export SBMdL
IQMexportSBMdL(mdl)

%% Import SBMdL
mdl = IQMmdl('Integrated_FGFR4_mdl.xmdl',1);
IQMedit(mdl)