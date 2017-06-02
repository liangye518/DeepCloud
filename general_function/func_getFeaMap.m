function feaThisLayer = func_getFeaMap(feaPath, imgName, layerName)
    load([feaPath.imgName,'.mat'],'res_cnnLayersFea');
    iLayer = find(strcmp(res_cnnLayersFea.nameOfLayer,layerName));
    feaThisLayer = res_cnnLayersFea.resOfLayer{iLayer};
end