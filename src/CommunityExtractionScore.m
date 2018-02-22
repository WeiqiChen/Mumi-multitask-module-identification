%% Description
% this funtion gives the score for Community Extration Framework
% input ind: a vector of index of nodes in the given community
% output score: a scalar score of the given community

%% Reference
% Zhao Y, Levina E, Zhu J. Community extraction for social networks[J].
% Proceedings of the National Academy of Sciences, 2011, 108(18): 7321-7326.

%% Function begins
function score = CommunityExtractionScore(ind)
global G;
OS = sum(sum(G(ind, ind)));
BS = sum(sum(G(ind, :))) - OS;
numModule = length(ind);
numBackground = size(G, 1) - numModule;
score = numModule * numBackground * (OS/numModule^2 - BS/(numModule * numBackground));
% modify to encourage large module
% score = numModule * (OS/numModule^2 - BS/(numModule * numBackground));
end