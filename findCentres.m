function [x,y] = findCentres(J_final)

s  = regionprops(J_final, 'centroid');
centroids = cat(1, s.Centroid);

x = centroids(:,1);
y = centroids(:,2);  



end

