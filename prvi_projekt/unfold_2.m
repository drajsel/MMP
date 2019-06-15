function [ A_2 ] = unfold_2( A )
[l, m, n]=size(A);
A_2=zeros(m, l*n);
for k=1:n
    A_2(:,(k-1)*l+1:(k-1)*l+l)=squeeze(A(:,:,k))'; 
    
end

end

