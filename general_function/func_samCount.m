%---------------------------------------------------------------------------------------------------------------------------------------------%
% This function count all of samples in the database path, in which there are m folders for m classes. Samples are in the m folders.
%---------------------------------------------------------------------------------------------------------------------------------------------%


function res_samCount = func_samCount(path_imgDataBase)

res_samCount.arr_className = {};
res_samCount.arr_imgPath = {};
res_samCount.arr_imgName = {};
res_samCount.arr_imgLabel = [];

if (path_imgDataBase(end) ~= '\')
    path_imgDataBase = [path_imgDataBase,'\'];
end

itemsInPath = dir(path_imgDataBase);
numClass = 0;
numImg = 0;
for i = 1:length(itemsInPath)
    if strcmp(itemsInPath(i).name,'.') || strcmp(itemsInPath(i).name,'..') || ~isdir([path_imgDataBase,itemsInPath(i).name])
        continue;
    end
    numClass = numClass + 1;
    res_samCount.arr_className{numClass} = itemsInPath(i).name;
    path_eachClass = [path_imgDataBase,itemsInPath(i).name,'\'];
    items = dir(path_eachClass);
    numImgOneClass = 0;
    
    for j = 1:length(items)
        if strcmp(items(j).name,'.') || strcmp(items(j).name,'..')
            continue;
        end
        dotIndex = find(items(j).name=='.',1,'last');
        exFileName = items(j).name(dotIndex+1:end);
        imgFileName = items(j).name(1:dotIndex-1);
        if ~strcmp(exFileName,'jpg')
            continue;
        end
        numImg = numImg + 1;
        res_samCount.arr_imgPath{numImg} = [path_eachClass,items(j).name];
        res_samCount.arr_imgName{numImg} = imgFileName;
        res_samCount.arr_imgLabel(numImg) = numClass;
        numImgOneClass = numImgOneClass + 1;
    end
    disp(['Counted ',num2str(numImgOneClass),' samples in class ',res_samCount.arr_className{numClass},'.']);
end
disp(['Finished counting samples, totally ',num2str(numImg),' samples belong to ',num2str(numClass),' classes.']);