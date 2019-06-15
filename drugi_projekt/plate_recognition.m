%detekcija registarske plocice sa slike
clc;    % Clear command window.
clear;  % Delete all variables.
close all;  % Close all figure windows except those created by imtool.
imtool close all;   % Close all figure windows created by imtool.
workspace;  % Make sure the workspace panel is showing.
 
% Read Image
 I = imread('test3.jpg');
 
figure(1);
imshow(I);
title('Original Image');
 
% Extract Y component (Convert an Image to Gray)
Igray = rgb2gray(I);
figure(2);
imshow(Igray);
title('Grayscale Image');

 
[rows cols] = size(Igray);
 
%% Dilate and Erode Image in order to remove noise
Idilate = Igray;
for i = 1:rows
    for j = 2:cols-1
        temp = max(Igray(i,j-1), Igray(i,j));
        Idilate(i,j) = max(temp, Igray(i,j+1));
    end
end
 
I = Idilate;
figure(3); 
title('Dilated Image')
imshow(Idilate);
 
 
difference = 0;
suma = 0;
total_suma = 0;
difference = uint32(difference);
 
%% PROCESS EDGES IN HORIZONTAL DIRECTION
disp('Processing Edges Horizontally...');
max_horz = 0;
maximum = 0;
for i = 2:cols
    suma = 0;
    for j = 2:rows    
        if(I(j, i) > I(j-1, i))
            difference = uint32(I(j, i) - I(j-1, i));
        else
            difference = uint32(I(j-1, i) - I(j, i));
        end 
        
        if(difference > 20)
            suma = suma + difference;
        end
    end
    horz1(i) = suma;
    
    % Find Peak Value
    if(suma > maximum)
        max_horz = i;
        maximum = suma;
    end
      
    total_suma = total_suma + suma;
end
average = total_suma / cols;
 
figure(5);
% Plot the Histogram for analysis
subplot(3,1,1);
plot (horz1);
title('Horizontal Edge Processing Histogram');
xlabel('Column Number ->');
ylabel('Difference ->');
 
%% Smoothen the Horizontal Histogram by applying Low Pass Filter
disp('Passing Horizontal Histogram through Low Pass Filter...');
suma= 0;
horz = horz1;
for i = 21:(cols-21)
    suma = 0;
    for j = (i-20):(i+20)
        suma = suma + horz1(j);
    end
    horz(i) = suma / 41;
end
 
subplot(3,1,2);
plot (horz);
title('Histogram after passing through Low Pass Filter');
xlabel('Column Number ->');
ylabel('Difference ->');
 
%% Filter out Horizontal Histogram Values by applying Dynamic Threshold
disp('Filter out Horizontal Histogram...');
for i = 1:cols
    if(horz(i) < average)
        horz(i) = 0;
        for j = 1:rows
            I(j, i) = 0;
        end
    end
end
 
subplot(3,1,3);
plot (horz);
title('Histogram after Filtering');
xlabel('Column Number ->');
ylabel('Difference ->');
 
%% PROCESS EDGES IN VERTICAL DIRECTION
difference = 0;
total_suma = 0;
difference = uint32(difference);
 
disp('Processing Edges Vertically...');
maximum = 0;
max_vert = 0;
for i = 2:rows
    suma = 0;
    for j = 2:cols          %cols
        if(I(i, j) > I(i, j-1))
            difference = uint32(I(i, j) - I(i, j-1));
        end
        if(I(i, j) <= I(i, j-1))
           difference = uint32(I(i, j-1) - I(i, j));
        end 
        
        if(difference > 20)
            suma = suma + difference;
        end
    end
    vert1(i) = suma;
    
    %% Find Peak in Vertical Histogram
    if(suma > maximum)
        max_vert = i;
        maximum = suma;
    end
    total_suma = total_suma + suma;
end
average = total_suma / rows;
 
figure(6)
subplot(3,1,1);
plot (vert1);
title('Vertical Edge Processing Histogram');
xlabel('Row Number ->');
ylabel('Difference ->');
 
%% Smoothen the Vertical Histogram by applying Low Pass Filter
disp('Passing Vertical Histogram through Low Pass Filter...');
suma = 0;
vert = vert1;
 
for i = 21:(rows-21)
    suma = 0;
    for j = (i-20):(i+20)
        suma = suma + vert1(j);
    end
    vert(i) = suma / 41;
end
 
subplot(3,1,2);
plot (vert);
title('Histogram after passing through Low Pass Filter');
xlabel('Row Number ->');
ylabel('Difference ->');
 
%% Filter out Vertical Histogram Values by applying Dynamic Threshold
disp('Filter out Vertical Histogram...');
for i = 1:rows
    if(vert(i) < average)
        vert(i) = 0;
        for j = 1:cols
            I(i, j) = 0;
        end
    end
end
 
subplot(3,1,3);
plot (vert);
title('Histogram after Filtering');
xlabel('Row Number ->');
ylabel('Difference ->');
 
figure(7), imshow(I);
 
%% Find Probable candidates for Number Plate
j = 1;
for i = 2:cols-2
    if(horz(i) ~= 0 && horz(i-1) == 0 && horz(i+1) == 0)
        column(j) = i;
        column(j+1) = i;
        j = j + 2;
    elseif((horz(i) ~= 0 && horz(i-1) == 0) || (horz(i) ~= 0 && horz(i+1) == 0))
        column(j) = i;
        j = j+1;
    end
