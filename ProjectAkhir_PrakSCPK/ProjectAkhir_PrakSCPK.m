function varargout = ProjectAkhir_PrakSCPK(varargin)
%PROJECTAKHIR_PRAKSCPK MATLAB code file for ProjectAkhir_PrakSCPK.fig
%      PROJECTAKHIR_PRAKSCPK, by itself, creates a new PROJECTAKHIR_PRAKSCPK or raises the existing
%      singleton*.
%
%      H = PROJECTAKHIR_PRAKSCPK returns the handle to a new PROJECTAKHIR_PRAKSCPK or the handle to
%      the existing singleton*.
%
%      PROJECTAKHIR_PRAKSCPK('Property','Value',...) creates a new PROJECTAKHIR_PRAKSCPK using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ProjectAkhir_PrakSCPK_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PROJECTAKHIR_PRAKSCPK('CALLBACK') and PROJECTAKHIR_PRAKSCPK('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PROJECTAKHIR_PRAKSCPK.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectAkhir_PrakSCPK

% Last Modified by GUIDE v2.5 05-Jul-2021 14:35:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectAkhir_PrakSCPK_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectAkhir_PrakSCPK_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ProjectAkhir_PrakSCPK is made visible.
function ProjectAkhir_PrakSCPK_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ProjectAkhir_PrakSCPK
handles.output = hObject;

data = xlsread('DATA RUMAH Fix.xlsx','C2:H21'); %mengambil data dari excel

set(handles.table_data,'Data',data);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectAkhir_PrakSCPK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProjectAkhir_PrakSCPK_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when entered data in editable cell(s) in table_data.
function table_data_CellEditCallback(~, ~, ~)
% hObject    handle to table_data (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_proses.
function btn_proses_Callback(~, ~, handles)
% hObject    handle to btn_proses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = xlsread('DATA RUMAH Fix.xlsx','C2:H21'); %mengambil data dari excel


%batas kriteria     
maksHrg = 20000000000;
maksLB = 500;
maksLT = 500;
maksKT = 10;
maksKM = 10;
maksGrs = 10;

%normalisasi
data(:,1) = data(:,1) / maksHrg;
data(:,2) = data(:,2) / maksLB;
data(:,3) = data(:,3) / maksLT;
data(:,4) = data(:,4) / maksKT;
data(:,5) = data(:,5) / maksKM;
data(:,6) = data(:,6) / maksGrs;

%menentukan relasi kriteria
%lalu buat asumsi kepentingan
relasiAntarKriteria = [ 1     2     2     4     4     4
                        0     1     1     2     2     2
                        0     0     1     2     2     2
                        0     0     0     1     1     1
                        0     0     0     0     1     1
                        0     0     0     0     0     1];
                    
%menentukan TFN                    
TFN = {[-100/3 0     100/3]     [3/100  0     -3/100]
       [0      100/3 200/3]     [3/200  3/100 0     ]
       [100/3  200/3 300/3]     [3/300  3/200 3/100 ]
       [200/3  300/3 400/3]     [3/400  3/300 3/200 ]};

%melakukan perhitungan raiso konsistensi
[RasioKonsistensi] = HitungKonsistensiAHP(relasiAntarKriteria);

if RasioKonsistensi < 0.10
    % Metode Fuzzy AHP
    [bobotAntarKriteria, ~] = FuzzyAHP(relasiAntarKriteria, TFN);    

    % Hitung nilai skor akhir 
    ahp = data * bobotAntarKriteria';

    for i = 1:size(ahp, 1)
        if ahp(i) > 0.7
            status = 'A';
        elseif ahp(i) > 0.5
            status = 'B';
        elseif ahp(i) > 0.3
            status = 'C';
        else
            status = 'D';
        end
        
        kesimpulan(i,:) = join(status);
    end
    
    opts = detectImportOptions('DATA RUMAH FIX.xlsx'); %mendeteksi file DATA RUMAH.xlsx
    opts.SelectedVariableNames = [2]; %memilih hanya kolom Nama Rumah

    %mengambil nama rumah dari file dan menyimpan di var nama
    nama = readmatrix('DATA RUMAH FIX.xlsx',opts); 
    
    %memilih hanya 20 nilai terbaik (20 rumah terbaik)
    for i=1:20
        hasil(i) = ahp(i);
    end
    
    %perulangan untuk mencari nama rumah dari 20 nilai terbaik
    for i=1:20
     for j=1:20
       if(hasil(i) == ahp(j))
        rekomendasi(i) = nama(j);
        break
       end
     end
    end

    %melakukan transpose pada rekomendasi agar tampilan menjadi per baris
    rekomendasi = rekomendasi';
    
    %mengubah dari array ke cell untuk ditampilkan di tabel
    ahp = num2cell(ahp); 
    kesimpulan = num2cell(kesimpulan);
    
    akhir = [rekomendasi ahp kesimpulan]; %menggabungkan matriks

    set(handles.table_hasil,'Data',akhir);
    
    
end
