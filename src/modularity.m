%% Description
% This function takes a set of selected nodes, calculate the modularity
% score using defined objective funtion for each connected components,
% selects the top k (num_module) values, and returns an average score.
% Input x: a BINARY vector of length n (size of network); x(i) == 1 means
% the i-th node is select as a member node of module
% Output score: a scalar value of defined modularity

%% Function begins

function score = modularity(x)
global G;
global num_module_max;

index = find(x);
bins = conncomp(graph(G(index,index))); % get connected components from solution x
scores = zeros(1, max(bins));  % max(bins) gives the number of connected compoents
for i = 1:max(bins)
    ind = find(bins == i);   % find all the nodes in the i-th componet
    scores(i) = CommunityExtractionScore(index(ind));
%     scores(i) = CosineSimilarity(index(ind));
end
scores = sort(scores,'descend');
num_module = min(num_module_max, max(bins));
score = - sum(scores(1:num_module)) / num_module;
end