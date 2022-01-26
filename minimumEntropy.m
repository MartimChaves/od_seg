function [filteredMin] = minimumEntropy(entropy,sizeMin)

filteredMin = ordfilt2(entropy,1,ones(sizeMin,sizeMin)); 

end

