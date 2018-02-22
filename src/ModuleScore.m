%% Description
% This funtion takes a set of selected nodes, calculate the active module
% score for each connected components,selects the top k (num_module) 
% values, and returns an average score.
% Input x: a INTEGER vector of length n (size of network); x(i) == c_j
% means the i-th node belongs to the j-th community, x(i) != 0 means the
% i-th node is selected as member of active module.
% Output score: a scalar value

%% Function begins
function score = ModuleScore(x)
global G h_score;
global num_module_max;

x = x > 0;
index = find(x==1);
bins = conncomp(graph(G(index,index))); % get connected components from solution x
scores = zeros(1, max(bins));  % max(bins) gives the number of connected compoents
for i = 1:max(bins)
    ind = find(bins == i);   % find all the nodes in the i-th componet
    scores(i) = sum(h_score(index(ind)));
end
scores = sort(scores,'descend');
num_module = min(num_module_max, max(bins));
score = - sum(scores(1:num_module)) / num_module;
end