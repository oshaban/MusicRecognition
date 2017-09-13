function varargout = orionGUI(varargin)
% ORIONGUI MATLAB code for orionGUI.fig
%      ORIONGUI, by itself, creates a new ORIONGUI or raises the existing
%      singleton*.
%
%      H = ORIONGUI returns the handle to a new ORIONGUI or the handle to
%      the existing singleton*.
%
%      ORIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORIONGUI.M with the given input arguments.
%
%      ORIONGUI('Property','Value',...) creates a new ORIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before orionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to orionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help orionGUI

% Last Modified by GUIDE v2.5 24-Apr-2017 12:41:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @orionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @orionGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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

% --- Executes just before orionGUI is made visible.
function orionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to orionGUI (see VARARGIN)

% Choose default command line output for orionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes orionGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = orionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in createDatabaseButton.
function createDatabaseButton_Callback(hObject, eventdata, handles)
% hObject    handle to createDatabaseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    notify = msgbox('Creating database');
    %PUT CREATEDATABASE FUNCTION
    delete(notify); 


% --- Executes on button press in recordButton.
function recordButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    %Record Song
    fs = 44100;
    recordingTime = 10;
    A = audiorecorder(fs,16,1); %Record in audio
    notify = msgbox('RECORDING');
    recordblocking(A,recordingTime); %Records from microphone
    delete(notify); 
    
    micRecording = getaudiodata(A);
    audiowrite('mic.wav',micRecording,fs)
    
    %Create constellation for the recording
    hashRecording = create_constellation_adaptive_threshold('mic.wav')';

    %Must declare global variables being used
    global database
    global songNames
    
    matches = zeros(1,length(database)); %Stores number of matches for each database song

    
    %Search for the matching song
    for(j=1:length(database))

        hashList = cell2mat(database(j))'; %Constellation for a corresponding database song

        %Searches a nx3 hash matrix, where the columns correspond to
        %f1,f2,deltaT
        for( i=1:size(hashRecording,1) )

            f = ismembertol(hashRecording(i,:),hashList,1,'ByRows',true,'DataScale',[1 1 0.05]);
            %Checks to see if f1 is within 2, f2 is within 2, and deltaT is
            %within 0.1 of the hashes in hashRecording

            if(f==1)
               matches(j) = matches(j)+1; 
            end

        end

    end
    
    %Find location of song with most matches
    [maxMatches,maxIndex] = max(matches);
    
   %Print song with most matches
    set(handles.resultBox ,'string',char( songNames(maxIndex)) )
    
    %Plots graph with number of matches
    axes(handles.bargraph)
    bar(1:length(matches),matches)
    title('Number of Hits per Song')
    xlabel('Song Numbers')
    ylabel('Number of Hits')
        
    
    
