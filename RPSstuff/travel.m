t=load('newport.mat')
lon = t.X;
lat = t.Y;
z_new = t.Z;
t=load('montauk.mat','Z')
z_mon=t.Z;
t=load('falmouth.mat','Z')
z_fal=t.Z;
%%
clf
lev = 1.5 % 1.5 hours travel time
hold on
contour(lon,lat,z_new,[lev lev],'r-')
contour(lon,lat,z_fal,[lev lev],'c-')
contour(lon,lat,z_mon,[lev lev],'b-')
hold off
