
# Issue Quota Change Quota Requests

Approvals for quota increases have to be approved by AWS Support, and this process can take
up to a day.

The scheduler uses 4 "M instance" vCPUs. The default quota for On-Demand Standard instances
is 5, which leaves a single vCPU available for SOCA workloads. That limit needs to be
increased before SOCA will be able to execute any workloads.

Note that quotas are for vCPUs, not CPUs. In general, there are 2 vCPUs per CPU.
This means that if you plan to have up to 4 instances of c5.18xlarge running at the
same time, there are 36 CPUs per machine * 2 * 4 machines + 4 scheduler VPUs = 148 vCPUs.

There is no AWS charge for having a higher quota. However, a higher quota does allow SOCA
to have more EC2 machine instances active at one time and this can result in significant
EC2 charges.

1. https://console.aws.amazon.com/servicequotas
2. Click "Elastic Compute Cloud" button.
3. Search "Running On-Demand G instances". Request 16 vCPUs. This quota allows use of a single
   g3.4xlarge instance for 3D desktop sessions.
4. Search "Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances". Request 360 vCPUs.

AWS Support will respond in AWS Console and via email updates regarding the Quate Change
Request.

These quotas can be changed at a later time by creating additional Quota Change Requests in AWS
Console.

# Install SOCA

1. `$ git clone https://github.com/awslabs/scale-out-computing-on-aws`
2. `$ cd scale-out-computing-on-aws`
3. `$ git checkout tags/2.6.1`
4. `$ python3 ./source/manual_build.py`
5. Follow the instructions output by the script. 
6. Click on the soca cluster stack in Stacks. It will be have the same name that you provided for the cluster.
   The stack's description will be "Scale-Out Computing on AWS. Template version 2.6.1".
7. Click on the Outputs tab for the Stack.
8. Copy the value for WebUserInterface and paste it in a document for later reference. This is the URL that will be used to access the SOCA User Interface.
9. Copy the value for SchedulerPublicIP and paste it in a document for later reference. This is the IP address used to acess the scheduler.

# Configure SOCA Account SSH Access

1. Visit SOCA's User Interface in your browser.
2. Login using the information that was provided to the CloudFormation form.
3. Click "SSH Access" on the left navigation bar.
4. Follow the instructions for downloading your private key.

# Configure the Scheduler

1. Login to the scheduler via ssh.
2. `git clone path-to-gitrepo`
3. `cd aws-soca-workshops`
4. `sudo ./1-configure-scheduler`
5. `sudo ./2-install-apps`

# Configure Compute Node AMI

1. Follow the instructions at https://awslabs.github.io/scale-out-computing-on-aws/tutorials/reduce-compute-node-launch-time-with-custom-ami/ to create an AMI.
    1. Choose Amazon Linux 2 HVM x86 AMI.
    2. Instance type c5.4xlarge is recommended. Any c5 or m5 machine will be fine.
    3. Choose a security group that has ssh access.
    4. Steps in section 3 are optional.
    5. Stop before proceeding to section 4.
    6. Copy the machine instance's public IP address to a document for reference. This is the address that will be used for copying files to and logging into the machine.
2. Download Intel MPI on the temporary machine `wget https://registrationcenter-download.intel.com/akdlm/irc_nas/17729/l_mpi_oneapi_p_2021.2.0.215_offline.sh`. In case you want to try a newer version of MPI go to https://software.seek.intel.com/performance-libraries
    1. Click on "Component Binary Packages -- M".
    2. Save the URL pointed by "Intel MPI Library for Linux Version 20XX.X.X" and  download the file on the temporary machine.
    3. Newer versions may work with the software packages used in this
       workshop. However, the testing was performed with `2021.2.0.215`. Also,
       using a newer version will require changing the paths for Intel MPI
       in the OpenFOAM application profile form. Older versions are NOT
       recommended.
3. Copy `configure-temporary-machine-for-ami` to the temporary machine instance. Note that
   the machine is configured to use the ssh key specified during the launch instance process and the
   user name is ec2-user.
