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
global modularity_matrix;
global num_edges;

delta = zeros(size(G));
edges =  -0.5:1:(max(x)+0.5);
bins = discretize(x,edges);
bin_count = unique(bins);
for i = 1:length(bin_count)
    ind = find(bins == bin_count(i));
    delta(ind, ind) = 1;
end

temp = modularity_matrix .* sparse(delta);
Q = sum(temp(:)) / (2 * num_edges);
Q = -full(Q);

end
