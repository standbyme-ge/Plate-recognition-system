%% ��������
%imageDatastore �����ļ��������Զ����ͼ�񣬲������ݴ洢Ϊ ImageDatastore ����

unzip('XXX.zip');  % ��ѹ��ͼ������
imds = imageDatastore('XXX', ...  % ͼ��·��
    'IncludeSubfolders',true, ... % �Ƿ������ȡ���ļ���
    'LabelSource','foldernames'); % ����labels �Ķ�ȡ��ʽ

%�����ݻ���Ϊѵ�����ݼ�����֤���ݼ����� 70% ��ͼ������ѵ����30% ��ͼ��������֤��
%splitEachLabel �� images ���ݴ洢���Ϊ�����µ����ݴ洢��
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.8,'randomized');


%% ����ѵ������
%������ѵ����Alexnet��

net=alexnet;

inputSize = net.Layers(1).InputSize
%% �滻������
%��ȡ1:end-3��
layersTransfer = net.Layers(1:end-3);

%��������滻Ϊȫ���Ӳ㡢softmax ��ͷ��������
%ȫ���Ӳ�����Ϊ��С���������е�������ͬ
%����ȫ���Ӳ�� WeightLearnRateFactor �� BiasLearnRateFactor ֵ�ӿ�ѵ���ٶ�
numClasses = numel(categories(imdsTrain.Labels));
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,...    %ȫ���Ӳ������
    'WeightLearnRateFactor',20,...    %Ȩֵ��ѧϰ����ȫ��ѧϰ�ʵı�ֵ
    'BiasLearnRateFactor',20)    %ƫ�õ�ѧϰ����ȫ��ѧϰ�ʵı�ֵ
    softmaxLayer    %����������
    classificationLayer];   %���������

%% ѵ������
pixelRange = [-30 30];  % ˮƽ�ʹ�ֱ����ƫ��
% ͼ�����������������
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...   % ���ݼ������ת
    'RandXTranslation',pixelRange, ...  % ˮƽ����ƽ��
    'RandYTranslation',pixelRange);  % ��ֱ����ƫ��
%%ͼ���������䲢���� resize
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);
%%

options = trainingOptions('sgdm', ...  % �����Ż�����
    'MiniBatchSize',10, ...       % BatchSize
    'MaxEpochs',6, ...            % ����������
    'InitialLearnRate',1e-4, ...  % ��ʼѧϰ��
    'Shuffle','every-epoch', ...  % ÿ��ѵ�����ڶ���Ҫ�����ݽ�����������
    'ValidationData',augimdsValidation, ...  % ������֤�����ݼ�
    'ValidationFrequency',4, ...  % ÿ3�ε���֮�������֤
    'Verbose',false, ...  %  �����ѵ���е���Ϣ
    'Plots','training-progress');  % ������ѵ���ڼ���ʾ��ͼ
    
    % ��ʼѵ��
    netTransfer = trainNetwork(augimdsTrain,layers,options);

%% ��֤����
%ʹ�þ���΢�����������֤ͼ����з��ࡣ
[YPred,scores] = classify(netTransfer,augimdsValidation);

%��ʾ�ĸ�ʾ����֤ͼ��Ԥ��ı�ǩ��
idx = randperm(numel(imdsValidation.Files),4);
figure
for i = 1:4
    subplot(2,2,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end

%���������֤���ķ���׼ȷ�ȡ�׼ȷ��������Ԥ����ȷ�ı�ǩ�ı�����
YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation)
disp(['accuracy:',num2str(accuracy)]); % ���Ԥ�⾫�Ƚ��

%% �������и���ͼƬ���ơ����������ش�С���⣩
[fn pn]=uigetfile('*.png');
figure(1),
image=imread([pn fn]);
image_val = imresize(image,[227,227]);
[label,conf] = classify(netTransfer,image_val);
imshow(image_val);title(sprintf('%s %.2f',char(label),max(conf)));


