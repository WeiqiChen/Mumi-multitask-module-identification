% this funtion gives the sum of cosine similarity between pairs of nodes in a given module
function similarity = CosineSimilarity(x)
global G;
len = length(x);
similarity = 0;
if len == 1   
    return
end
for i = 1:len-1
    for j = i+1 : len-1
        v1 = G(x(i),:);
        v2 = G(x(j),:);
        neighbor = find(sum(v1+v2) == 2);  % find the common network neighbors
        similarity = similarity + length(neighbor)/sqrt(sum(v1)*sum(v2));
    end
end
end