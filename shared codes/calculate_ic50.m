function [fitobject1,gof1] = calculate_ic50(d1,r1)

D1(:,1) = d1;
R1(:,1) = r1/max(r1);


H0 = 1:2:20;
% Drug 1
for kk = 1:length(H0)
    [fitobject1,gof1] = FourParameterLogisticCurve(D1,R1,H0(kk));
    if gof1.rsquare > 0.8
        break
    end
end