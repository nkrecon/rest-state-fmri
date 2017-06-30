#  Docker and Singularity images for Resting State FMRI pipeline (Nan-kuei Chen/Duke University) 
Please refer to [https://wiki.biac.duke.edu/biac:analysis:resting_pipeline](https://wiki.biac.duke.edu/biac:analysis:resting_pipeline) for details of use.

The Docker image will be about 3GB when built. It comes with version 5.09 of FSL.
Alternatively if you do not want to build the the docker image locally you can pull it from the Docker hub using the command `docker run -it —-rm -v $PWD:/opt/data orbisys/rsfmri_duke` or `docker pull orbisys/rsfmri_duke`

The Singularity image will be about 11GB when built. It comes with version 5.10 of FSL and has CUDA 7.5 libraries installed.
Alternatively if you dou not want to build the singularity image you can pull it from the Singularity Hub using the command `singularity pull shub://chidiugonna/nkfmri-singularity-test`

## Introduction
The original python source available at the link above `resting_pipeline.py` has been slightly amended and is included in this repository in the folder `src`. These changes are:

* `data1` has been selectively converted to dtype `numpy.float64`
* slice indices have been cast as longs in certain instances.

## Docker

### Build Docker Image

* You will need to have docker installed. Simply clone this repository to a convenient directory.
* Navigate into the `rest-state-fmri`directory and check that all you have a Docker file `Dockerfile` and the directory `src`
* Confirm that `src` folder and the `src/resting_pipeline.py` file have full read and write privileges. if not then `sudo chmod -R 777 src` should accomplish this.
* Now build the image as follows `sudo docker build -t orbisys/rsfmri_duke .`


### Run Docker Image

* Navigate to a directory with a test NIFTII image and enter `docker run -it --rm -v $PWD:/opt/data orbisys/rsfmri_duke`
* The docker image should run and automatically start in `/opt/data` directory which is mapped to the original directory from which you ran the image. The prompt should look something like below:  
`root@62e040b47368:/opt/data#`
* You can now run the pipeline as follows: `resting_pipeline.py --func PBIA6_26386_20140402_045154_93696_magnitude.nii --throwaway=4 --steps=2,3,4,5,6,7 -o PBIA6_26386_20140402_045154_93696 --sliceorder=odd --tr=5000`


## Singularity

### Build Singularity Image

* You will need to have singularity 2.3.1 installed. Simply clone this repository to a convenient directory.
* Navigate into the `rest-state-fmri`directory and check that you have a Singularity definiton file `rsfmriSingCuda.1.0.1.def` and the directory `src`
* Confirm that `src` folder and the `src/resting_pipeline.py` file have full read and write privileges. if not then `sudo chmod -R 777 src` should accomplish this.
* Create a singularity image as `sudo singularity create --size 11048 rsfmriSingCuda.1.0.1.img`
* Now build the image as follows `sudo singularity bootstrap rsfmriSingCuda.1.0.1.img rsfmriSingCuda.1.0.1.def`

### Run Singularity Image
* You can now run the pipeline as follows: `singularity run rsfmriSingCuda.1.0.1.img /opt/rsfmri_python/bin/resting_pipeline.py--func PBIA6_26386_20140402_045154_93696_magnitude.nii --throwaway=4 --steps=2,3,4,5,6,7 -o PBIA6_26386_20140402_045154_93696 --sliceorder=odd --tr=5000`
* You can als run FSL commands directly as follows: `singularity run --nv rsfmriSingCuda.1.0.img /opt/fsl/bin/eddy_cuda --imain=G1_1_OFF_28271_cgm --mask=G1_1_OFF_28271_cgm0_brain_mask --acqp=acqparams.txt --index=index.txt --bvecs=bvecs --bvals=bvals --out=G1_1_OFF_28271_cgm_eddy`