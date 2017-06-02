%compute distance of each patch to each cluster center
function distMap = func_distCenter(sam,centers)
% sam is n-by-p matrix, n is the number of samples, p is the feature dimension
% center is m by p matrix, m is the number of cluster center
[numCenter,~] = size(centers);
[numSam,~] = size(sam);
distMap = zeros(numSam,numCenter);

for ic = 1:numCenter
    c = centers(ic,:);
    for is = 1:numSam
        s = sam(is,:);
        %d = norm(s,c);
        distMap(is,ic) = sqrt(sum((s-c).^2));
    end
end