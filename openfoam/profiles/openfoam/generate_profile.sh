#!/bin/bash

PROFILE=profile.csv
echo -n '3,bsmith,OpenFOAM22,' > $PROFILE

base64 -w0 profile.json >> $PROFILE
echo -n ',' >> $PROFILE

base64 -w0 pbs_script >> $PROFILE
echo -n ',qsub,' >> $PROFILE

echo -n '"data:image/png;base64,' >> $PROFILE
base64 -w0 thumbnail.png >> $PROFILE

echo -n '",,,"2021-06-02 01:36:41",' >> $PROFILE