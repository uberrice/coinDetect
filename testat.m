clear all;
Image = imread('Muenzen.png'); %read the image
if size(Image,3) == 3
    %in case it is a color image
    Image = rgb2gray(Image);
end


%plot it
figure(1)
subplot(1,2,1)
imshow(Image)
title('original image');

%Put Median filter over it to smooth over reflections
ImageMedian = ordfilt2(Image, 5, ones(6,6));


imshow(ImageMedian)
level = graythresh(ImageMedian);
BW = imbinarize(ImageMedian,level+0.1);
%Turn dark recognized coins into light ones that are used as arguments for
%regionprops
BW = imcomplement(BW);


Prop = regionprops(BW,'Area','Centroid', 'Orientation', 'BoundingBox', 'ConvexHull', 'MajorAxisLength', 'MinorAxisLength');
%Prop(1)=[];
figure(1)
subplot(1,2,2)
imshow(BW)
title('binary image');
Prop(1) = []; %remove the first property, artifact caused by smoothing filter

figure(2);
imshow(Image)
hold on;
totval = 0;
for Ind=1:size(Prop,1) 
    
    %Make crosses
    Cent=Prop(Ind).Centroid;   
    X=Cent(1);Y=Cent(2);
    %make a cross
    line([X-10 X+10], [Y Y],'LineWidth',1,'Color',[1 0 0]);
    line([X X], [Y-10 Y+10],'LineWidth',1,'Color',[1 0 0]);
    %End Make crosses
    
    %Make Circles around objects
    centers = Prop(Ind).Centroid;
    diameters = (Prop(Ind).MajorAxisLength+Prop(Ind).MinorAxisLength)/2;
    radius = diameters/2;
    radiuses(Ind)=radius; %for plotting occurrences
    Prop(Ind).radius = radius; %save radius as new property
    viscircles(centers,radius); 
    %end of making circles
    
    %make bounding boxes
    rectangle('Position', Prop(Ind).BoundingBox, 'EdgeColor',[0 1 0]);
    %end making bounding boxes
    
    if radius > 100 %too big
        Prop(Ind).CoinValue = 0; %no coin
    elseif radius > 70
        Prop(Ind).CoinValue = 5; %5 Francs
    elseif radius > 60
        Prop(Ind).CoinValue = 2; %2 Francs
    elseif radius > 54
        Prop(Ind).CoinValue = 1; %1 Franc
    elseif radius > 47
        Prop(Ind).CoinValue = 0.2; %20 Rappen
    elseif radius > 40
        Prop(Ind).CoinValue = 0.5; %50 Rappen
    else
        Prop(Ind).CoinValue = 0; %no coin
    end
    text(X+50,Y, sprintf('Value = %0.2f Fr', Prop(Ind).CoinValue), 'BackgroundColor',[.8 .8 .8]);  %add coin value label to the coin
    totval = totval + Prop(Ind).CoinValue; %add coin value to total
end
text(50,50, sprintf('Total Value = %0.2f Fr', totval), 'BackgroundColor',[.8 .8 .8]); %show label depicting total value
hold off;
figure(3);
radiSize = size(radiuses);
radiSize = radiSize(1);
plot(radiuses,ones(radiSize,1),'o'); %plots all the occurrences of coin sizes for manual classification; maybe implement something like otsu in the future