function []=grid2mirone(d,g);
% GRID2MIRONE passes data and a grid obtained from "nj_subsetGrid" to Mirone
% Usage: grid2mirone(d,g)
%   where d = data
%         g = sure containing g.lon and g.lat
% Example: uri='http://geoport.whoi.edu/thredds/dodsC/bathy/crm_vol1.nc';
%          [d,g]=nj_subsetGrid(uri,'topo',[-71.0 -70.1 41.2 41.7]);
%          grid2mirone(d,g);
s.geog=1;  % 1=geographic, 0=other coords
g.lon = double(g.lon);        g.lat = double(g.lat);
d = single(d);
s.head=[min(g.lon(:)) max(g.lon(:)) min(g.lat(:)) max(g.lat(:)) min(d(:)) max(d(:)) 0 abs(diff(g.lon(1:2))) abs(diff(g.lat(1:2)))];
s.head= double(s.head);
if g.lat(1) > g.lat(end),
  d=flipud(d);
  g.lat=flipud(g.lat(:));
end
s.X=g.lon;
s.Y=g.lat;
mirone(d,s)