function [flag] = issuccessful(SR)
%ISSUCCESSFUL 此处显示有关此函数的摘要
%   此处显示详细说明
    index1=find(SR>0);
    array=SR(index1);
    index2=find(array<0.01);
    num=size(index2,2);
    flag=1;
    if num>0
        flag=0;
    end
end

