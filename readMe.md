Mountainlab-JS for JadhavLab
======

Repository for Jadhav Lab code for the use of MountainSort-JS

Setup
------
* Download and install miniconda

```shell
        wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda3.sh
        bash miniconda3.sh -bp ~/conda
        echo ". ~/conda/etc/profile.d/conda.sh" >> ~/.bashrc
```

* Setup a conda environment and install mountainlab and all processors

```shell
        conda create --name mlab
        conda activate mlab
        conda update conda
        conda config --set max_shlvl 1
        conda install -c flatiron -c conda-forge mountainlab mountainlab_pytools ml_ephys ml_ms4alg ml_ms3 ml_pyms qt-mountainview
```
* Add `~/conda/env/mlab/lib/node_modules/mountainlab/utilities/matlab/mdaio/` to your matlab path

* Get additional processors from franklab for drift tracking and tagged curation
    * [Tagged Curation](https://bitbucket.org/franklab/franklab_mstaggedcuration/src/master/)
    * [Drift Tracking](https://bitbucket.org/franklab/franklab_msdrift/src/master/)
    * These should be cloned into `~/.mountainlab/packages/`

* Create configuration file for mountainlab
    * `touch ~/conda/env/mlab/etc/mountainlab/mountainlab.env`
    * Now you can set the temporary directory path to be on the same drive as your data
    * Also add the `~/.mountainlab/packages/` to the mountainlab package search path
    * Just modify and add these lines to the `mountainlab.env` file you created:
        * `ML_TEMPORARY_DIRECTORY='/path/to/data/drive/tmp/mountainlab-tmp'`
        * `ML_ADDITIONAL_PACKAGE_SEARCH_DIRECTORIES='~/.mountainlab/packages'`

### Updates 9-23-18
The franklab msdrift and mstaggedcuration packages will throw errors as is due to changes in package locations in the new mountainlab-js. So instead copy the `franklab_mstaggedcuration` and `franklab_msdrift` folder from this repository into `~/.mountainlab/packages/`. 
