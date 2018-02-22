classdef Chromosome    
    properties
        rnvec; % (genotype)--> decode to find design variables --> (phenotype) 
        factorial_costs;
        factorial_ranks;
        scalar_fitness;
        skill_factor;
    end    
    methods        
        function object = initialize(object,x)            
            object.rnvec = x;            
        end
        
        function [object,calls] = evaluate(object,Tasks,p_il,no_of_tasks,options)     
            if object.skill_factor == 0
                calls=0;
                for i = 1:no_of_tasks
                    [object.factorial_costs(i),xxx,funcCount]=fnceval(Tasks(i),object.rnvec,p_il,options);
                    calls = calls + funcCount;
                end
            else
                object.factorial_costs(1:no_of_tasks)=inf;
                for i = 1:no_of_tasks
                    if object.skill_factor == i
                        [object.factorial_costs(object.skill_factor),object.rnvec,funcCount]=fnceval(Tasks(object.skill_factor),object.rnvec,p_il,options);
                        calls = funcCount;
                        break;
                    end
                end
            end
        end
        
        function [object,calls] = evaluate_SOO(object,Task,p_il,options)   
            [object.factorial_costs,object.rnvec,funcCount]=fnceval(Task,object.rnvec,p_il,options);
            calls = funcCount;
        end
                       
        function object=mutate(object,p,num_community)
            global G h_score;
%             rvec=normrnd(0,sigma,[1,D]);
%             object.rnvec=p.rnvec+rvec;
%             object.rnvec(object.rnvec>1)=1;
%             object.rnvec(object.rnvec<0)=0;
            
            % binary encoding mutation - random flip
%             mutation = randi(length(p.rnvec));
%             object.rnvec = p.rnvec;
%             object.rnvec(mutation) = 1 - object.rnvec(mutation); % flip          
            if p.skill_factor == 1
            % stochasticly delete negative nodes   
            object.rnvec = p.rnvec;
            elements = setdiff(unique(p.rnvec), [0]);
            x = p.rnvec > 0;                     
            ind = find(sum(G(x,:))); % find neighboring nodes
            for i = 1:length(ind)
                node = ind(i);
                if p.rnvec(node) == 0  
                    if h_score(node) >= 0
                        object.rnvec(node) = elements(randi(length(elements)));
                    elseif exp(h_score(node)) > rand()
                        object.rnvec(node) = elements(randi(length(elements)));
                    end
                end
            end
            ind = find(object.rnvec);  % all nodes in active module
            object.rnvec(ind(exp(h_score(ind)') < rand(1, length(ind)))) = 0;
            
                        
            elseif p.skill_factor == 2   
                % merge two connected communities
                x = p.rnvec;
                label = x(randi(length(x)));
                ind = x == label;
                neighbors = find(sum(G(ind, :)) > 0);
                neighbors = setdiff(neighbors, ind);
                if ~isempty(neighbors)
                    target = x(neighbors(randi(length(neighbors))));
                    x(x == target) = label;
                end
                object.rnvec = x;
                
                             
                % merge two randomly picked communities
                % pros: somehow performs better than merging connected communities
                % cons: generate disconnected communities
%                 x = p.rnvec;
%                 label = x(randi(length(x)));
%                 targets = setdiff(x, label);
%                 if ~isempty(targets)
%                     target = targets(randi(length(targets)));
%                     x(x == target) = label;
%                 end
%                 object.rnvec = x;
            else
                error('skill factor not recognized');
            end           
        end
        
        function [object]=crossover(object, p1, p2) % uniform crossover
            mask = rand(1, length(p1.rnvec)) > 0.5;
            object.rnvec = p1.rnvec;
            object.rnvec(mask > 0.5) = p2.rnvec(mask > 0.5);
        end
        
        function [object] = improve(object)
            global G;
            % Mark disconnected community with different labels for each component
            n = size(G, 1);
            x = object.rnvec;
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

            % Merge one-node community to neighbor community
            elements = unique(x);
            for i = 1:length(elements)
                ind = find(x == elements(i));
                if length(ind) == 1
                    communities = x(find(G(ind, :))); % communities of neighbor nodes
                    x(ind) = mode(communities); % most frequent community label;
                end
            end
        end
        
    end
    
    methods (Static)
        function [object1, object2]=crossover_strict_swap(object1, object2, p1, p2)
            % random variable encoding crossover
%             object.rnvec=0.5*((1+cf).*p1.rnvec + (1-cf).*p2.rnvec);
%             object.rnvec(object.rnvec>1)=1;
%             object.rnvec(object.rnvec<0)=0;

            object1.rnvec = p1.rnvec;
            object2.rnvec = p2.rnvec;
%             if p1.skill_factor == 1 && p2.skill_factor == 1
%             % static version of binary encoding uniform crossover
%             mask = rand(1, length(p1.rnvec)) > 0.5;
%             object1.rnvec(mask > 0.5) = p2.rnvec(mask > 0.5);
%             object2.rnvec(mask > 0.5) = p1.rnvec(mask > 0.5);   
%             
%             else
%             % copy one community from target to source
%             label = p1.rnvec(randi(length(p1.rnvec)));
%             object2.rnvec(p1.rnvec == label) = label;
%             label = p2.rnvec(randi(length(p2.rnvec)));
%             object1.rnvec(p2.rnvec == label) = label;
%             end
            
            % static version of binary encoding uniform crossover
            mask = randi(2, 1, length(p1.rnvec)) - 1;
            object1.rnvec(mask == 1) = p2.rnvec(mask == 1);
            object2.rnvec(mask == 1) = p1.rnvec(mask == 1);   
            
%             if p1.skill_factor == 2 || p2.skill_factor == 2
%             % copy one community from target to source
%             label = p1.rnvec(randi(length(p1.rnvec)));
%             object2.rnvec(p1.rnvec == label) = label;
%             label = p2.rnvec(randi(length(p2.rnvec)));
%             object1.rnvec(p2.rnvec == label) = label;
%             end
       end
    end
end