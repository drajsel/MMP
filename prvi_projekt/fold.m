function [ A ] = fold( a, mod, l, m, n )
if mod==1
   A=fold_1(a, l, m, n);
elseif mod==2
    A=fold_2(a, l, m, n);
elseif mod==3
   A=fold_3(a,l, m, n);
end


end

