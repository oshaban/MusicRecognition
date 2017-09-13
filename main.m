%% Create database
%Creates .txt files for all the .mp3 files in the folder
    %%%Might need to create functionality for other song formats
%createDatabase();
%% Load the database

%Must declare global in other m files being used
global database
global songNames
[database,songNames] = loadDatabase();
%Loads all the constellations into a cell array, where each cell contains the song 
    
%% Run the Program

orionGUI();

