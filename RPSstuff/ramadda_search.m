function [links, query_struct] = ramadda_search( q )
%RAMADDA_SEARCH Queries unidata ramadda database of metadata, and
% returns a list of available links from the matching resources
%
% Usage:  [ links, query_structure ] = ramadda_search(q)
%   q (Can be a stucture with the following fields:)
%
%     q.endpoint = URL to opensearch server
%     q.string_text = text string to match 
%     q.bbox= [xmin,ymin,xmax,ymax]
%     q.date_start = start date string
%     q.date_end  = ending date string
%
%   q (Can also be ramadda search string.)

% Example:
% q.endpoint='http://testbedapps.sura.org/repository/';
% q.string_text='sea_water_temperature';
% q.bbox= [-74,39,-66,45];
% q.date_start='2006-04-09';
% q.date_end='2006-06-22';
% [links,params]=ramadda_search(q);   % make the query or
% [links]=ramadda_search(q);   % make the query
%
% Rich Signell and Alexander Crosby
tic
if isstruct(q)
  if ~isfield(q,'endpoint'); 
    error('ramadda_search:noEndpointURL',...
        'Add *.endpoint to the input structure'); return; end
  if ~isfield(q,'string_text'); q.string_text='';end
  if ~isfield(q,'bbox'); 
    west='';
    south='';
    east='';
    north='';
  else
    if iscell(q.bbox)
      west = q.bbox(1);
      south = q.bbox(2);
      east = q.bbox(3);
      north = q.bbox(4);
    else
      west = num2str(q.bbox{1});
      south = num2str(q.bbox{2});
      east = num2str(q.bbox{3});
      north = num2str(q.bbox{4});
    end
  end
  if ~isfield(q,'date_start'); q.date_start='';end
  if ~isfield(q,'date_end'); q.date_end='';end
  if ~isfield(q,'time_start'); q.time_start='';end
  if ~isfield(q,'time_end'); q.time_end='';end
  if ~isfield(q,'type'); q.type='opendaplink';end
  if ~isfield(q,'datemode'); q.datemode='overlaps';end
  if ~isfield(q,'relativedate'); q.relativedate='none';end
  if ~isfield(q,'areamode'); q.areamode='areaoverlaps';end
  if ~isfield(q,'filesuffix'); q.filesuffix='';end
  if ~isfield(q,'metadatatype_enum_tag'); q.metadatatype_enum_tag='enum_tag';end
  if ~isfield(q,'metadatatype_enum_gcmdkeyword'); q.metadatatype_enum_gcmdkeyword='enum_gcmdkeyword';end
  if ~isfield(q,'metadatatype.thredds_project'); q.metadatatype.thredds_project='thredds.project';end
  if ~isfield(q,'metadatatype.thredds_keyword'); q.metadatatype.thredds_keyword='thredds.keyword';end
  if ~isfield(q,'metadatatype.thredds_creator'); q.metadatatype.thredds_creator='thredds.creator';end
  if ~isfield(q,'metadatatype.thredds_publisher'); q.metadatatype.thredds_publisher='thredds.publisher';end
  if ~isfield(q,'metadatatype.thredds_contributor'); q.metadatatype.thredds_contributor='thredds.contributor';end
  if ~isfield(q,'metadatatype.thredds_property'); q.metadatatype.thredds_property='thredds.property';end
  if ~isfield(q,'metadatatype.thredds_propertyname'); q.metadatatype.thredds_propertyname='';end
  if ~isfield(q,'metadatatype.thredds_documentation'); q.metadatatype.thredds_documentation='thredds.documentation';end
  if ~isfield(q,'metadatatype.thredds_variable'); q.metadatatype.thredds_variable='thredds.variable';end
  if ~isfield(q,'metadatatype.thredds_variablename'); q.metadatatype.thredds_variablename='';end
  if ~isfield(q,'metadatatype.thredds_standardname'); q.metadatatype.thredds_standardname='thredds.standardname';end
  if ~isfield(q,'metadatatype.thredds_standardnamename'); q.metadatatype.thredds_standardnamename='';end
  if ~isfield(q,'metadatatype.netcdf_ioosmodel'); q.metadatatype.netcdf_ioosmodel='netcdf.ioosmodel';end
  if ~isfield(q,'metadatatype.netcdf_ioosmodelname'); q.metadatatype.netcdf_ioosmodelname='';end
  if ~isfield(q,'orderby'); q.orderby='none';end
  if ~isfield(q,'output'); q.output='xml.xml';end
  if ~isfield(q,'search_submit'); q.search_submit='Search';end

  params = {
  'text';q.string_text;
  'type'; q.type;
  'fromdate';q.date_start;
  'fromdate.time';q.time_start;
  'todate';q.date_end;
  'todate.time';q.time_end;
  'date.searchmode';q.datemode;
  'relativedate';q.relativedate;
  'area_north';north;
  'area_west';west;
  'area_east';east;
  'area_south';south;
  'areamode';q.areamode;
  'filesuffix';q.filesuffix;
  'metadatatype.enum_tag';q.metadatatype_enum_tag;
  'metadatatype.enum_gcmdkeyword';q.metadatatype_enum_gcmdkeyword;
  'metadatatype.thredds.project';q.metadatatype.thredds_project;
  'metadatatype.thredds.keyword';q.metadatatype.thredds_keyword;
  'metadatatype.thredds.creator';q.metadatatype.thredds_creator;
  'metadatatype.thredds.publisher';q.metadatatype.thredds_publisher;
  'metadatatype.thredds.contributor';q.metadatatype.thredds_contributor;
  'metadatatype.thredds.property';q.metadatatype.thredds_property;
  'metadata.attr1.thredds.property';q.metadatatype.thredds_propertyname;
  'metadatatype.thredds.documentation';q.metadatatype.thredds_documentation;
  'metadatatype.thredds.variable';q.metadatatype.thredds_variable;
  'metadata.attr1.thredds.variable';q.metadatatype.thredds_variablename;
  'metadatatype.thredds.standardname';q.metadatatype.thredds_standardname;
  'metadata.attr1.thredds.standardname';q.metadatatype.thredds_standardnamename;
  'metadatatype.netcdf.ioosmodel';q.metadatatype.netcdf_ioosmodel;
  'metadata.attr1.netcdf.ioosmodel';q.metadatatype.netcdf_ioosmodelname;
  'orderby';q.orderby;
  'output';q.output;
  'search.submit';q.search_submit;
  };

  uri=[q.endpoint, 'search/do'];
  result=urlread(uri,'get',params);
  
