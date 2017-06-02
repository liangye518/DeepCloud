%****** dpCluster function ******
function res_cluster = func_dpCluster(data,K)

ab = data;
disp('starting unique...');
[ab, ~, ic] = unique(ab, 'rows');

% compute distance matrix
disp('Computing distance map...');
N = size(ab, 1); % ab is a n x p matrix

dist_mat = sqdist(ab', ab');
s = reshape(dist_mat, N * N, 1);
NB = length(s);

percent=2.0;
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);

position=round(NB*percent/100);
sda=sort(s);
dc=sda(position);

% dp clustering
%exemplar = dpcluster(dist_mat, dc, K);
[exemplar,idxC] = dpcluster2(dist_mat, dc, K);

clear dist_mat;
clear dc;
clear ab;
clear s;
clear sda;

% reassign label
[class, ~, id] = unique(exemplar);
cluster_num = length(class);
label = 1:cluster_num;
cluster_idx = label(id);
res_cluster.labels = cluster_idx(ic);
idxCenter = ones(1,length(idxC)) * -1;
for i = 1:length(idxC)
    idxCenter(i) = min(find(ic == idxC(i)));
end
res_cluster.centersIdx = idxCenter;
res_cluster.centersFea = data(idxCenter,:);

end