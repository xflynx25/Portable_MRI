% on choisit un fichier dans un browser
% il lit l'en-tête .LIST
% il décode cet en-tête
% il lit l'image et l'affiche en module et en phase
% pour l'instant, n'est adapté qu'à du 2D flux (mais assez facile de l'adapter)


clear i     % complex
% choix des chemin d'accès 
[FileName,PathName] = uigetfile('*.list','header (list)','c:\');
fullpath=[PathName,FileName];
datapath=[fullpath(1:end-4),'data'];

% ouverture et lecture du header .LIST
fichier = fopen(fullpath, 'r');

frewind(fichier);
h_name = textscan(fichier, '%s %s %s %s %s %s %s ', 1, 'headerlines', 5); 
NAME.A   = h_name{1,5};
NAME.B   = h_name{1,6};
NAME.C   = h_name{1,7};
clear h_name

frewind(fichier);
h_name = textscan(fichier, '%s %s %s %s', 1, 'headerlines', 6); 
NAME.D   = h_name{1,4}(1);
clear h_name

frewind(fichier);
taille_mix  = textscan(fichier, '%s %d %d %d %s %s %d', 1, 'headerlines', 16);
NB_mix=taille_mix{1,7};
clear taille_mix

frewind(fichier);
taille_rest = textscan(fichier, '%s %d %d %d %s %s %d', 8, 'headerlines', 20); 
NB_dimensions   = taille_rest{1,7}(1);
NB_dynamics     = taille_rest{1,7}(2);
NB_phases       = taille_rest{1,7}(3);
NB_echoes       = taille_rest{1,7}(4);
NB_locations    = taille_rest{1,7}(5);
NB_ext1         = taille_rest{1,7}(6);
NB_ext2         = taille_rest{1,7}(7);
NB_NSA          = taille_rest{1,7}(8);   
clear taille_rest

frewind(fichier);
taille_xy = textscan(fichier, '%s %d %d %d %s %s %d', 2, 'headerlines', 31); 
TAILLE_X   = taille_xy{1,7}(1);
TAILLE_Y   = taille_xy{1,7}(2);
clear taille_xy

frewind(fichier);
header = textscan(fichier, '%s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d', -1, 'headerlines', 67);
[HNX,xxx]=size(header);
[HNY,xxx]=size(header{1,1});
clear xxx
% header_cell=mat2cell(header,ones(1,HNY),ones(1,HNX))
% champs= {'type',    'mix',      'dyn',      'card',     'echo',...
%         'location', 'channel',  'extr1',    'extr2',    'y', ...
%         'z',        'na1',      'na2',      'na3',      'na4',...
%         'na5',      'na6',      'na7',      'size',     'offset'};
% HEADER=cell2struct(header,champs, 2);
HNY=HNY-1;
for k=1:HNY
    HEADER(k).type      =header{1,1}(k,1);
    HEADER(k).mix       =header{1,2}(k,1);
    HEADER(k).dyn       =header{1,3}(k,1);
    HEADER(k).card      =header{1,4}(k,1);
    HEADER(k).echo      =header{1,5}(k,1);
    HEADER(k).location  =header{1,6}(k,1);
    HEADER(k).channel   =header{1,7}(k,1);
    HEADER(k).extr1     =header{1,8}(k,1);      % step en velocimétrie
    HEADER(k).extr2     =header{1,9}(k,1);
    HEADER(k).y         =header{1,10}(k,1);
    HEADER(k).z         =header{1,11}(k,1);
    HEADER(k).size      =header{1,19}(k,1);     % nb d'octets
    HEADER(k).length    =HEADER(k).size/8;      % nb de points complexes
    HEADER(k).offset    =header{1,20}(k,1);
end    
HNY=HNY-1; 
clear header
fclose(fichier);

% ouverture et lecture des données .DATA
fichier2 = fopen(datapath, 'r');

% les lignes ont-elles toute la même taille ?
same_length = true;
n = HEADER(1).length;
for k=1:(HNY)
    if (n ~= HEADER(1).length) 
        same_length = false;
        break;
    end
end
% [num2str(HNY) ' lignes']

% si OUI, lecture en bloc (les lignes s'enchaînent simplement)
if (same_length)
    ['même longueur pour toutes les lignes : ',num2str(HEADER(1).length)]
    n = double(2*HEADER(1).length);             % nb de points réels
    r_data = fread(fichier2,[n,HNY], 'float32=>real*4', 0, 'ieee-le').'; 

% SINON, lecture ligne par ligne selon en-tête
else 
    'lignes de longueurs inégales'
    for k=1:(HNY)
        n = double(2*HEADER(k).length);             % nb de points réels
        r_data(k,:) = fread(fichier2, n, 'float32=>real*4', HEADER(k).offset, 'l').';
    end
end

fclose(fichier);

% conversion 2 réels ==> 1 complexe
C_DATA(:,1:n/2) = r_data(:,1:2:n-1) + i * r_data(:,2:2:n);
clear r_data

% choix du type de fichier
% pour l'instant : une seule possibilité prévue
% (à enrichir par la suite)
type = '2Dflow';

% réarrangement des données lues dans l'ordre d'acquisition
% vers un tableau multidimensionnel structuré complexe (SC_DATA)
clear FC_DATA;
switch lower(type)
    
    % cas de 2D + FLUX
    case '2dflow'   % images spatialement 2D, avec axe supplémentaire de flux
                    % meme si plusieurs directions de flux, ce programme
                    % les aligne sur le meme axe
                        % dimension 1 : X
                        %     d°    2 : Y
                        %     d°    3 : segments
    for k= 1:HNY
        SC_DATA(:,1+HEADER(k).y,1+HEADER(k).extr1)=C_DATA(k,:).';
    end
    [NX,NY,NS]=size(SC_DATA);
    if (NS ~= NB_ext1)
        'dimensions mesurées (steps) incompatibles avec l''en-tête'
    elseif (NX ~= TAILLE_X)
        'dimensions mesurées (X) incompatibles avec l''en-tête'
    elseif (NY ~= TAILLE_Y)
        'dimensions mesurées (Y) incompatibles avec l''en-tête'
    else
        'sortie : tableau multidimensionnel complexe structuré SC_DATA(X,Y,S) :'
        ['      X : dimension spatiale (',num2str(NX),')']
        ['      Y : dimension spatiale (',num2str(NY),')']
        ['      S : velocity steps     (',num2str(NS),')']            
    end
    
                    
    % cas inconnu
    otherwise error('Unknown type!')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pour tester seulement : supprimer du vrai module !
for k=1:NS
    h=imview(uint16(abs(5*SC_DATA(:,:,k))));                % module
    pause(2)
    close(h)
    h=imview(uint16((pi+angle(5*SC_DATA(:,:,k)))/pi*32000));% phase    
    pause(2)
    close(h)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear C_DATA 
clear HEADER
clear fichier
clear fichier2
clear FileName
clear PathName
clear same_length
clear type
clear k
clear n
clear fullpath
clear datapath
clear HNX
clear HNY
clear h
                       


% 
% # === DATA DESCRIPTION FILE ======================================================
% #
% # CAUTION - Investigational device.
% # Limited by Federal Law to investigational use.
% #
% # Scan name   : REC REC 2D_Q
% # Dataset name: CPX_019
% #
% # Gyroscan SW release            : 1.2-2
% # Reconstruction Host SW Version :  31
% # Reconstruction   AP SW Version :  54
% #
% # === GENERAL INFORMATION ========================================================
% #
% # n.a. n.a. n.a.  number of ...                        value
% # ---- ---- ----  ----------------------------------   -----
% .    0    0    0  number_of_mixes                    :     1
% #
% # mix  n.a. n.a.  number of ...                        value
% # ---- ---- ----  ----------------------------------   -----
% .    0    0    0  number_of_encoding_dimensions      :     2
% .    0    0    0  number_of_dynamic_scans            :     1
% .    0    0    0  number_of_cardiac_phases           :     1
% .    0    0    0  number_of_echoes                   :     1
% .    0    0    0  number_of_locations                :     1
% .    0    0    0  number_of_extra_attribute_1_values :     3
% .    0    0    0  number_of_extra_attribute_2_values :     1
% .    0    0    0  number_of_signal_averages          :     1
% #
% # mix  n.a. n.a.  reconstruction matrix                value
% # ---- ---- ----  ----------------------------------   -----
% .    0    0    0  X-resolution                       :   256
% .    0    0    0  Y-resolution                       :   256
% #
% # Complex data vector types:
% # --------------------------
% # STD = Standard data vector (image data or spectroscopy data). This is the only type of data vector
% #       in exported cpx data. Unless explicitly disabled, the STD data has been subjected to:
% #       - Averaging
% #       - Ringing filtering
% #       - Fourier transformations
% #       - Frequency spectrum correction
% #       - EPI/GraSE phase correction
% #       In this form the STD data is ready for image production.
% #
% # Other complex data vector attributes:
% # -------------------------------------
% # mix    = mixed sequence number
% # dyn    = dynamic scan number
% # card   = cardiac phase number
% # echo   = echo number
% # loca   = location number
% # chan   = synco channel number
% # extr1  = extra attribute 1 (semantics depend on type of scan)
% # extr2  = extra attribute 2 (   ''       ''   ''  ''  ''  '' )
% # x,y    = spatial coordinates in 1st and 2nd preparation direction (spectroscopy data)
% # y,z    = spatial coordinates in 1st and 2nd preparation direction (image data)
% # size   = data vector size   in number of bytes (1 complex element = 2 floats = 8 bytes)
% # offset = data vector offset in number of bytes (first data vector starts at offset 0)
% #
% # The complex data vectors are represented as binary data in little endian single precision IEEE float format.
% #
% # === START OF DATA VECTOR INDEX =================================================
% #
% # typ mix   dyn   card  echo  loca  chan  extr1 extr2 y     z     n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  n.a.  size   offset
% # --- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ------ ------
% #
%   STD     0     0     0     0     0    27     0     0     0     0     0     0     0     0     0     0     0   2048 0
%   STD     0     0     0     0     0    27     0     0     1     0     0     0     0     0     0     0     0   2048 2048
%  STD     0     0     0     0     0    27     0     0     2     0     0     0     0     0     0     0     0   2048 4096