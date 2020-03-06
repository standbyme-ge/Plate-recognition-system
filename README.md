# Plate-recognition-system
This my plate recognition system based on deep learning


====================based on MATLAB

%main
```
close all %关闭所有的figure 窗口
clear all %清除工作区的变量
clc  %清除代码区代码
```
%1.读取图像
```
[fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),subplot(2,3,1);
imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字
```

%2.定位车牌

```
[y,x,z]=size(I);      % size(I) 反回矩阵行数/列数/片数          
d_I=double(I);          %将I数据转换成双精度型
Y_threshlow=5;          %阈值 决定提取的彩图质量

% Y 方向
B_y=zeros(y,1);      %创建y列向量,统计蓝色像素点
for i=1:y
    for j=1:x   
        if((d_I(i,j,1)<=48) && ((d_I(i,j,2)<=100)&&(d_I(i,j,2)>=40)) && ((d_I(i,j,3)<=200)&&(d_I(i,j,3)>=80)))  
           %蓝色像素的判断条件:R<=48;  40<=G<=100;  80<=B<=200     R:28  G:63  B:138
           B_y(i,1)= B_y(i,1)+1;     %统计每行蓝色像素点数                    
        end  
    end       
end

%上下界 Y1 Y2
  [temp,MaxY]=max(B_y);  %先Y方向。temp=最多累积的像素点。MaxY=temp(蓝点最多)所在行
  
  Y1=MaxY;   %找到蓝点最多的行,up
  while ((B_y(Y1,1)>=Y_threshlow)&&(Y1>1))   %查找车牌上边界 
    Y1=Y1-1;
  end
  Y2=MaxY;    %找到蓝点最多的行,down
  while ((B_y(Y2,1)>=Y_threshlow)&&(Y2<y))   %查找车牌下界
    Y2=Y2+1;
  end
  subplot(2,3,3);
imshow(I(Y1:Y2,:,:)),title('Y1');
%X方向
  X_threshhigh=(Y2-Y1)/11;    %X方向长度
  B_x=zeros(1,x);   %统计X行的蓝色像素点
  for j=1:x
    for i=Y1:Y2     %在Y1-Y2间统计蓝色像素点
      if((d_I(i,j,1)<=48) && ((d_I(i,j,2)<=100)&&(d_I(i,j,2)>=40)) && ((d_I(i,j,3)<=200)&&(d_I(i,j,3)>=80)))   
      %蓝色像素点：R:28  G:63  B:138
      B_x(1,j)=B_x(1,j)+1;
      end
    end
  end
  [temp,MaxX]=max(B_x);   %蓝色像素点所在列
  X1=MaxX-6*(Y2-Y1);    %查找X方向左边界(因为车牌是矩形，取Y:X=1:6)
  if X1<=1
     X1=1;
  end
  while((B_x(1,X1)<=X_threshhigh)&&(X1<x))    %查找左边界
      X1=X1+1;
  end
  X2=MaxX+6*(Y2-Y1);    %查找右边界，并且不超限x
  if X2>=x
     X2=x; 
  end
  while((B_x(1,X2)<=X_threshhigh)&&(X2>X1))   %限定范围，右>左
      X2=X2-1;
  end
subplot(2,3,4);
imshow(I(Y1:Y2,X1:X2,:)),title('X1');
    
X_firrectify=5;          %干扰因子 适当提高贴近车牌边框，但小图会剪裁太多 
Y_firrectify=fix((Y2-Y1)/5);      %取整 车牌区域修正系数
Y1=Y1-Y_firrectify;               %对车牌区域的修正,向上
if(Y1<=0)
  Y1=1;
end
Y2=Y2+Y_firrectify;               %对车牌区域的修正,向下
if(Y2>=y)
  Y2=y;
end
X1=X1-X_firrectify;               %对车牌区域的修正
if(X1<=0)
  X1=1;
end
X2=X2+X_firrectify;               %对车牌区域的修正
if(X2>=x)
  X2=x;
end
I1= I(Y1:Y2,X1:X2,:);
subplot(2,3,2);
imshow(I1);title('初步修正');
```
%二次修正
```
S=(Y2-Y1)*(X2-X1)   %通过车牌识别区域面积来设置不同的阈值
if  S<=25000
  threshold=50;
  Y_secrectify=3;
  X_secrectify=3;
  
elseif S>25000&&S<=45000
  threshold=100;
  Y_secrectify=-3;
  X_secrectify=3;
  
elseif S>45000&&S<=80000
  threshold=200;
  Y_secrectify=-3;
  X_secrectify=3;
elseif S>80000&&S<=150000
  threshold=300;
  Y_secrectify=-10;
  X_secrectify=-10;
  elseif S>150000&&S<=400000
  threshold=600;
  Y_secrectify=-10;
  X_secrectify=-22;
else
  threshold=1800;
  Y_secrectify=-20;
  X_secrectify=-35;
end
Y1=Y1-Y_secrectify;               %对车牌区域的修正,向上
if(Y1<=0)
  Y1=1;
end
Y2=Y2+Y_secrectify;               %对车牌区域的修正,向下
if(Y2>=y)
  Y2=y;
end
X1=X1-X_secrectify;               %对车牌区域的修正
if(X1<=0)
  X1=1;
end
X2=X2+X_secrectify;               %对车牌区域的修正
if(X2>=x)
  X2=x;
end

I2= I(Y1:Y2,X1:X2,:);
subplot(2,3,3);
imshow(I2);title('二次修正');
```
%倾斜校正
```
I3=rgb2gray(I2);subplot(2,3,4);   %灰度处理
imshow(I3),title('灰度图像');
I4=wiener2(I3,[5 5]);    %2D维纳滤波函数去噪声。 函数：wiener2(I，[m n]，噪声)
I5=edge(I4,'canny');     %canny边缘检测以减少干扰
subplot(2,3,5);imshow(I5);title('canny算子');
theta=1:180;     %检测的变化角度
[R xp]=radon(I5,theta);     %沿theta做radon变换，返回R矩阵和每个投影对应的列向量。最大角90
[r c]=find(R>=max(max(R)));     %检索最大投影角度的最大值，倾斜角存于c中
I6=imrotate(I3,90-c,'bilinear','crop');     %校正图像，用'90-c'来计算倾斜角
                                        %取负值，向右旋转。双线性插值并且输出相同大小的图像
subplot(2,3,6);imshow(I6);title('倾斜角校正');
```
%形态学处理
```
bw1=im2bw(I6,graythresh(I6));   %通过graythresh找阈值，进行而二值处理
bw2=bwmorph(bw1,'hbreak',inf);    %使用H型断开，Inf表无穷次，直到图像无变化为止。
bw3=bwmorph(bw2,'spur',inf);    %除去毛刺类小分支
bw4=bwmorph(bw3,'open',5);      %开运算(先膨胀再腐蚀)，5次
bw5=bwareaopen(bw4,threshold);  %删除面积小于threshold的部分，默认8邻域
bw=~bw5;    %倒置二进制矩阵，凸显车牌字体。
figure('name','形态学处理'),subplot(2,3,1);imshow(bw1);title('二值化');
subplot(2,3,2);imshow(bw2);title('Hbreak');
subplot(2,3,3);imshow(bw3);title('去毛刺');
subplot(2,3,4);imshow(bw4);title('开运算');
subplot(2,3,5);imshow(bw5);title('擦除');
subplot(2,3,6);imshow(bw);title('取反 倒置');
```
%投影法去边框

