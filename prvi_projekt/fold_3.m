function [ A ] = fold_3( A_3, l, m, n )
for j=1:m
    A(:,j,:)=A_3(:,(j-1)*l+1:(j-1)*l+l)'; 
end
end

