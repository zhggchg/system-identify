function Rxy=Est_Rxy(x,y,L,Methord)
%函数功能： 估计互相关矩阵
% x ：数据向量
% L ：自相关矩阵阶数
%Methord: 估计方法.
%Rxy: 互相关矩阵

Rxy=zeros(L,1);
Len=floor((length(x)+length(y))/2);
%方法2
if Methord==2
    rxy=xcorr(x,y);
    for i=1:L
        Rxy(i)=rxy(Len-i);
    end
end
end