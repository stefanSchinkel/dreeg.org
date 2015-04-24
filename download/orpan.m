function nws = orpan(x,varargin)

% orpan - construct order patterns networks
%
% function nws = orpan(x,[dim,tau])
%
% Construct a network from the observed time
% series at the individual nodes. A link is
% defined as the simultaneous occurence of
% a symbol (order pattern) at two nodes.
% For the construction for order patterns
% a dimension and a delay can be provided.
%
% Input:
%	x = set of time series (nodes X time)
%
% Parameters
%	dim = dimension (def: 2)
%	tau = dimension (def: 1)
%
% Output:
%	mws = set of networks (nodes X nodes x time)
%
% requires: 
%
% see also: ERRP
%
% References: 
% Schinkel S, Zamora-López G, Dimigen O, Sommer W and Kurths J (2012). 
% Order Patterns Networks (orpan) – a method to estimate time-evolving functional 
% connectivity from multivariate time series. Front. Comput. Neurosci. 6:91. 
% doi: 10.3389/fncom.2012.00091


% Copyright (C) 2012- Stefan Schinkel, HU Berlin
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

varargin{3} = [];
if ~isempty(varargin{1}), dim =  varargin{1}; else dim = 2; end
if ~isempty(varargin{2}), tau =  varargin{2}; else tau = 1; end
	
nChan = size(x,1);
nEpoch = size(x,2);

% pre-allocate space for patterns
ops = zeros(nChan,nEpoch-(dim-1)*tau);

for iChan = 1:nChan
	ops(iChan,:) = opCalc(x(iChan,:),dim,tau);
end

% pre allocate output
nw = uint8( zeros( nChan,nChan, nEpoch - (dim-1)*tau ));


for iEpoch = 1:size(ops,2)

	% this roughly is makeRP	
	X = ops(:,iEpoch);
	Y = X';
	nw(:,:,iEpoch) =  uint8(X(:,ones(1,nChan)) == Y(ones(1,nChan),:))';		

end % epoch loop

function varargout=opCalc(X,dim,tau)

%opCalc Encode time series as a symbols based on ranks.
%
% function [patterns] = opCalc(X,dim,tau)
%
% Encode time series as series of symbols based on ranks 
% on elements. the function uses different encoding schemes,
% depending on the number of elements forming the pattern.  
% 
% Note: Limitation for dimension is 10 (due to endoding routine,
% hexadecimal or other base will allow higher)
%
% Input:
% 	X = time series (vector)
% 	dim = dimension (number of points)
% 	tau = time delay (distance between points)
%
% Output:
% 	patterns = encoded time series
%

%% check input
if nargin<3
	error('Usage:[patterns] = opCalc(X,dim,tau)');
end

if dim < 2;
	error('Too few time instances. Need at least tau=2'),
elseif dim > 10;
	error('Dimension too large. Max dim supported: 10.');
end
if  tau < 1;
	error('Delay must be positive integer >= 1'),
end

if length(X) < (dim-1)*tau;
	error('Time series too short. Need a least (dim-1)*tau');
end

pattern = zeros(numel(X)-(dim-1)*tau,1);

for i=1:numel(X)-(dim-1)*tau
	[a b]=sort(X(i:tau:i+tau*dim-1));
	calcPow = 0;
	for j =numel(b):-1:1
		pattern(i) = pattern(i) + b(j)*10^calcPow;
		if b(j) > 9;calcPow = calcPow +2;else calcPow = calcPow + 1;end
	end	
end
	


%% assign output
varargout{1}=pattern;

	
