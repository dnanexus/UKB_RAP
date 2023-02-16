# Running Nextflow on cloud_workstation

You can set up Nextflow on a job running cloud_workstation. Below are the instructions on how to install `nextflow` and perfroom `nextflow run` on a cloud_workstation job. 

1. Follow the [quick-start](https://documentation.dnanexus.com/getting-started/cli-quickstart#step-0-install-the-sdk) instructions. Install dx-toolkit and login to the platform on your local machine. 
2. Open terminal and login to RAP

```
$ dx login
```
3. Start a job running the cloud_workstation app on your local machine with SSH access. You may want to select an instance type with sufficient compute resources (number of CPUs, disk and memory capacity) for the Nextflow pipeline analysis.  For guidance on cloud computing and how to select instance types see [here](https://laderast.github.io/bash_for_bioinformatics/03-cloud-computing-basics.html#sec-instance). Available instance types can be found [here](https://documentation.dnanexus.com/developer/api/running-analyses/instance-types).

```
$ dx run cloud_workstation \
  --ssh \
  --instance-type mem1_ssd1_v2_x36 \
  --brief -y

job-cccc
Waiting for job-cccc to start............
```
4. Once the cloud_workstation job starts, you will see that you are SSH’ed on the job. 
```
Welcome to DNAnexus!

This is the DNAnexus Execution Environment, running job-cccc.
Job: Cloud Workstation
App: cloud_workstation:main
Instance type: mem1_ssd1_v2_x36
Project: Project_Name (project-aaaa)
Workspace: container-mmmm
Running since: Thu Sep 15 17:18:24 UTC 2022
Running for: 0:01:48
The public address of this instance is ec2-54-144-71-189.compute-1.amazonaws.com.
You are running byobu, a terminal session manager.
If you get disconnected from this instance, you can log in again; your work will be saved as long as the job is running.
For more information on byobu, press F1.
The job is running in terminal 1. To switch to it, use the F4 key (fn+F4 on Macs; press F4 again to switch back to this terminal).
Use sudo to run administrative commands.
From this window, you can:
 - Use the DNAnexus API with dx
 - Monitor processes on the worker with htop
 - Install packages with apt-get install or pip3 install
 - Use this instance as a general-purpose Linux workstation
OS version: Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-1084-aws x86_64)
dnanexus@job-cccc:~$
```

5. Install java dependency
```
dnanexus@job-cccc:~$ sudo apt install openjdk-17-jre-headless -y
```

6. Download Nextflow installation scripts onto the cloud_workstation job:
```
dnanexus@job-cccc:~$ curl -fL https://get.nextflow.io > nextflow_install.sh
```
7. Specify the version of nextflow to use. After you open the file using nano, edit the file to change NXF_VER=22.10.6 to NXF_VER=22.04.5 (text highlighted in red below). You can then save and exit using the following [key commands](https://www.freecodecamp.org/news/how-to-save-and-exit-nano-in-terminal-nano-quit-command/)

```
dnanexus@job-cccc:~$ nano nextflow_install.sh

#!/usr/bin/env bash
#
#  Copyright 2020-2022, Seqera Labs
#  Copyright 2013-2019, Centre for Genomic Regulation (CRG)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

[[ "$NXF_DEBUG" == 'x' ]] && set -x
NXF_VER=${NXF_VER:-'22.10.6'}
```

8. Install Nextflow environment on the cloud_workstation job: 
```
dnanexus@job-cccc:~$ cat nextflow_install.sh | bash
```

9. Start using nextflow on the cloud_workstation job
```
dnanexus@job-cccc:~$ ./nextflow -v 
nextflow version 22.04.5.5708

dnanexus@job-cccc:~$ ./nextflow run nextflow-io/hello

N E X T F L O W  ~  version 22.04.5
Pulling nextflow-io/hello ...
 downloaded from https://github.com/nextflow-io/hello.git
Launching `https://github.com/nextflow-io/hello` [lonely_lavoisier] DSL2 - revision: 4eab81bd42 [master]
executor >  local (4)
[d8/bbf6f0] process > sayHello (4) [100%] 4 of 4 ✔
Ciao world!

Bonjour world!

Hello world!

Hola world!
```