end
 
j = 1;
for i = 2:rows-2
    if(vert(i) ~= 0 && vert(i-1) == 0 && vert(i+1) == 0)
        row(j) = i;
        row(j+1) = i;    
        j = j + 2;
    elseif((vert(i) ~= 0 && vert(i-1) == 0) || (vert(i) ~= 0 && vert(i+1) == 0))
        row(j) = i;
        j = j+1;
    end
end
 
[temp column_size] = size (column);
if(mod(column_size, 2))
    column(column_size+1) = cols;
end    
 
[temp row_size] = size (row);
if(mod(row_size, 2))
    row(row_size+1) = rows;
end    

%% Region of Interest Extraction
%Check each probable candidate
for i = 1:2:row_size
     for j = 1:2:column_size
         
            % If it is not the most probable region remove it from image
            if(~((max_horz >= column(j) && max_horz <= column(j+1)) && (max_vert >= row(i) && max_vert <= row(i+1))))
                
                %This loop is only for displaying proper output to User
                for m = row(i):row(i+1)
                    for n = column(j):column(j+1)
                        I(m, n) = 0;
                    end
                end
            end
    end
end
 
figure(8), imshow(I);

binaryImage = I > 0;
labeledImage = bwlabel(binaryImage);
measurements = regionprops(labeledImage, 'BoundingBox');
bb = [measurements.BoundingBox];
% Put up red rectangle
hold on;
rectangle('Position', bb, 'EdgeColor', 'r');
% Crop
croppedImage = imcrop(I, bb);
hold off;
% 
% %% Daljnje izdvajanje plocice i slova
% J=I;
% regions = regionprops(J, 'BoundingBox');
% 
% 
% regionsCount = size(regions, 1) ;
% 
% 
% for i = 1:regionsCount
%     region = regions(i);
%     RectangleOfChoice = region.BoundingBox;
% %    PlateExtent = region.Extent;
%     
%     PlateStartX = fix(RectangleOfChoice(1));
%     PlateStartY = fix(RectangleOfChoice(2));
%     PlateWidth  = fix(RectangleOfChoice(3));
%     PlateHeight = fix(RectangleOfChoice(4));
%         
%     if PlateWidth/PlateHeight >= 2 && PlateWidth/PlateHeight <=3 && PlateHeight> 15 & PlateWidth>50
%         im2 = imcrop(J, RectangleOfChoice);       
%         figure(9), imshow(im2);
%         imwrite(im2,'outPlate.jpg')
%         break;
%     end
% end
im2=I;
im2=im2bw(im2,0.5);
im2=~im2;
figure(10),imshow(im2);

%% izdvajanje znamenki i prepoznavanje pomocu hosvd-a
load training_tensor.mat
load baza3.mat

% im2=I;

stats=regionprops(im2);
statsCount = size(stats, 1) ;

f_output=fopen('RegistarskaOznaka.txt','wt');
broj_znakova=0;
znakovi=cell(1,7); % bit ce 7 ili 8 znakova na hrv tablicama
for i = 1:statsCount
    region = stats(i);
    RectangleOfChoice = region.BoundingBox;
    
    CharStartX = fix(RectangleOfChoice(1));
    CharStartY = fix(RectangleOfChoice(2));
    CharWidth  = fix(RectangleOfChoice(3));
    CharHeight = fix(RectangleOfChoice(4));
        
%     if CharWidth <= 0.7*CharHeight && CharWidth>5 && CharHeight>10
  if CharHeight/CharWidth <= 2.5 && CharHeight/CharWidth >=1 && CharWidth>10 && CharHeight>18
%         if CharWidth>10 && CharHeight>10
            broj_znakova=broj_znakova+1;
        char3 = imcrop(im2, RectangleOfChoice); 
        figure(10+i);
        imshow(char3);
        dil=imdilate(char3,strel('disk',1));
        znakovi{1,broj_znakova}=dil;
%         [ind,aprox,znak]=test_znam2(dil, 10, A, B, ime_znaka, f_output);
%         znak
    end
end

%sad prolazimo po znakovima po redu i u ovisnosti o tome gdje se nalaze
%znamo da li je broj ili slovo

%prvi slucaj - 7 znakova
%tada su prva dva slova i onda imamo 3 broja i onda 2 slova
%drugi sluca - 8 znakova
%prva dva su slova, sljedeca 4 broja i onda 2 slova


pocetak=11;
kraj=35;
for i=1:2 %znamo da su prva dva slova
       [ind,aprox,znak]=test_znam_ind(znakovi{1,i}, 10, A, B, ime_znaka, f_output, pocetak, kraj);
end

if size(znakovi,2)==7 
    kraj_petlje2=5;
else kraj_petlje2=6;
end

pocetak=1;
kraj=10;
    
for i=3:kraj_petlje2
    [ind,aprox,znak]=test_znam_ind(znakovi{1,i}, 10, A, B, ime_znaka, f_output, pocetak, kraj);
end

pocetak=11;
kraj=35;
    
for i=(kraj_petlje2+1):size(znakovi,2) %znamo da su zadnja dva slova
       [ind,aprox,znak]=test_znam_ind(znakovi{1,i}, 10, A, B, ime_znaka, f_output, pocetak, kraj);
end
        
system('notepad C:\Users\Dorotea\Desktop\mmp_sem2\RegistarskaOznaka.txt');
