function cl = dpcluster(dist, dc, K)

ND = size(dist, 1);
fprintf('Computing rho with cut-off kernel of radius: %12.6f\n', dc);

% "Cut off" kernel
rho = sum(dist < dc, 1) - 1;
maxd = max(dist(:));

% compute delta measure
[rho_sorted, idx_rho] = sort(rho,'descend');
delta(idx_rho(1)) = -1;
nneigh(idx_rho(1)) = 0;

for i = 2:ND
  idxHighRho = idx_rho(1:i-1);
  distI = dist(:, idx_rho(i));
  distHighRho = distI(idxHighRho);
  if nnz(distHighRho < maxd)
    [delta(idx_rho(i)), id] = min(distHighRho);
    nneigh(idx_rho(i)) = idxHighRho(id);
  end
end
delta(idx_rho(1))=max(delta(:));

% compute gamma measure
gamma = rho .* delta;
[gamma, ig] = sort(gamma,'descend');

idx_cl = ig(1:K);
NCLUST = length(idx_cl);

cl = -1 * ones(ND, 1);
for i = 1:NCLUST
  cl(idx_cl(i)) = i;
end

% plot decision graph
subplot(1, 2, 1)
plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')

subplot(1, 2, 2)
plot(gamma, 'k.');
title ('\gamma in Decreasing Order','FontSize',15.0)
xlabel ('n')
ylabel ('\gamma')
axis([-100 4500 0 gamma(1) + gamma(1) * 0.25])
hold on
icm = colormap;
for i = 1:K
  ic = int8(i * 64 / NCLUST);
  plot(i,gamma(i), 'o', 'MarkerSize', 8, 'MarkerFaceColor', icm(ic, :), 'MarkerEdgeColor', icm(ic,:));
end
hold off
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

%assignation
for i=1:ND
  if (cl(idx_rho(i))==-1)
    cl(idx_rho(i))=cl(nneigh(idx_rho(i)));
  end
end