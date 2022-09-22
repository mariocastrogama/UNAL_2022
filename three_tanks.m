function [dCdt]=three_tanks(t,C,E)
  E12 = E(1);
  E13 = E(2);
  V  = [10; 8; 5];
  Q = 4;
  A  = [-(Q+E12+E13), +E12, +E13;
                +E12, -E12,  0.0;
                +E13,  0.0, -E13];
  dCdt = (A*C)./V;
  
end
