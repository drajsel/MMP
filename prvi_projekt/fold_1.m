function [ A ] = fold_1( A_1, l, m, n )
for k=1:n
    A(:,:,k)=A_1(:,(k-1)*m+1:(k-1)*m+m);
end

end

