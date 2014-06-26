%GINPUT_IJ find i,j points clicked on map
function [lon,lat,ii,jj]=ginput_ij(grid);
[x,y]=ginput;
for i=1:length(x);
   ind=nearxy(grid.lon(:),grid.lat(:),x(i),y(i));
   [jj(i),ii(i)]=ind2ij(grid.lon,ind);
   lon(i)=grid.lon(jj(i),ii(i));
   lat(i)=grid.lat(jj(i),ii(i));
end