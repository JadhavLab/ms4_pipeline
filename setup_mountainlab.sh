#!/bin/bash
cd Downloads
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3.sh && \
bash miniconda3.sh -bp ~/conda && \
echo ". ~/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
conda activate base && \
conda update conda && \
conda config --set max_shlvl 1 && \
conda install -c flatiron -c conda-forge mountainlab mountainlab_pytools && \
touch ~/conda/etc/mountainlab/mountainlab.env
ml-config
conda install -c flatiron -c conda-forge ml_ephys ml_ms4alg && \
if [ -x "$(command -v lolcat)" ] && [ -x "$(command -v figlet)" ]; then
    echo 'mountainlab setup complete' | figlet | lolcat
    echo 'add ~/conda/lib/node_modules/mountainlab/utilities/matlab/mdaio/ to matlab path' | lolcat
else
    echo 'mountainlab setup complete'
    echo 'add ~/conda/lib/node_modules/mountainlab/utilities/matlab/mdaio/ to matlab path'
fi

