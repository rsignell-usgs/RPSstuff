function dat=nj_tseries4d(uri,var,loni,lati,method,layer,irange);
% nj_tseries4d  interpolate time series at lon,lat points from CF-compliant NetCDF file
%
% Usage:
% dat=nj_tseries4d(uri,var,lon,lat,method,[layer],irange);
%
% Inputs:
%      uri = netcdf file name, dods url, or netcdf file object
%      var = variable name (string) (e.g. 'salt');
%      lon = vector of longitudes where time series are desired
%      lat = vector of latitudes  where time series are desired
%      method = 'nearest' or 'linear'
%      [layer] = vertical layer (for 4D data)
%      irange = time step range
% Outputs:
%      dat.vals = data values
%      dat.time = time values
%      dat.ii= i value
%      dat.jj= j value

% Rich Signell (rsignell@usgs.gov)
if(nargin<5),method='nearest',end;
nc=mDataset(uri);
[lon,lat]=nj_lonlat(nc,var);
if isvector(lon), [lon,lat]=meshgrid(lon,lat);end;
try
    jdmat=nj_time(uri,var);
catch
    jdmat=nan;
end
nt=length(jdmat);
switch method
    case 'nearest'
        for k=1:length(loni);
            [ind,dist]=nearxy(double(lon(:)),double(lat(:)),loni(k),lati(k));
            [jj,ii]=ind2ij(double(lon),ind);
            lono(k)=lon(jj,ii);
            lato(k)=lat(jj,ii);
            disp(sprintf('extracting point %d:lon=%f,lat=%f',k,lono(k),lato(k)));
            if isnan(jdmat), % 2D (no time dimension)
                u(:,k)=nc{var}(jj,ii);
            elseif nargin==6
                u(:,k)=nc{var}(:,layer,jj,ii);
                dat.layer=layer;
            elseif nargin==7
                u(:,k)=nc{var}(irange,layer,jj,ii);
                dat.layer=layer;
            else
                u(:,k)=nc{var}(:,jj,ii);
            end
            inear(k)=ii;
            jnear(k)=jj;
        end
    case 'linear'
        lono=loni;
        lato=lati;
        [n,m]=size(lon);
        [ii,jj]=meshgrid(1:m,1:n);
        ivar=griddata(double(lon(:)),double(lat(:)),ii(:),loni(:),lati(:));
        jvar=griddata(double(lon(:)),double(lat(:)),jj(:),loni(:),lati(:));
        for k=1:length(loni);
            disp(sprintf('interpolating at point %d:lon=%f,lat=%f',k,loni(k),lati(k)));
            i0=floor(ivar(k));
            ifrac=ivar(k)-i0;
            j0=floor(jvar(k));
            jfrac=jvar(k)-j0;
            if isnan(jdmat), % 2D (no time dimension)
                uall=nc{var}(j0:j0+1,i0:i0+1);
                u1=uall(1,1);
                u2=uall(1,2);
                u3=uall(2,1);
                u4=uall(2,2);
            elseif nargin==6
                uall=nc{var}(:,layer,j0:j0+1,i0:i0+1);
                u1=uall(:,1,1);
                u2=uall(:,1,2);
                u3=uall(:,2,1);
                u4=uall(:,2,2);
                dat.layer=layer;
            elseif nargin==7
                uall=nc{var}(irange,layer,j0:j0+1,i0:i0+1);
                u1=uall(:,1,1);
                u2=uall(:,1,2);
                u3=uall(:,2,1);
                u4=uall(:,2,2);
                dat.layer=layer;
            else               % 3D (2D with time dimension)
                uall=nc{var}(:,j0:j0+1,i0:i0+1);
                u1=uall(:,1,1);
                u2=uall(:,1,2);
                u3=uall(:,2,1);
                u4=uall(:,2,2);
            end
            dat.ii=[i0 i0+1];
            dat.jj=[j0 j0+1];
            ua=u1+(u2-u1)*ifrac;
            ub=u3+(u4-u3)*ifrac;
            u(:,k)=ua+jfrac*(ub-ua);
        end
end
close(nc);
dat.lon=lono;
dat.lat=lato;
if ~isnan(jdmat)
    dat.time=jdmat;
end
dat.vals=u;
if exist('inear','var'),
    dat.ii=inear;
    dat.jj=jnear;
end