function []=write_coast_cf(ncfile,coast)
% WRITE_COAST: Writes 2D coast/bathy data to CF-compliant NetCDF file
% works with 1D or 2D lon/lat coordinates
% Usage: write_coast_cf(ncfile,z,lon,lat);
%         ncfile = name of netcdf file for output
%         lon = longitude (west negative)
%         lat = latitude (north positive)
%         z = z dependent variable (coast grid, bathy grid)
% Note: make sure that "imagesc(lon,lat,z);axis xy"
% displays the grid correctly before writing to NetCDF

% Rich Signell (rsignell@usgs.gov)
[nc,two]=size(coast);
if two~=2,
  error('not a coast variable: must be lon,lat');
end
ind=find(isnan(coast));
missval=-9999.99;
coast(ind)=missval;
% create file
ncid = netcdf.create(ncfile,'CLOBBER');
% define dimensions, variables, and attributes
dimID = netcdf.defDim(ncid,'ncoast',nc);
lat_ID = netcdf.defVar(ncid,'lat','double',dimID);
netcdf.putAtt(ncid,lat_ID,'units','degree_north');
netcdf.putAtt(ncid,lat_ID,'missing_value',missval);
lon_ID = netcdf.defVar(ncid,'lon','double',dimID);
netcdf.putAtt(ncid,lon_ID,'missing_value',missval);
netcdf.putAtt(ncid,lon_ID,'units','degree_east');
gid=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,gid,'Conventions','COARDS');
netcdf.endDef(ncid);
% write data
netcdf.putVar(ncid,lon_ID,0,nc,coast(:,1));
netcdf.putVar(ncid,lat_ID,0,nc,coast(:,2));
% close
netcdf.close(ncid)