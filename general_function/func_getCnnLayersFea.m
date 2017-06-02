%---------------------------------------------------------------------------------------------------------------------------------------------%
% This function gets the results of all layers of CNN using a pretrained model.
% Parameter img is the input img, net is the pretrained model instance. With only these two parameter, all layers results will be got.
% Parameter layerSelect is the names which layer result would be got.layerSelect should be a cell like {'covn1','fc2'}.
%---------------------------------------------------------------------------------------------------------------------------------------------%
function res_cnnLayersFea = func_getCnnLayersFea(varargin)

if nargin == 2
    img = varargin{1};
    net = varargin{2};
%     res_cnnLayersFea.img = img;
%     res_cnnLayersFea.net = net;
    im_single = single(img);
    im_resized = imresize(im_single,net.normalization.imageSize(1:2));
    imInput = im_resized - net.normalization.averageImage;
    res = vl_simplenn(net,imInput);
    res_cnnLayersFea.realInput = res(1).x;
    res_cnnLayersFea.resOfLayer = {};
    res_cnnLayersFea.nameOfLayer = {};
    for i = 2:length(res)
        res_cnnLayersFea.resOfLayer{i-1} = res(i).x;
        res_cnnLayersFea.nameOfLayer{i-1} = net.layers{i-1}.name;
    end
else if nargin == 3
    img = varargin{1};
    net = varargin{2};
    layerSelect = varargin{3};
%     res_cnnLayersFea.img = img;
%     res_cnnLayersFea.net = net;
%     res_cnnLayersFea.layerSelect = layerSelect;
    im_single = single(img);
    im_resized = imresize(im_single,net.normalization.imageSize(1:2));
    imInput = im_resized - net.normalization.averageImage;
    res = vl_simplenn(net,imInput);
    res_cnnLayersFea.realInput = res(1).x;
    
    numLayerSelect = length(layerSelect);
    numLayerAll = length(net.layers);
    for i = 1:numLayerSelect
        nameLayerSelect = layerSelect{i};
        for j = 1:numLayerAll
            if strcmp(nameLayerSelect,net.layers{j}.name)
                res_cnnLayersFea.resOfLayer{i} = res(j+1).x;
                res_cnnLayersFea.nameOfLayer{i} = nameLayerSelect;
            end
        end
    end
    
    else
    res_cnnLayersFea = 0;
    end
end
