% TRI_TIDE_MOVIE: Script to make tidal current movie from tri mesh models
% (This uses ADCIRC, but could be easily modified for FVCOM, QUODDY, etc.)
% Rich Signell (rsignell@usgs.gov)

% Prerequisites:  
%   - Matlab 2008b or higher (built-in NetCDF routines)
%   - "T_TIDE" & "RPSstuff" toolboxes, get them from
%             http://woodshole.er.usgs.gov/operations/sea-mat/
%             and put them in your Matlab path.
% 
%   - The 100MB tidal database netcdf file from
% http://geoport.whoi.edu/thredds/fileServer/usgs/vault0/models/tides/vdatum_gulf_of_maine/adcirc54_38_orig.nc
%% START HERE: Beginning of user-specified options

% SELECT: a NetCDF file with tidal const data from triangular mesh model
ncfile='adcirc54_38_orig.nc';

% Note: ADCIRC54_38 is a 38 constituent model set up by the NOAA VDATUM
% Group for computing datums (MLLW, MLW, MHW, MHHW)in for the Gulf of
% Maine.  NOAA was interested in elevations only, but we obtained the
% set-up and reran the model, saving the tidal current coefficients. ADCIRC
% is a depth-averaged model, so these are depth-averaged simulated currents.
%
% Contacts: Model developed by: Zhizhang Yang <Zhizhang.Yang@noaa.gov>
%                               Ed Myers <Edward.Myers@noaa.gov>
%           Rerun by: Erin Twomey (etwomey@usgs.gov)
%                     Rich Signell (rsignell@usgs.gov)

% SELECT: a coastline file with variable named "coast", which
% is a (two column, [lon(:) lat(:)] with rows of
% [NaN NaN] indicating breaks in coastline segments

%load mass_coast.mat coast   % Better coastline for Cape Cod Region
%load gom_coast.mat coast % World Vector Shoreline for entire Gulf of Maine


% SELECT: which constituents to use.  For all 38 constituents, use {-1}:

%consts={-1};  % use all 38 constituents
%consts={'STEADY','M2','S2','N2','K1','O1','P1','M4','M6','M8'};
consts={'STEADY','M2','S2','N2','K1','O1','M4','M6'};

%consts={'M2'};

% SELECT: velocity units for specifying the color range and
% unit labels on movie frames
units='knots';
%units='m/s';

% SELECT: color scale for current speed and velocity vector length

% SELECT: axis range for plot: [lon_min lon_max lat_min lat_max]
%ax=[ -70.8  -70.64   41.48   41.57];   %woods hole region
%ax=[ -71.0932  -70.5912   41.3633   41.7676]; %buzzards bay
%ax=[-70.4155  -69.9107   41.2322   41.6574]; % nantucket sound

%ax=[-71.1 -70.0 41.7 42.7]; %mass bay
%ax=[-70.7234  -70.5432   41.4658   41.5643]; %vineyard sound 2
%ax=[ -76.1328  -75.1414   34.9468   35.6094];
%ax=[-70.8658  -70.3828   41.3036   41.5798]; %vineyard sound
%ax=[ -70.6259  -70.3971   41.3788   41.5125]; %cow bay, vineyard sound
ax=[ -70.56  -70.34   41.33   41.47]; %MVCO
cax=[0 3.0]; % in units selected above
vscale=[0.005]; % velocity vector scale (try 0.01 and then perhaps adjust)


% Choose a time convention for specifying start/stop times
% and the labeled times on the movie frames (EST, EDT, UTC)

%time_zone='EST';
time_zone='EDT';
%time_zone='UTC';

start='07-Aug-2011 00:00';
stop= '07-Aug-2011 13:00';

% SELECT: an output time interval (hours)
dt=1.0; % hours

% SELECT: location of color legend on page
clegend_loc=[.96 .35 .02 .5];

% SELECT: a movie file name prefix (prefix.flc will be created)
outfile='mvco';

% SELECT: codec for output avi movie
codec='none';     % Use 'none' for optimal quality and large file size
% I use 'none' and later use "VideoMach" outside
% outside of Matlab to convert to RLE
% Note: You MUST use this on Linux
%codec='indeo5';   % Use 'indeo5' for poorer quality but much smaller avi size

%% END HERE: End of User-specified Options

switch units
    case 'm/s'
        vfac=1.0
    case 'knots'
        vfac=1.9438;
end

switch time_zone
    case 'UTC'
        toff = 0.0;
    case 'EDT'
        toff = -4.0;
    case 'EST'
        toff = -5.0;
end


xoff=0.0;
yoff=0.0;
sta=[-70.7299 41.5224];  % station to plot on map

halo=0.1;
ax2(1)=ax(1)-halo*(ax(2)-ax(1));
ax2(2)=ax(2)+halo*(ax(2)-ax(1));
ax2(3)=ax(3)-halo*(ax(4)-ax(3));
ax2(4)=ax(4)+halo*(ax(4)-ax(3));

jdlocal=datenum(start):dt/24:datenum(stop);
jd=jdlocal-toff/24;
glocals=datestr(jdlocal,'yyyy-mmm-dd HH:MM');
ntimes=length(jd);
jd_start=jd(1);

ncid = netcdf.open(ncfile,'NC_NOWRITE');

% Get variable ID of the first variable, given its name.
varid = netcdf.inqVarID(ncid,'tidenames');
names = netcdf.getVar(ncid,varid);
names = permute(names,[2 1]);

varid = netcdf.inqVarID(ncid,'lon');
lonf = netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'lat');
latf = netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'ele');
trif = netcdf.getVar(ncid,varid);
trif = trif.';

