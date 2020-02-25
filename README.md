# Plate-recognition-system
This my plate recognition system based on deep learning


====================based on MATLAB

%main
```
close all； %关闭所有的figure 窗口
clear all； %清除工作区的变量
clc;  %清除代码区代码
```
%1.读取图像
```
[fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),subplot(1,3,1);
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
baisebili=0;        %白色比例
changkuanbi=0;      %窗口比例（长宽比）
k=0;   %第一次定位
while(~((baisebili>=0.12)&&(baisebili<=0.5)&&(changkuanbi>=0.20)&&(changkuanbi<=0.6)))
if (k==0)
%上下界 Y1 Y2
  [temp,MaxY]=max(B_y);  %先Y方向。temp=最多累积的像素点。MaxY=temp(蓝点最多)所在行
  if temp<20
    msgbox('location warning')
    pause;
  end
  Y1=MaxY;   %找到蓝点最多的行,up
  while ((B_y(Y1,1)>=Y_threshlow)&&(Y1>1))   %查找车牌上边界 
    Y1=Y1-1;
  end
  Y2=MaxY;    %找到蓝点最多的行,down
  while ((B_y(Y2,1)>=Y_threshlow)&&(Y2<y))   %查找车牌下界
    Y2=Y2+1;
  end
  
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
   a=Y2-Y1+1;        %宽度
   b=X2-X1+1;        %长度
   White=0;            %存储白色区域色素点
   for i=Y1:Y2
       for j=X1:X2
          if  (std([d_I(i,j,1) d_I(i,j,2) d_I(i,j,3)],1,2)<=22)&&(d_I(i,j,1)>=90)&&(d_I(i,j,1)<=255)
             White= White+1;    %白色像素点统计                    
            end  
            end       
        end
 baisebili=White/(a*b);     %白色像素区域比例
 changkuanbi=a/b;           %宽高比
 k=k+1;  %限定第一次定位 
 elseif (k~=0)  
%排除再定位
    B_y(Y1:Y2,1)=0;
    
    [temp,MaxY]=max(B_y);
    if temp<=20
      msgbox('location arning')
      pause;
    end
    Y1=MaxY;    %up side
    while ((B_y(Y1,1)>+Y_threshlow)&&(Y1>1))    %up side
        Y1=Y1-1;
    end
    Y2=MaxY;    %down side
    while ((B_y(Y2,1)>+Y_threshlow)&&(Y2<y))    %down side
        Y2=Y2+1;
    end
  %x
    X_threshhigh=(Y2-Y1)/15;    %X方向长度
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
  a=Y2-Y1+1;
  b=X2-X1+1;
  white=0;
  for i=Y1:Y2
     for j=X1:X2
        if  (std([d_I(i,j,1) d_I(i,j,2) d_I(i,j,3)],1,2)<=16)&&(d_I(i,j,1)>=90)&&(d_I(i,j,1)<=255)
             White= White+1;    %白色像素点统计                    
            end  
            end       
        end
  baisebili=White/(a*b);
        changkuanbi=a/b;
  end
end  
    
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
subplot(1,3,2);
imshow(I1);title('初步修正');     
```




