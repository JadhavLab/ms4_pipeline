function msortTrode(mtnSortFolder, sourceTrodeFileName)

MASK_ARTIFACTS = 1;
IGNORE_TIMESTAMPS = false;
PARAMS = struct('samplerate',30000);

if isempty(sourceTrodeFileName) % Assume already imported.
else
    createMtnSortDir(sourceTrodeFileName, mtnSortFolder, PARAMS, IGNORE_TIMESTAMPS);
end

diary([mtnSortFolder filesep 'ml_sorting.log'])
fprintf('\n\n------\nBeginning analysis of %s\nDate: %s\n\nBandpass Filtering, Masking out artifacts and Whitening...\n------\n',...
    mtnSortFolder,datestr(datetime('Now')));

% filter mask and whiten
% TODO: Add check to make sure there is data in the mda files, maybe up in mda_util
[processesdFileName,maskErrors] = ml_filter_mask_whiten(mtnSortFolder,'mask_artifacts',MASK_ARTIFACTS);
% returns path to pre.mda.prv file

fprintf('\n\n------\nPreprocessing of data done. Written to %s\n------\n',processesdFileName)

fprintf('\n------\nBeginning Sorting and curation...\n------\n')
% Sort and curate
sortOutput = ml_sort_on_segs(mtnSortFolder);
% returns paths to firings_raw.mda, metrics_raw.json and firings_curated.mda
%fprintf('\n\nSorting done. outputs saved at:\n    %s\n    %s\n    %s\n',out2{1},out2{2},out2{3})
fprintf('\n\n------\nSorting done. outputs saved at:\n    %s\n    %s\n------\n',sortOutput{1},sortOutput{2})

% Delete intermediate files
%if ~keep_intermediates
%    tmpDir = '/tmp/mountainlab-tmp/';
%    disp('Removing intermediate processing mda files...')
%    delete([tmpDir '*.mda'])
%end

if maskErrors
    fprintf('\n######\nMasking error for this trode. Masking Artifacts skipped. Spikes may be noisy\n######\n')
end

diary off


end