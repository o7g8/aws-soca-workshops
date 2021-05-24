#!/usr/bin/make -f
#
# Copyright (c)2020 System Fabric Works, Inc.
#

A320-geometry=A320/A320-mesh.org/constant/triSurface/A320.stl
A320-zip=A320-tutorial-OpenFOAM-17.10.zip
A320-url=https://www.cfdsupport.com/download-cases-a320.html

all:: $(A320-geometry)

$(A320-geometry): A320-tutorial-OpenFOAM-17.10.zip
	unzip $(A320-zip) $(A320-geometry)

A320-tutorial-OpenFOAM-17.10.zip:
	@echo "ERROR: does not exist: $(PWD)/$(A320-url)"
	@echo "Please register at https://www.cfdsupport.com/download-cases-a320.html"
	@echo "Download $(A320-zip)and copy it to $(PWD)."
	@exit 1