4. `$ sudo ./configure-temporary-machine-for-ami l_mpi_oneapi_p_2021.2.0.215_offline.sh --accept-eula`
5. Clean up the ec2-user's home directory. e.g. `$ cd ~ec2-user && sudo rm -rf l_mpi* build* install.*`
6. Continue with step 4 of the AMI creation instructions.
7. Copy the AMI ID to a document for later reference. This will be the AMI ID
   used for Desktop Sessions and Job Submissions.
8. Register the AMI with SOCA: login to your SOCA web interface and go to "AMI management" under "Admin" section. Fill out the form: specify the AMI ID, operating system (Linux), minimum storage requirement (50Gb) as well as pick a friendly label (e.g. OpenFOAM).
# Install Mesh A320 Geomatry (not needed, is a part of workshop Git)

1. Register at https://www.cfdsupport.com/download-cases-a321.html and follow
instructions for downloading A320-tutorial-OpenFOAM-17.10.zip
2. Copy the ZIP file to the scheduler node.
3. `$ cd /apps/aws-workshops/openfoam/models`
4. `$ sudo cp $HOME/A320-tutorial-OpenFOAM-17.10.zip .`
5. `$ sudo make`
   The STL will be extracted to A320/A320-mesh.org/constant/triSurface/A320.stl.

# Launch Visualization Session

