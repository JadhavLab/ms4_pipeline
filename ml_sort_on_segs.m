function out = ml_sort_on_segs(resDir,varargin)


    geom = [];
    adjacency_radius = -1;
    detect_sign=1;
    detect_threshold = 3;
    tet_list = [];

    assignVars(varargin)


    % Get tetrode list
    tetDirs = dir([resDir filesep '*.nt*']);
    tetDirs = {tetDirs.name};
    pat = '\w+.nt(?<tet>[0-9]+).\w+';
    tmp = cellfun(@(x) regexp(x,pat,'names'),tetDirs);
    allTets = str2double({tmp.tet});
    if isempty(tet_list)
        tet_list = allTets;
    else
        missing = setdiff(tet_list,allTets);
        tet_list = intersect(tet_list,allTets);
        if ~isempty(missing)
            disp('Cannot find data for tetrodes:')
            disp(missing)
        end
        keep = arrayfun(@(x) find(allTets==x),tet_list);
        tetDirs = tetDirs(keep);
    end