%垂直方向投影，扫描每一列像素，绘制柱状图 来直观表示像素个数。
%先平滑去噪声后再和阈值化一起使用。
```
[y,x]=size(bw);     %获取倒置的逻辑图像，进一步处理：投影法
Y_ty=(sum((~bw)'))';   %向左边投影：分析水平方向像素点，识别上下边框
X_ty=sum((~bw));       %向下投影：分析垂直方向像素点，识别左右边框

%figure,subplot(1,3,1);
%imhist(Y_ty);title('left');
%subplot(1,3,2);
%imhist(X_ty);title('down');    %显示错误，需要修改显示内容

%找黑色边框边缘

%由曲线图的上下两个极大值分别从上向下和从下向上搜索波谷，
%波谷值小于阈值 且 上下波谷间有距离字符
%由这两个波谷位置水平分割车牌，截去车牌的上下边框。

Y_up=fix(y/2);    %设上边界为中间。 mean()取平均值。
Y_threshold=mean(Y_ty((Y_up-10):(Y_up+10),1))/2;    %对投影的中间区域的平均值来设定阈值
while((Y_ty(Y_up,1)>=Y_threshold)&&(Y_up>1))      %大于阈值且不超上限
    Y_up=Y_up-1;
end

Y_down=fix(y/2);
while((Y_ty(Y_down,1)>=Y_threshold)&&(Y_down<y))      %大于阈值且不超下限
    Y_down=Y_down+1;
end

%垂直投影，车牌第一个字为汉字，所以第一个波峰到波谷为左边框
%删除左边框，以提取车牌字符
X_right=1;    %右边限制值
X_threshold=1;
if (X_ty(1,fix(x/14)))<=X_threshold
  X_right=fix(x/14);
end

bw6=bw(Y_up:Y_down,X_right:x);
figure, %subplot(1,3,3);
imshow(bw6);title('上下边框擦除');
bw7=~bw6;
bw7=bwareaopen(bw7,threshold);    %擦除面积小于阈值的部分
bw7=~bw7;
[y,x]=size(bw7);    %更新车牌长宽
```
%分割字符
```
S2=x*y;   %利用面积设置分割阈值
if S2<=20000
    S_thresh=4;
elseif S2>20000&&S2<=30000
    S_thresh=4;
elseif S2>30000&&S2<=50000
    S_thresh=4;
elseif S2>50000&&S2<=80000
    S_thresh=4;
else
    S_thresh=4;
end
ganrao=S2/100;          %干扰系数，为字符大小框选减小误差
histogram=sum(~bw7);    %自定义histogram数组，存储垂直方向黑色像素点

%字符边界识别
k=1;
for h=1:x-1     %判定字符左边界，并存储
  if  ((histogram(1,h)<=S_thresh)&&(histogram(1,h+1)>S_thresh))||((h==1)&&histogram(1,h)>S_thresh)
        sign(1,k)=h;        %存储字符左边界
        k=k+1;
    elseif ((histogram(1,h)>S_thresh)&&(histogram(1,h+1)<=S_thresh))||((h==x-1)&&histogram(1,h)>S_thresh)       %上下判断交换，
        sign(1,k)=h+1;      %字符右边界
        k=k+1;
    end
end
k=k-1;    %减去上一步多产生的K。
if k<10
    msgbox('warning');    %每个字符两个K，
    pause;
end

%若字符的左右边界的垂直黑色像素小于干扰值
% 或者 第一个识别字符边界与后面的字符边界宽度不一样
%则第一个字符为左边框，删去，用后面识别字符替代

i=18;  %疑问：常常测试下面除去左边框干扰超出界。原因i未变。添加预赋值减少错误
if (sum(histogram(1,sign(1,1):sign(1,2)))<ganrao)||((sign(1,2)-sign(1,1))<(sign(1,4)-sign(1,3))/2)
    for i=3:k
      sign(1,i-2)=sign(1,i);
    end
 end
bw8=bw7(:,sign(1):sign(i));%除去左边框干扰
[y,x]=size(bw8);%更新长宽
size_x=zeros(1,x);
i=1;
while i<=x
    while (sum(bw8(:,1))<1 && i<=x)   %从左到右 统计每一列的黑色像素点
        size_x(1,i)=sum(bw8(:,i));    %存储每列黑色像素数目
        i=i+1;
        
        if i>x 
          i=x;    %限制边界
        end
        if (i>x/7 && sum(bw8(:,i))==0) || i==x  %黑色像素长度大于1/10且没有存储
          break;    %跳出
        end
     end
     
     if i>x/7   %黑色像素长于1/10车牌，
        break;    %则是一个字符，跳出
     end
     
     while i<=x/7 &&sum(size_x(1,i)) ==0   %黑色像素小于1/10车牌
          size_x(1,i)=5;                    %可能是与汉字的偏旁（之间断开）
          i=i+1;                            %所以设置中间值=5，连接。并且右移一位
     end                                    %知道sum~=0，表示遇见汉字主体
end
if i<x/7
    x_1=i-1;
else
    [~,x_1]=min(size_x);
end

word1=bw8(:,1:x_1-1);       %汉字区域
figure('name','字符识别'); 
subplot(1,7,1);
imshow(word1),title('省');

bw9=bw8(:,x_1:end);
[y,x]=size(bw9);    %更新车牌长宽
%分割字符
ganrao=(x*y)/100;          %干扰系数，为字符大小框选减小误差
histogram=sum(~bw9);    %自定义histogram数组，存储垂直方向黑色像素点
k=1;
for h=1:x-1     %判定字符左边界，并存储
  if  ((histogram(1,h)<=S_thresh)&&(histogram(1,h+1)>S_thresh))||((h==1)&&histogram(1,h)>S_thresh)
        sign(1,k)=h;        %存储字符左边界
        k=k+1;
    elseif ((histogram(1,h)>S_thresh)&&(histogram(1,h+1)<=S_thresh))||((h==x-1)&&histogram(1,h)>S_thresh)       %上下判断交换，
        sign(1,k)=h+1;      %字符右边界
        k=k+1;
    end
end
k=k-1;    %减去上一步多产生的K。

sign=sign(1,1:k);    %7个字符，左右共14个边界
[m n]=size(sign);
    %显示切割的字符
for s=1:2:n-1
    subplot(1,7,(s+1)/2+1);
    imshow(bw9(1:y,sign(s):sign(s+1)));
end

```
%7个字符的位置。
```
sign_1=bw9(1:y,sign(1):sign(2));
sign_2=bw9(1:y,sign(3):sign(4));
sign_3=bw9(1:y,sign(5):sign(6));
sign_4=bw9(1:y,sign(7):sign(8));
sign_5=bw9(1:y,sign(9):sign(10));
sign_6=bw9(1:y,sign(11):sign(12));

S_1 = imresize(word1,[110 55],'bilinear');
S_2 = imresize(sign_1,[110 55],'bilinear');
S_3 = imresize(sign_2,[110 55],'bilinear');
S_4 = imresize(sign_3,[110 55],'bilinear');
S_5 = imresize(sign_4,[110 55],'bilinear');
S_6 = imresize(sign_5,[110 55],'bilinear');
S_7 = imresize(sign_6,[110 55],'bilinear');

figure;
subplot(1,7,1);imshow(S_1);
subplot(1,7,2);imshow(S_2);
subplot(1,7,3);imshow(S_3);
subplot(1,7,4);imshow(S_4);
subplot(1,7,5);imshow(S_5);
subplot(1,7,6);imshow(S_6);
subplot(1,7,7);imshow(S_7);
```








