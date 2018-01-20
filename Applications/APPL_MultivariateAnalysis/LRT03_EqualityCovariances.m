function [pval,result] = LRT03_EqualityCovariances(W,n,p,q,options)
%% LRT03_EqualityCovariances computes p-value of the log-transformed LRT 
%  statistic W = -log(Lambda), for testing the null hypothesis of equality
%  of covariance matrices (under normality assumptions) of q (q>1)
%  p-dimensional populations, and/or its null distribution CF/PDF/CDF. 
%
%  This is based on BALANCED samples of size n for each population! 
%
%  In particular, let X_k ~ N_p(mu_k,Sigma_k) are p-dimensional random
%  vectors, for k = 1,...,q. We want to test the hypothesis that the
%  covariance matrix Sigma is common for all X_k, k = 1,...,q. Then, the
%  null hypothesis is given as  
%    H0: Sigma_1 = ... = Sigma_q, 
%  i.e. the covariance matrices are equal in all q populations. Here, the
%  LRT test statistic is given by
%    Lambda = ( q^{p*q} * prod(det(S_k)) / (det(S))^q )^{n/2},
%  where S_k are MLEs of Sigma_k, for k = 1,...,q, and S = S_1 + ... + S_q,
%  based on n samples from each of the the q p-dimensional populations.  
%
%  Under null hypothesis, distribution of the test statistic Lambda is
%    Lambda ~  prod_{k=1}^q prod_{j=1}^{p} (B_{jk})^{n/2}, 
%  with B_{jk} ~ Beta((n-j)/2,(j*(q-1)+2*k-1-q)/2), and we set B_{11} = 1
%  for j=k=1. Here we assume that  n > p.
%
%  Hence, the exact characteristic function of the null distribution of
%  minus log-transformed LRT statistic Lambda, say W = -log(Lambda) is
%  given by 
%   cf = @(t) cf_LogRV_Beta(-(n/2)*t, (n-j)/2, (j*(q-1)+2*k-1-q)/(2*q)),
%  where k = [1*o,...,q*o] with p-dimensional vector of ones o = [1,...,1]
%  and j = [j_1,...,j_q] with j_k = 1:p. 
%
% SYNTAX:
%  pval = LRT03_EqualityCovariances(W,n,p,q,options)
%  [pval,result] = LRT03_EqualityCovariances(W,n,p,q,options)
%  [~,result] = LRT03_EqualityCovariances([],n,p,q,options)
%
% INPUTS:
%  W       - observed value of the minus log-transformed LRT statistic
%            W = -log(Lambda). If empty [], the  algorithm evaluates the
%            CF/PDF/CDF and the quantiles of the null distribution of W.  
%  n       - sample size, n > min(p+q-1).
%  p       - common dimension of the vectors X_k, k = 1,...q.
%  q       - number of normal populations, q > 1.
%  options - option structure, for more details see cf2DistGP. Moreover,
%            x    - set vector of values where PDF/CDF is evaluated
%            prob - set vector of probabilities for the quantiles.
%            coef - set arbitrary multiplicator of the argument t of
%            the characteristic function. If empty, default value is -n/2
%            (standard value for minus log-transform of LRT). Possible
%            alternative is e.g. coef = -1, leading to W = -(2/n)*log(LRT).
%
% EXAMPLE: (LRT for testing hypothesis on equality of covariances)
% % Null distribution of the minus log-transformed LRT statistic
% n = 30;           % total sample size
% p = 8;            % dimension of X_k, k = 1,...,q where q = 5
% q = 5;            % number of populations 
% W = [];           % observed value of W = -log(Lambda)
% % options.coef = -1;
% options.prob = [0.9 0.95 0.99];
% [pval,result] = LRT03_EqualityCovariances(W,n,p,q,options)
%
% REFERENCES:
%   [1] ANDERSON, Theodore Wilbur. An Introduction to Multivariate
%       Statistical Analysis. New York: Wiley, 3rd Ed., 2003.   
%   [2] MARQUES, Filipe J.; COELHO, Carlos A.; ARNOLD, Barry C. A general
%       near-exact distribution theory for the most common likelihood ratio
%       test statistics used in Multivariate Analysis. Test, 2011, 20.1:
%       180-203.
%   [3] WITKOVSKÝ, Viktor. Exact distribution of selected multivariate test
%       criteria by numerical inversion of their characteristic functions.
%       arXiv preprint arXiv:1801.02248, 2018.   

% (c) 2018 Viktor Witkovsky (witkovsky@gmail.com)
% Ver.: 20-Jan-2018 12:43:15

%% ALGORITHM
% [pval,result] = LRT03_EqualityCovariances(W,n,p,q,options)

%% CHECK THE INPUT PARAMETERS
narginchk(4,5);

if nargin < 5, options = []; end

if ~isfield(options, 'x')
    options.x = [];
end

if ~isfield(options, 'prob')
    options.prob = [];
end

if ~isfield(options, 'coef')
    options.coef = [];
end

if ~isfield(options, 'xMin')
    options.xMin = 0;
end

%% 
if n <= p 
error('Sample size n is too small')
end


% CHARACTERISTIC FUNCTION CF
alpha = zeros(p*q,1);
beta  = zeros(p*q,1);
ind   = 0;
for k = 1:q
    for j = 1:p
        ind = ind +1;
        alpha(ind) = (n - j) / 2;
        beta(ind)  = (j*(q-1) + 2*k - 1 - q) / (2*q);       
    end
end

% For k=j=1 the coefficient beta=0, hence the term log(Beta(alpha,beta))=0. 
alpha = alpha(2:end);
beta  = beta(2:end);

% CHARACTERISTIC FUNCTION CF
coef = options.coef;
if isempty(coef)
    coef = -n/2;  % Set this option for using with W = -log(LRT)
    % coef = -1;  % Set this options for using normalized -log(LRT^(2/n))
end
cf = @(t)cf_LogRV_Beta(t,alpha,beta,coef);

% Evaluate the p-value and PDF/CDF/QF of the log-transformed LRT statistic
if ~isempty(W)
    % P-VALUE
    options.isPlot = false;
    result = cf2DistGP(cf,W,[],options);
    pval   = 1-result.cdf;
else
    % DISTRIBUTION of Lambda PDF/CDF
    pval   = [];
    result = cf2DistGP(cf,options.x,options.prob,options);
end

% Save the parameters of the used beta distributions
result.alpha = alpha;
result.beta  = beta;

end