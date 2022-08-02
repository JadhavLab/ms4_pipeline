function msortRec(mdaDir, mtnSortFolder, varargin)

%% Parse Inputs
p = inputParser;
p.StructExpand = false;
validStr = @(x) isstring(x) || ischar(x);
addRequired(p,'mdaDir');
addRequired(p,'mtnSortFolder');
addOptional(p,'trodeList',[])
addOptional(p,'pattern','(?<animalID>[A-Z]+[0-9]+)_D(?<day>[0-9]{2}).nt(?<tet>[0-9]+).mda',validStr);
addParameter(p,'maskArtifacts',true);
addParameter(p,'cuttingParams',struct('samplerate',30000));

parse(p,mdaDir, mtnSortFolder,varargin{:});
mdaDir = p.Results.mdaDir;
mtnSortFolder = p.Results.mtnSortFolder;
pattern = p.Results.pattern;
trodeList = p.Results.trodeList;

if mdaDir(end)==filesep
    mdaDir = mdaDir(1:end-1);
end
if mtnSortFolder(end)==filesep
    mtnSortFolder = mtnSortFolder(1:end-1);
end

%% Find valid trode mda files, select trode files to sort
trodeFileList = findRawTrodeMdas(mdaDir,pattern);
if ~isempty(trodeList)
    disp('restricting to tetrodes:')
    disp(trodeList')
    missing = setdiff(trodeList,[trodeFileList.tet]);
    if ~isempty(missing)
        disp('Could not find data for days:')
        disp(missing)
    end
    [~,keepInd] = intersect([trodeFileList.tet],trodeList);
    trodeFileList = trodeFileList(keepInd);
end

%% Sort trodes
nTrodes = numel(trodeFileList);
needTimeStamps = true;
for iTrode = 1:nTrodes
    trodeSortFolder = [mtnSortFolder, filesep, 'nt',int2str(trodeFileList(iTrode).tet),'.mountain'];
    trodeMda = [mdaDir, filesep, trodeFileList(iTrode).filename];
    msortTrode(trodeSortFolder, trodeMda, 'needTimeStamps', needTimeStamps);
    needTimeStamps = false; % Only need to do this 1x per rec
end

end