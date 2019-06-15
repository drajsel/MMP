function [ rez ] = tnorm( A )
[m,n,p]=size(A);
sum=0;
for i=1:m
    for j=1:n
        for k=1:p
            sum=sum+A(i,j,k)^2;
        end
    end
end
rez=sqrt(sum);
end

