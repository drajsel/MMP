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

% %filtriranje podataka, blurring
% h=fspecial('gaussian', [-1 1], 0.9);
% 
% for i=1:10
%     for j=1:max_size
%         A{i}(:,:,j)=imfilter(A{i}(:,:,j),h,'same');
%     end
% end
