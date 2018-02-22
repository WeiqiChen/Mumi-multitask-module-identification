
data = 'yeast' ;% can be 'yeast' or 'karate' or 'dolphins'
pop = 300;
gen = 800;
runs = 10;

Q = zeros(runs, 2);
for run = 1:runs
    [Q1, Q2] = repair(data, pop, gen, run);
    Q(run, 1) = Q1;
    Q(run, 2) = Q2;
end
csvwrite(strcat(data, num2str(pop),'pop_',num2str(gen),'gen_repair_record.csv'), Q);