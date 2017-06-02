%---------------------------------------------------------------------------------------------------------------------------------------------%
% This function split all samples to training samples and testing samples by using the result of func_samCount, which include the path of all
% samples, the class names, the labels of all samples.
% Parameter samCount is the result of func_samCount, numTrain greater than 1 is the number of training samples in EACH CLASS, numTrain less
% than 1 is the ratio of training samples in EACH CLASS
%---------------------------------------------------------------------------------------------------------------------------------------------%
function res_samSplit = func_samSplit(samCount,numTrain)

res_samSplit.arr_indexTraining = [];
res_samSplit.arr_indexTesting = [];

numClass = length(samCount.arr_className);
for i = 1:numClass
    indexPerClass = find(samCount.arr_imgLabel == i);
    numSamPerClass = length(indexPerClass);
    subInd = randperm(numSamPerClass);
    
    if numTrain > 1
        indexSubTr = subInd(1:numTrain);
        res_samSplit.arr_indexTraining = [res_samSplit.arr_indexTraining indexPerClass(indexSubTr)];
        indexSubTs = subInd(numTrain+1:end);
        res_samSplit.arr_indexTesting = [res_samSplit.arr_indexTesting indexPerClass(indexSubTs)];
        disp(['Split ',num2str(numTrain),' training samples and ',num2str(length(indexSubTs)),...
            ' testing samples in class ',samCount.arr_className{i},'.']);
    end
    
    if numTrain < 1
        numTrainT = round(numTrain * numSamPerClass);
        indexSubTr = subInd(1:numTrainT);
        res_samSplit.arr_indexTraining = [res_samSplit.arr_indexTraining indexPerClass(indexSubTr)];
        indexSubTs = subInd(numTrainT+1:end);
        res_samSplit.arr_indexTesting = [res_samSplit.arr_indexTesting indexPerClass(indexSubTs)];
        disp(['Split ',num2str(numTrainT),' training samples and ',num2str(length(indexSubTs)),...
            ' testing samples in class ',samCount.arr_className{i},'.']);
    end
end
disp(['Finished splitting! ',num2str(length(res_samSplit.arr_indexTraining)),' training samples and ', ...
    num2str(length(res_samSplit.arr_indexTraining)),' testing samples.']);