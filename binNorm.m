function [J_N_b_neg] = binNorm(J_Norm)

J_Norm_bin = imbinarize(J_Norm,0.01);
J_N_b_neg = imcomplement(J_Norm_bin);

end

