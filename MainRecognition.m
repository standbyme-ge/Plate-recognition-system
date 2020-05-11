close all
clear,clc;
%% ��ȡ
load('netTransfer.mat')%����ѵ���õĻ���Alexnet��Ǩ�����硣

[fn,pn,fi]=uigetfile('*.jpg','choose your image');  
                       %[filename,pathname,filetype]��uigetfile����ֱ�ӵ���ѡȡ�ļ��С�
I=imread([pn,fn]);     %��ȡͼ�����ļ�·�������ļ���
Plate_number=I;
figure('name','ԭʼͼ��'),subplot(2,2,1);
imshow(I);     %�����´��ڣ���ʾͼ��I
title('ԭʼͼ��');     %Ϊͼ���������

%% %%%%2.��λ����

[y,x,z]=size(I);      % size(I) ���ؾ�������/����/Ƭ��          
d_I=double(I);          %��I����ת����˫������
Y_threshlow=5;          %��ֵ ������ȡ�Ĳ�ͼ����

%% %%%%%%%%%%%%%%%%%%Y ����
B_y=zeros(y,1);      %����y������,ͳ����ɫ���ص�
for i=1:y
    for j=1:x   
        if((d_I(i,j,1)<=48) && ((d_I(i,j,2)<=100)&&(d_I(i,j,2)>=40)) && ((d_I(i,j,3)<=200)&&(d_I(i,j,3)>=80)))  
           %��ɫ���ص��ж�����:R<=48;  40<=G<=100;  80<=B<=200     R:28  G:63  B:138
           B_y(i,1)= B_y(i,1)+1;     %ͳ��ÿ����ɫ���ص���                    
        end  
    end       
end

%���½� Y1 Y2
  [~,MaxY]=max(B_y);  %��Y����temp=����ۻ������ص㡣MaxY=temp(�������)������
  
  Y1=MaxY;   %�ҵ�����������,up
  while ((B_y(Y1,1)>=Y_threshlow)&&(Y1>1))   %���ҳ����ϱ߽� 
    Y1=Y1-1;
  end
  Y2=MaxY;    %�ҵ�����������,down
  while ((B_y(Y2,1)>=Y_threshlow)&&(Y2<y))   %���ҳ����½�
    Y2=Y2+1;
  end
  subplot(2,2,4);
imshow(I(Y1:Y2,:,:)),title('Y1');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%X����
  X_threshhigh=(Y2-Y1)/11;    %X���򳤶�
  B_x=zeros(1,x);   %ͳ��X�е���ɫ���ص�
 for i=Y1:Y2     %��Y1-Y2��ͳ����ɫ���ص�
   for j=1:x
      if((d_I(i,j,1)<=48) && ((d_I(i,j,2)<=100)&&(d_I(i,j,2)>=40)) && ((d_I(i,j,3)<=200)&&(d_I(i,j,3)>=80)))   
      %��ɫ���ص㣺R:28  G:63  B:138
      B_x(1,j)=B_x(1,j)+1;
      end
    end
  end
  [temp,MaxX]=max(B_x);   %��ɫ���ص�������(x����)
  X1=MaxX-6*(Y2-Y1);    %����X������߽�(��Ϊ�����Ǿ��Σ�ȡY:X=1:6)
  if X1<=1
     X1=1;
  end
  while((B_x(1,X1)<=X_threshhigh)&&(X1<x))    %������߽�
      X1=X1+1;
  end
  X2=X1+3*(Y2-Y1);    %�����ұ߽磬���Ҳ�����x
  while((B_x(1,X2)>=X_threshhigh)&&(X2>X1))   %�޶���Χ����>��
      X2=X2+1;   
  end

  XXXX=X2-X1;YYYY=Y2-Y1;
  if X2>=x
     X2=x; 
  end
subplot(2,2,2);
imshow(I(:,X1:X2,:));
title('X1');
figure,subplot(1,2,2);
imshow(I(Y1:Y2,X1:X2,:));title("������λ");
%% %%%%%%%%%%%%%%%%%%%%��ѡ��λ����    
X_firrectify=10;          %�������� �ʵ�����������Ʊ߿򣬵�Сͼ�����̫�� 
Y_firrectify=fix((Y2-Y1)/7);      %ȡ�� ������������ϵ��
Y1=Y1-Y_firrectify;               %�Գ������������,����
if(Y1<=0)
  Y1=1;
