function [ Ms,header] = Read_FID(filename)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

if nargin<1
[filename path]=uigetfile('*.*');
filename=[path filename];
end

Ms=[];
header=[];
off_info=[];

finfo=dir(filename);
header=finfo;
if finfo.bytes<4498
disp('error opening file, check file name')
else

% extraction des infos de date
strfile=finfo.name;
year=strfile([1 2]);
year=str2num(['19' year])+20;
month=strfile([3 4 5]);
date0=str2num(strfile([6 7]));
ext=str2num(strfile([9 10 11]));

offset0=50;
offset1=12;

head=Read_FID_Header(filename,0,0,0);
head.year=year;
head.month=month;
head.day=date0;
head.ext=ext;
header=head;

NX=header.nb_points+12;
NY=1; % ne sert a rien ???
NZ=(finfo.bytes-offset0)/(header.nb_points+offset1)/4;

dim=[NX NY NZ];
offset=offset0;
Type='long';
Endian='ieee-le';
Ms0=Read_Raw_Field(filename,offset,dim,Type,Endian);
Ms00=Ms0(offset1:1:NX,1,:);
Ms00x=Ms00(1:header.nb_points/2,1,:);
Ms00y=Ms00(header.nb_points/2+1:1:header.nb_points,1,:);


Ms=Ms00x+i*Ms00y;
Ms=Ms(:);
Ms=reshape(Ms,header.nb_points/2,NZ);
Ms=Ms/2^31;

%lecture des informations trace
for k=1:size(Ms,2);
   trace=k-1;
   nbpt=header.nb_points;
   head=Read_FID_Header(filename,trace,nbpt,offset1);
   head0(k)=head;
end

header=head0;
end
