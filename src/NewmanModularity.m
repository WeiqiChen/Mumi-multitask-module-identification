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

n = length(x);
delta = zeros(size(G));
group = cell(1, max(x)+1);
for i = 1:n
    group{x(i)+1} = [group{x(i)+1}, i];
end
group = group(~cellfun('isempty',group));
for i = 1:length(group)
    delta(group{i}, group{i}) = 1;
end

Q = sum(sum(modularity_matrix .* delta)) / (2 * m);
Q = - Q;  % minimization
end
