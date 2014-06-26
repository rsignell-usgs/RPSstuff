function xnew=boxfilt3(x,n)
%function xnew=boxfilt3(x,n)
% box car filter of length n
% Like boxfilt, but in vicinity of bad points everything gets NaN, and
% the original time base is maintained, with points at the beginning 
% and end returned as NaN.
[m1,n1]=size(x);
x2=boxfilt(x,n);
[m2,n2]=size(x2);
nbeg=ceil((n+1)/2);
xnew=ones(size(x))*nan;
xnew(nbeg:nbeg+m2-1,:)=x2;
