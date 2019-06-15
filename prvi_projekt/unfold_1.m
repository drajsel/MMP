function [ A_1 ] = unfold_1( A )
[l, m, n]=size(A);
A_1=zeros(l, m*n);
for k=1:n
    A_1(:, ((k-1)*m+1):((k-1)*m+m))=A(:,:,k);
end

end

