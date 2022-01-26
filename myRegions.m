function [J_final,flag] = myRegions(J_edge_filled,circ,area)

CC = bwconncomp(J_edge_filled);
stats = regionprops(CC,'Area','Eccentricity','Perimeter','Extent');
allArea = [stats.Area];
allPerimeter = [stats.Perimeter];
circularity = (4*3.14159265).*(allArea./(allPerimeter.^2));

idx = find(circularity > circ & [stats.Area]>area & [stats.Area]< 50000 & [stats.Extent] > 0.5 & [stats.Eccentricity] < 0.65);
J_final = ismember(labelmatrix(CC),idx);

quality = size(idx);

if(isempty(idx))
    flag = 0;
elseif (quality(1,2) == 1)
    flag = 1;
elseif (quality(1,2)>1)
    flag = 2;
end    

end

