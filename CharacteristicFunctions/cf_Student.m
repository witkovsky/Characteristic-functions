function cf = cf_Student(t,df,coef,n)
%%cf_Student Characteristic function of the distribution of a linear
%  combination of independent random variables with Student's
%  t-distribution with df > 0 degrees of freedom.
%
%  In particular, cf_Student(t,df,coef) evaluates the characteristic
%  function cf(t) of of Y = coef_1 * X_1 + ... + coef_N * X_N, where X_i ~
%  t(df_i), for i = 1,...,N. 
%
%  The characteristic function of X ~ t(df) is 
%   cf(t) = besselk(df/2,abs(t)*sqrt(df),1) * exp(-abs(t)*sqrt(df)) * ...
%          (sqrt(df)*abs(t))^(df/2) / 2^(df/2-1)/gamma(df/2).
%
%  Hence, the characteristic function of Y  = coef_1*X_1 +...+ coef_N*X_N
%  is cf_Y(t) =  cf_1(coef_1*t) *...* cf_N(coef_N*t), where cf_i(t) 
%  is the characteristic function of X_i ~ t(df_i). 
%
% SYNTAX:
%  cf = cf_Student(t,df,coef,n)
% 
% INPUTS:
%  t     - vector or array of real values, where the CF is evaluated.
%  df    - vector of the degrees of freedom of the the chi-squared random
%          variables.  If df is scalar, it is assumed that all degrees of
%          freedom are equal. If empty, default value is df = 1.
%  coef  - vector of the coefficients of the linear combination of the
%          log-transformed random variables. If coef is scalar, it is
%          assumed that all coefficients are equal. If empty, default value
%          is coef = 1.
%  n     - scalar convolution coeficient n, such that Z = Y + ... + Y is
%          sum of n iid random variables Y, where each Y = sum_{i=1}^N
%          coef_i * X_i is independently and identically distributed random
%          variable. If empty, default value is n = 1. 
%
% EXAMPLE 1:
%  % CF of a linear combination of independent Student's t RVs
%  coef = 1./(1:50);
%  df   = 50:-1:1;
%  t    = linspace(-1,1,201);
%  cf   = cf_Student(t,df,coef);
%  figure; plot(t,real(cf),t,imag(cf))
%  title('Characteristic function of the linear combination of t RVs')
%
% EXAMPLE 2:
%  % CDF/PDF of a linear combination of independent Student's t RVs
%  coef = 1./(1:50);
%  df   = 50:-1:1;
%  cf   = @(t) cf_Student(t,df,coef);
%  x    = linspace(-50,50);
%  prob = [0.9 0.95 0.975 0.99];
%  clear options;
%  options.N = 2^12;%   
%  result = cf2DistGP(cf,x,prob,options);
%  disp(result)
%
% REFERENCES:
%   WITKOVSKY, V.: On the exact computation of the density and of the
%   quantiles of linear combinations of t and F random variables. Journal
%   of Statistical Planning and Inference 94 (2001), 1�13.

% (c) 2017 Viktor Witkovsky (witkovsky@gmail.com)
% Ver.: 02-Jun-2017 12:08:24

%% ALGORITHM
% cf = cf_Student(t,df,coef,n)

%% CHECK THE INPUT PARAMETERS
narginchk(1, 4);
if nargin < 4, n = []; end
if nargin < 3, coef = []; end
if nargin < 2, df = []; end

%%
if isempty(df) && ~isempty(coef)
    df = 1;
end

if isempty(coef) && ~isempty(df)
    coef = 1;
end

%% Equal size of the parameters
[errorcode,coef,df] = distchck(2,coef(:)',df(:)');
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

%% Characteristic function of linear combination of noncentral chi-squares
df2   = df/2;
t     = t(:);
o     = ones(length(t),1);
idx0  = 1;

for j = 1:idc(end)
    idx1 = min(idc(j)*szcLimit,szcoefs);
    idx  = idx0:idx1;
    idx0 = idx1+1;
    aux = bsxfun(@times,abs(t),abs(df(idx).*coef(idx)));
    aux = - aux + bsxfun(@times,df2(idx),log(aux)) + ...
        log(besselk(o*df2(idx),aux,1));
    aux = bsxfun(@plus,aux,(-log(2)*(df2(idx)-1))-gammaln(df2(idx)));
    cf  = exp(sum(aux,2));
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