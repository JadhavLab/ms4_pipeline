function createMtnSortDir(trodeFileName, destFolder, params, ignoreTimestamps)
% Assumes there is a timestamps.mda in the same folder as the trode


if destFolder(end)==filesep
    destFolder = destFolder(1:end-1);
end

mkdir(destFolder);

% make params file
fid = fopen([destFolder filesep 'params.json'],'w+');
fwrite(fid,jsonencode(params));
fclose(fid);

% create prv file
destFile = [destFolder filesep 'raw.mda.prv'];
create_prv(trodeFileName,destFile);

if ~ignoreTimestamps
    % add timestamps to parent folder if not already there
    origDir = pwd;
    destParentFolder = fileparts(destFolder);
    cd(destParentFolder);
    timestampFileSearch = dir('*timeStamps.mda.prv');

    if isempty(timestampFileSearch)
        % Find source file, create pointer file
        mdaFolder = fileparts(trodeFileName);
        cd(mdaFolder);
        timestampSourceFile = dir('*timestamps.mda');
        create_prv(fullfile(timestampSourceFile.folder,timestampSourceFile.name),...
            [destParentFolder filesep timestampSourceFile.name '.prv']);
    end

    cd(origDir);
end
end