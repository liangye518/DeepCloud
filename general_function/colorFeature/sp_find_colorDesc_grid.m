%----FUNCTION:
% extract statistical color features (mean and standard deviation) from various of color spaces (RGB, HSV, LAB, Opponent color space)
%----INPUT:
% I - the raw RGB image
% gridX - x grid
% gridY - y grid
% patchSize - patch size
%----OUTPUT:
% colorArr - the statistical color features
%----AUTHOR:
% Yang Xiao @ AUTOMATION SCHOOL HUST (Yang_Xiao@hust.edu.cn)
% Created on 2014.10.30
% Last modified on 2014.10.30

function [colorArr] = sp_find_colorDesc_grid(I, grid_x, grid_y, patch_size)

nPatch = numel(grid_x);
colorArr = zeros(nPatch, 24);

% obtain the various of color spaces
% HSV
I_hsv = rgb2hsv(I);
hImg = double(I_hsv(:,:,1)*255);    sImg = double(I_hsv(:,:,2)*255);    vImg = double(I_hsv(:,:,3)*255);

% LAB
colorTransform = makecform('srgb2lab');     I_lab = applycform(I, colorTransform);
lImg = double(I_lab(:,:,1));    aImg = double(I_lab(:,:,2));    bImg = double(I_lab(:,:,3));

% Opponent
trans_matrix = [0.3333 0.3333 0.3333; 0.4082 0.4082 -0.8164; 0.7071 -0.7071 0]';
I_oppo = image_decor(I, trans_matrix);
o1Img = double(I_oppo(:,:,1));    o2Img = double(I_oppo(:,:,2));    o3Img = double(I_oppo(:,:,3));

% for all patches
for ii = 1:nPatch
    
    % find window of pixels that contributes to this descriptor
    x_lo = grid_x(ii);
    x_hi = grid_x(ii) + patch_size - 1;
    y_lo = grid_y(ii);
    y_hi = grid_y(ii) + patch_size - 1;
    
    % RGB feature
    rImg = double(I(:,:,1));    gImg = double(I(:,:,2));    bImg = double(I(:,:,3));
    rPatch = rImg(y_lo:y_hi,x_lo:x_hi);     gPatch = gImg(y_lo:y_hi,x_lo:x_hi);     bPatch = bImg(y_lo:y_hi,x_lo:x_hi);
    colorArr(ii, 1) = mean(reshape(rPatch,[power(patch_size,2), 1]));   colorArr(ii, 2) = std(reshape(rPatch,[power(patch_size,2), 1]));
    colorArr(ii, 3) = mean(reshape(gPatch,[power(patch_size,2), 1]));   colorArr(ii, 4) = std(reshape(gPatch,[power(patch_size,2), 1]));
    colorArr(ii, 5) = mean(reshape(bPatch,[power(patch_size,2), 1]));   colorArr(ii, 6) = std(reshape(bPatch,[power(patch_size,2), 1]));
    
    % HSV feature
    hPatch = hImg(y_lo:y_hi,x_lo:x_hi);     sPatch = sImg(y_lo:y_hi,x_lo:x_hi);     vPatch = vImg(y_lo:y_hi,x_lo:x_hi);
    colorArr(ii, 7) = mean(reshape(hPatch,[power(patch_size,2), 1]));   colorArr(ii, 8) = std(reshape(hPatch,[power(patch_size,2), 1]));
    colorArr(ii, 9) = mean(reshape(sPatch,[power(patch_size,2), 1]));   colorArr(ii, 10) = std(reshape(sPatch,[power(patch_size,2), 1]));
    colorArr(ii, 11) = mean(reshape(vPatch,[power(patch_size,2), 1]));   colorArr(ii, 12) = std(reshape(vPatch,[power(patch_size,2), 1]));
    
    % LAB feature
    lPatch = lImg(y_lo:y_hi,x_lo:x_hi);     aPatch = aImg(y_lo:y_hi,x_lo:x_hi);     bPatch = bImg(y_lo:y_hi,x_lo:x_hi);
    colorArr(ii, 13) = mean(reshape(lPatch,[power(patch_size,2), 1]));   colorArr(ii, 14) = std(reshape(lPatch,[power(patch_size,2), 1]));
    colorArr(ii, 15) = mean(reshape(aPatch,[power(patch_size,2), 1]));   colorArr(ii, 16) = std(reshape(aPatch,[power(patch_size,2), 1]));
    colorArr(ii, 17) = mean(reshape(bPatch,[power(patch_size,2), 1]));   colorArr(ii, 18) = std(reshape(bPatch,[power(patch_size,2), 1]));
    
    % opponent feature
    o1Patch = o1Img(y_lo:y_hi,x_lo:x_hi);     o2Patch = o2Img(y_lo:y_hi,x_lo:x_hi);     o3Patch = o3Img(y_lo:y_hi,x_lo:x_hi);
    colorArr(ii, 19) = mean(reshape(o1Patch,[power(patch_size,2), 1]));   colorArr(ii, 20) = std(reshape(o1Patch,[power(patch_size,2), 1]));
    colorArr(ii, 21) = mean(reshape(o2Patch,[power(patch_size,2), 1]));   colorArr(ii, 22) = std(reshape(o2Patch,[power(patch_size,2), 1]));
    colorArr(ii, 23) = mean(reshape(o3Patch,[power(patch_size,2), 1]));   colorArr(ii, 24) = std(reshape(o3Patch,[power(patch_size,2), 1]));
    
end