else
  result=urlread(q);
 
  query_struct.string_text= ...
   char(regexp(q, 'text=(.*?)&','tokens','once'));
  query_struct.type = ...
   char(regexp(q, 'type=(.*?)&','tokens','once'));
  query_struct.date_start = ...
   char(regexp(q, 'fromdate=(.*?)&','tokens','once'));
  query_struct.time_start = ...
   char(regexp(q, 'fromdate.time=(.*?)&','tokens','once'));
  query_struct.date_end = ...
   char(regexp(q, 'todate=(.*?)&','tokens','once'));
  query_struct.time_end = ...
   char(regexp(q, 'todate.time=(.*?)&','tokens','once'));
  query_struct.datemode = ...
   char(regexp(q, 'date.searchmode=(.*?)&','tokens','once'));
  query_struct.relativedate = ...
   char(regexp(q, 'relativedate=(.*?)&','tokens','once'));
  query_struct.bbox(4) = ...
   regexp(q, 'area_north=(.*?)&','tokens','once');
  query_struct.bbox(1) = ...
   regexp(q, 'area_west=(.*?)&','tokens','once');
  query_struct.bbox(3) = ...
   regexp(q, 'area_east=(.*?)&','tokens','once');
  query_struct.bbox(2) = ...
   regexp(q, 'area_south=(.*?)&','tokens','once');
  query_struct.areamode = ...
   char(regexp(q, 'areamode=(.*?)&','tokens','once'));
  query_struct.filesuffix = ...
   char(regexp(q, 'filesuffix=(.*?)&','tokens','once'));
  query_struct.metadatatype_enum_tag = ...
   char(regexp(q, 'metadatatype.enum_tag=(.*?)&','tokens','once'));
  query_struct.metadatatype.enum_gcmdkeyword = ...
   char(regexp(q, 'metadatatype.enum_gcmdkeyword=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_project = ...
   char(regexp(q, 'metadatatype.thredds.project=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_keyword = ...
   char(regexp(q, 'metadatatype.thredds.keyword=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_creator = ...
   char(regexp(q, 'metadatatype.thredds.creator=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_publisher = ...
   char(regexp(q, 'metadatatype.thredds.publisher=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_contributor = ...
   char(regexp(q, 'metadatatype.thredds.contributor=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_property = ...
   char(regexp(q, 'metadatatype.thredds.property=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_propertyname = ...
   char(regexp(q, 'metadata.attr1.thredds.property=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_documentation = ...
   char(regexp(q, 'metadatatype.thredds.documentation=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_variable = ...
   char(regexp(q, 'metadatatype.thredds.variable=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_variablename = ...
   char(regexp(q, 'metadata.attr1.thredds.variable=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_standardname = ...
   char(regexp(q, 'metadatatype.thredds.standardname=(.*?)&','tokens','once'));
  query_struct.metadatatype.thredds_standardnamename = ...
   char(regexp(q, 'metadata.attr1.thredds.standardname=(.*?)&','tokens','once'));
  query_struct.metadatatype.netcdf_ioosmodel = ...
   char(regexp(q, 'metadatatype.netcdf.ioosmodel=(.*?)&','tokens','once'));
  query_struct.metadatatype.netcdf_ioosmodelname = ...
   char(regexp(q, 'metadata.attr1.netcdf.ioosmodel=(.*?)&','tokens','once'));
  query_struct.orderby = ...
   char(regexp(q, 'orderby=(.*?)&','tokens','once'));
  query_struct.output = ...
   char(regexp(q, 'output=(.*?)&','tokens','once'));
  query_struct.search_submit = ...
   char(regexp(q, 'search.submit=(.*?)&','tokens','once'));
  query_struct.endpoint = ...
   char(regexp(q, '(.*?)search/do','tokens','once'));
  
end

 links = regexp(result, 'resource=\"(.*?)"','tokens');
 
toc

end
