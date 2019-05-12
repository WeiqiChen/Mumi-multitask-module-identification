function data_MFEA = MFEA(Tasks,pop,gen,selection_process,rmp,p_il)
    %%
    global G h_score;
    
    %% Set Parameters
    clc    
    tic       
    if mod(pop,2) ~= 0
        pop = pop + 1;
    end   
    no_of_tasks=length(Tasks);
    if no_of_tasks <= 1
        error('At least 2 tasks required for MFEA');
    end
    D=zeros(1,no_of_tasks);
    for i=1:no_of_tasks
        D(i)=Tasks(i).dims;
    end
    D_multitask=max(D);
    num_community = D_multitask;
%     num_community = 3;
    options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton','MaxIter',5); 
    
    fnceval_calls = 0;
    calls_per_individual=zeros(1,pop);
    EvBestFitness = zeros(no_of_tasks,gen);
    TotalEvaluations=zeros(1,gen);
    bestobj=inf*(ones(1,no_of_tasks));
        
    
    
    %% binary encoding initialization for one connected module
%     [sortedValues,indexValue] = sort(h_score,'descend');  % Sort the values in descending order
%     [sortedDeg,indexDeg] = sort(sum(G, 2),'descend'); 
%     sortIndex = [indexValue(1:round(pop/2)); indexDeg(1:pop-round(pop/2))];
%     pre_pop = zeros(pop,D_multitask);
%     k = length(h_score);
%     for i = 1:pop
%         firstID = mod(i, k);
%         if (firstID  == 0)
%             firstID = D_multitask;
%         end
%         firstID = sortIndex(firstID);
%         pre_pop(i,firstID) = 1;
%         neighborID = find(G(firstID,:)); 
%         ind = neighborID(h_score(neighborID) > 0);   % add all neighbor id with positive h score
%         %pre_pop(i, ind) = 1;
%         pre_pop(i, neighborID) = 1;
%     end

    %% binary encoding uniformly random initialization allowing disconnected components
%     pre_pop = rand(pop, D_multitask) > 0.5;
%     pre_pop = randi(num_community, pop, D_multitask) - 1; 
    %% random variable encoding
   % pre_pop = rand(pop,D_multitask);
    %% %% Population Initialization

    for i = 1 : pop
        population(i) = Chromosome();
%         population(i) = initialize(population(i),pre_pop(i,:));
        population(i) = initialize(population(i),randperm(num_community) - 1);
        population(i).skill_factor=0;
    end
    for i = 1 : pop
    %parfor i = 1 : pop
        [population(i),calls_per_individual(i)] = evaluate(population(i),Tasks,p_il,no_of_tasks,options);
    end
    
    fnceval_calls=fnceval_calls + sum(calls_per_individual);
    TotalEvaluations(1)=fnceval_calls;
    
    factorial_cost=zeros(1,pop);
    for i = 1:no_of_tasks
        for j = 1:pop
            factorial_cost(j)=population(j).factorial_costs(i);
        end
        [xxx,y]=sort(factorial_cost);
        population=population(y);
        for j=1:pop
            population(j).factorial_ranks(i)=j; 
        end
        bestobj(i)=population(1).factorial_costs(i);
        EvBestFitness(i,1)=bestobj(i);
        bestInd_data(i)=population(1);
    end
    for i=1:pop
        [xxx,yyy]=min(population(i).factorial_ranks);
        x=find(population(i).factorial_ranks == xxx);
        equivalent_skills=length(x);
        if equivalent_skills>1
            population(i).skill_factor=x(1+round((equivalent_skills-1)*rand(1)));
            tmp=population(i).factorial_costs(population(i).skill_factor);
            population(i).factorial_costs(1:no_of_tasks)=inf;
            population(i).factorial_costs(population(i).skill_factor)=tmp;
        else
            population(i).skill_factor=yyy;
            tmp=population(i).factorial_costs(population(i).skill_factor);
            population(i).factorial_costs(1:no_of_tasks)=inf;
            population(i).factorial_costs(population(i).skill_factor)=tmp;
        end
    end
        
    %% Cross over and Mutation
    mu = 10; % Index of Simulated Binary Crossover (tunable)
    sigma = 0.02; % standard deviation of Gaussian Mutation model (tunable)
    generation=1;
    while generation <= gen 
        generation = generation + 1;
        indorder = randperm(pop);
        count=1;
        for i = 1 : pop/2     
            p1 = indorder(i);
            p2 = indorder(i+(pop/2));
            child(count)=Chromosome();
            child(count+1)=Chromosome();
            if (population(p1).skill_factor == population(p2).skill_factor) || (rand(1)<rmp)            
