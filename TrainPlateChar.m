%% 加载数据
%imageDatastore 根据文件夹名称自动标记图像，并将数据存储为 ImageDatastore 对象。

unzip('XXX.zip');  % 解压新图像数据
imds = imageDatastore('XXX', ...  % 图像路径
    'IncludeSubfolders',true, ... % 是否继续读取子文件夹
    'LabelSource','foldernames'); % 设置labels 的读取方式

%将数据划分为训练数据集和验证数据集。将 70% 的图像用于训练，30% 的图像用于验证。
%splitEachLabel 将 images 数据存储拆分为两个新的数据存储。
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.8,'randomized');


%% 加载训练网络
%加载与训练的Alexnet。

net=alexnet;

inputSize = net.Layers(1).InputSize
%% 替换后三层
%提取1:end-3层
layersTransfer = net.Layers(1:end-3);

%最后三层替换为全连接层、softmax 层和分类输出层
%全连接层设置为大小与新数据中的类数相同
%增大全连接层的 WeightLearnRateFactor 和 BiasLearnRateFactor 值加快训练速度
numClasses = numel(categories(imdsTrain.Labels));
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,...    %全连接层的类数
    'WeightLearnRateFactor',20,...    %权值的学习率与全局学习率的比值
    'BiasLearnRateFactor',20)    %偏置的学习率与全局学习率的比值
    softmaxLayer    %分类器类型
    classificationLayer];   %类型输出层

%% 训练网络
pixelRange = [-30 30];  % 水平和垂直方向偏移
% 图像数据扩充参数设置
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...   % 数据集随机翻转
    'RandXTranslation',pixelRange, ...  % 水平方向平移
    'RandYTranslation',pixelRange);  % 竖直方向偏移
%%图像数据扩充并进行 resize
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);
%%

options = trainingOptions('sgdm', ...  % 参数优化方法
    'MiniBatchSize',10, ...       % BatchSize
    'MaxEpochs',6, ...            % 最大迭代周期
    'InitialLearnRate',1e-4, ...  % 初始学习率
    'Shuffle','every-epoch', ...  % 每个训练周期都需要将数据进行重新排列
    'ValidationData',augimdsValidation, ...  % 用来验证的数据集
    'ValidationFrequency',4, ...  % 每3次迭代之后进行验证
    'Verbose',false, ...  %  不输出训练中的信息
    'Plots','training-progress');  % 在网络训练期间显示绘图
    
    % 开始训练
    netTransfer = trainNetwork(augimdsTrain,layers,options);

%% 验证分类
%使用经过微调的网络对验证图像进行分类。
[YPred,scores] = classify(netTransfer,augimdsValidation);

%显示四个示例验证图像及预测的标签。
idx = randperm(numel(imdsValidation.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end

%计算针对验证集的分类准确度。准确度是网络预测正确的标签的比例。
YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation)
disp(['accuracy:',num2str(accuracy)]); % 输出预测精度结果

%% 可以自行更换图片名称。（输入像素大小任意）
[fn pn]=uigetfile('*.png');
figure(1),
image=imread([pn fn]);
image_val = imresize(image,[227,227]);
[label,conf] = classify(netTransfer,image_val);
imshow(image_val);title(sprintf('%s %.2f',char(label),max(conf)));


