function [Ms]=Read_FID_hdr()
% 
Ms=['num_acq                    ',' 000050 ',' short  ',' 001 ','number of acquisition                ';
    'pw                         ',' 000052 ',' double ',' 001 ','pulse duration                       ';
    'sampling                   ',' 000068 ',' double ',' 001 ','sampling period                      ';
    'minute                     ',' 000076 ',' char   ',' 001 ','                                     ';
    'hour                       ',' 000077 ',' char   ',' 001 ','                                     ';
    'sec                        ',' 000079 ',' char   ',' 001 ','                                     ';
    'nb_points                  ',' 000080 ',' long   ',' 001 ','number of points                     '
];


% ty=['schar  ','uchar  ','int8   ','int16  ','int32  ','int64  ','uint8  ','uint16 ','uint32 ','uint64 ','float32','float64','double ',...
%                          'char   ','short  ','int    ','long   ','ushort ','ulong  ','float  '];
% for i=(1:(max(size(ty)))/7)+10
% m=[ 't' num2str(i),ty((i-11)*7+(1:7)) '                 ',' 000050 ',' ', ty((i-11)*7+(1:7)) ' 004 ','number of acquisition                '; ];
% m2=[ 'd' num2str(i),ty((i-11)*7+(1:7)) '                 ',' 000052 ',' ', ty((i-11)*7+(1:7)) ' 004 ','number of acquisition                '; ];
% 
% size(m);
% Ms=[Ms;m;m2];
% 
% end
% 

