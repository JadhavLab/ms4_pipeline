function trodeFileList = findRawTrodeMdas(mdaDir,pattern)
    
    %% Input handling:
    if isempty(pattern)
        pattern = '(?<animalID>[A-Z]+[0-9]+)_D(?<recID>[0-9]{2}).nt(?<tet>[0-9]+).mda';
    end
    if mdaDir(end)==filesep
        mdaDir = mdaDir(1:end-1);
    end
        
    % Initialize Output
    trodeFileList = {};

    if isfolder(mdaDir)
        mdaFiles = dir([mdaDir filesep '*nt*.mda']);
        if isempty(mdaFiles)
            disp('no valid tetrode files');
        else
            trodeFileList = regexp([mdaFiles.name],pattern,'names');
            [trodeFileList.filename] = deal(mdaFiles.name);
            nTrodes = numel(trodeFileList);
            for iTrode = 1:nTrodes
                trodeFileList(iTrode).day  = str2double(trodeFileList(iTrode).day);
                trodeFileList(iTrode).tet  = str2double(trodeFileList(iTrode).tet);
            end
        end
    else
        disp('not a valid folder');
    end