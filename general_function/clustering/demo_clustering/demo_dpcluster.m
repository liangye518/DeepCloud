% demo_dpcluster

clear; close all; clc

rand('state', 2)

K = 3; % number of clusters

im3u = imread('scene.jpg');
im3u = imresize(im3u, 0.5);
[height, width, chn] = size(im3u);
im3f = im2double(im3u);

% rgb2lab
cform = makecform('srgb2lab');
lab = applycform(im3f, cform);
lab = reshape(lab, height * width, 3);
ab = round(single(lab(:, 2:3)));

[ab, ~, ic] = unique(ab, 'rows');

% compute distance matrix
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
exemplar = dpcluster(dist_mat, dc, K);

% reassign label
[class, ~, id] = unique(exemplar);

cluster_num = length(class);
label = 1:cluster_num;
cluster_idx = label(id);
idx_map = cluster_idx(ic);
idx_map = reshape(idx_map, height, width);

colormap = floor(rand(4, 3) .* 255);
RGB = uint8(ind2rgb(idx_map, colormap));
imwrite(RGB, 'im_dpcluster.bmp')
figure; imshow(RGB)