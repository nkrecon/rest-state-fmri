#  Docker image for Resting State FMRI pipeline (Nan-kuei Chen/Duke University) 
Please refer to [https://wiki.biac.duke.edu/biac:analysis:resting_pipeline](https://wiki.biac.duke.edu/biac:analysis:resting_pipeline) for details of use.

## Introduction
The original python source available at the link above `resting_pipeline.py` has been slightly amended and is included in this repository in the folder `src`. These changes are:

* `data1` has been selectively converted to dtype `numpy.float64`
* slice indices have been cast as longs in certain instances.

## Build Docker Image

* You will need to have docker installed. Simply clone this repository to a convenient directory.
* Navigate to the directory and check that all you have is the `Dockerfile` and the directory `src`
* Change permissions on `src` and on `src/resting_pipeline.py` so that they have full read and write privileges. `sudo chmod -R 777 src` should accomplish this.
* Now build the image as follows `sudo docker build -t rsfmri_duke .`


## Run Docker Image

* Navigate to a directory with a test NIFTII image and enter `docker run -it —-rm -v $PWD:/opt/data rsfmri_duke`
* The docker image should run and automatically start in `/opt/data` directory which is mapped to the original directory from which you ran the image. The prompt should look something like below:  
`root@62e040b47368:/opt/data#`
* You can now run the pipeline as follows: `resting_pipeline.py --func PBIA6_26386_20140402_045154_93696_magnitude.nii --throwaway=4 --steps=2,3,4,5,6,7 -o PBIA6_26386_20140402_045154_93696 --sliceorder=odd --tr=5000`

