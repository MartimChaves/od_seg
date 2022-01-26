%% testing functions
clearvars -except eye_rgb name ODs distance failed;
disp('variables cleared')

%% Reading Images
disp('started reading images')
eye_rgb=cell(1,50); % Original images for display
name=num2str([1:50].','IDRiD_%03d.jpg'); % Variable of image file names
for i=1:50
   eye_rgb{i}= im2double(imread(name(i,:)));
end
disp('images read')

%% Reading Excel for manual center reference
disp('started reading center info')
data = xlsread('OD_Fovea_CenterCoordinates.xlsx'); % Importing data from excel
% Redefining variables
x_OD=data(:,1);  y_OD=data(:,2); 
x_Fo=data(:,3);  y_Fo=data(:,4);

ODs = zeros(50,2);

for c = 1:50
  ODs(c,1) = (x_OD(c));
  ODs(c,2) = (y_OD(c));
end

distance = zeros(50,3);
disp('DO center read')

%% DacoTest - 07/11/2019
clear all;
clc;
img = imread('IDRiD_02.jpg');
Img = im2double(img);
Img_r = imresize(Img,0.25);
Img = imadjust(Img_r,[0.1 1],[0 1],1); %removes background from zeros
Hue = myHue(Img); %Works!!

values = [0.2 1 0 1 7];
IV = intenseVessels(Hue,values); %Works!!

%imshow(Img_r)
%imshow(Img)
%imshow(Hue)
%imshow(IV)

highCon = adapthisteq(Img(:,:,2));

kern = strel('square',5);

closeImg = imerode(highCon,kern);

botHat = closeImg - highCon;

imshow(botHat)


%% 
% NN = 50;
% name=num2str((1:NN).','Task1_2_%02d.tif');
for number = 1:50
    clear A;
    A = eye_rgb{number};
    Img = im2double(A);
    Img = imresize(Img,0.25);
    Img = imadjust(Img,[0.1 1],[0 1],1); %removes background from zeros

    Hue = myHue(Img); %Works!!

    values = [0.2 1 0 1 7];
    IV = intenseVessels(Hue,values); %Works!!

    smVessels = smoothVessels(Img,IV,0.15); %Works!!

    pI = intialProcessing(smVessels,7,23); %Works!! - pI = J_1

    J_Norm = minimumEntropy(pI,9); %Works!!

    detect1 = closeThinFill(pI,0.6,5); %Works!!

    valuesEdge = [0 1 0 1 3.5];
    edge = classicEdges(J_Norm,valuesEdge); %Works!!
    J_edge_filled = imfill(edge,'holes');

    %values here
    circularity = 0.92;
    Area = 5000;

    disp('phase1')
    thisCirc = circularity;
    thisArea = Area;
    count = 0;
    countIn = 0;
    flag = 2;
    while (flag~=1 && count< 30)
        
        if (thisCirc < 0.95)
            thisCirc = thisCirc + 0.04;
        elseif (thisCirc > 0.99)
            thisCirc = thisCirc - 0.1;
        end

        [Final,flag]=myRegions(J_edge_filled,thisCirc,thisArea);
        
        if (flag == 0)
            countIn = 0;
            while (flag<1 && countIn<20)
                
                [Final,flag]=myRegions(J_edge_filled,thisCirc,thisArea);
                
                if (thisCirc > 0.75)
                    thisCirc = thisCirc - 0.03;
                end
                countIn = countIn + 1;
            end
        end
        count = count + 1;
    end

    disp('phase2')
    %***binNorm
    count = 0;
    countIn = 0;
    otherFill = binNorm(J_Norm);
    flagNorm = 2;
    thisCircN = circularity;
    thisAreaN = Area;
    while (flagNorm~=1 && count < 30)
        
        if (thisCircN < 0.95)
            thisCircN = thisCircN + 0.04;
        elseif (thisCircN > 0.99)
            thisCircN = thisCircN - 0.1;
        end
        
        [Fnorm,flagNorm]=myRegions(otherFill,thisCircN,thisAreaN);
        
        if (flagNorm == 0)
            countIn = 0;
            while (flagNorm<1 && countIn < 20)
                
                [Fnorm,flagNorm]=myRegions(otherFill,thisCirc,thisAreaN);
                
                if (thisCircN > 0.75)
                    thisCircN = thisCircN - 0.03;
                end
                
                countIn = countIn+ 1;
            end
        end
        
        count = count + 1;
    end

    %detect1
    disp('phase 3')
    count = 0;
    countIn = 0;
    flagDetect = 2;
    thisCircD = circularity;
    thisAreaD = Area;
    while (flagDetect~=1 && count < 30)
        %disp('c')
        
        if (thisCircD < 0.95)
            thisCircD = thisCircD + 0.04;
        elseif (thisCircD > 0.99)
            thisCircD = thisCircD - 0.1;
        end
        
        [finDetect, flagDetect] = myRegions(detect1,thisCircD,thisAreaD);
        
        if (flagDetect == 0)
            countIn = 0;
            while (flagDetect<1 && countIn < 20)
                %disp('c.1')
                %thisCirc = circularity;
                %thisArea = Area;
                [finDetect, flagDetect] = myRegions(detect1,thisCircD,thisAreaD);
                
                if (thisCircD > 0.75)
                    thisCircD = thisCircD - 0.03;
                end
                
                countIn = countIn+ 1;
            end
        end
        
        count = count + 1;
    end
    
    SE_f = strel('disk',3);
    R_bw = imbinarize(Img(:,:,1),0.98);
    R_J = imopen(R_bw,SE_f);
    [redOn, flag4Red] = myRegions(R_J,0.7,Area);

    x = 0;
    y = 0;
    x1 = 0;
    y1 = 0;
    x2 = 0;
    y2 = 0;

    disp('phase4')
    
    circDemand = 0.9;
    circCount = 0;
    classic = false;
    Norm = false;
    Detect = false;
    
    while (circDemand > 0.76 && circCount < 2)
        if(flag == 1 && thisCirc > circDemand)
            [x,y] = findCentres(Final); %flag
            classic = true;
            circCount = circCount + 1;
        end

        if (flagNorm == 1 && thisCircN > circDemand)
            [x1,y1] = findCentres(Fnorm); %flagNorm
            Norm = true;
            circCount = circCount + 1;
        end

        if (flagDetect == 1 && thisCircD > circDemand)
            [x2,y2] = findCentres(finDetect); %flagDetect
            Detect = true;
            circCount = circCount + 1;
        end
        circDemand = circDemand - 0.03;
    end
    
    if(classic)
        [x,y] = findCentres(Final); %flagccc
    else
        saveF_final = flag;
        flag = 0;
    end

    if (Norm)
        [x1,y1] = findCentres(Fnorm); %flagNorm
    else
        saveF_Norm = flagNorm;
        flagNorm = 0;
    end

    if (Detect)
        [x2,y2] = findCentres(finDetect); %flagDetect
    else
        saveF_detect = flagDetect;
        flagDetect = 0;
    end

    bigFail = 0;

    if (flagNorm == 1 && flag == 1 && flagDetect == 1)
        xf = (x+x1+x2)/3;
        yf = (y+y1+y2)/3;
    elseif (flagNorm == 1 && flag == 1 && flagDetect ~= 1)
        xf = (x+x1)/2;
        yf = (y+y1)/2;
    elseif (flagNorm == 1 && flagDetect == 1 && flag ~= 1)
        xf = (x2+x1)/2;
        yf = (y2+y1)/2;
    elseif (flag == 1 && flagDetect == 1 && flagNorm ~= 1)
        xf = (x+x2)/2;
        yf = (y+y2)/2;
    elseif (flagNorm == 1 && flag ~= 1 && flagDetect ~= 1)
        xf = x1;
        yf = y1;
    elseif (flagNorm ~= 1 && flag == 1 && flagDetect ~= 1)
        xf = x;
        yf = y;
    elseif (flagNorm ~= 1 && flag ~= 1 && flagDetect == 1)
        xf = x2;
        yf = y2;
    else
        if (flag4Red == 1)
            [xf,yf] = findCentres(redOn);
        else
            xf = 10;
            yf = 10;
            bigFail = 1;
        end
        
    end

%     figure,imshow(A);
%     hold on
%     plot(xf/0.25, yf/0.25, 'b*', ODs(number,1),ODs(number,2), 'r*');
%     hold off
    
    if (bigFail ~= 1)
        distanceSingular = sqrt(((ODs(number,1)-(xf/0.25))^2)+((ODs(number,2)-(yf/0.25))^2));
        distance(number,1) = xf/0.25;
        distance(number,2) = yf/0.25;
        distance(number,3) = distanceSingular;
    else
        distance(number,1) = 0;
        distance(number,2) = 0;
        distance(number,3) = 3000;
    end

%     FIG=figure(number);
%     imshow(eye_rgb{number}); hold on
%     plot(xf/0.25,yf/0.25,'kx', 'LineWidth', 2, 'MarkerSize', 12);
%     plot(ODs(number,1),ODs(number,2), 'gx', 'LineWidth', 2, 'MarkerSize', 12);
%     saveas(FIG,name(number,:),'tif') %saving images

    disp('Operation done')
    disp(number)
end

disp('finished')




