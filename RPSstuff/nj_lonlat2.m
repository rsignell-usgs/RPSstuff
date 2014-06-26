function [lon,lat]=nj_lonlat(ncRef,var);
% NJ_LONLAT  find longitude and latitude variables
% [lon,lat]=nj_lonlat(fname,var);
%    Inputs: fname = file name, url, or netcdf file object
%            var   = variable name (e.g. 'U10')
%         idouble  = [0] default, [1] convert output to double
%    Output: lon   = longitude array corresponding to "var"
%            lat   = latitude array corresponding to "var"

% import the NetCDF-Java methods we need for this example

% Rich Signell (rsignell@usgs.gov);

if nargin < 2, help(mfilename), return, end

isNcRef=0;
try
    if (isa(ncRef, 'ncgeodataset')) %check for ncgeodataset Object
        nc = ncRef;
        isNcRef=1;
    else
        % open CF-compliant NetCDF File as a Common Data Model (CDM) "Grid Dataset"
        nc = ncgeodataset(ncRef);
    end
    
    geogrid = getGeoGridVar(nc, var); %get geo grid
    % get the grid coordinates object associated with the grid
    coordSys = getCoordSys(geogrid);
    % get coordinate axes
    lat=coordSys.getLatAxis();
    lon=coordSys.getLonAxis();
    if (~isNcRef)
        nc.close();
    end
catch
    %gets the last error generated
    err = lasterror();
    disp(err.message);
end
