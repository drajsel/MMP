%pretvorba podataka usps_resampled kao sto smo prije imali azip, dzip,
%dtest, testzip...
%u train_labels i test_labels oznacava se znamenka tako da je jedinica u
%onom retku koji oznacava tu znamenku

%izvor: http://www.gaussianprocess.org/gpml/data/, 
%https://github.com/marionmari/Graph_stuff/blob/master/usps_digit_data/usps_resampled.mat

clear all;

load usps_resampled.mat

dzip=zeros(1,size(train_labels,2));
dtest=zeros(1,size(train_labels,2));

for i=1:size(train_labels,2) %==size(test_labels,2)
    ind1=find(train_labels(:,i)==1);
    dzip(i)=ind1-1;
    
    ind2=find(test_labels(:,i)==1);
    dtest(i)=ind2-1;
end

azip=train_patterns;
testzip=test_patterns;

%potrebno je posloziti sve vektore koji su znamenka i u matrice 16x16 i
%onda u tenzore

%potrebno je poduplati neke znamenke tako da svi imaju isti broj
%training faza -> fajlovi dzip i azip

class_size=zeros(1,10);
for i=0:9
    ind=find(dzip==i);
    class_size(i+1)=size(ind,2);
end

max_size=max(class_size);

for i=0:9
    %u dzip gledam koji vektori po redu su znamenka i
    ind=find(dzip==i); %trazim u vektoru znamenki stupce s i-tom znamenkom
    A{i+1}=zeros(16,16,max_size); %A{i+1} je tenzor koji sadrzi sve vektore koji predstavljaju znamenku i !!!
    for j=1:size(ind,2) %ind(j) pokazuje j-to mjesto u vektoru koje prikazuje stupac u matrici azip na kojoj je i-ta znamenka
          %ind(j)- stupac u azip koji prikazuje i-tu znamenku
          A{i+1}(:,:,j)=reshape(azip(:,ind(j)), 16, 16)'; %pretvorim vektor koji prikazuje sliku u obliku 16x16
    end
    
    %sad je potrebno jos nadodati elemente
    velicina=class_size(i+1);
    
    if velicina<max_size
        k=floor(max_size/velicina);
        for l=1:k-1 % jos k-1 puta punimo tenzor istim vektorima i onda je jos potrebno ostatak nadopuniti
           
            A{i+1}(:,:,velicina+(l-1)*k+1: velicina+(l-1)*k+velicina)=A{i+1}(:,:,1:velicina);
        end
        A{i+1}(:,:, k*velicina+1:max_size)=A{i+1}(:,:,1:max_size-k*velicina);
    end
    
end

rez=zeros(1, size(dtest,2));
U1=cell(1,10);
U2=cell(1,10);
U3=cell(1,10);
S1=cell(1,10);
S2=cell(1,10);
S3=cell(1,10);
S=cell(1,10);

%biramo k-dimenzionalne potprostore, k isti za sve, k=1, ..., 319
indeks=0;
for K=size(A{1},3)
    indeks=indeks+1;
    clear B;
B=cell(10,K);
for i=0:9
   [U1{i+1}, S1{i+1}]=svd(unfold(A{i+1}, 1));
   [U2{i+1}, S2{i+1}]=svd(unfold(A{i+1}, 2));
   [U3{i+1}, S3{i+1}]=svd(unfold(A{i+1}, 3));
   S{i+1}=product(product(product(A{i+1}, U1{i+1}', 1), U2{i+1}', 2), U3{i+1}', 3);
   %B je prije bio AJ
   
   for j=1:K
          b=product(product(S{i+1}(:,:,j), U1{i+1}, 1), U2{i+1}, 2);
          B{i+1,j}=b/tnorm(b); %ortogonalne bazne matrice, u clanku A_v^{mi}
   end
end

%faza testiranja
for k=1:size(testzip, 2);
    display(k);
    Z=reshape(testzip(:,k), 16, 16)'; %nepoznata znamenka
    Z=Z/norm(Z, 'fro'); %normaliziramo
    
    %zelim naci znamenku kojoj pripada
    %A{i} - tenzor koji prikazuje znamenke (i-1)
    aprox=zeros(1,10); %aproksimacije za pojedinu znamenku, R niz u clanku
    %imshow(reshape(testzip(:,k), 16, 16)')
    for i=0:9
       %prvo konstruirati A_{j} za (i+1) tenzor A{i}
       %ne trebaju nam V_{i} matrice od SVD-a pa izbjegavam dodatno
       %racunanje
%       S=product(product(product(A{i+1}, U1{i+1}', 1), U2{i+1}', 2), U3{i+1}', 3);
      %A_i=product(product(S(:,:,i), U1, 1), U2, 2)
      
      %mat=Z;
     r=1;
     for j=1:K
         r=r-trace(B{i+1,j}'*Z)^2;
     end
     
    aprox(i+1)=r;
    end
    [mini, minind]=min(aprox);
   %minind-1
    rez(k)=minind-1; %znamenka koju je odredio programcic
    
    
end

clear usporedi
usporedi(:,1)=rez';
usporedi(:,2)=dtest';

rezultat(indeks)=sum(usporedi(:,1)==usporedi(:,2))/size(testzip,2);
end