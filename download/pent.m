function [varargout]= pent(varargin)

%PENT-compute permutation entrop 
%
% function [pEnt pEntNorm] = pent(X,order[,lag, ws,ss])
%
% Compute the permutation entropy of a
% time series. Windowing is supported 
%
%
% Input: 
%	X = vector 
%	order = order of entropy
% 	lag = time delay (def: 1)
%	ws = window size (def: length(X))
%	ss = step size (def: 1);
%
% Output:
%	pEnt = permutation entropy
%	pEntNorm = normalized permutation entropy
%
%
% requires: 
%
% see also: 
%
% References: 
%	
%	Bandt, C., & Pompe, B. (2002). Permutation entropy: A natural complexity measure for 
%	time series. Physical Review Letters, 88(17), 174102.
%
%	D. O’Hora, S. Schinkel, M. J. Hogan, L. Kilmartin, M. Keane, 
%	R. Lai and N. Upton (2013) Age-Related Task Sensitivity of Frontal EEG Entropy 
%	During Encoding Predicts Retrieval, Brain Topography, doi: 10.1007/s10548-013-0278-x

% Copyright (C) 2012 Stefan Schinkel, HU Berlin 
% http://people.physik.hu-berlin.de/~schinkel 
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


debug=false;
if debug;warning('on','all');else warning('off','all');end

% I/O check
if (nargchk(2,5,nargin)), help(mfilename),error(nargchk(2,4,nargin)); end
if (nargchk(0,2,nargout)), help(mfilename),error(nargchk(0,2,nargout)); end

%% assignstuff
varargin{6} = [];

X = varargin{1};
order = varargin{2};
if ~isempty(varargin{3});delay = varargin{3};else delay = 1;end
% adjust window size to size of pattern sequence, if none given
if ~isempty(varargin{4});ws = varargin{4};else ws = numel(X) - (order-1) *delay;end
if ~isempty(varargin{5});ss = varargin{5};else ss = 1;end


% regular vector routine
% ensure row vector 
X = X(:);

ops = opCalc(X,order,delay);

% loop through data
for i = 1:ss:size(ops,1) - (ws-1)

	%slice out patters
	pies = ops(i:i+ws-1);
	
	% all patterns in there
	uniquePies = unique(pies);

	% relative frequencies of occuring pies
	for j = 1:length(uniquePies);
		pieFreq(j) = sum(pies == uniquePies(j))  / length(pies);
	end

	pEnt(i)  = -sum(pieFreq .* log(pieFreq));
	pEntNorm(i) = pEnt(i) / (order - 1);
end

varargout{1} = pEnt;
varargout{2} = pEntNorm;

function varargout=opCalc(X,dim,tau)

%OPCALC -- Encode time series as a order patterns
%
% function [patterns] = opCalc(X,dim,tau)
%
% Input:
% 	X = time series (vector)
% 	dim = dimension (number of points)
% 	tau = time delay (distance between points)
%
% Output:
% 	patterns = encoded time series
%
% requires: 
%
% see also: 

%% check input
if nargin<3
	error('PENT:opCalc:InputError','Usage:[patterns] = opCalc(X,dim,tau)');
end

if dim < 2;
	error('PENT:opCalc:DimensionError','Too few time instances. Need at least tau=2'),
end

if  tau < 1;
	error('PENT:opCalc:DelayError','Delay must be positive integer >= 1'),
end

if length(X) < (dim-1)*tau;
	error('PENT:opCalc:IndexError','Time series too short. Need a least (dim-1)*tau');
end

% allocate mem for output
pattern = zeros(numel(X)-(dim-1)*tau,1);

% switch between fixed and flexible
% base encoding. 
if dim < 10
	for i = 1:numel(X)-(dim-1)*tau
		
		% sort the data
		[a b] = sort(X(i:tau:i+tau*dim-1));
		
		% we start with 10^0 
		calcPow = 0;

		% loop over order in reverse
		for j = numel(b):-1:1
			pattern(i) = pattern(i) + b(j)*10^calcPow;
			calcPow = calcPow + 1;
		end	% j  
	end % i 

else
	
	%pre-compute mask
	mask = cumprod( [1 dim(ones(1,dim-1))] )';

	for i=1:numel(X)-(dim-1)*tau
		% sort data
		[a b] = sort(X(i:tau:i+tau*dim-1));

		% multiply with mask and sum
		pattern(i) = sum( b .*mask);

	end % i
end %if dim 

%% assign output
varargout{1}=pattern;
