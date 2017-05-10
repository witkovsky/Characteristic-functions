function cf = cf4InverseGamma(t,alpha,beta,coef,n)
%%cf4InverseGamma Characteristic function of a linear combination (or
%  convolution) of independent Inverse-Gamma random variables, X_i~IGamma. 
%
%  In particular, cf4InverseGamma(t,alpha,beta,coef,n) evaluates the
%  characteristic function cf(t) of Y = coef(1) * X_1 + ... + coef(N) *
%  X_N, where X_i ~ IGamma(alpha(i),beta(i)), and alpha(i) and  beta(i)
%  represent the 'shape' and the 'rate' parameters of the Inverse-Gamma
%  distribution. 
%
%  The characteristic function of Y is defined by
%   cf(t) = Prod( 2 / gamma(alpha(i)) * (-1i*beta(i)*t).^(alpha(i)/2) ...
%                 * besselk(alpha(i),sqrt(-4i*beta(i)*t)) )
%
% SYNTAX:
%  cf = cf4InverseGamma(t,alpha,beta,coef,n)
%
% INPUTS:
%  t     - vector or array of real values, where the CF is evaluated.
%  alpha - vector of the 'shape' parameters alpha > 0. If empty, default
%          value is alpha = 1.  
%  beta  - vector of the 'rate' parameters beta > 0. If empty, default
%          value is beta = 1.  
%  coef  - vector of the coefficients of the linear combination of the
%          IGamma random variables. If coef is scalar, it is assumed
%          that all coefficients are equal. If empty, default value is
%          coef = 1.
%  n     - scalar convolution coeficient n, such that Z = Y + ... + Y is
%          sum of n iid random variables Y, where each Y = sum_{i=1}^N
%          coef(i) * GAMMA(k(i),theta(i))) is independently and identically
%          distributed random variable. If empty, default value is n = 1.   
%
% PARAMETRIZATION:
%   As for the GAMMA distribution, also for the Inverse-Gamma distribution
%   there are three different possible parametrizations: 
%   i)   With a shape parameter k and a scale parameter theta.
%   ii)  With a shape parameter alpha = k and an inverse scale parameter
%        beta = 1/theta, called a rate parameter. 
%   iii) With a shape parameter k and a mean parameter mu = k/beta.
%   In each of these three forms, both parameters are positive real numbers.
%
%   Here, cf4InverseGamma implements the shape-rate parametrization with
%   parameters alpha and beta, respectively. 
%
%   If X ~ IGamma(df/2,1/2)(shape-rate parametrization), then X is identical
%   to ICHI2(df), the Inverse-Chi-squared distribution with df degrees of
%   freedom.
%
% WIKIPEDIA: 
%   https://en.wikipedia.org/wiki/Inverse-gamma_distribution.
%
% EXAMPLE 1:
% % CF of a linear combination of K=100 independent IGamma RVs
%   K    = 50;
%   t    = linspace(-100,100,201);
%   idx  = 1:K;
%   coef = 1./((idx - 0.5)*pi).^2;
%   figure; plot(idx,coef,'.-')
%   title('Coefficients of the linear combination of IGamma RVs')
%   alpha= 5/2;
%   beta = 2;
%   cf   = cf4InverseGamma(t,alpha,beta,coef);
%   figure; plot(t,real(cf),t,imag(cf))
%   title('Characteristic function of the linear combination of IGamma RVs')
%
% EXAMPLE 2:
% % PDF/CDF from the CF by cf2DistGP
%   alpha= 5/2;
%   beta = 1/2;
%   coef = 1./(((1:50) - 0.5)*pi).^2;
%   cf   = @(t) cf4InverseGamma(t,alpha,beta,coef);
%   clear options
%   options.N    = 2^10;
%   options.xMin = 0;
%   result = cf2DistGP(cf,[],[],options);
%
% REFERENCES
%  WITKOVSKY, V. (2001). Computing the distribution of a linear combination
%  of inverted gamma variables. Kybernetika 37, 79�90.

% (c) 2017 Viktor Witkovsky (witkovsky@gmail.com)
% Ver.: 10-May-2017 18:11:50

%% ALGORITHM
% cf = cf4InverseGamma(t,alpha,beta,coef,n)

%% CHECK THE INPUT PARAMETERS
narginchk(1, 5);
if nargin < 5, n = []; end
if nargin < 4, coef = []; end
if nargin < 3, beta = []; end
if nargin < 2, alpha = []; end

%%
if isempty(beta) && ~isempty(alpha)
    beta = 2;
elseif isempty(beta) && ~isempty(coef)
    beta = 2;
elseif ~any(beta)
    beta = 2;
end

if isempty(alpha) && ~isempty(coef)
    alpha = 2;
elseif isempty(alpha) && ~isempty(beta)
    alpha = 2;
end

if isempty(coef) && ~isempty(beta)
    coef = 1;
elseif isempty(coef) && ~isempty(alpha)
    coef = 1;
end

%% Equal size of the parameters   
[errorcode,coef,alpha,beta] = distchck(3,coef(:)',alpha(:)',beta(:)');
if errorcode > 0
    error(message('InputSizeMismatch'));
end

% Special treatment for linear combinations with large number of RVs
szcoefs  = size(coef);
szcoefs  = szcoefs(1)*szcoefs(2);
szt      = size(t);
sz       = szt(1)*szt(2);
szcLimit = ceil(1e3 / (sz/2^16));
idc = 1:fix(szcoefs/szcLimit)+1;

%% Characteristic function
t        = t(:);
idx0     = 1;
cf       = 1;
for j = 1:idc(end)
    idx1 = min(idc(j)*szcLimit,szcoefs);
    idx  = idx0:idx1;
    idx0 = idx1+1;
    aux  = (bsxfun(@times,-1i*t,coef(idx)./beta(idx))).^(1/2);
    aux  = 2*bsxfun(@power,aux,alpha(idx)) .* ...
           besselk(ones(length(t),1)*alpha(idx),2*aux);
    aux  = bsxfun(@times,aux,1./gamma(alpha(idx)));
    cf   = cf .* prod(aux,2);
end
cf = reshape(cf,szt);
cf(t==0) = 1;

if ~isempty(n)
    if isscalar(n)
        cf = cf .^ n;
    else
        error('n should be a scalar (positive integer) value');
    end
end

end