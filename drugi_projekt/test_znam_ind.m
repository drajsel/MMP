function [ind, aprox, znak]=test_znam_ind(image, K, A, B, ime_znaka, f_output, poc,kraj)

%     Z=rgb2gray(image); %nepoznata znamenka!!!
%     figure(1),imshow(Z);
       Z=double(image);
%     figure(2),imshow(Z);
    Z=imresize(Z,[32 20]);
%     imshow(Z);
%     Z=Z/norm(Z, 'fro'); %normaliziramo
%     imshow(Z);
    %normaliziranje radi problem!!!
    
    %zelim naci znamenku kojoj pripada
    %A{i} - tenzor koji prikazuje apznamenke (i-1)
    aprox=zeros(1,35); %aproksimacije za pojedinu znamenku, R niz u clanku
    
    for i=poc-1:kraj-1
         r=Z;
         for j=1:K
             r=r-(trace(B{i+1,j}'*Z)/trace(B{i+1,j}'*B{i+1,j}))*B{i+1,j};
         end

        aprox(i+1)=norm(r);
    end
    aprox(1,1:poc-1)=Inf;
    aprox(kraj+1:35)=Inf;
    [mini, minind]=min(aprox);
   %minind-1
    ind=minind; %znamenka koju je odredio programcic
    znak=ime_znaka(ind);
  
fprintf(f_output, znak);
  
end
