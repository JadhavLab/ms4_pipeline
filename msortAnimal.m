function msort_animal(Parameters)

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
% animal id and day can take any form. X is a the trode number.
% There must also be a timestamps.mda in the same folder.

% Data will be placed into the folder % SomePath/animalID/day/MTNSORD_DIR

animalFolderPath = '';
animalID = 'SL09';


% Defaults
% pat = '(?<day>[0-9]{2})_(?<date>\d*)'; % rec folder name pattern
pat = [animalID,'_D(?<day>[0-9]{2})']; % My default pattern
dataDir = [fileparts(rawDir) filesep animID '_direct'];
sessionNums = [];
tet_list = [];
mask_artifacts = 1;

% Overwrites defaults with any parameters passed in.
assignVars(varargin)
%Maybe use inputparser instead.

% Constants
MTNSORT_DIR = 'Mountainsort';

SPIKE_CLIPS_FILE_NAME = 'clipsForPlexon.mda';
TIMESTAMP_FILE_SUFFIX = '.timestamps.mda';
TET_FILE_SUFFIX = 'wfForPlx.mat';

FQ_SAMPLE = 30000;
PRE_TIME_MS = 0.4;
POST_TIME_MS = 1.2;



animalRawDataDir = [animalFolderPath, animalID, filesep()];
mdaList = dir([animalRawDataDir,'**',filesep(),'*.mda']);
tetMdas = mdaList(arrayfun(@(x) contains(x.name,'nt'),mdaList));
mdaListSplit = arrayfun(@(x) strsplit(x.name,'.'),tetMdas,'UniformOutput',false);

[~, dayDirName, ~] = fileparts(tetMdas(1).folder);

ntNums = cellfun(@(x) x{2},mdaListSplit,'UniformOutput',false);
tetIDs = cellfun(@(x) str2double(x(3:end)),ntNums);
[tetList, tetListInds] = sort(tetIDs);
%         tetList = tetListManual;
directDir = [DATA_DIR, animalID, '_direct',filesep()];

ml_process_animal(animalID,animalRawDataDir,'tet_list',tetList,'dataDir',directDir);

% Trim trailing slash if there
if rawDir(end)==filesep
    rawDir = rawDir(1:end-1);
end




for k=1:numel(resDirs)
    
    msortTrode(resDirs{k});

end
fprintf('Completed automated clustering!\n')











end