function [Hue] = myHue(Img)
%myHue - calculates Img (a double) hue
%throguht formula

%separation of colour layers
R=Img(:,:,1);
G=Img(:,:,2);
B=Img(:,:,3);

%Hue
numi=1/2*((R-G)+(R-B));
denom=((R-G).^2+((R-B).*(G-B))).^0.5;

%To avoid dividind by zero we add a small value to denom
H=acosd(numi./(denom+0.000001)); %acos -> arcosine in degrees

%If B>G then H= 360-Theta
H(B>G)=360-H(B>G);

%Normalize to the range [0 1]
H=H/360;

%Result
Hue = H;

end

