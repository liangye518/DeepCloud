% demo_apcluster
clear; close all; clc

rand('state', 0)

im3u = imread('luffy.jpg');
im3u = imresize(im3u, 0.5);
[height, width, chn] = size(im3u);
im3f = im2double(im3u);

% rgb2lab
cform = makecform('srgb2lab');
lab = applycform(im3f, cform);
lab = reshape(lab, height * width, 3);
ab = round(single(lab(:, 2:3)));

[ab, ~, ic] = unique(ab, 'rows');

% compute similarity matrix
N = size(ab, 1); % X is n by p sample matrix

s = zeros(N * N, 3, 'single');
s(:, 1) = reshape(repmat(1:N, N, 1), N * N, 1);
s(:, 2) = repmat((1:N)', N, 1);
s(:, 3) = reshape(sqdist(ab', ab'), N * N, 1);

idx = 1:N+1:N*N;
s(idx, :) = [];

% set preference
p = median(s(:, 3));
% p = 3050; 

% main problem
[idx,netsim,dpsim,expref]=apcluster(s, p, 'plot');

[class, ~, id] = unique(idx); % class assigned by apcluster
cluster_num = length(class); % number of clusters
label = 1:cluster_num;
cluster_idx = label(id);
idx_map = cluster_idx(ic);
idx_map = reshape(idx_map, height, width);

colormap = floor(rand(length(class), 3) .* 255);
RGB = uint8(ind2rgb(idx_map, colormap));
imwrite(RGB, 'im_apcluster.bmp')
figure; imshow(RGB)