varid = netcdf.inqVarID(ncid,'lat');
latf = netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'depth');
depth = netcdf.getVar(ncid,varid);

varid = netcdf.inqVarID(ncid,'tidefreqs');
frequency = netcdf.getVar(ncid,varid);

names=cellstr(names);
ncon_available=length(names);

if consts{1}==-1,
    ncon=ncon_available;
    consts=names;
else
    ncon = length(consts);
end
consts=cellstr(consts);
% find indices in box
inbox=find(lonf>=ax2(1)&lonf<=ax2(2)&latf>=ax2(3)&latf<=ax2(4));
nt=length(lonf);
lon=lonf(inbox);
lat=latf(inbox);
np=length(inbox);


% Find the indices of the tidal constituents.

con_info = t_getconsts;
k=0;
ind_nc=[];
ind_ttide=[];
for i = 1:ncon  
    if strcmp(consts{i},'STEADY')
        indx = strmatch('Z0',con_info.name,'exact');
    else
        indx = strmatch(consts{i},con_info.name,'exact');
    end
    
    if ~isempty(indx)
        k=k+1;
        ind_ttide(k) = indx;
        ind_nc(k) = strmatch(consts{i},names,'exact');
    end  
end
ncon_match=k;
uamp=zeros(np,ncon);
vamp=zeros(np,ncon);
upha=zeros(np,ncon);
vpha=zeros(np,ncon);
% read all nodes for each consituent
disp('reading tidal coefficients...')
ua_var = netcdf.inqVarID(ncid,'u_amp');
up_var = netcdf.inqVarID(ncid,'u_phase');
va_var = netcdf.inqVarID(ncid,'v_amp');
vp_var = netcdf.inqVarID(ncid,'v_phase');
for i = 1:ncon_match
    ua = netcdf.getVar(ncid,ua_var,[ind_nc(i)-1 0 0],[1 nt 1]);
    up = netcdf.getVar(ncid,up_var,[ind_nc(i)-1 0 0],[1 nt 1]);
    va = netcdf.getVar(ncid,va_var,[ind_nc(i)-1 0 0],[1 nt 1]);
    vp = netcdf.getVar(ncid,vp_var,[ind_nc(i)-1 0 0],[1 nt 1]);
     
    upha(:,i)=up(inbox);
    vpha(:,i)=vp(inbox);
    uamp(:,i)=ua(inbox);
    vamp(:,i)=va(inbox);
    
end
netcdf.close(ncid)

freq_nc = frequency(ind_nc);
freq_ttide = con_info.freq(ind_ttide);
t_tide_names=cellstr(con_info.name(ind_ttide,:));
%%
tri = delaunay(double(lon),double(lat));

omega_ttide=2*pi.*freq_ttide; % convert from radians/s to radians/hour
omega=freq_nc*3600;
rllat=55;  %reference latitude for 3rd order satellites (degrees) (55 is fine always)
%[v,u,f]=t_vuf(jd_start,ind_ttide,rllat); % T_TIDE 1.1 syntax
[v,u,f]=t_vuf('nodal',jd_start,ind_ttide,rllat); %T_TIDE 1.2 syntax
v=v*2*pi;  % convert v to phase in radians
u=u*2*pi;  % convert u to phase in radians

thours=(jd-jd_start)*24;

ncon=length(freq_nc);
disp('computing tide...')
%%
for j=1:ntimes;
    %for j=1:1;
    %%
    glocal=glocals(j,:);
    U=zeros(size(lat));
    V=zeros(size(lat));
    
    for i=1:ncon_match;
        U=U+f(i).*uamp(:,i).*cos(v(i)+thours(j)*omega(i)+u(i)-upha(:,i)*pi/180);
        V=V+f(i).*vamp(:,i).*cos(v(i)+thours(j)*omega(i)+u(i)-vpha(:,i)*pi/180);
    end
    
    w=vfac*complex(U,V);
    clf
    set(gcf,'pos',[30 40 900 768]);
    set(gcf,'color','white');
    h1=axes('position',[0.100    0.100    0.80    0.8]);
    
    wf=NaN*ones(size(lonf));
    wf(inbox)=w;
    trisurf(trif,lonf+xoff,latf+yoff,zeros(size(wf))-1,abs(wf));
    shading interp; view(2);
    axis(ax);
    set(gca,'tickdir','out');
    caxis(cax);
    %fillseg(coast);
    hold on
    arrows(lon+xoff,lat+yoff,w,vscale,'k');
    % put a marker on.
    % line(sta(:,1),sta(:,2),'marker','+','markersize',14,'color','white');
    % line(sta(:,1),sta(:,2),'marker','o','markersize',14,'color','black');
    %title_str=sprintf('ADCIRC Predicted Tidal Current (m/s): %s UTC',gstart);
    title_str=sprintf('Predicted Tidal Current (%s): %s %s',units,glocal,time_zone);
    title(title_str,'fontsize',12)
    
    axis(ax);
    grid off
    grid2
    set(gca,'box','on');
    c=jet(128);
    colormap(c(20:108,:));
    %colorbar
    
    pclegend(cax.',clegend_loc); %use pclegend instead of colorbar for more control
    axes(h1);
    hold off
    %%
    set(gca,'DataAspectRatio',[1 cos(mean(lat(:))*pi/180) 100])
%    anim_frame(outfile,j);  % write frames to /tmp
    M(j)=getframe(gcf);
end
%anim_make

% Make movie with 2 frames per second.  Use no compression as
% best AVI compression for this application is RLE, and we don't have a
% RLE CODEC available in Matlab.  So convert later using VideoMach.

movie2avi(M,outfile,'compression',codec,'fps',2);
