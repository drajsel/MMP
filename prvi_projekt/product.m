function [ rez ] = product( T, A, mod )
% unfoldati tenzor T
% pomnoziti A*unfold(T, mod)
% fold produkt
[l,m,n]=size(T);
if(size(A,2)~=size(T, mod))
    display('nisu dobre dimenzije');
end
[ a ] = unfold( T, mod );
novi=A*a;
x=[l,m,n];

x(mod)=size(A,1);

rez=fold( novi, mod, x(1), x(2), x(3));

end

