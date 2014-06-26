function [ U,g ] = cgrid_uv2rho(nc,uvar,vvar,hvar,avar,itime,klev,jj,ii);
% url='http://geoport.whoi.edu/thredds/dodsC/coawst_2_2/fmrc/coawst_2_2_best.ncd';
% hvar='h'; uvar='u'; vvar='v'; avar='angle';
% nc=mDataset(url);
% itime=10051; % 1st time step
% klev=1; % bottom layer
% Note: this routine assumes that the C grid has variables arranged:
%   
%       rho  u  rho  u  rho  u  rho
%        v       v       v       v 
%       rho  u  rho  u  rho  u  rho
%        v       v       v       v 
%       rho  u  rho  u  rho  u  rho
%% (e.g. size(rho)=ny,nx;  size(u)=ny,nx-1, size(v)=ny-1,nx)
i1=min(ii);i2=max(ii);  % range of ii
j1=min(jj);j2=max(jj);  % range of jj
gz=nc{hvar}(jj,ii).grid; % get a rho-point variable (like 'h' in ROMS)
u=nc{uvar}(itime,klev,j1+1:j2-1,i1:i2-1); % get u
v=nc{vvar}(itime,klev,j1:j2-1,i1+1:i2-1); % get v
U=ones(size(gz.lon))*nan; % template for U at rho points
U(2:end-1,2:end-1)=complex(av2(u.').',av2(v)); %average u,v to rho
ang=nc{avar}(jj,ii); % get angle
U=U.*exp(sqrt(-1)*ang); % rotate U
g.lon=gz.lon;
g.lat=gz.lat;
