%% Description
% This script reads in solution for modularity maximization generated from
% MAIN.m, repair the disconnected communities and isolated nodes in
% solution, and outputs a file with repaired solution that can be further
% processed by analysis.m

function [Q1, Q2] = repair(data, pop, gen, run)
%% set parameters
% data = 'karate' ;% can be 'yeast' or 'karate' or 'dolphins'
% pop = 100;
% gen = 200;
% run = 1;

%% load data
x = csvread(strcat(num2str(pop),'pop_',num2str(gen),'gen_',num2str(run),'run_task_2.csv'));
if strcmp(data, 'yeast')
    load('yeastData.mat');
    G = full(G);
elseif strcmp(data, 'karate')
    load('karate.mat');
    G = full(Problem.A);
elseif strcmp(data, 'dolphins')
    load('dolphins.mat');
    G = m;
else
    error('Data source not defined');
end

Q1 = NewmanModularity(x);
disp(['Modularity before repair: ', num2str(Q1)]);

%% Mark disconnected community with different labels for each component
n = size(G, 1);
elements = unique(x);
increament = 1;
for i = 1:length(elements)
    label = elements(i);
    ind = find(x == label);
    if length(ind) == 1
        continue
    end
    bins = conncomp(graph(G(ind,ind)));
    if max(bins) > 1
        for j = 2:max(bins)
            x(ind(bins == j)) = n + increament;
            increament = increament + 1;
        end
    end
end

%% Merge one-node or two-nodes community to neighbor community
elements = unique(x);
for i = 1:length(elements)
    ind = find(x == elements(i));
    if length(ind) == 1                % find one-node community 
        communities = x(find(G(ind, :))); % communities of neighbor nodes
        x(ind) = mode(communities); % most frequent community label;
    elseif length(ind) == 2            % find two-nodes community
         communities = [x(find(G(ind(1), :))); x(find(G(ind(2), :)))];
         labels = setdiff(communities, x(ind));
         if ~isempty(labels)
             x(ind) = labels(1);
         end
    end
end

%% Test Modularity after repair
Q2 = NewmanModularity(x);
disp(['Modularity after repair: ', num2str(Q2)]);

%% write file
filename = strcat(num2str(pop),'pop_',num2str(gen),'gen_',num2str(run),'run_task_2_repaired.csv');
csvwrite(filename, x);


    

