function [jj,ii]=lonlat2ij(lon,lat,ax);
%LONLAT2IJ finds the i,j range corresponding to a lon/lat bounding box
% Usage: [jj,ii]=lonlat2ij(lon,lat,ax);
%  where  lon = 2D matrix of longitude
%         lat = 2D matrix of latitude
%          ax = [lon_min lon_max lat_min lat_max];
%
%  example:
%  url='http://coast-enviro.er.usgs.gov/models/test/bora_feb.nc';
%  nc=mDataset(url);
%  [h,g]=nj_tslice(nc,'h');
%  ax=[ 16.2401   18.8301   40.6848   42.9558];
%  [jj,ii]=lonlat2ij(g.lon,g.lat,ax);
%  h2=nc{'h'}(jj,ii);
%  g2=nc{'h'}(jj,ii).grid;
%  close(nc);
%  figure(1); pcolorjw(g.lon,g.lat,h);axis(ax);
%  figure(2); pcolorjw(g2.lon,g2.lat,h2);axis(ax);


box_x=[ax(1) ax(1) ax(2) ax(2) ax(1)];
box_y=[ax(3) ax(4) ax(4) ax(3) ax(3)];
ind=find(insider(lon(:),lat(:),box_x(:),box_y(:)));
if isempty(ind),
 disp('no points found inside box');
 jj=[];ii=[];return
end
[jj,ii]=ind2ij(lon,ind);
ii=min(ii(:)):max(ii(:));
jj=min(jj(:)):max(jj(:));
