% get CONUS ASCII data file from GEOID03 web site
% http://www.ngs.noaa.gov/PC_PROD/GEOID03/
% system('wget http://www.ngs.noaa.gov/PC_PROD/GEOID03/geoid03_conus.asc.gz')
% system('wget http://www.ngs.noaa.gov/PC_PROD/GEOID09/Format_ascii/GEOID09_conus.asc.gz');

% Rich Signell (rsignell@usgs.gov)

fid=fopen('c:/rps/geoid/geoid09_conus.asc','rt');  
C=textscan(fid,'%f',4);
lat0=C{1}(1);
lon0=C{1}(2)-360;
dlat=C{1}(3);
dlon=C{1}(4);

C=textscan(fid,'%d',3);
nlat=C{1}(1);
nlon=C{1}(2);
lat=lat0+double([0:(nlat-1)])*dlat;
lon=lon0+double([0:(nlon-1)])*dlon;

C=textscan(fid,'%f',nlon*nlat);
b=reshape(C{1}(:),nlon,nlat);
b=permute(b,[2 1]);
fclose(fid);
  
write_topo_cf('geoid09.nc',b,lon,lat)



