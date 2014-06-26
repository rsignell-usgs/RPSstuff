function [lon,lat,z,url]=read_srtm30plus(lon_range,lat_range,res,iplot);
% READ_SRTM30PLUS  Read SRTM30+ ~1km) World topo/bathy into Matlab via WMS
% Usage:   [lon,lat,depth]=read_srtm30plus(lon_range,lat_range,res,iplot);
%  Inputs: lon_range=[lon_min lon_max] (decimal degrees, east positive)
%          lat_range=[lat_min lat_max] (decimal degrees, north positive)
%          res = optional resolution of requested grid (arc seconds) [default=30]
%          iplot = option to control plot. (1 for plot) [default=0]
%          
%  Outputs:lon = vector of longitudes
%          lat = vector of latitudes
%          z  = topography/bathymetry in meters (up positive)
%               NOTE: SRTM30+ data are integers, therefore flat shallow
%               areas will have a stair-step behavior, and gentle sloping
%               coastal areas will have poorly defined coastlines (z=0).
%          url = the url sent to the WMS
%
%  Examples: [lon,lat,z]=read_srtm30plus([10 20],[40 46],30,1); 
%               Reads and plots 30" topo/bathy for the Adriatic Sea
%
%            [lon,lat,z,url]=read_srtm30plus([-71 -65],[40 46],60);
%               Reads topo/bathy averaged to 60" for the Gulf of Maine (no
%             plot)

% Full SRTM30PLUS info:  http://topex.ucsd.edu/WWW_html/srtm30_plus.html
% Requires NCTOOLBOX (http://nctoolbox.github.io/nctoolbox/)
% Rich Signell (rsignell@usgs.gov)

if(nargin<3);iplot=0;res=30;end
if(nargin<4);iplot=0;end
if(nargin>4);help read_srtm30plus;end
isub = round(res/30);
url='http://geoport.whoi.edu/thredds/dodsC/bathy/srtm30plus_v1.nc';
nc=ncgeodataset(url);
topovar=nc.geovariable('topo');
s.lon=lon_range;
s.lat=lat_range;
s.h_stride=[isub isub];  
g=topovar.geosubset(s);
lon = g.grid.lon;
lat = g.grid.lat;
z = g.data;
if iplot
  imagesc(lon,lat,z);axis('xy');colorbar
  xfac=cos(mean(lat(:))*pi/180);set(gca,'DataAspectRatio', [1 xfac 1] );
  if(max(z(:))*min(z(:))<0),
    hold on;
    contour(lon,lat,z,[0 0],'k-');
    hold off;
    title('SRTM30+ World Topo/Bathy');
  end
end