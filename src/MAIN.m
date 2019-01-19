%% Description
% This is the MATLAB code for Mumi: multitask module identification for biological networks

% The multitask framework is based on the Multi-Factorial Optimization (MFO)
% source code released from the link below
% http://www.cil.ntu.edu.sg/mfo/SourceCode.html

clear
clc
%% Load Data
global G h_score;
global num_module_max;
global modularity_matrix;
global num_edges;

load('yeastData.mat');
G = full(G);
h_score = (a - 1) * (log(array_p_value) - log(tau));  
%h_score = 0.5 - rand(1, size(G, 1));
num_module_max = 1;
n=size(G, 1);

%% test the task to optimize Newman Modularity using Karate network model
% load('karate.mat');
% G = full(Problem.A);
% h_score = 0.5 - rand(size(G, 1), 1);
% num_module_max = 1;
% n=size(G, 1);

%% test the task to optimize Newman Modularity using dolphins network
% load('dolphins.mat');
% G = m;
% h_score = 0.5 - rand(size(G, 1), 1);
% num_module_max = 1;
% n=size(G, 1);

%% test the task to optimize Newman Modularity using football network
% load('football.mat');
% G = full(G);
% h_score = 0.5 - rand(size(G, 1), 1);
% num_module_max = 1;
% n=size(G, 1);

%% pre-calculate modularity matrix 
m = sum(G(:))/2;
D = sum(G, 2);
modularity_matrix = G - D * D' ./ (2 * m);
num_edges = sum(G(:))/2;

%% Set Tasks
Tasks(1).dims=n;
Tasks(1).fnc=@(x)ModuleScore(x);
Tasks(1).Lb=zeros(1,n);
Tasks(1).Ub=ones(1,n);

Tasks(2).dims=n;
% modularity function provides different versions of topological
% module score; CommunityExtraction and CosineSimilarity are implemented
% for testing;
% Tasks(2).fnc=@(x)modularity(x);  
Tasks(2).fnc=@(x)NewmanModularity(x);
Tasks(2).Lb=zeros(1,n);
Tasks(2).Ub=ones(1,n);

%% Calling the solvers
% For large population sizes, consider using the Parallel Computing Toolbox
% of MATLAB.
% Else, program can be slow.
runs = 1;
pop=100; % population size
gen=100; % generation count
selection_pressure = 'elitist'; % choose either 'elitist' or 'roulette wheel'
% Inable Indiviudal Learning as it's not a continuous optimization;
% Indiviudal Learning is replaced by specially designed mutation operator
p_il = 0; % probability of individual learning (BFGA quasi-Newton Algorithm) --> Indiviudal Learning is an IMPORTANT component of the MFEA.
rmp=0.1; % random mating probability

no_of_tasks=length(Tasks);
best_fitness = zeros(runs, 2);
for run = 1:runs
    data_MFEA = MFEA(Tasks,pop,gen,selection_pressure,rmp,p_il);
    for i=1:no_of_tasks
        filename = strcat(num2str(pop),'pop_',num2str(gen),'gen_',num2str(run),'run_task_',num2str(i),'.csv');
        csvwrite(filename, data_MFEA.bestInd_data(i).rnvec');
    end
    best_fitness(run, :) = data_MFEA.EvBestFitness(:, end)';
end
csvwrite(strcat(num2str(pop),'pop_',num2str(gen),'gen_running_record.csv'), best_fitness);

% "task_for_comparison_with_SOO" compares performance of corresponding task in MFO with SOO.
% For Instance, In EXAMPLE 1 ...
% "task_for_comparison_with_SOO" = 1 --> compares 40-D Rastrin in MFO with 40-D
% Rastrigin in SOO.
% "task_for_comparison_with_SOO" = 2 --> compares 30D Ackley in MFO with
% 30D Ackley in SOO.

%task_for_comparison_with_SOO = 1;
%data_SOO=SOO(Tasks(task_for_comparison_with_SOO),task_for_comparison_with_SOO,pop,gen,selection_pressure,p_il);     
