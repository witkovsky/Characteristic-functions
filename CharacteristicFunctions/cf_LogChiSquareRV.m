function cf = cf_LogChiSquareRV(t,df,coef,n)
%%cf_LogChiSquareRV Characteristic function of a linear combination (resp.
%  convolution) of independent log-transformed random variables (RVs)
%  log(X), where X ~ ChiSquare(df) is central ChiSquare distributed RV with
%  df degrees of freedom.
%  
%  That is, cf_LogChiSquareRV evaluates the characteristic function cf(t) of
%  Y = coef_1*log(X_1) +...+ coef_N*log(X_N), where X_i ~ ChiSquare(df_i),
%  with df_i > 0 degrees of freedom. 
%
%  The characteristic function of Y = log(X), with X ~ ChiSquare(df) is
%  defined by cf_Y(t) = E(exp(1i*t*Y)) = E(exp(1i*t*log(X))) = E(X^(1i*t)). 
%  That is, the characteristic function can be derived from expression for
%  the r-th moment of X, E(X^r) by using (1i*t) instead of r. In
%  particular, the characteristic function of Y = log(X) is
%   cf_Y(t) = 2^(1i*t) * gamma(df/2 + 1i*t) / gamma(df/2).
%
%  Hence,the characteristic function of Y  = coef_1*X_1 +...+ coef_N*X_N
%  is  cf_Y(t) =  cf_1(coef_1*t) *...* cf_N(coef_N*t), where cf_i(t)
%  is the characteristic function of the ChiSquare distribution with df_i
%  degrees of freedom. 
%
% SYNTAX
%  cf = cf_LogChiSquareRV(t,df,coef,n)
%
% INPUTS:
%  t     - vector or array of real values, where the CF is evaluated.
%  df    - vector of the degrees of freedom of the the chi-squared random
%          variables.  If df is scalar, it is assumed that all degrees of
%          freedom are equal. If empty, default value is df = 1. 
%  coef  - vector of the coefficients of the linear combination of the
%          logGamma random variables. If coef is scalar, it is assumed
%          that all coefficients are equal. If empty, default value is
%          coef = 1.
%  n     - scalar convolution coeficient n, such that Z = Y + ... + Y is
%          sum of n iid random variables Y, where each Y = sum_{i=1}^N
%          coef(i) * X_i, with X_i ~ logGamma(alpha(i),beta(i)))
%          independently and identically distributed random variables. If
%          empty, default value is n = 1.    
%
% EXAMPLE 1:
% % CF of a weighted linear combination of independent log-ChiSquare RVs
%   coef   = [1 2 3 4 5];
%   weight = coef/sum(coef);
%   df     = [1 2 3 4 5];
%   t      = linspace(-20,20,1001);
%   cf     = cf_LogChiSquareRV(t,df,weight);
%   figure; plot(t,real(cf),t,imag(cf)); grid on;
%   title('CF of a linear combination of minus log-ChiSquare RVs')
%
% EXAMPLE 2:
% % PDF/CDF of a linear combination of independent log-ChiSquare RVs
%   coef   = [1 2 3 4 5];
%   weight = coef/sum(coef);
%   df     = [1 2 3 4 5];
%   cf     = @(t) cf_LogChiSquareRV(t,df,weight);
%   clear options
%   options.N = 2^12;
%   prob = [0.9 0.95 0.99];
%   result = cf2DistGP(cf,[],prob,options);
%   disp(result)
%
% WIKIPEDIA:
%  https://en.wikipedia.org/wiki/Chi-squared_distribution

% (c) 2017 Viktor Witkovsky (witkovsky@gmail.com)
% Ver.: 02-Jun-2017 12:08:24

%% ALGORITHM
% cf = cf_LogChiSquareRV(t,df,coef,n)

%% CHECK THE INPUT PARAMETERS
narginchk(1, 4);
if nargin < 4, n = []; end
if nargin < 3, coef = []; end
if nargin < 2, df = []; end

%% SET the default values 
if isempty(df) && ~isempty(coef)
    df = 1;
end

if isempty(coef) && ~isempty(df)
    coef = 1;
end

%% Check size of the parameters
[errorcode,coef,df] = distchck(2,coef(:)',df(:)');
if errorcode > 0
    error(message('InputSizeMismatch'));
end

%% Characteristic function of linear combination 
szt = size(t);
t   = t(:);
aux = 1i*t*coef;
aux = gammalog(bsxfun(@plus,aux,df/2))-ones(length(t),1)*gammalog(df/2);
aux = aux + 1i*t*log(2);
cf  = prod(exp(aux),2);
cf  = reshape(cf,szt);
cf(t==0) = 1;

if ~isempty(n)
    if isscalar(n)
        cf = cf .^ n;
    else
        error('n should be a scalar (positive integer) value');
    end
end

end
%% Function gammalog
function [f] = gammalog(z)
% GAMMALOG  Natural Log of the Gamma function valid in the entire complex
%           plane. This routine uses an excellent Lanczos series
%           approximation for the complex ln(Gamma) function.
%
%usage: [f] = gammalog(z)
%             z may be complex and of any size.
%             Also  n! = prod(1:n) = exp(gammalog(n+1))
%
%References: C. Lanczos, SIAM JNA  1, 1964. pp. 86-96
%            Y. Luke, "The Special ... approximations", 1969 pp. 29-31
%            Y. Luke, "Algorithms ... functions", 1977
%            J. Spouge,  SIAM JNA 31, 1994. pp. 931
%            W. Press,  "Numerical Recipes"
%            S. Chang, "Computation of special functions", 1996

% Paul Godfrey, pgodfrey@conexant.com, 07-13-01

siz = size(z);
z   = z(:);
zz  = z;

%f = 0.*z; % reserve space in advance

p = find(real(z)<0);
if ~isempty(p)
    z(p) = -z(p);
end

%Lanczos approximation for the complex plane

g=607/128; % best results when 4<=g<=5

c = [0.99999999999999709182;
    57.156235665862923517;
    -59.597960355475491248;
    14.136097974741747174;
    -0.49191381609762019978;
    0.33994649984811888699e-4;
    0.46523628927048575665e-4;
    -0.98374475304879564677e-4;
    0.15808870322491248884e-3;
    -0.21026444172410488319e-3;
    0.21743961811521264320e-3;
    -0.16431810653676389022e-3;
    0.84418223983852743293e-4;
    -0.26190838401581408670e-4;
    0.36899182659531622704e-5];

s = 0;
for k = size(c,1):-1:2
    s = s + c(k)./(z+(k-2));
end

zg   = z+g-0.5;
s2pi = 0.9189385332046727417803297;

f = (s2pi + log(c(1)+s)) - zg + (z-0.5).*log(zg);

f(z==1 | z==2) = 0.0;

if ~isempty(p)
    lpi  = 1.14472988584940017414342735 + 1i*pi;
    f(p) = lpi-log(zz(p))-f(p)-log(sin(pi*zz(p)));
end

p = find(round(zz)==zz & imag(zz)==0 & real(zz)<=0);
if ~isempty(p)
    f(p) = Inf;
end

f = reshape(f,siz);
end