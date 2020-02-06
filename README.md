# Plate-recognition-system
This my plate recognition system based on deep learning


====================based on MATLAB

%//main.m
close all； %关闭所有的figure 窗口
clear all； %清除工作区的变量
clc;  %清除代码区代码

[fn,pn,fi]=uigetfile('*.jpg','choose your image');   %1.读取图像
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字

%//Prtreatment     2.预处理 (I1)
I1=rgb2gray(I);     %RGB转灰度图像
I1=imadjust(I1,[0.3,0.7],[]);     %调整灰度区间，或者说灰度增强
figure('name','预处理后的图片'),
subplot(3,3,1),imshow(I1);title('灰度处理的图片');
subplot(3,3,3),imhist(I1);title('灰度处理的直方图')；
I1=medffilt2(I1);     %采用中值滤波处理
subplot(3,3,4),imshow(I1);title('中值滤波')

%//Edge detection     3.边缘检测 (I2)
I2=edge(I1,'roberts',0.25,'both');     %边缘检测算法，省略小于阈值的边缘，both 两个方向检测
%figure('name','边缘检测')，     %因为subplot，所以仅需第一个figure加参数，所以加%
subplot(3,3,5),imshow(I2);title('Roberts算子');

%//morphological processing     4.形态学处理 (I3-5)
%腐蚀
se=[1;1;1];     %
I3=imerode(I2,se);     %腐蚀图像 ,图像和结构元素对象
%figure('name','腐蚀后图像')，
subplot(3,3,7),imshow(I3);title('腐蚀后图像')
%平滑
se=strel('rectangle',[20,20]);     %strel(shape,parameters):形状参数，控制形状大小参数
I4=imclose(I3,se)；     %平滑处理 ，闭运算（先膨胀后腐蚀）
%figure('name','平滑处理')，
subplot(3,3,8),imshow(I4);title('平滑图像轮廓')
%擦除
I5=bwareaopen(I4,2000);     %擦除 ，从二进制图像中移除小于2000像素的连接对象.
%figure('name','擦除'),
subplot(3,3,9),imshow(I5);titile('擦除');
                                                          %2020-2-5
%//location     5.定位
[y,x,z]=size(I5);     %读取I5的行y、列x、片数z.
I6=double(I5);     %转换成双精度

%针对蓝色车牌,非蓝车

% Y方向获取上下边界
Blue_y=zeros(y,1);     %创建y行的全0列向量
for i=1:y     %获取每行的蓝色像素点
    for j=1:x
        if(I6(i,j,1)==1)     %对于预处理的图像判断蓝色像素
            Blue_y(i,1)=Blue_y(i,1)+1;     %统计每一行蓝色像素个数，从上到下循环
        end
    end
end
[temp MaxY]=max(Blue_y);     %统计 temp 最多的点数，MaxY 点数所在行。
if temp<=20     %出错
   msgbox('定位出错'，'warning');
   pause;
end
Y_threshlow=5;     %提取彩图的质量因子，阈值
Y1=MaxY;     %获取上边界
while ((Blue_y(Y1,1)>=Y_threshlow)&&(Y1>1))     %蓝色像素数大于阈值且不跳出图像顶端
      Y1=Y1-1;     %上移
end
Y2=MaxY;     %获取下边界
while ((Blue_y(Y2,1)>=Y_threshlow)&&(Y2<y))     %不跳出下边界
      Y2=Y2+1;     %下移
end

% X方向获取左右边界
Blue_x=zeros(1,x);     %创建x列的全0行向量
for j=1:x     %获取每列的蓝色像素数
    for i=Y1:Y2     %在上下边界中探查
        if(I6(i,j,1)==1)
            Blue_x(1,j)=Blue_x(1,j)+1;     %统计每列蓝色像素数
        end
    end
end
X_threshlow=5;
X1=1;     %左侧
while ((Blue_x(1,X1)<X_thrershlow)&&(X1<x))     %从车牌左侧向车牌靠近 且小于图像最右边
      X1=X1+1;     %右移
end
X2=x;
while ((Blue_x(1,X2)<3)&&(X2>X1))     %右侧大于左侧
       X2=X2-1;     %左移
end
% 修正边缘
X_firrectify=5;     %干扰因子
Y_firrectify=fix((Y2-Y1)/5);     %取整，修正系数
Y1=Y1-Y_firrectify;        %向上修正
Y2=Y2+Y_firrectify;        %向下修正
X1=X1-X_firrectify;        %向左修正
X2=X2+X_firrectify;        %向右修正

%//tailor     6.裁剪
dw=I(Y1:Y2-8,X1:X2,:);     %根据识别出的边缘裁剪原图
figure('name','定位裁剪后的图像')，
imshow(dw);title('裁剪后的图像');
                                                         %2020-2-6
        
        
        
        










