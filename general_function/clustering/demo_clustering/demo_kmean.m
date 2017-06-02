% demo_Kmeans

clear; close all; clc

rand('state', 1)

K = 6;

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

initM = floor((rand(K, 2)-0.5) * 255);
imshow(im3u)

exemplar = kmeans(ab, K, 'start', initM); 
[class, ~, id] = unique(exemplar);

cluster_num = length(class);
label = 1:cluster_num;
cluster_idx = label(id);
idx_map = cluster_idx(ic);
idx_map = reshape(idx_map, height, width);

colormap = floor(rand(K, 3) .* 255);
RGB = uint8(ind2rgb(idx_map, colormap));
imwrite(RGB, 'im_kmeans.bmp')
figure; imshow(RGB)
