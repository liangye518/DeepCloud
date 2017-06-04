clear all;
%------ tools and functions path ------%
addpath('..\general_function\');
addpath('..\general_function\clustering\demo_clustering\');
addpath('..\libraryPubliced\CNN\matconvnet-win\matlab\');
vl_setupnn;
addpath('..\libraryPubliced\tool\VLFEAT\vlfeat-0.9.19\toolbox');
vl_setup;
addpath('..\libraryPubliced\tool\liblinear\matlab\');
addpath('..\libraryPubliced\tool\libsvm\matlab\');

%------ global parameters setting ------%
dataBase = 'cloud_6';
netName = 'vgg-fine-tune-byYL';
%netName = 'imagenet-vgg-m';
layerSelect = {'conv1','conv2','conv3','conv4','conv5'};%{'conv5','conv4','conv3'};%{'conv5'};%{'conv1','conv2','conv3','conv4','conv5'};
layerSelectOri = {'conv1','conv2','conv3','conv4','conv5','fc6','fc7'};
layerSelectOriFeaName = 'oriCnnFea_allConv_fc67';
nameInPathForLayerSelect = 'conv5'; % or 'allConv'
numTrain = 40;
clusterfun = 'no'; % or 'dplim', or 'no', or 'kmlim';
isReCountSam = 0;
isReSplitSam = 0;
isReGetOriginFeaData = 0;
isReGetGmm = 1;
isReGetFvFea = 1;
isFVNorm = 1;
isReSVMforEachLayer = 1;
numRound = 10;

numGmm = 4;
gmmSamRatio = 0.6; %0.1~1

% mining parameters setting -------%
numCluster = 10;
percent=2.0;
exemplar = {};
%idx_map = {};
numClSelect = 1;

%for numCluster = [3,5,8];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for numTrain = [80,40,20,10,5] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%accuracyAll = []; %#ok<*SAGROW>
%predLabelAll = {};
%gndLabelAll = {};
%------ path setting ------%
path_imgDBRoot = '..\imageDataBase\';
path_imgDB = [path_imgDBRoot,dataBase,'\'];
path_netRoot = '..\libraryPubliced\CNN\models\mat\';
path_net = [path_netRoot,netName,'.mat'];

path_work = '..\workSpace\';
if ~isdir(path_work) mkdir(path_work); end
path_work_DB_Net = [path_work,dataBase,'_',netName,'\'];
if ~isdir(path_work_DB_Net) mkdir(path_work_DB_Net); end
path_work_OriFea = [path_work_DB_Net,layerSelectOriFeaName,'\'];
if ~isdir(path_work_OriFea) mkdir(path_work_OriFea); end
if strcmp(clusterfun,'no') numCluster = 0; end
path_work_OptPara = [path_work_DB_Net,'Res','_nTr',num2str(numTrain),'_nGMM',num2str(numGmm),'_',clusterfun,'Cluster',num2str(numCluster),'\'];
if ~isdir(path_work_OptPara) mkdir(path_work_OptPara); end


% path_midResRoot = '..\midRes\';
% path_midRes = [path_midResRoot,dataBase,'_',netName,'_',layerSelectFeaName,'\'];
% if ~isdir(path_midRes) mkdir(path_midRes); end
% path_feaDataRoot = '..\featureData\';
% path_feaDataOri = [path_feaDataRoot,'cnnOriginFea\'];
% path_feaData = [path_feaDataRoot,dataBase,'_',netName,'_',layerSelectFeaName,'\'];
% if ~isdir(path_feaData) mkdir(path_feaData); end
% path_finalResRoot = '..\finalRes\';
% path_finalRes = [path_finalResRoot,dataBase,'_',netName,'_',layerSelectFeaName,'\'];
% if ~isdir(path_finalRes) mkdir(path_finalRes); end

%------ count all samples and split samples to training samples and testing samples ------%
if ~exist([path_work_DB_Net,'samCount_',dataBase,'.mat'],'file')%isReCountSam
    res_samCount = func_samCount(path_imgDB);
    save([path_work_DB_Net,'samCount_',dataBase,'.mat'],'res_samCount');
else
    disp('Load the existed samCount instance......');
    load([path_work_DB_Net,'samCount_',dataBase,'.mat'],'res_samCount');
end
if ~exist([path_work_DB_Net,'samSplitArr_',dataBase,'_nR',num2str(numRound),'_Tr',num2str(numTrain),'.mat'],'file')%isReSplitSam
    for i = 1:numRound
        disp(['Split the samples for round ',num2str(i),':......']);
        res_samSplit = func_samSplit(res_samCount,numTrain);
        samSplitArr{i} = res_samSplit; %#ok<SAGROW>
        %save([path_midResRoot,'samSplitArr.mat']);
    end
    save([path_work_DB_Net,'samSplitArr_',dataBase,'_nR',num2str(numRound),'_Tr',num2str(numTrain),'.mat'],'samSplitArr');
else
    disp('Load the existed sample split result......');
    load([path_work_DB_Net,'samSplitArr_',dataBase,'_nR',num2str(numRound),'_Tr',num2str(numTrain),'.mat'],'samSplitArr');
end

%------ get and save the CNN original layer selected feature data for each img ------%
if isReGetOriginFeaData

numSam = length(res_samCount.arr_imgPath);
net = load(path_net);
for i = 1:numSam
    disp(['Computing the CNN feature for sample no.',num2str(i),'......']);
    iPath = res_samCount.arr_imgPath{i};
    img = imread(iPath);
    imgName = res_samCount.arr_imgName{i};
    res_cnnLayersFea = func_getCnnLayersFea(img,net,layerSelectOri);
    save([path_work_OriFea,imgName,'.mat'],'res_cnnLayersFea');
end

end

numRound = length(samSplitArr);
    
for iLayerS = 1:length(layerSelect) %length(layerConvName):-1:2%1:length(layerConvName)%5:5%length(layerConvName):-1:1
    iLayer = find(strcmp(layerSelectOri,layerSelect{iLayerS}));
    
    for iRound = 1:numRound
        
    indexArr_trainSam = samSplitArr{iRound}.arr_indexTraining;
    indexArr_trainLabel = res_samCount.arr_imgLabel(indexArr_trainSam);
    samCluster = []; %#ok<*SAGROW>
    patchesClusterLabel = [];
    samImgLabel = [];
    nSamImg = 0;

    %------ got all patches of iLayer of training samples------%
    if isReGetGmm
    for iTrSam = 1:length(indexArr_trainSam)
        indexImg = indexArr_trainSam(iTrSam);
        imgName = res_samCount.arr_imgName{indexImg};
        load([path_work_OriFea,imgName,'.mat'],'res_cnnLayersFea');

        feaThisLayer = res_cnnLayersFea.resOfLayer{iLayer};
        [row,col,fea] = size(feaThisLayer);
        dSam = reshape(feaThisLayer,[row*col,fea]);
        dLabel = ones(row*col,1);
        dLabel = dLabel * indexArr_trainLabel(iTrSam);
        samImgLabel = [samImgLabel;dLabel]; %#ok<*AGROW>
        samCluster = [samCluster;dSam];
        nSamImg = nSamImg + 1;

        disp(['got patch samples for clustering or gmm learning in ',num2str(nSamImg),' images for layer ',layerSelectOri{iLayer},'......']);
    end

    if ~strcmp(clusterfun,'no')
        %------ cluster patches of training sample in iLayer ------%
        if strcmp(clusterfun,'dplim')
            res_cluster = func_dpCluster(samCluster,numCluster);
        end
        if strcmp(clusterfun,'kmlim')
            res_cluster = func_kmCluster(samCluster,numCluster,10000,10);
        end

        %------ compute the statistical information for each cluster ------%
        numClass = length(res_samCount.arr_className);
        for i = 1:numCluster
            for j = 1:numClass
                numInCluster(i) = length(find(res_cluster.labels == i));
                idxClassJ = find(samImgLabel == j);
                clusterLabelForClassJ = res_cluster.labels(idxClassJ);
                numEachClInClass(i,j) = length(find(clusterLabelForClassJ == i));
            end
            ratioEachCl(i,:) = numEachClInClass(i,:) / numInCluster(i);
            stdEachCl(i) = std(ratioEachCl(i,:));
        end

        [stdSort,idxClusterLabelSort] = sort(stdEachCl);

        if ~isdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\']) 
            mkdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\']);
        end
        save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\',...
            'resCluster.mat'],...
            'stdSort','idxClusterLabelSort','ratioEachCl','stdEachCl','numEachClInClass','numInCluster',...
            'res_cluster','samCluster');

        %------ select patches ------% 
        %for iSel = 1:numClSelect
        idx_selete = find(res_cluster.labels == idxClusterLabelSort(1));
        samGmm = samCluster;
        samGmm(idx_selete,:) = [];
        %end
        clear samCluster;

        %------ learning gmm ------%
        disp('Computing the gmm model......');
        [gmmComp.mean,gmmComp.covariances,gmmComp.priors] = vl_gmm(samGmm',numGmm);
        save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\',...
            'resGmm_.mat'],'gmmComp');
        disp('gmmComp have been saved!');
    else
        samGmm = samCluster;
        clear samCluster;
        %------ learning gmm ------%
        disp('Computing the gmm model......');
        [gmmComp.mean,gmmComp.covariances,gmmComp.priors] = vl_gmm(samGmm',numGmm);
        if ~isdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\']) 
            mkdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\']);
        end
        save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\',...
            'resGmm_.mat'],'gmmComp');
        disp('gmmComp have been saved!');
    end
    end

    %------ get the fv features for each layer which is selected ------%
    if isReGetFvFea %%%%%%%%
    load([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\',...
            'resGmm_.mat'],'gmmComp');
    numSam = length(res_samCount.arr_imgPath);
    for iSam = 1:numSam
        imgName = res_samCount.arr_imgName{iSam};
        load([path_work_OriFea,imgName,'.mat'],'res_cnnLayersFea');
        feaThisLayer = res_cnnLayersFea.resOfLayer{iLayer};
        [row,col,fea] = size(feaThisLayer);
        dSam = reshape(feaThisLayer,[row*col,fea]);
        
        if strcmp(clusterfun,'no')
            if isFVNorm
                feaFV = vl_fisher(dSam',gmmComp.mean,gmmComp.covariances,gmmComp.priors,'Normalized');
            else
                feaFV = vl_fisher(dSam',gmmComp.mean,gmmComp.covariances,gmmComp.priors);
            end
            if ~isdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\'])
                mkdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\']);
            end
            save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\',imgName,'.mat'],'feaFV');
            disp(['Got ',num2str(iSam),'/',num2str(numSam),' samples'' final feature data in Round ',num2str(iRound),'......']);
        else
            load([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\',...
                'resCluster.mat'],...
                'stdSort','idxClusterLabelSort','ratioEachCl','stdEachCl','numEachClInClass','numInCluster',...
                'res_cluster');
            idxCenterChoose = idxClusterLabelSort(1);
            samDist = func_distCenter(dSam,res_cluster.centersFea);
            for i = 1:row*col
                samLabel(i) = find(samDist(i,:) == min(samDist(i,:)), 1 );
            end
            idxSelect = find(samLabel == idxCenterChoose);
            if length(idxSelect) > row*col*gmmSamRatio
                iidx = randperm(length(idxSelect));
                nnumSel = row*col*(1-gmmSamRatio);
                idxSelect = idxSelect(iidx(1:nnumSel));
            end
            dSam(idxSelect,:) = [];
            if isFVNorm
                feaFV = vl_fisher(dSam',gmmComp.mean,gmmComp.covariances,gmmComp.priors,'Normalized');
            else
                feaFV = vl_fisher(dSam',gmmComp.mean,gmmComp.covariances,gmmComp.priors);
            end
            if ~isdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\'])
                mkdir([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\']);
            end
            save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\',imgName,'.mat'],'feaFV');
            disp(['Got ',num2str(iSam),'/',num2str(numSam),' samples'' final feature data in Round ',num2str(iRound),'......']);
        end
        
    end
    end%%%%%%%%

    if isReSVMforEachLayer %%%%%%%%
    %------ train svm model for each layer's fv feature 
    if ~exist([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','SVMmodel.mat'],'file')
        disp('No svm model exist for this layer, reTrain svm...');
        indexTr = samSplitArr{iRound}.arr_indexTraining;
        training_label_vector = double((res_samCount.arr_imgLabel(indexTr))');
        samTrain = [];
        disp('Porcessing all training samples......');
        for i = 1:length(indexTr)
            imgName = res_samCount.arr_imgName{indexTr(i)};
            load([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\',imgName,'.mat'],'feaFV');
            tempSamFea = feaFV;
            tempSamFea = tempSamFea';
            samTrain = [samTrain;tempSamFea];
        end
        training_instance_sparse = sparse(double(samTrain));
        disp('Training svm model......');
        svmModel = train(training_label_vector, training_instance_sparse);
        save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','SVMmodel.mat'],'svmModel');
    else
        disp('Loading svm model exist for this layer...');
        load([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','SVMmodel.mat'],'svmModel');
    end

    %------ test svm model for each layer's fv feature 
    indexTs = samSplitArr{iRound}.arr_indexTesting;
    testing_label_vector = double((res_samCount.arr_imgLabel(indexTs))');
    samTest = [];
    disp('Processing all testing samples......');
    for i = 1:length(indexTs)
        imgName = res_samCount.arr_imgName{indexTs(i)};
        load([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','finalFea\',imgName,'.mat'],'feaFV');
        tempSamFea = feaFV;
        tempSamFea = tempSamFea';
        samTest = [samTest;tempSamFea];
    end
    testing_instance_sparse = sparse(double(samTest));
    disp('Testing......');
    [predicted_label,accuracy,decision_values] = predict(testing_label_vector, testing_instance_sparse, svmModel);

    %------ record the result for one round ------%
    save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','Round',num2str(iRound),'\','res.mat'],'predicted_label','accuracy','decision_values');
    accuracyAll(iRound) = accuracy(1);  %#ok<*SAGROW>
    predLabelAll{iRound} = predicted_label;
    gndLabelAll{iRound} = testing_label_vector;

    end%%%%%%%%
    end
    
    %------ record results for one layer by multi Rounds------%
    accuracyAvg = mean(accuracyAll); 
    accuracyStd = std(accuracyAll); 
    numRound = length(accuracyAll);
    label = unique(gndLabelAll{1});
    numClass = length(label);
    accuracyPerClass = zeros([numClass+1,numRound+1],'double');
    stdPerClass = zeros([1,numClass+1],'double');
    for iRound = 1:numRound
        for iClass = 1:numClass
            indexTest = find(gndLabelAll{iRound} == label(iClass));
            numTest = length(indexTest);
            predResult = predLabelAll{iRound}(indexTest);
            numPred = length(find(predResult == label(iClass)));
            accuracyPerClass(iClass,iRound) = 100 * numPred / numTest;
        end
    end
    for iClass = 1:numClass
        accuracyPerClass(iClass,end) = sum(accuracyPerClass(iClass,1:numRound)) / numRound;
        stdPerClass(iClass) = std(accuracyPerClass(iClass,1:numRound));
    end
    stdPerClass(end) = mean(stdPerClass(1:end-1));
    accuracyPerClass(end,:) = mean(accuracyPerClass(1:end-1,:));
    timeNow = datestr(clock,30);
    save([path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','result_',num2str(numRound),'Rounds_T',timeNow,'.mat'],...
        'accuracyAll','predLabelAll','gndLabelAll','accuracyAvg','accuracyStd','accuracyPerClass','stdPerClass');

    fileFullName = [path_work_OptPara,'Layer_',layerSelectOri{iLayer},'\','result_',num2str(numRound),'Rounds_T',timeNow,'.txt'];
    fp = fopen(fileFullName,'w+');
    fprintf(fp,['The average accuracy of %d rounds is: %.2f, Standard deviation: %.2f\r\n',...
        'Parameter of Fisher Vector:\r\n',...
        'Number of Gmms:%d\r\n',...
        'Is normalize on fisher vector:%d\r\n',...
        'Ration of gmm learning sampling:%d\r\n'],...
        numRound,accuracyPerClass(end,end),stdPerClass(end),numGmm,isFVNorm,gmmSamRatio);
    fclose(fp);
    disp('!!!!! Results has been recorded!!!!!');   

end
    
%%%%end%%%%%%%%

end %%%%% numTrain
%end %%%%%%%%%%numCluster


