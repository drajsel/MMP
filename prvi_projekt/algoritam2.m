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

%training faza -> fajlovi dzip i azip
%pixel=dimenzija vektora koji prikazuje sliku
%class=10 (10 znamenki)
%digit=broj znamenki pojedine klase =1000
%A=zeros(pixel, digit, class); %tenzor koji sadrzi sve znamenke


pixel=256;
klasa=10;
dimenzije=zeros(1,10);

for i=0:9
   ind=find(dzip==i);
   dimenzije(i+1)=size(ind,2);
end

digit=max(dimenzije);
% h=fspecial('gaussian', [3 3], 0.4);
A=zeros(pixel, digit, klasa);
for i=0:9
    ind=find(dzip==i);
    az=azip(:,ind); %matrica vektora koji predstavljaju znamenku i
%    az=imfilter(az,h,'same');
    A(:,1:size(ind,2),i+1)=az;
    velicina=size(ind,2);
    k=floor(digit/velicina);
    for l=1:k-1
       A(:, velicina+(l-1)*k+1:velicina+(l-1)*k+velicina, i+1)=az;
    end
    A(:,k*velicina+1:digit)=az(:,1:digit-k*velicina);
end
[U, S1]=svd(unfold(A, 1));
[V, S2]=svd(unfold(A, 2));
[W, S3]=svd(unfold(A, 3));
S=product(product(product(A, U', 1), V', 2), W', 3);
p=64;
q=64;
p=[32 48 64];
q=[32 48 64];
ind2=0;
postoci=zeros(3,3,16);
for m=1:size(p,2)
    for n=1:size(q,2)
        
U_p=U(:,1:p(m));
V_q=V(:,1:q(n));
F=product(S(1:p(m), 1:q(n), :), W, 3);
%F je reducirani tenzor

F_mi=cell(1,10);
UB=cell(1,10);
B=cell(1,10);
BT=cell(1,10);
SF=cell(1,10);
for k=1:p(m)
    %k=p/2; %k=p/2 zasad najbolji 
    ind2=ind2+1;
for i=0:9
   F_mi{i+1}=F(:,:,i+1); 
   [UB{i+1}, SF{i+1}]=svd(F_mi{i+1}); %economy size
   B{i+1}=UB{i+1}(:,1:k);
   BT{i+1}=UB{i+1}(:, k+1:p(m));
   %trebali bi bit velicine pxk, oni razapinju dominantni k-dim potprostor
   %od F-mi
end


%test faza
%rez - rezultati

for j=1:size(testzip,2)
   d=testzip(:,j); %j-ta znamenka u test podacima, nju klasificiramo
   %njena niskodim reprezentacija je d_p
   d_p=U_p'*d;
   res=zeros(1,10);
   for i=0:9
       %racunamo reziduale za pojedinu klasu
       res(i+1)=norm(d_p-B{i+1}*B{i+1}'*d_p);
   end
   
   [mini, minind]=min(res);
   rez(j)=minind-1;
end

clear usporedi
usporedi(:,1)=rez';
usporedi(:,2)=dtest';

postotak(k)=sum(usporedi(:,1)==usporedi(:,2))/size(testzip,2);
postoci(m,n,k)=postotak(k);
end
[maxi, maxind]=max(postotak);
naj_ind(m,n)=maxind;
naj_post(m, n)=maxi; %najbolji postotci


    end
    
end
