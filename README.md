# Plate-recognition-system
This my plate recognition system based on deep learning


====================based on MATLAB

//main.m
close all； %关闭所有的figure 窗口
clear all； %清除工作区的变量
clc;  %清除代码区代码

[fn,pn,fi]=uigetfile('*.jpg','choose your image');   %1.读取图像
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字

//Prtreatment     2.预处理 (I1)
I1=rgb2gray(I);     %RGB转灰度图像
I1=imadjust(I1,[0.3,0.7],[]);     %调整灰度区间，或者说灰度增强
figure('name','预处理后的图片'),
subplot(3,3,1),imshow(I1);title('灰度处理的图片');
subplot(3,3,3),imhist(I1);title('灰度处理的直方图')；
I1=medffilt2(I1);     %采用中值滤波处理
subplot(3,3,4),imshow(I1);title('中值滤波')

//Edge detection     3.边缘检测 (I2)
I2=edge(I1,'roberts',0.25,'both');     %边缘检测算法，省略小于阈值的边缘，both 两个方向检测
%figure('name','边缘检测')，     %因为subplot，所以仅需第一个figure加参数，所以加%
subplot(3,3,5),imshow(I2);title('Roberts算子');

//morphological processing     4.形态学处理 (I3)
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














