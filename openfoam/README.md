Download the HPC Kit:

https://software.intel.com/content/www/us/en/develop/tools/oneapi/hpc-toolkit/download.html?operatingsystem=linux&distributions=webdownload&options=offline

or do 

```bash
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/17764/l_HPCKit_p_2021.2.0.2997_offline.sh 
```

Configure the build machine:

```bash
./configure-build-machine l_HPCKit_p_2021.2.0.2997_offline.sh --accept-eula
```

Build OpenFOAM:

```bash
sudo ./build-openfoam  &>log 
```