1. Visit the SOCA User Interface with a web browser and login.
2. Click on "Linux Desktop"
3. Choose Session Type "3D - Small" (or a smaller session if capacity doesn't allow).
4. Click "Software Stack" and choose your custom AMI (OpenFOAM).
5. Launch the session.

# Launch FreeCAD

1. Login to a desktop session.
2. Click on **Applications -> System Tools -> Terminal**
3. Launch FreeCAD: `$ /opt/aws-workshops/freecad/freecad`

# Execute A320 Mesh

1. `cp -r /apps/aws-workshops/openfoam/models/A320 $HOME`
1. In SOCA User Interface, click Submit Job (Web).
2. Select `A320/A320-mesh.conf` as the input file.
3. In "What software do you want to run?", select OpenFOAM.
4. Complete the submission form. For simplicity of this example, use the default settings except for the following:
    1. Instance type 'Mesh Medium' is recommended.
    2. In 'How many CPUs', enter the quantity of CPUs (8). This should be the same quantity of CPUs that is offered by the
       instance type.
    3. In 'ID for instance AMI', enter the id of the custom AMI created earlier (e.g. ami-0d76e1a9ec404616a).
5. Click 'Submit Job'. The current job queue will be displayed, and will contain an entry
    for the newly created job with state 'Queued'.
6. After about 7 minutes, the job should enter a state of 'Running'. The job should take about
    18 minutes to complete, depending upon the number of CPUs selected.
    1. Job progress can by monitored via `soca_job_output/JOB_ID/log.all` (see "My Files" section in the SOCA UI). This path
       will not exist until the job is Running.
7. Once the job completes, the PBS log is available in `soca_job_output/logs/JOB_ID.OU`

# Execute A320 Case-Stationary

1. In SOCA User Interface, click Submit Job (Web).
2. Select `soca_job_output/JOB_ID/A320/A320-solve-stationary.conf` as the input file. `JOB_ID` is the ID of a
   successful A320 mesh job.
3. In "What software do you want to run?", select OpenFOAM.
4. Complete the submission form. For simplicity of the example, use the default settings except for the following:
    1. Instance type 'Solve Large' is recommended.
    2. In 'How many CPUs', enter the quantity of CPUs.
       1. This should be at least same quantity of CPUs that is offered by the instance type.
       2. If multiple nodes are desired, multiple the instance type CPU quantity by the number
          of nodes desired. For example, If 'Solve Large (18 CPUs)' is selected and 2 nodes are
	  desired, enter 36 CPUs.
    3. In 'ID for instance AMI', enter the id of the custom AMI created earlier (e.g. ami-0d76e1a9ec404616a).
5. Click 'Submit Job'. The current job queue will be displayed, and will contain an entry
    for the newly created job with state 'Queued'.
6. After about 7 minutes, the job should enter a state of 'Running'. The job should take about
    26 minutes to complete, depending upon the number of CPUs selected.
    1. Job progress can by monitored via `soca_job_output/JOB_ID/log.all`. This path
       will not exist until the job is Running.
7. Once the job completes, the PBS log is available in `soca_job_output/logs/JOB_ID.OU`

# Launch ParaView

1. Login to your visualization session started earlier (it must be a GPU Workstation).
2. Click on Applications -> System Tools -> Terminal
3. Change directory to a processed model directory. e.g `$ cd ~/soca_job_output/3.ip-10-0-26-16/A320/A320-mesh `
4. Launch ParaView: `$ /opt/aws-workshops/bin/runParaFoam -builtin`

# OpenFOAM Application

The OpenFOAM application for SOCA Web Submission has features that allow configuration of different
use cases and user preferences for an OpenFOAM workload. The intent is that it is simple to use for
the basic case but still allows a good deal of control over how the workload executes.

## Definitions

* model - collection of scripts, OpenFOAM data and geometry
* PBS script - the PBS script stored in the SOCA application profile for OpenFOAM
* model script - a script contained within the model directory. This script implements some phase
  of model processing (e.g. mesh, solve)
* .conf file - a BASH scriptlet located at the top level of the model directory

## .conf File

The .conf file selected as input for the workload is interpreted as a BASH script within the OpenFOAM
PBS script. a320-mesh.conf contains:

```
SCRIPT_PATH=A320/1-makeMesh
SCRIPT_PARAMS=
```

This tells the PBS script run the A320/1-makeMesh model script with no parameters.

The PBS script uses the parent directory of the selected .conf file as the "model directory". The
standard copy-out/copy-back process works as follows:

1. Copy the "model directory" (i.e. A320, the parent of 1-makeMesh) to a per-job scratch directory.
2. Execute the model script.
3. Copy the per-job scratch directory to `$HOME/soca_job_output`.

If EFS is selected as the scratch type, the scratch directory is `$HOME/soca_job_output/JOB_ID` and
no copying out or back takes place.

This process can be modified using the form inputs, as explained below.

## Alternate Input Type ZIP

It is also possible to select a ZIP file as a simulation input for OpenFOAM. In the case of A320,
A320.zip would contain the A320 model directory.

```
$ cd /apps/aws-workshops/openfoam/models
$ zip -r ~/A320.zip A320
```

If this ZIP is selected as simulation input, that ZIP will be extracted to a per-job scratch directory.
Processing and copy-back occur as normal.

However, the PBS script doesn't know which model script to execute. The user should complete the "Path to Script"
form element with either:

* A320/1-makeMesh
* A320/2-runStationaryCase
* A320/3-runTransientCase

Note that the model script paths depend up what has been created for a particular model.

## OpenFOAM Form Inputs

The simplest job submission involves selecting the appropriate .conf file and completing the following
form elements:

1. `instance_type`
2. `cpus`
3. `ami_id`

The job will execute using EFS scratch `$HOME/soca_job_output/JOB_ID`.

Every form input has online help available by hovering the mouse cursor over the `?`. The following inputs
require further explanation:

* `ami_id` - this would be more user-friendly as a drop down. Edit the form in SOCA to make this a drop down and
  add the blessed AMIs as selectable options. If there is only one AMI for use, then this could be made
  a hidden input.
* `scratch_opts` - the values chose here are arbitrary. Edit the form to provide more options, if desired.
  Note that OpenFOAM requires a shared filesystem (EFS or FSx Lustre) if there is more than one node
  for the job.
* `efa_support` - Only valid for c5n.18xlarge and r5n.24xlarge machines. The configured AMI should automatically
  configure Intel MPI for EFA if this is selected.
* `additional_pbs_opts` - contains any additional `#PBS` directives desired for the job. Typically, this
  may be used to configure scratch in a way that is not supported by the form inputs (e.g. persistent FSx
  Lustre). Refer to the PBS and SOCA documentation regarding PBS directives.
* `custom_scratch_path` - override the auto-computed scratch path. The PBS script automatically choose the scratch
  directory according to what is mounted, in the following order of preference:
  
  1. `/fsx/JOB_ID` - FSx for Lustre scratch
  2. `/scratch/JOB_ID` - EBS scratch
  3. `$HOME/soca_job_output/JOB_ID` - EFS scratch

  Specify `custom_scratch_path` to choose a different location. Typically, this may be used in conjunction with
  `copy_out=No` and `copy_back=No` to perform multiple phases (e.g. mesh, solve) in the same scratch
  directory, reducing the time sent copying data to and from scratch.
* `copy_out` - If Yes, copy the selected model directory to scratch before invoking the model script. No indicates
  that the `custom_scratch_path` already contains a model.
* `copy_back` - If Yes, copy the per-job scratch folder to `$HOME/soca_job_output/JOB_ID` after the model script terminates.
* `fsx_export_paths` - specify a path relative to the per-job scratch directory that should be exported to s3.
  For example the value of "." would export the entire per-job scratch directory.
  Requires use of FSx Lustre scratch that has been configured with an s3 backend.
* `script_path` - specify the model script to execute. Overrides anything specified by the .conf file.
* `script_params` - specify the parameters to the model script. Overrides anything specified by the .conf file.
* `preserve_processor_dirs` - "processor dirs" are the per-core temporary directories use by the OpenFOAM parallel
  processes. These may contain data that is useful for post-processing, but may also be extremely large. Yes
  leaves the processor directories intact, No removes the directories before any copy back or export operation.
* `archive_scratch` - Yes causes the PBS script to create a ZIP of the per-job scratch directory and store it in
  $HOME. This is to facilitate easy download of job output.


## Example of FSx Lustre and Reduced Copies

Persistent FSx Lustre can be used with the OpenFOAM application to reduce the amount of data copying between
scratch and EFS.

### Setup

1. Configure an FSx for Lustre filesystem in AWS Console. If desired, specify an s3 backend. Make sure it's in
   the cluster's VPC and ComputeNode security group.
2. Record the filesystem's DNS name and subnet ID for later reference.

### Mesh

1. Select the .conf file for mesh in the model directory.
2. Select EFS for `scratch_type`. The job will use the FSx Lustre volume, but EFS tells the PBS script that
   no additional scratch should be allocated.
3. In `additional_pbs_opts`, enter the following and replace `FSX_LUSTRE_DNS` and `FSX_LUSTRE_SUBNET`. with the
   filesystem's DNS name and subnet ID:
   ```
   #PBS -l fsx_lustre=FSX_LUSTRE_DNS,subnet_id=FSX_LUSTRE_SUBNET
   ```
4. Select `copy_back = No`
5. Click "Submit Job"

Record the full job ID from the details for the newly created job (e.g. 11.ip-10-0-16-230, not 11).

### Solve

After the mesh job has completed and the log confirms that the mesh was successful, the solve
job can be executed in the same scratch directory used by mesh.

1. Select the .conf file for solve in the model directory. This is the same directory where you selected
   the mesh conf.
2. Select EFS for `scratch_type`.
3. In `additional_pbs_opts`, enter the following and replace `FSX_LUSTRE_DNS` and `FSX_LUSTRE_SUBNET` with the
   filesystem's DNS name and subnet ID:
   ```
   #PBS -l fsx_lustre=FSX_LUSTRE_DNS,subnet_id=FSX_LUSTRE_SUBNET
   ```
4. In `custom_scratch_path`, enter `/fsx/MESH_JOB_ID` (e.g. /fsx/11.ip-10-0-16-230). This tells the job
   script to use the same scratch directory used by the mesh job.
5. Select `copy_out=No`. This tells the PBS script that the scratch directory already has data
   in it.
6. Click "Submit Job"

Upon job termination, the scratch directory containing both mesh and solve results will be copied
to `$HOME/soca_job_output/MESH_JOB_ID`.

An alternative would be to set `fsx_export_paths=.` and `copy_back=No`. This would avoid the copy back to
$HOME and store the scratch directory the s3 backend for the FSx Lustre Volume.

