function [IV] = intenseVessels(Hue,values)

Hneg = imcomplement(Hue);
sharpVessels = imadjust(Hneg,[values(1) values(2)],[values(3) values(4)],values(5));
IV = adapthisteq(sharpVessels);

end

