1.  1号代码：解决IMG_1011.JPG 车牌。（倾斜度较小）
```
[fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),subplot(2,3,1);
imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字
%2.定位车牌


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
  subplot(2,3,3),imshow(I(Y1:Y2,:,:));
  title('Y1');
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
  subplot(2,3,4),imshow(I(Y1:Y2,X1:X2,:));
  title('X1');
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
%添加：图像倾斜改正
I3=rgb2gray(I);     %灰度处理
I4=wiener2(I3,[5 5]);    %2D维纳滤波函数去噪声。 函数：wiener2(I，[m n]，噪声)
I5=edge(I4,'canny');     %canny边缘检测以减少干扰
theta=1:180;     %检测的变化角度
[R xp]=radon(I5,theta);     %沿theta做radon变换，返回R矩阵和每个投影对应的列向量。最大角90
[r c]=find(R>=max(max(R)));     %检索最大投影角度的最大值，倾斜角存于c中
I=imrotate(I,90-c,'bilinear','crop');     %校正图像，用'90-c'来计算倾斜角
                                        %取负值，向右旋转。双线性插值并且输出相同大小的图像
%改正end
[y,x,z]=size(I);      % size(I) 反回矩阵行数/列数/片数          
d_I=double(I);          %将I数据转换成双精度型
B_y=zeros(y,1);      %创建y列向量,统计蓝色像素点
for i=1:y
    for j=1:x   
        if((d_I(i,j,1)<=48) && ((d_I(i,j,2)<=100)&&(d_I(i,j,2)>=40)) && ((d_I(i,j,3)<=200)&&(d_I(i,j,3)>=80)))  
           %蓝色像素的判断条件:R<=48;  40<=G<=100;  80<=B<=200     R:28  G:63  B:138
           B_y(i,1)= B_y(i,1)+1;     %统计每行蓝色像素点数                    
        end  
    end       
end
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
subplot(2,3,5),imshow(I(Y1:Y2,:,:));
  title('Y2');
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
  subplot(2,3,6),imshow(I(Y1:Y2,X1:X2,:));
  title('X2');
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
subplot(2,3,2);
imshow(I1);title('初步修正');
```
////////////////////////////////////////////////////////////////////////////////////////////////////////
2.    1号代码：解决IMG_1018.JPG （带一定倾斜角度）

```
[fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),subplot(2,3,1);
imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字

%2.定位车牌

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
subplot(2,3,2);
imshow(I1);title('初步修正');     
```
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
3. 2号代码：解决问题1和问题2

```
[y,x,z]=size(tu);


myi=double(tu);
blue_y=zeros(y,1);  

%统计纵向蓝色像素（将每行的蓝色像素相加放入[y,1]矩阵所对应的行，y是图片的宽）
for i=1:y
    for j=1:x
        rij = myi(i, j, 1)/(myi(i, j, 3)+eps);
        gij = myi(i, j, 2)/(myi(i, j, 3)+eps);
        bij = myi(i, j, 3);
        if ( (rij < 0.3 && gij < 0.6 && bij > 120) ...
                || (gij < 0.8 && rij < 0.9 && bij > 120) )  %判别是否是蓝色像素
            blue_y(i,1)=blue_y(i,1)+1;                      %是蓝色像素就加1            
        end
    end
end


[~,maxy]=max (blue_y);                                  %找到最大蓝色像素行
%有时候蓝色最大像素行并不是车牌区域，所以要进行如下判别
%当蓝色像素行的上面五行和下面五行都大于最大像素行的一半时，才可认为是最大像素行在车牌区域里面
%说明：有时候最大蓝色像素行可能由于干扰原因，并不在车牌区域位置，所以进行此步骤
while blue_y(maxy-5)<blue_y(maxy)/2 && blue_y(maxy+5)<blue_y(maxy)/2  
    blue_y(maxy)=0;
    [~,maxy]=max(blue_y);
end

%确定车牌区域的上边界
py1=maxy;
while((blue_y(py1,1)>=50)&&(py1>1))
    py1=py1-1;
end

%确定车牌区域的下边界
py2=maxy;
while (blue_y(py2,1)>=5)&&(py2<y)
    py2=py2+1;
end

%x1就是车牌区域的上下边界
x1=tu(py1:py2, :, :);
%subplot(2,2,2);imshow(x1);



blue_x=zeros(1,x);

%统计横向蓝色像素，方法同上
for j=1:x
    for i=py1:py2
        rij = myi(i, j, 1)/(myi(i, j, 3)+eps);
        gij = myi(i, j, 2)/(myi(i, j, 3)+eps);
        bij = myi(i, j, 3);
        if ( (rij < 0.3 && gij < 0.6 && bij > 120) ...
                || (gij < 0.8 && rij < 0.9 && bij > 120) )
            blue_x(1,j)=blue_x(1,j)+1;
            %bw2(i,j)=1;
        end
    end
end

%确定车牌左边界
px1=1;
while(blue_x(1,px1)<10 && (px1<x) )
    px1=px1+1;
end

%确定车牌右边界
px2=x;
while(blue_x(1,px2)<25 && (px2>px1))
    px2=px2-1;
end

%得到车牌区域
dw=tu(py1+10:py2-10, px1+5:px2-5, :);

subplot(2,2,2);imshow(dw);

[y,x,z]=size(dw);
bw=zeros(y,x);


%将车牌区域转为黑白
for i=1:y
    for j=1:x
        if (dw(i,j,1)>140 && dw(i,j,2)>150 && dw(i,j,3)>120 )
            bw(i,j)=1;            
        end
    end
end
subplot(2,2,3);imshow(bw);
```
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
4. 除去1号代码中的倾斜校正.(对于倾斜的车牌，K=0部分识别出来，会进入k=1.然后排出识别的倾斜车牌，识别非车牌的部分，最终失败)
4.1  对问题1的车牌识别成功，仅运行Y1,X1 。if语句k=0部分。
4.2  对问题2的车牌识别失败，运行Y1,X1,Y2,X2.  if语句k=0部分成功，识别出车牌。k=2部分失败temp=0<20
4.3  IMG_1034 if k=0 success,k=2 failure
4.4  IMG_0997 (图片比较正) k=0 success,
     IMG_0998 (图片倾斜，与墙上的蓝色标牌水平切割，导致进入k=1) k=0 success,Y1过长，k=1 failure。
     IMG_1001 (图片比较正) k=0 Y1高度不够，X1仅识别车牌局部蓝色，K=1 success 识别出图片
     IMG_1002 (图片倾斜，与1001同一张图)，全部失败。K=0同，K=1 错误 temp=0<20


```
>> [fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]，uigetfile函数直接弹出选取文件夹。
I=imread([pn,fn]);     %读取图像，先文件路径，后文件名
figure('name','原始图像'),subplot(2,3,1);
imshow(I);     %创建新窗口，显示图像I
title('原始图像');     %为图像添加名字
%2.定位车牌


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
    
    Y1=MaxY;    %up side
    while ((B_y(Y1,1)>+Y_threshlow)&&(Y1>1))    %up side
        Y1=Y1-1;
    end
    Y2=MaxY;    %down side
    while ((B_y(Y2,1)>+Y_threshlow)&&(Y2<y))    %down side
        Y2=Y2+1;
    end
subplot(2,3,5);
imshow(I(Y1:Y2,:,:)),title('Y2');
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
subplot(2,3,6);
imshow(I(Y1:Y2,X1:X2,:)),title('X2');
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
subplot(2,3,2);
imshow(I1);title('初步修正'); 
```



