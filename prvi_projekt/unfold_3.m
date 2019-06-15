function [ A_3 ] = unfold_3( A )
[l, m, n]=size(A);
A_3=zeros(n, l*m);
for j=1:m
    A_3(:,(j-1)*l+1:(j-1)*l+l)=squeeze(A(:,j,:))';

end