end
Y2=Y2+Y_firrectify;               %�Գ������������,����
if(Y2>=y)
  Y2=y;
end
X1=X1-X_firrectify;               %�Գ������������
if(X1<=0)
  X1=1;
end
X2=X2+X_firrectify;               %�Գ������������
if(X2>=x)
  X2=x;
end
I1= I(Y1:Y2,X1:X2,:);
subplot(1,2,1);imshow(I);
rectangle('position',[X1,Y1,X2-X1,Y2-Y1],'edgecolor','r');
title('��������');

%% %%%%%%radon
I2=rgb2gray(I1);
figure;subplot(2,2,1);   %�Ҷȴ���
imshow(I2),title('�Ҷ�ͼ��');
I3=wiener2(I2,[5 5]);    %2Dά���˲�����ȥ������ ������wiener2(I��[m n]������)
I4=edge(I3,'canny');     %roberts��Ե����Լ��ٸ���
subplot(2,2,2);imshow(I4);title('canny����');
theta=1:180;     %���ı仯�Ƕ�
[r, xp]=radon(I4,theta);     %��theta��radon�任������R�����ÿ��ͶӰ��Ӧ��������������90
[m, n] = size(r); 
c = 1; 
for i = 1 : m
   for j = 1 : n
      if r(1,1) < r(i,j)
         r(1,1) = r(i,j);
         c = j;
      end
   end
end
I5=imrotate(I2,90-c,'bilinear','crop');     %У��ͼ����'90-c'��������б��
%I=imrotate(I,90-c,'bilinear','crop');%��ԭͼ����У��
                                        %ȡ��ֵ��������ת��˫���Բ�ֵ���������ͬ��С��ͼ��
subplot(2,2,3);imshow(I5);title('��б��У��');

%% %%%%%%%%%%%%%%%%%%%%%%%��������
S=(Y2-Y1)*(X2-X1);   %ͨ������ʶ��������������ò�ͬ����ֵ
if  S<=25000
  threshold=50;
  Y_secrectify=5;
  X_secrectify=3;
  
elseif S>25000&&S<=45000
  threshold=100;
  Y_secrectify=-3;
  X_secrectify=0;
  
elseif S>45000&&S<=80000
  threshold=200;
  Y_secrectify=-3;
  X_secrectify=3;
elseif S>80000&&S<=150000
  threshold=300;
  Y_secrectify=-2;
  X_secrectify=-10;
  elseif S>150000&&S<=400000
  threshold=600;
  Y_secrectify=-35;
  X_secrectify=-10;
else
  threshold=1800;
  Y_secrectify=-20;
  X_secrectify=-35;
end
Y1=Y1-Y_secrectify;               %�Գ������������,����
if(Y1<=0)
  Y1=1;
end
Y2=Y2+Y_secrectify;               %�Գ������������,����
if(Y2>=y)
  Y2=y;
end
X1=X1-X_secrectify;               %�Գ������������
if(X1<=0)
  X1=1;
end
X2=X2+X_secrectify;               %�Գ������������
if(X2>=x)
  X2=x;
end
I5= I(Y1:Y2,X1:X2,:);       %����С��Χ����ת
I5=imrotate(I5,90-c,'bilinear','crop');
subplot(2,2,4);
imshow(I5);title('�߿�����');
figure;imshow(I);
rectangle('position',[X1,Y1,X2-X1,Y2-Y1],'edgecolor','r');
title('��������');

