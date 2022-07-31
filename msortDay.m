function msort_rec()



disp('Processing raw data with mountain lab. Processing:')
disp(dayDirs')
if ~isempty(tet_list)
    disp('restricting to tetrodes:')
    disp(tet_list')
end

   % Run mda_util, returns list of tetrode results directories
    resDirs = mda_util(dayDirs,'tet_list',tet_list,'dataDir',dataDir);
    dayResDirs = cell(numel(dayDirs),1);
    dayIdx = 1;
    maskErrors = zeros(numel(resDirs),1);



end