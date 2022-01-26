function [processedImage] = intialProcessing(smV,sizeAv,sizeM)

avrg = fspecial('average',sizeAv);

imgForProcessing = imfilter(smV,avrg);

f = ordfilt2(imgForProcessing,round((sizeM.^2)/2),ones(sizeM,sizeM));

J = entropyfilt(f);

maxJ = max(J(:));
J_1 = J./maxJ;

processedImage = J_1;

end

