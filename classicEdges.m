function [outputImg] = classicEdges(J_Norm,values)

J_test = imadjust(J_Norm,[values(1) values(2)],[values(3) values(4)],values(5));   %J_test is J_Norm

J_bw = imbinarize(J_test,graythresh(J_test));

J_edge = edge(J_bw,'canny');

Jsize = size(J_edge);
killThreshX = round(Jsize(1,1)*0.97);

newJ_edge = J_edge;
newJ_edge(killThreshX:end,:) = 0; %remove bottom line

C = corner(newJ_edge);
newJ_edge(C) = 0;

outputImg = newJ_edge;


end