%% %%%%%%��̬ѧ����
bw1=im2bw(I5,graythresh(I5));   %ͨ��graythresh����ֵ�����ж���ֵ����
bw2=bwmorph(bw1,'hbreak',inf);    %ʹ��H�ͶϿ���Inf������Σ�ֱ��ͼ���ޱ仯Ϊֹ��
bw3=bwmorph(bw2,'spur',inf);    %��ȥë����С��֧
bw4=bwmorph(bw3,'open',5);      %������(�������ٸ�ʴ)��5��
bw4=bwareaopen(bw4,threshold);  %ɾ�����С��threshold�Ĳ��֣�Ĭ��8����
figure('name','��̬ѧ����'),
subplot(2,2,1);imshow(bw1);title('��ֵ��');
subplot(2,2,2);imshow(bw2);title('Hbreak');
subplot(2,2,3);imshow(bw3);title('ȥë��');
subplot(2,2,4);imshow(bw4);title('������+����');
%subplot(2,3,5);imshow(bw5);title('����');

%% ȥ�߿�

%%%%%%��ֱͶӰ
b=bw4;
[m,n]=size(b);
y = 1:n;
x = 1:m;
figure;     %��ɫ���ص���ͶӰ
subplot(2,2,1),imshow(I5);
title('ԭͼ');
subplot(2,2,2),plot(sum(b,2),x);
title('ˮƽͶӰ');
subplot(2,2,3),plot(y,sum(b));
title('��ֱͶӰ');
bw=~bw4;    %���ö����ƾ���͹�Գ������塣
subplot(2,2,4),imshow(bw);
title('ȡ�� ����');

%% �Һ�ɫ�߿��Ե

%����������
%����ֵС����ֵ �� ���²��ȼ��о����ַ�
%������������λ��ˮƽ�ָ�ƣ���ȥ���Ƶ����±߿�

