# Isolated-Builder

# Prerequisites:
- Docker installed 
- Ubuntu e-mail installed: `sudo apt-get install mailutils`
- SSH folder with ssh keys (`/home/xap/docker/ssh`)

# Configuration:
The builder is located in `/home/xap/docker/`, build logs are located in: `/home/xap/buildlogs` and sources are located in: `/home/xap/dockersources`.

All environment varialbes are located in `/home/xap/docker/env.sh`.

Branch list is located in `/home/xap/docker/branch_list.txt` and can be modified in order to trigger build on a specific build.

The build process is executed inside a docker container, the file is located in `/home/xap/docker/Dockerfile`.
The folder `/home/xap/docker/ssh` MUST contain valid ssh keys of an authorized github user that can access private XAP repositories.

There are some environment variables inside that are being passed to the docker container and then being passed to the quickbuild.xml file - you may modify them in `/home/xap/docker/env.sh` according to your needs (e.g TGRID_MILESTONE, TGRID_SUITE_CUSTOM_SYSPROPS, TGRID_SUITE_CUSTOM_EXCLUDE, TGRID_SUITE_CUSTOM_INCLUDE etc).

In addition the variable RECIPIENTS includes the mail recipients that will receive mail if CI build failed.

Please notice that there are mock files/directories that the build process is using in order to accelerate the build process without building some of the targets that quickbuild is executing.

# Execution:
The main script which triggers the build process is `/home/xap/docker/build_loop.sh`.

In order to execute the build process in the background run `/home/xap/docker/nohup_build_loop.sh`.

In order to see the main script's log, read the `/home/xap/buildlogs/loop.log` file (best using `tail -f <loop.log>`).

In order to see the current build log read the `/home/xap/buildlogs/<COUNTER>/build.log`.

The COUNTER value can be extracted from the loop.log file (e.g `buildlogs/251/build.log`).

# Tips:
It is possible to trigger single build from a specific branch by running `/home/xap/docker/run_single_build.sh <branch_name>`.
but before doing so, verify no other build process is in progress (a process can be stopped by running `/home/xap/docker/stop.sh`).

There is an option to check the last build status (fail/success/no changes made in github) by executing  `/home/xap/docker/last_build_status.sh`.

# Simple pseudo code of the execution logic:
build_loop(){

        while true{
        
                for each branch from branches_file {
                
                        build_number = get_build_counter()
                        
                        variables[] vars = set_env_variables()
                        
                        success = run_build_inside_docker(vars, branch)
                        
                        if (!success){
                        
                                send_ci_failure_mail(vars.get(recipients))
                                
                                break;
                                
                       }
                       
                        publish_build_to_isolated_regression()
                        
                }
                
        }
        
}



//executed inside the docker container
boolean run_build_inside_docker(vars, branch){

        clear_local_sources_junk() // leave only source files - clean changes from previous execution
        
        if (!check_github_changes(branch)){
        
                print ("no changes")
                
                return true
                
        }
        
        pull_changes_from_github(branch)
        
        return ant_execute_build(vars)
        
}

# Maintenance:
When developing/changing the docker file/scripts that are used inside the docker container, execute the `/home/xap/docker/build.sh` script - this will build a new docker image that will be used in the build process.

Termination (if the process is running in the background):
Execute `/home/xap/docker/stop.sh`.
