%****** k means cluster
function res_cluster = func_kmCluster(data,K,maxIter,rep)
    [idx,C] = kmeans(data,K,'Display','final','MaxIter',maxIter,'Replicates',rep);
    res_cluster.labels = idx;
    res_cluster.centersFea = C;
end