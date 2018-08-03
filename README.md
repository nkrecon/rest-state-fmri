#  Docker and Singularity images for Resting State FMRI pipeline (Nan-kuei Chen/Duke University) 
Please refer to [https://wiki.biac.duke.edu/biac:analysis:resting_pipeline](https://wiki.biac.duke.edu/biac:analysis:resting_pipeline) for details of use.

# Summary
This repository contains the build scripts for Docker and Singularity images of the Duke resting pipeline that perform processing of resting state data using FSL (Jenkinson et al. 2012) tools and custom scripts.

version information can be obtained as `docker run --rm orbisys/rest-state-fmri -V` and `singularity run rest-state-fmri.simg -V`
help information can be obtained as `docker run --rm orbisys/rest-state-fmri -h` and `singularity run rest-state-fmri.simg -h`

The Docker image will be about 3GB when built. It comes with version 5.09 of FSL.
Alternatively if you do not want to build the docker image locally you can pull it from the Docker hub using the command `docker run -it --rm -v $PWD:/opt/data orbisys/rest-state-fmri` or `docker pull orbisys/rest-state-fmri`

The Singularity image will be about 4GB when built. It comes with version 5.10 of FSL. Again if you prefer not to build this locally then a sister version of this singularity image can be downloaded as `Singularity pull shub://chidiugonna/nklab-neuro-reststate`

## Introduction
The original python source  `resting_pipeline.py` available at at [https://wiki.biac.duke.edu/biac:analysis:resting_pipeline] has been slightly amended. These changes are:

* `data1` has been selectively converted to dtype `numpy.float64`
* slice indices have been cast as longs in certain instances.
* BXH functionality is ignored. To explicitly use BXH info pass the flag --ignorebxh=N
* Changes have been made in step 8 to force the diagonals of the correlation matrix to zero to prevent inconsistencies due to NaNs.

### Sliding window functionality
A new step has been added `-7sw` to enable sliding window functionality. In order to use this step you will need to use the `--slidewin` parameter which takes 2 numbers seperated by a comma. The 1st number is the window size in seconds and the second number is the shift in seconds between sequential windows. So for example `--slidewin=60,3` will use a window size of `60` seconds shifted by `3` seconds for each subsequent window. Keep in mind that the `--tr` (in milliseconds) parameter is required to calculate the number of volumes to use for each sliding window correlation. If you do not specify the --slidwin parameter and run step `7sw` then default values of `30,3` will be used. Sliding window files are exported to a new directory `SlidingWindow_W_S` and image files are consolidated into 4D volumes for viewing in FSL as a movie 

### Extensions to Slice Correction functionality
The pipeline has been extended to accept custom slice correction timing files. A python script `make_fsl_stc.py` has been bundled in this container which can take .json files created by dcm2niix. This python program will create a slice correction file with timing values and one with slices in order of acquisition. It can be called as follows:

`/opt/rsfmri_python/bin/make_fsl_stc.py fmri.json` where fmri.json is the json output from dcm2niix. custom names for the slice order and slice time files can be provided as parameters as follows:

`make_fsl_stc.py fmri.json  --slicenum=/path/num.txt --slicetime=/path/time.txt` 

Otherwise these files default to `sliceorder.txt` and `slicetimes.txt` in the current directory.

If `--slicetime`  is provided and --sliceorder is not then only the slicetimes textfile is created. The opposite is true if `--slicenum` is provided.

Once these custom files have been created then they can be provided to the resting state pipeline using the full path as input to the `--sliceorder` parameter 
`--sliceorder=/path/num.txt` as follows `docker run  --rm  -v $PWD:/opt/data  orbisys/rest-state-fmri  /opt/rsfmri_python/bin/resting_pipeline.py --func /opt/data/fmri-std-pre.nii.gz -o restoutput --steps=1,2,3,4,5,6,7,8 --slidewin=30,3 --sliceorder=/opt/data/slicetimes.txt --slicetiming=time --tr=3000` 

please note that the default custom slice file expected uses slice order. If you pass a text file with slice times then you will need to use another parameter `--slicetimings=time` 


## Docker

### Build Docker Image

* You will need to have docker installed. Simply clone this repository to a convenient directory.
* Navigate into the `rest-state-fmri`directory and check that have a Docker file `Dockerfile` and the directory `src`
* Confirm that `src` folder and the `src/resting_pipeline.py` file have full read and write privileges. if not then `sudo chmod -R 777 src` should accomplish this.
* Now build the image as follows `sudo docker build -t orbisys/rest-state-fmri .`


### Run Docker Image
#### Within Shell
* Navigate to a directory with a test NIFTII image and enter `docker run -it --rm -v $PWD:/opt/data --entrypoint /bin/bash orbisys/rest-state-fmri`
* The docker image should run and automatically start in `/opt/data` directory which is mapped to the original directory from which you ran the image. The prompt should look something like below:
`root@62e040b47368:/opt/data#`
* You can now run the pipeline with the shell as follows: `resting_pipeline.py --func PBIA6_26386_20140402_045154_93696_magnitude.nii --throwaway=4 --steps=2,3,4,5,6,7 -o PBIA6_26386_20140402_045154_93696 --sliceorder=odd --tr=5000`

#### As a one line command
* Navigate to a directory with a test NIFTII image and enter: 
`docker run  --rm  -v $PWD:/opt/data  orbisys/rest-state-fmri  /opt/rsfmri_python/bin/resting_pipeline.py --func moco14a0001.nii.gz --steps=1,2,3,4,5,6,7,8 -o 14a0001 --sliceorder="even" --tr=3000`


#### Running Gui within docker
To access GUI interaces of programs in the docker image then use the construct shown next (Courtesy of work by Fabio Rehm [https://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/] ). For example to run FSL as GUI then perform the following:

`sudo docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/developer/.Xauthority -it --net=host --pid=host --ipc=host orbisys/rest-state-fmri fsl`

### Example Commands
#### Create Slice Timing files from json
`docker run --rm -v $PWD:/opt/data  orbisys/rest-state-fmri /opt/rsfmri_python/bin/make_fsl_stc.py fmri.json`

#### Run pipeline (also runs sliding window with window-30s, shift=3s) using custom slice timing file
`docker run  --rm  -v $PWD:/opt/data  orbisys/rest-state-fmri  /opt/rsfmri_python/bin/resting_pipeline.py --func /opt/data/fmri-std-pre.nii.gz -o restoutput --steps=1,2,3,4,5,6,7,8 --slidewin=30,3 --sliceorder=/opt/data/slicetimes.txt --slicetiming=time --tr=3000`

## Singularity

### Build Singularity Image

* You will need to have singularity 2.4 or greater installed. Simply clone this repository to a convenient directory.
* Navigate into the `rest-state-fmri`directory and check that you have a Singularity definiton file `Singularity` and the directory `src`
* Confirm that `src` folder and all the files in `src` have full read and write privileges. if not then `sudo chmod -R 777 src` should accomplish this.
* Now build the image as follows `sudo singularity build rest-state-fmri.simg Singularity`

### Run Singularity Image
* You can now run the pipeline as follows: `singularity run nklab-reststate-fmri.simg /opt/rsfmri_python/bin/resting_pipeline.py --func PBIA6_26386_20140402_045154_93696_magnitude.nii --throwaway=4 --steps=2,3,4,5,6,7 -o PBIA6_26386_20140402_045154_93696 --sliceorder=odd --tr=5000`
* You can also run FSL commands (e.g. flirt) directly as follows: `singularity run --nv rest-state-fmri.simg /opt/fsl/bin/flirt ....`

### Shell into Singularity Image
* You can shell into the singularity image using: `singularity shell rest-state-fmri.simg` 

### Example Commands
#### Create Slice Timing files from json
`singularity run  -B $PWD:/opt/data nklab-reststate-fmri.simg /opt/rsfmri_python/bin/make_fsl_stc.py fmri.json`

#### Run pipeline (also runs sliding window with window-30s, shift=3s) using custom slice timing file
`singularity run  --rm  -B $PWD:/opt/data  nklab-reststate-fmri.simg  /opt/rsfmri_python/bin/resting_pipeline.py --func /opt/data/fmri-std-pre.nii.gz -o restoutput --steps=1,2,3,4,5,6,7,8 --slidewin=30,3 --sliceorder=/opt/data/slicetimes.txt --slicetiming=time --tr=3000`

## References
M. Jenkinson, C.F. Beckmann, T.E. Behrens, M.W. Woolrich, S.M. Smith. FSL. NeuroImage, 62:782-90, 2012 

