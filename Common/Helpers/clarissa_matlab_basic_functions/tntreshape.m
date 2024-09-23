function data0 = tntreshape(Ms, Nro, Necho)

temp2 = reshape(Ms,Nro*Necho,'');
temp3 = reshape(Ms, Nro,Necho,'');
data0 = permute(temp3,[ 2 1 3 ]);
% Ms_reorder_pos = data0;