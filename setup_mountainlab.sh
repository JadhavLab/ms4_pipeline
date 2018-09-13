cd Downloads
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3.sh
bash miniconda3.sh -bp ~/conda
echo ". ~/conda/etc/profile.d/conda.sh" >> ~/.bashrc # or zshrc if you use zsh
conda activate base
conda update conda
conda config --set max_shlvl 1
conda install -c flatiron -c conda-forge mountainlab mountainlab_pytools
touch ~/conda/etc/mountainlab/mountainlab.env
ml-config
conda install -c flatiron -c conda-forge ml_ephys
echo 'mountainlab setup complete'
echo 'add ~/conda/lib/node_modules/mountainlab/utilities/matlab/mdaio/ to matlab path'
