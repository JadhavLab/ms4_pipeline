function msortAnimal(animalID, animalDir, varargin)

% Based off of code from Roshan Nanu and Ryan Young (I believe).
% Author: Jacob Olson
% Written: July 2022
% Last Editor:
% Last Edits:

%% COMMENT FROM ML_PROCESS_ANIMAL - refine
% ml_process_animal(animID,rawDir,varargin) will setup, preprocess and
% spike sort data with mountainlab-js. rawDir is the raw data directory
% containing the day directories. It is expected that mda files were
% extracted from the rec files already.

%% My comments
% Continutous time data is assumed to be organized in trodes in the
% following file structure:
% SomePath/animalID/day/animalID_day.mda/ntX.mda
% animal id and day (day is a set of rec(s) that have been extracted 
% together) can take any form. X is the trode number.
% There must also be a timestamps.mda in the same folder.

% Data will by default be placed into the folder 
% SomePath/animalID/day/MTNSORT_DIR

%% Constants
MTNSORT_DIR = 'MountainSort';

SPIKE_CLIPS_FILE_NAME = 'clipsForPlexon.mda';
TIMESTAMP_FILE_SUFFIX = '.timestamps.mda';
TET_FILE_SUFFIX = 'wfForPlx.mat';

FQ_SAMPLE = 30000;
PRE_TIME_MS = 0.4;
POST_TIME_MS = 1.2;

%% Parse Inputs
p = inputParser;
p.StructExpand = false;
validStr = @(x) isstring(x) || ischar(x);
addRequired(p,'animalID');
addRequired(p,'animalDir');
addOptional(p,'recList',[])
addOptional(p,'trodeList',[])
addOptional(p,'recPattern','(?<animalID>[A-Z]+[0-9]+)_D(?<recID>[0-9]{2})',validStr);
addOptional(p,'trodePattern','(?<animalID>[A-Z]+[0-9]+)_D(?<day>[0-9]{2}).nt(?<tet>[0-9]+).mda',validStr);
addParameter(p,'mtnSortFolder',MTNSORT_DIR);
addParameter(p,'maskArtifacts',true);
addParameter(p,'cuttingParams',struct('samplerate',30000));

parse(p,animalID, animalDir,varargin{:});
animalID = p.Results.animalID;
animalDir = p.Results.animalDir;
mtnSortFolder = p.Results.mtnSortFolder;
recPattern = p.Results.recPattern;
recList = p.Results.recList;
trodePattern = p.Results.trodePattern;
trodeList = p.Results.trodeList;

if animalDir(end)==filesep
    animalDir = animalDir(1:end-1);
end
if mtnSortFolder(end)==filesep
    mtnSortFolder = mtnSortFolder(1:end-1);
end

recFolders = findRecFolders(animalDir,recPattern,recList);
disp('Processing raw data with mountain lab. Processing:');
disp(recFolders.recID');
for iRec = 1:numel(recFolders)
    parentFolder = [recFolders(iRec).folder,filesep,recFolders(iRec).name];
    recMdaDir = [parentFolder, filesep, recFolders(iRec).name,'.mda'];
    recMtnSortFolder = [parentFolder, filesep, mtnSortFolder];
    msortRec(recMdaDir, recMtnSortFolder, varargin);
end

end