%                 u = rand(1,D_multitask);
%                 cf = zeros(1,D_multitask);
%                 cf(u<=0.5)=(2*u(u<=0.5)).^(1/(mu+1));
%                 cf(u>0.5)=(2*(1-u(u>0.5))).^(-1/(mu+1)); 

%                 child(count) = crossover(child(count),population(p1),population(p2));
%                 child(count+1) = crossover(child(count+1),population(p2),population(p1));
                
                [child(count), child(count+1)] = Chromosome.crossover_strict_swap(child(count), ...
                    child(count+1), population(p1),population(p2));

%                 if rand(1) < 0  % tunable
%                     child(count)=mutate(child(count),child(count),D,sigma/2);
%                     child(count+1)=mutate(child(count+1),child(count+1),D,sigma/2);
%                 end        
                sf1=1+round(rand(1));
                sf2=1+round(rand(1));
                if sf1 == 1
                    child(count).skill_factor=population(p1).skill_factor;
                else
                    child(count).skill_factor=population(p2).skill_factor;
                end
                if sf2 == 1
                    child(count+1).skill_factor=population(p1).skill_factor;
                else
                    child(count+1).skill_factor=population(p2).skill_factor;
                end
            else              
                child(count)=mutate(child(count),population(p1),num_community);
                child(count).skill_factor=population(p1).skill_factor;
                child(count+1)=mutate(child(count+1),population(p2),num_community);
                child(count+1).skill_factor=population(p2).skill_factor;
            end
            % repair solution for task 2 every 10 generations
%             if mod(generation, 10) == 0
%                 if child(count).skill_factor == 2
%                     child(count)=improve(child(count));
%                 end
%                 if child(count+1).skill_factor == 2
%                     child(count+1)=improve(child(count+1));
%                 end
%             end
            
            count=count+2;
        end  
        for i = 1 : pop
        % parfor i = 1 : pop            
            [child(i),calls_per_individual(i)] = evaluate(child(i),Tasks,p_il,no_of_tasks,options);           
        end             
        fnceval_calls=fnceval_calls + sum(calls_per_individual);
        TotalEvaluations(generation)=fnceval_calls;
        
        intpopulation(1:pop)=population;
        intpopulation(pop+1:2*pop)=child;
        factorial_cost=zeros(1,2*pop);
        for i = 1:no_of_tasks
            for j = 1:2*pop
                factorial_cost(j)=intpopulation(j).factorial_costs(i);
            end
            [xxx,y]=sort(factorial_cost);
            intpopulation=intpopulation(y);
            for j=1:2*pop
                intpopulation(j).factorial_ranks(i)=j;
            end
            if intpopulation(1).factorial_costs(i)<=bestobj(i)
                bestobj(i)=intpopulation(1).factorial_costs(i);
                bestInd_data(i)=intpopulation(1);
            end
            EvBestFitness(i,generation)=bestobj(i);            
        end
        for i=1:2*pop
            [xxx,yyy]=min(intpopulation(i).factorial_ranks);
            intpopulation(i).skill_factor=yyy;
            intpopulation(i).scalar_fitness=1/xxx;
        end   
        
        if strcmp(selection_process,'elitist')
            [xxx,y]=sort(-[intpopulation.scalar_fitness]);
            intpopulation=intpopulation(y);
            population=intpopulation(1:pop);            
        elseif strcmp(selection_process,'roulette wheel')
            for i=1:no_of_tasks
                skill_group(i).individuals=intpopulation([intpopulation.skill_factor]==i);
            end
            count=0;
            while count<pop
                count=count+1;
                skill=mod(count,no_of_tasks)+1;
                population(count)=skill_group(skill).individuals(RouletteWheelSelection([skill_group(skill).individuals.scalar_fitness]));
            end     
        end
        disp(['MFEA Generation = ', num2str(generation), ' best factorial costs = ', num2str(bestobj)]);
        
        if (generation > 100) && (EvBestFitness(2, generation) == EvBestFitness(2, generation - 30))
            break
        end
    
    end 
    data_MFEA.wall_clock_time=toc;
    data_MFEA.EvBestFitness=EvBestFitness;
    data_MFEA.bestInd_data=bestInd_data;
    data_MFEA.TotalEvaluations=TotalEvaluations;
    save('data_MFEA','data_MFEA');
    
    %% write file
%     for i=1:no_of_tasks
%         filename = strcat(num2str(pop),'pop_',num2str(gen),'gen_task_',num2str(i),'.csv');
%         csvwrite(filename, bestInd_data(i).rnvec');
%     end
    
    %% draw figure
    for i=1:no_of_tasks
        figure(i)        
  %      subplot(1, no_of_tasks, i);
        hold on
        plot(-EvBestFitness(i,:));
        xlabel('GENERATIONS')
        ylabel(['TASK ', num2str(i), ' OBJECTIVE'])
 %       legend('MFEA')
    end
    
    
end
