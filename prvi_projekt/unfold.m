function [ a ] = unfold( A, mod )
[l, m, n]=size(A);
if mod==1
    a=unfold_1(A);
elseif mod==2
   a=unfold_2(A);
elseif mod==3
    a=unfold_3(A);
end

end

