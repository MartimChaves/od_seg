function [readyToFindCircles] = closeThinFill(preJ_Norm,thresh,seSize)

fresh = imbinarize(preJ_Norm,thresh);
SE = strel('disk',seSize);
closed = imclose(fresh,SE);
J_aC_t=bwmorph(closed,'thin',Inf);
J_edge_filled = imfill(J_aC_t,'holes');
readyToFindCircles = imopen(J_edge_filled,SE);


end

