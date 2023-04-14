
% Clear the workspace
clear
% Close all open figures
close all
% Clear the command window
clc;


% Include dependencies
addpath(genpath('./packages')); 
addpath(genpath('./shared results')); 
addpath(genpath('./shared codes')); 
addpath(genpath('./shared files')); 


% Get the current working directory and assign it to the variable rootwd.
rootwd = pwd; 


% Select a simulation task from the list
listJob = {'making odes', 'model calibration', 'screening/estimate ic50', 'drug response'}; 
jobID = readInput(listJob); 
jobcode = listJob{jobID};


% Defining variables as global
% Model information
model = 'FGFR4_model_rev2a_mex';
global param_names state_names variable_names p0 X0
param_names     = eval(strcat("deblank(",model,"('Parameters'))"));
state_names     = eval(strcat("deblank(",model,"('States'))"));
variable_names  = eval(strcat("deblank(",model,"('VariableNames'))"));
p0  = eval(strcat(model,"('parametervalues')"));
X0  = eval(model);


% Task_Manager launches a script based - interface 
% where the user can define options for a task manager program.
Task_Manager

