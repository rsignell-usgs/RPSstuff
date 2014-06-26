function []=write_topo_cf(ncfile,z,lon,lat)
% WRITE_TOPO: Writes 2D topo/bathy data to CF-compliant NetCDF file
% works with 1D or 2D lon/lat coordinates
% Usage: write_topo_cf(ncfile,z,lon,lat);
%         ncfile = name of netcdf file for output
%         lon = longitude (west negative)
%         lat = latitude (north positive)
%         z = z dependent variable (topo grid, bathy grid)
% Note: make sure that "imagesc(lon,lat,z);axis xy" 
% displays the grid correctly before writing to NetCDF

% Rich Signell (rsignell@usgs.gov)
[ny,nx]=size(z);
% define variables
[m,n]=size(lon);
ncid = netcdf.create(ncfile,'CLOBBER');
if(min(m,n)==1),
  % lon,lat are 1D
  % define dimensions
  lat_dimID = netcdf.defDim(ncid,'lat',ny);
  lon_dimID = netcdf.defDim(ncid,'lon',nx);
  lat_ID = netcdf.defVar(ncid,'lat','double',lat_dimID);
  netcdf.putAtt(ncid,lat_ID,'units','degree_north');
  lon_ID = netcdf.defVar(ncid,'lon','double',lon_dimID);
  netcdf.putAtt(ncid,lon_ID,'units','degree_east');
  topo_ID = netcdf.defVar(ncid,'topo','float',[lon_dimID lat_dimID]);
  netcdf.putAtt(ncid,topo_ID,'units','m');
  gid=netcdf.getConstant('NC_GLOBAL');
  netcdf.putAtt(ncid,gid,'Conventions','COARDS');
  netcdf.endDef(ncid);
  netcdf.putVar(ncid,topo_ID,[0 0],[nx ny],z.');
  netcdf.putVar(ncid,lon_ID,0,nx,lon);
  netcdf.putVar(ncid,lat_ID,0,ny,lat);
else
  % lon,lat are 2D
  lat_dimID = netcdf.defDim(ncid,'y',ny);
  lon_dimID = netcdf.defDim(ncid,'x',nx);
  lat_ID = netcdf.defVar(ncid,'lat','double',[lon_dimID lat_dimID]);
  netcdf.putAtt(ncid,lat_ID,'units','degree_north');
  lon_ID = netcdf.defVar(ncid,'lon','double',[lon_dimID lat_dimID]);
  netcdf.putAtt(ncid,lon_ID,'units','degree_east');
  topo_ID = netcdf.defVar(ncid,'topo','float',[lon_dimID lat_dimID]);
  netcdf.putAtt(ncid,topo_ID,'units','m');
  gid=netcdf.getConstant('NC_GLOBAL');
  netcdf.putAtt(ncid,gid,'Conventions','CF-1.0');
  netcdf.endDef(ncid);
  netcdf.putVar(ncid,topo_ID,[0 0],[nx ny],z.');
  netcdf.putVar(ncid,lon_ID,[0 0],[nx ny],lon.');
  netcdf.putVar(ncid,lat_ID,[0 0],[nx ny],lat.');
end
netcdf.close(ncid)