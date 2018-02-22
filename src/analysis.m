%% Description
% This script reads in solution generated from MAIN.m or repair.m or repair_batch.m,
% maps it to the node names, and output a file that is used for result visulization in Cytoscape

%% set parameters
data = 'yeast' ;% can be 'yeast' or 'karate' or 'dolphins'
pop = 300;
gen = 800;
run = 9;
task = 2;
num_module_max = 1;
repaired = 1; % can be 0 or 1

if repaired == 0
    x = csvread(strcat(num2str(pop),'pop_',num2str(gen),'gen_',num2str(run),'run_task_',num2str(task),'.csv'));
elseif repaired == 1
    x = csvread(strcat(num2str(pop),'pop_',num2str(gen),'gen_',num2str(run),'run_task_',num2str(task),'_repaired.csv'));
else
    error('repair not defined');
end

if strcmp(data, 'yeast')
%% handle optimized active module score solution
names = importdata('yeast/geneNamelist.txt');

if task == 1
load('yeastData.mat');
G = full(G);
tau = 1.76e-6;
h_score = (a - 1) * (log(array_p_value) - log(tau)); 
n = size(G, 1);
index = find(x>0);
bins = conncomp(graph(G(index,index))); % get connected components from solution x
scores = zeros(1, max(bins));  % max(bins) gives the number of connected compoents
for i = 1:max(bins)
    ind = find(bins == i);   % find all the nodes in the i-th componet
    scores(i) = sum(h_score(index(ind))); % active module score
end
[scores_sorted, I] = sort(scores,'descend');
num_module = min(num_module_max, max(bins));
out = zeros(n, num_module + 1);
for i = 1:num_module
    ind = find(bins == I(i));
    out(index(ind), i) = 1;    
end
out(:, num_module + 1) = sum(out(:, 1:num_module), 2);

elseif task == 2
    out =x;
end

elseif strcmp(data, 'karate')
names = [1:34]';
out = x;
elseif strcmp(data, 'dolphins')
names = importdata('dolphins/dolphins_names.txt');  
out = x;
else
    error('wrong data source')
end

T = table(names, out);
if repaired == 0
    writetable(T, strcat(data, '/', num2str(pop),'pop_',num2str(gen),'gen_task_',num2str(task),'_modules.csv'));
elseif repaired == 1
    writetable(T, strcat(data, '/', num2str(pop),'pop_',num2str(gen),'gen_task_',num2str(task),'_modules_repaired.csv'));
end


