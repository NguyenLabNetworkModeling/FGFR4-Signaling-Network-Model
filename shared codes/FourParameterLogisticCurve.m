function [fitobject,gof]=FourParameterLogisticCurve(D1,R1,H0)

% 4PL model
ft='ymin + (ymax - ymin)/(1+(x/IC50)^HillSlop)';
f1=fittype(ft,'coefficients',{'ymax','ymin','IC50','HillSlop'});

% ft='ymin + (ymax - ymin)/(1 + 10^((LogIC50 - x)*HillSlop))';
% f1=fittype(ft,'coefficients',{'ymax','ymin','LogIC50','HillSlop'});

rng(1)
% Note: dose = 0 removed
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,0,1],...
               'Upper',[max(R1),max(R1),max(D1)*5,50],...
               'StartPoint',[max(R1), min(R1), max(D1)/2, H0]);
           
[fitobject,gof]=fit(D1,R1,f1,fo);

