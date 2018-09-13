function out = mda_util(dayDirs,varargin)
    % out = mda_util(dayDirs,varargin)
    % dayDirs should be a list of raw day directories, each containing a .mda folder
    % use exportmda or RN_TrodesExtractionBuilder to generate mda files from rec files
    % reorganizes raw extracted mda files into a .mnt directory with symlinks
    % so that data can be easily passed to mountainsort
    % Required: recording files have names AnimID_Day_Date_Epoch (e.g.
    % RZ2_02_180228_1Sleep or RW2_01_20180913_2Linear)
    % Required Directory Structure:
    %   -ExpFolder
    %   |-> animID (raw directory)
    %       |-> 01_181011 (day directory)
    %           |-> animID_01_181011.mda (mda directory)
    %           .
    %           .
    %       .
    %       .
    %    |-> animID_direct  (results directory)
    % NAME-VALUE Pairs:
    %   params  : structure with params for clustering (default = struct('samplerate',3000)) 
    
    params = struct('samplerate',30000);
    assignVars(varargin)
    if ~any(strcmpi(fieldnames(params),'samplerate'))
        params.samplerate = 30000;
    end

    if ~iscell(dayDirs)
        dayDirs = {dayDirs};
    end
    out = cell(numel(dayDirs),1);
    for k=1:numel(dayDirs)
        dd = dayDirs{k};
        [~,a] = fileparts(dd);
        if ~isdir(dd) || (isempty(a) || all(a=='.'))
            continue;
        end
        
        if dd(end)==filesep
            dd = dd(1:end-1);
        end
        topDir = fileparts(fileparts(dd));
        mdaDir = dir([dd filesep '*.mda']);
        pat = '(?<anim>[A-Z]+[0-9]+)_(?<day>[0-9]{2})_(?<date>[0-9]+)_*(?<epoch>[0-9]*)(?<epoch_name>\w*).mda';
        parsed = regexp(mdaDir.name,pat,'names');
    %    mntDir = [parsed.anim,'_',parsed.day,'_',parsed.date,'.mnt',filesep];
        dataDir = [topDir filesep parsed.anim '_direct' filesep];
        resDir = [dataDir 'MountainSort' filesep parsed.anim '_' parsed.day '_' parsed.date '.mountain' filesep];
        mkTree(resDir);
     %   mkdir([dd filesep mntDir])

        mdaFiles = dir([mdaDir.folder filesep mdaDir.name filesep '*.mda']);
        pat2 = '(?<anim>[A-Z]+[0-9]+)_(?<day>[0-9]{2})_(?<date>[0-9]+)_*(?<epoch>[0-9]*)(?<epoch_name>\w*).nt(?<tet>[0-9]+).mda';
        for l=1:numel(mdaFiles)
            parsedF = regexp(mdaFiles(l).name,pat2,'names');
            if isempty(parsedF)
                continue;
            end
      %      tetDir = [mntDir parsed.anim '_' parsed.day '_' parsed.date '.nt' parsedF.tet '.mnt' filesep];
            tetResDir = [resDir parsed.anim '_' parsed.day '_' parsed.date '.nt' parsedF.tet '.mountain' filesep];
            mkTree(tetResDir);
            % make params file
            fid = fopen([tetResDir 'params.json'],'w+');
            fwrite(fid,jsonencode(params));
            fclose(fid);

            % create prv file
            srcFile = [mdaFiles(l).folder filesep mdaFiles(l).name];
            destFile = [tetResDir 'raw.mda.prv'];
            create_prv(srcFile,destFile);
       %     mkdir([dd filesep tetDir]);
       %     lnStr = sprintf('ln -s %s %s',[mdaFiles(l).folder filesep mdaFiles(l).name],[dd filesep tetDir filesep mdaFiles(l).name]);
       %     system(lnStr);
        end
        out{k} = resDir;
    end
