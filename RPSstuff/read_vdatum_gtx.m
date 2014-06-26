function [b,lon,lat]=read_vdatum_gtx(gtxfile);
% READ_VDATUM_GTX  Read NOAA Vdatum GTX binary grid file format (.gtx)
% (reference: http://vdatum.noaa.gov/dev/gtx_info.html#dev_gtx_binary)
% Usage: [data,lon,lat]=read_vdatum_gtx(gtxfile);
% Input:  gtxfile = VDatum GTX grid file name (string), e.g. 'mllw.gtx'  
% Output: data = 2D array of data values (double)
%         lon = vector array of longitudes (double)
%         lat = vector of latitudes (real)
% Example: 
%  [data,lon,lat]=read_vdatum_gtx('c:/rps/vdatum/MENHMAgome01_8301/mllw.gtx');
%  imagesc(lon,lat,data);axis xy
%  set(gca,'DataAspectRatio',[1 cos(mean(lat(:))*pi/180) 1000]);
%  colorbar

% Rich Signell (rsignell@usgs.gov)

a=fopen(gtxfile,'r','ieee-be');  % java binary is big-endian
% read corner and increment lon,lat values as double 
b=fread(a,4,'float64'); % read 4 lat/lon vals as double
lat0=b(1);
lon0=b(2);
dlat=b(3);
dlon=b(4);

% read nlon,nlat array size values as integer
b=fread(a,2,'int'); 
nlat=b(1); % number of lon/rows
nlon=b(2); % number of lat/columns

lat=lat0+[0:nlat-1]*dlat;
lon=lon0+[0:nlon-1]*dlon;

% read data array as float
b=fread(a,[nlon,nlat],'float32');
fclose(a);
b=permute(b,[2 1]);

% null values are supposed to be -88.8888, but they turn out to be 
% numbers like -88.8888015747, so we have to look within a tolerance: 
b(b>-88.8889&b<-88.8887)=nan; 

