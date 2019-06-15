function [ A ] = fold_2( A_2, l, m, n )
for k=1:n
    A(:,:,k)=A_2(:,(k-1)*l+1:(k-1)*l+l)';
end

end

