function [z,g]=nj_topo(uri,bbox,isub,jsub);
% NJ_TOPO get topography 'topo' from a URL within a bounding box with subsampling
% [z,g]=nj_topo(uri,bbox,isub,jsub);
switch nargin
    case 2
      isub=1;jsub=1;
    case 3
        jsub=isub;
    case 4
    otherwise
        disp('incorrect number of args');help nj_topo;return
end
nc=mDataset(uri);
g=nc{'topo'}(:,:).grid;
ii=find(g.lon>=bbox(1) & g.lon<=bbox(2));
jj=find(g.lat>=bbox(3) & g.lat<=bbox(4));
if ~isempty(ii) & ~isempty(jj)
    z=nc{'topo'}(jj(1):jsub:jj(end),ii(1):isub:ii(end));
    g=nc{'topo'}(jj(1):jsub:jj(end),ii(1):isub:ii(end)).grid;
end
close(nc);