[y,x]=size(bw);     %��ȡ���õ��߼�ͼ�񣬽�һ������ͶӰ��
Y_ty=(sum((bw4)'))';   %�����ͶӰ������ˮƽ�������ص㣬ʶ�����±߿�
X_ty=sum((bw4));       %����ͶӰ��������ֱ�������ص㣬ʶ�����ұ߿�

Y_up=fix(y/2);    %���ϱ߽�Ϊ�м䡣 mean()ȡƽ��ֵ��
Y_threshold=mean(Y_ty((Y_up-10):(Y_up+10),1))/2;    %��ͶӰ���м������ƽ��ֵ���趨��ֵ
%���ϱ���
while((Y_ty(Y_up,1)>=Y_threshold)&&(Y_up>1))      %������ֵ�Ҳ�������
    Y_up=Y_up-1;
end
%���±���
Y_down=fix(y/2);
while((Y_ty(Y_down,1)>=Y_threshold)&&(Y_down<y))      %������ֵ�Ҳ�������
    Y_down=Y_down+1;
end

%��ֱͶӰ�����Ƶ�һ����Ϊ���֣����Ե�һ�����嵽����Ϊ��߿�
%ɾ����߿�����ȡ�����ַ�
X_right=1;    %�ұ�����ֵ
%X_threshold=1;
%if (X_ty(1,fix(x/14)))<=X_threshold
%  X_right=fix(x/14);
%end
%% %%%%%%%%%%%%%
figure,imshow(I);title('��Ե����');
rectangle('position',[X1,Y1+Y_up,x-X_right,Y_down-Y_up],'edgecolor','r');
%% %%%%%%%%%%%%%
bw6=bw(Y_up:Y_down,X_right:x);
figure, subplot(3,1,1);
imshow(bw6);title('��ֱ�߿����');
%%
bw6=bwmorph(bw6,'open',5);
bw7=bwareaopen((~bw6),threshold);    %�������С����ֵ�Ĳ���
bw7=~bw7;
subplot(3,1,2);
imshow(bw7);title('����ë��');

%%
[y,x]=size(bw7);    %���³��Ƴ���
S2=x*y;   %����������÷ָ���ֵ
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
ganrao=S2/80;          %����ϵ����Ϊ�ַ���С��ѡ��С���
histogram=sum(~bw7);    %�Զ���histogram���飬�洢��ֱ�����ɫ���ص�


%�ַ��߽�ʶ��
k=1;
for h=1:x-1     %�ж��ַ���߽磬���洢
  if  ((histogram(1,h)<=S_thresh)&&(histogram(1,h+1)>S_thresh))...
          ||((h==1)&&histogram(1,h)>S_thresh) 
      %����1��x-1��x=i�е�����С����ֵ��i+1���д�����ֵ��Ϊ���
    sign(1,k)=h;        %��sign k �洢�ַ���߽�
    k=k+1;
  elseif ((histogram(1,h)>S_thresh)&&(histogram(1,h+1)<=S_thresh))...
          ||((h==x-1)&&histogram(1,h)>S_thresh)       
      %����1��x-1��x=i�е�����С����ֵ��i+1���д�����ֵ��Ϊ���
     sign(1,k)=h+1;      %�ַ��ұ߽�
     k=k+1;
  end
end
k=k-1;    %��ȥ��һ���������K��
%%
%���ַ������ұ߽�Ĵ�ֱ��ɫ����С�ڸ���ֵ
% ���� ��һ��ʶ���ַ��߽��������ַ��߽��Ȳ�һ��
%���һ���ַ�Ϊ��߿�ɾȥ���ú���ʶ���ַ����

i=k;  %���ʣ��������������ȥ��߿���ų����硣ԭ��iδ�䡣���Ԥ��ֵ���ٴ���
%
if (sum(histogram(1,sign(1,1):sign(1,2)))<ganrao)||((sign(1,2)-sign(1,1))<(sign(1,4)-sign(1,3))/2)
    for i=3:k
      sign(1,i-2)=sign(1,i);
    end
 end
bw8=bw7(:,sign(1):sign(i));%��ȥ��߿����
subplot(3,1,3);imshow(bw8);title('��߿����');
%%
figure,imshow(I);title('��߿����');
rectangle('position',[X1+sign(1),Y1+Y_up,x,y],'edgecolor','r');
%%
[y,x]=size(bw8);%���³���
size_x=zeros(1,x);
i=1;
while i<=x
    while (sum(bw8(:,1))<1 && i<=x)   %������ ͳ��ÿһ�еĺ�ɫ���ص�
        size_x(1,i)=sum(bw8(:,i));    %�洢ÿ�к�ɫ������Ŀ
        i=i+1;
        
        if i>x 
          i=x;    %���Ʊ߽�
        end
        if (i>x/8 && sum(bw8(:,i))==0) || i==x  %��ɫ���س��ȴ���1/7��û�д洢
          break;    %����
        end
     end
     
     if i>x/8   %��ɫ���س���1/7���ƣ�
        break;    %����һ���ַ�������
     end
     
     while i<=x/8 &&sum(size_x(1,i)) ==0   %��ɫ����С��1/7����
          size_x(1,i)=5;                    %�������뺺�ֵ�ƫ�ԣ�֮��Ͽ���
          i=i+1;                            %���������м�ֵ=5�����ӡ���������һλ
     end                                    %֪��sum~=0����ʾ������������
end
if i<x/8
    x_1=i-1;
else
    [~,x_1]=min(size_x);
end

%word1=bw8(:,1:x_1-1);       %��������
%%
oy1=Y1+Y_up;
ox1=X1+sign(1);
%figure,imshow(I);title('��������');
%rectangle('position',[ox1,oy1,x_1-1,y],'edgecolor','r');

ORG_1=I(oy1:oy1+y,ox1:ox1+x_1,:);  %ԭͼʡ��


%figure('name','�ַ�ʶ��'); 
%subplot(1,7,1);
%imshow(word1),title('ʡ');
%% ����Iͼox,oy
oy2=oy1;
ox2=ox1+x_1-1;
%%
bw9=bw8(:,x_1:end);
[y,x]=size(bw9);    %���³��Ƴ���
%�ָ��ַ�
ganrao=(x*y)/100;          %����ϵ����Ϊ�ַ���С��ѡ��С���
histogram=sum(~bw9);    %�Զ���histogram���飬�洢��ֱ�����ɫ���ص�
k=1;
for h=1:x-1     %�ж��ַ���߽磬���洢
  if  ((histogram(1,h)<=S_thresh)&&(histogram(1,h+1)>S_thresh))||((h==1)&&histogram(1,h)>S_thresh)
        sign(1,k)=h;        %�洢�ַ���߽�
        k=k+1;
  elseif ((histogram(1,h)>S_thresh)&&(histogram(1,h+1)<=S_thresh))||((h==x-1)&&histogram(1,h)>S_thresh)       %�����жϽ�����
        sign(1,k)=h+1;      %�ַ��ұ߽�
        k=k+1;
  end
end
k=k-1;    %��ȥ��һ���������K��

sign=sign(1,1:k);    %7���ַ������ҹ�14���߽�
%[m, n]=size(sign);
    %��ʾ�и���ַ�
%for s=1:2:n-1
%    subplot(1,7,(s+1)/2+1);
%    imshow(bw9(1:y,sign(s):sign(s+1)));
%end
%%
figure,imshow(I);title('�ַ���ѡ');
rectangle('position',[ox1,oy1,x_1-1,y],'edgecolor','r');
rectangle('position',[ox2+sign(1),oy2,sign(2),y],'edgecolor','r');
rectangle('position',[ox2+sign(3),oy2,sign(4)-sign(3),y],'edgecolor','r');
rectangle('position',[ox2+sign(5),oy2,sign(6)-sign(5),y],'edgecolor','r');
rectangle('position',[ox2+sign(7),oy2,sign(8)-sign(7),y],'edgecolor','r');
rectangle('position',[ox2+sign(9),oy2,sign(10)-sign(9),y],'edgecolor','r');
rectangle('position',[ox2+sign(11),oy2,sign(12)-sign(11),y],'edgecolor','r');
%% 7���ַ���λ�á�

sign_1=I(oy2:oy2+y,ox2+sign(1):ox2+sign(2),:);
sign_2=I(oy2:oy2+y,ox2+sign(3):ox2+sign(4),:);
sign_3=I(oy2:oy2+y,ox2+sign(5):ox2+sign(6),:);
sign_4=I(oy2:oy2+y,ox2+sign(7):ox2+sign(8),:);
sign_5=I(oy2:oy2+y,ox2+sign(9):ox2+sign(10),:);
sign_6=I(oy2:oy2+y,ox2+sign(11):ox2+sign(12),:);

%%
ORG_1 = imresize(ORG_1,[227,227]);
sign_1 = imresize(sign_1,[227,227]);
sign_2 = imresize(sign_2,[227,227]);
sign_3 = imresize(sign_3,[227,227]);
sign_4 = imresize(sign_4,[227,227]);
sign_5 = imresize(sign_5,[227,227]);
sign_6 = imresize(sign_6,[227,227]);

[label1,conf1] = classify(netTransfer,ORG_1);
[label2,conf2] = classify(netTransfer,sign_1);
[label3,conf3] = classify(netTransfer,sign_2);
[label4,conf4] = classify(netTransfer,sign_3);
[label5,conf5] = classify(netTransfer,sign_4);
[label6,conf6] = classify(netTransfer,sign_5);
[label7,conf7] = classify(netTransfer,sign_6);

figure;
subplot(2,7,1);imshow(ORG_1);title(sprintf('%s %.2f',char(label1),max(conf1)));
subplot(2,7,2);imshow(sign_1);title(sprintf('%s %.2f',char(label2),max(conf2)));
subplot(2,7,3);imshow(sign_2);title(sprintf('%s %.2f',char(label3),max(conf3)));
subplot(2,7,4);imshow(sign_3);title(sprintf('%s %.2f',char(label4),max(conf4)));
subplot(2,7,5);imshow(sign_4);title(sprintf('%s %.2f',char(label5),max(conf5)));
subplot(2,7,6);imshow(sign_5);title(sprintf('%s %.2f',char(label6),max(conf6)));
subplot(2,7,7);imshow(sign_6);title(sprintf('%s %.2f',char(label7),max(conf7)));
%% ��ʶ����תΪ�ַ���
a1=char(cellstr(label1));
a2=char(cellstr(label2));
a3=char(cellstr(label3));
a4=char(cellstr(label4));
a5=char(cellstr(label5));
a6=char(cellstr(label6));
a7=char(cellstr(label7));

%���ؽ��
str=[a1 a2 a3 a4 a5 a6 a7];
%%
disp(str); %��ʾ���
subplot(2,7,8:14);imshow(Plate_number);
title(['���ƺ���:', str],'Color','b');