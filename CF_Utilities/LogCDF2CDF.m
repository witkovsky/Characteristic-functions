function [x,cdf] = LogCDF2CDF(LogX,LogCDF)
%LogCDF2CDF 
%  Transforms the CDF of the LOG-TRANSFORMED RV (random variable),
%  specified by the known values of LogX and LogCDF, into the CDF of the
%  original RV, specified by the calculated values of x and cdf.
%
% SYNTAX:
%  [x,cdf] = LogCDF2CDF(LogX,LogCDF)
%  [x,cdf] = LogCDF2CDF(result)
%
% INPUT:
%  LogX    - vector of the given x-values of the LOG-TRANSFORMED random
%            variable. Alternatively, it is assumed that it is the given
%            result (structure) from the inversion algorithm (cf2DistGP).
%  LogCDF  - vector of the given CDF values of the LOG-TRANSFORMED random
%            variable. If this parameter is missing,it is assumed that
%            the second parameter is the given result (structure) from the
%            inversion algorithm (cf2DistGP).
%
% OUTPUT:
%  x       - vector of the evaluated x-values of the back transformed
%            random variable, x = exp(LogX).
%  cdf     - vector of the CDF values of the the back transformed
%            random variable, cdf(x) = LogCDF(LogX).
%
% EXAMPLE 1
%  cf = @(t) cf_LogRV_Beta(t,2,3);
%  clear options
%  options.xMax = 0;
%  result  = cf2DistGP(cf,[],[],options);
%  LogX    = result.x;
%  LogCDF  = result.cdf;
%  [x,cdf] = LogCDF2CDF(LogX,LogCDF);
%  figure; plot(x,cdf)
%
% EXAMPLE 2
%  cf = @(t) cf_LogRV_Beta(t,2,3);
%  clear options
%  options.xMax = 0;
%  result  = cf2DistGP(cf,[],[],options);
%  [x,cdf] = LogCDF2CDF(result);
%  figure; plot(x,cdf)
%
% EXAMPLE 3:
%  % CDF of Wilks Lambda (p=5, n=10, q=3) from CDF of LOG-TRANSFORMED RV
%  p    = 5;
%  n    = 10;
%  q    = 3;
%  cf   = @(t) cf_LogRV_WilksLambda(t,p,n,q);
%  clear options
%  options.xMax = 0;
%  result = cf2DistGP(cf,[],[],options);
%  [x,cdf] = LogCDF2CDF(result);
%  figure; plot(x,cdf)

% (c) Viktor Witkovsky (witkovsky@gmail.com)
% Ver.: 17-Oct-2018 16:55:59

%% ALGORITHM
%  [x,cdf] = LogCDF2CDF(LogX,LogCDF)

%% CHECK THE INPUT PARAMETERS
narginchk(1, 2);

if nargin < 2
    if isstruct(LogX)
        result = LogX;
        LogX   = result.x;
        LogCDF = result.cdf;
    else
        error('Missing Inputs')
    end
end

x   = exp(LogX);
cdf = LogCDF;

end