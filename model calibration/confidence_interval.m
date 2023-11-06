
bf_params = readmatrix('fitted_paramsets_step3.csv');
fitscore = bf_params(:,1);
% note: the first column is the fit score

randsample_fitscore = randsample(fitscore,20)



mu = mean(randsample_fitscore)
sigma =std(randsample_fitscore)
alpha = 0.005
n = length(randsample_fitscore)
cd = icdf('Normal',1-alpha,0,1)
CI_upper = mu + cd*sigma/(sqrt(n))
CI_lower = mu - cd*sigma/(sqrt(n))