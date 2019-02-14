function Rxx=Est_Rxx(x,L,Methord)
%函数功能： 估计自相关矩阵
% x ：数据向量
% L ：自相关矩阵阶数
%Methord: 估计方法.取值范围为1-2
%Rxx: 自相关矩阵

Rxx=zeros(L,L);
%方法2
if Methord==2
    rxx=xcorr(x);
    for i=1:L
        for j=1:L
            Rxx(i,j)=rxx(length(x)-i+j);
        end
    end
end
end