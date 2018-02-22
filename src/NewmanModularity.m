%% Description
% This funtion evaluates the Modularity Q for a given community devision
% Input x: an INTEGER vector of length n (size of network); x(i) == c_j
% means the i-th node belongs to the j-th community
% Output Q: a scalar value of Newman Modularity

%% Reference
% Newman M E J. Analysis of weighted networks[J]. Physical review E, 2004, 70(5): 056131.

%% Function begins

function Q = NewmanModularity(x)
global G;
delta = zeros(size(G));
communities = unique(x);
for i = 1:length(communities)
    ind = find(x == communities(i));
    delta(ind, ind) = 1;
end
m = sum(G(:))/2;
D = sum(G, 2);
modularity_matrix = G - D * D' ./ (2 * m);
Q = sum(sum(modularity_matrix .* delta)) / (2 * m);
Q = - Q;  % minimization
end