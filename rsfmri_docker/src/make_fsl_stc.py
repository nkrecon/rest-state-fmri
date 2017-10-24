#!/usr/bin/env python
from __future__ import (absolute_import, division,
                        print_function, unicode_literals)

import json
import os
import argparse
parser = argparse.ArgumentParser(description="Setup all parameters for slice time correction file generation for FSL")
parser.add_argument("jsonfile",help="location of json file provided by dcm2niix -b during dicom conversion.")
parser.add_argument("--slicetime",help="name and location to place slice timing file with slice times for each slice acquired.")
parser.add_argument("--slicenum",help="name and location to place slice timing file with slices in order of acquisition.")
args=parser.parse_args()

if args.slicetime:
	slicetimefile=os.path.abspath(args.slicetime)
else:
	slicetimefile=os.path.join(os.getcwd(),'slicetimes.txt')

if args.slicetime:
	slicenumfile=os.path.abspath(args.slicenum)
else:
	slicenumfile=os.path.join(os.getcwd(),'sliceorder.txt')

json_file=open(args.jsonfile)
info = json.load(json_file)
slicetime=info['SliceTiming']
TR=float(info['RepetitionTime'])
reftime=TR/2
slicelist = [ (sliceidx+1,(float(sliceval) - reftime)/TR, sliceval) for sliceidx,sliceval in enumerate(slicetime)]
sortedSlices = sorted(slicelist, key=lambda tup: tup[1])

slicetimes=[str(sliceinfo[1]) for sliceinfo in slicelist]
slicenums=[str(sliceinfo[0]) for sliceinfo in sortedSlices]

slicetimef=open(slicetimefile,'w')
slicetimef.write("\n".join(slicetimes))

slicenumf=open(slicenumfile,'w')
slicenumf.write("\n".join(slicenums))