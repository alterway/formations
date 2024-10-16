<!--
author:   Hervé Leclerc

email:    herve.leclerc@alterway.fr

version:  0.0.1

language: fr

narrator: FR French Male

comment:  Labs Docker Fundamentals

logo: https://assets.alterway.fr/2021/01/strong-mind.png


-->

# Lab Docker Fundamentals



## Docker Container Fundamentals

```text
Docker Container Fundamentals
```

## 0. Docker installation

```bash
# Get installer 

curl -o install.sh -L get.docker.com

# launch installer

bash install.sh

# Add ubuntu user to docker  group

sudo usermod -aG docker ubuntu


# Reload user group

newgrp docker


# Test installation

docker run --rm -ti wernight/funbox nyancat


```


## 1. The Container Lifecycle

```text
By the end of this exercise, you should be able to:
```

- Start, stop and restart containers
- Interrogate containers for process logs, resource consumption, and configuration and state
    metadata
- Launch new processes inside pre-existing containers

### 1.1. Launching and Managing Containers


<p style="color: purple"><b>
Step 1:</b></p>
**Let’s begin by containerizing a simple ping process on your node:**


```shell
[ubuntu@node ~]$ docker container run alpine ping 8.8.8.8.
```

- docker container run creates a new container
- alpine is the container image we’ll use to define the filesystem our process sees
- what follows the image definition (ping 8.8.8.8 in this case) is the actual process
    and its arguments to be containerized.
You should see Docker download the alpine image, and then start the ping:

```text
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
df20fa9351a1: Pull complete
Digest: sha256:185518070891758909c9f839cf4ca393ee977ac378609f700f60a771a2dfe
Status: Downloaded newer image for alpine:latest
PING 8 .8.8.8 ( 8 .8.8.8): 56 data bytes
64 bytes from 8 .8.8.8: seq= 0 ttl= 109 time= 2 .094 ms
64 bytes from 8 .8.8.8: seq= 1 ttl= 109 time= 1 .156 ms
64 bytes from 8 .8.8.8: seq= 2 ttl= 109 time= 1 .186 ms
64 bytes from 8 .8.8.8: seq= 3 ttl= 109 time= 1 .185 ms
64 bytes from 8 .8.8.8: seq= 4 ttl= 109 time= 1 .146 ms
```

```text
Press CTRL+C to kill the process.
```

```text
Step 2: List all of the containers on your node host:
```

```shell
[ubuntu@node ~]$ docker container ls -a
```

```text
CONTAINER ID IMAGE COMMAND ... STATUS ...
81484551f69b alpine "ping 8.8.8.8" ... Exited ( 0 ) 50 seconds ago ...
```

```text
We can see our container and its status. Sending a CTRL+C to the ping process that was
attached to our terminal killed the ping, and since ping was the primary process in our
container, it caused the container itself to exit.
```

```text
Step 3: Let’s run the same container again, this time with the -d flag to detach the ping process
from our shell so it can run in the background:
```

1. The Container Lifecycle


```shell
[ubuntu@node ~]$ docker container run -d alpine ping 8 .8.8.
```

```text
4bf570c09043c0094fef87e9cad7e94e20b2b2c8bd1029bb49def581cdcb
```

```text
This time we just get the container ID back (4bf5... in my case, yours will be different), but
the ping output isn’t streaming to the terminal this time.
```

```text
List your running containers:
```

```shell
[ubuntu@node ~]$ docker container ls
```

```text
CONTAINER ID IMAGE COMMAND STATUS ...
4bf570c09043 alpine "ping 8.8.8.8" Up About a minute ...
```
```
By omitting the -a flag, we get only our running containers - so only the one we just started
and which is still running in the background.
```
Step 4: Stop your running container:

```
[ubuntu@node ~]$ docker container stop <container ID of running container>
```
```
Notice it takes a long time (about 10 seconds) to return. When a container is stopped, there
is a two step process:
```
1. A SIGTERM is sent to the PID 1 process in the container, asking but not forcing it to
    stop
2. After 10 seconds, a SIGKILL is sent to the PID 1 process, forcing it to return and the
    container to enter its EXITED state.

Step 5: Run the docker container ls again, and you’ll see nothing; there are no running
containers. To see our stopped containers, again use:

```
[ubuntu@node ~]$ docker container ls -a
```
```
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 4 minutes ago Exited ( 137 ) a minute ago
81484551f69b alpine "ping 8.8.8.8" 8 minutes ago Exited ( 0 ) 8 minutes ago
```
```
The exit codes presented (137 and 0) are the exit codes of the ping process when it was
terminated.
```
Step 6: Restart the container you just exited (it should be the one more recently created, with the
137 exit code), and list containers one more time:

```
[ubuntu@node ~]$ docker container start <container ID>
```
```
[ubuntu@node ~]$ docker container ls
```
```
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 11 minutes ago Up 25 seconds
```
```
Even when a container exits, its filesystem and configuration information are preserved so
that it can be restarted later.
```
### 1.2. Interrogating Containers

1. The Container Lifecycle


```
Step 1: Retrieve your state and config information about your running container:
```
```
[ubuntu@node ~]$ docker container inspect <container ID>
```
```
[
{
"Id": "4bf570c09043c0094fef87e9cad7e94e20b2b2c8bd1029bb49def581cdcb8864",
"Created": "2020-06-24T15:36:18.849921401Z",
"Path": "ping",
"Args": [
"8.8.8.8"
],
"State": {
"Status": "running",
...
```
```
This output provides a wealth of information about how your container is configured, as well
as state conditions and error messages. This is one of the first places to look when
debugging a malfunctioning container. Take some time to read through the fields now so you
have a rough idea of the information available here.
```
```
Step 2: Retrieve your resource consumption stats about your container:
```
```
[ubuntu@node ~]$ docker container stats <container ID>
```
```
CONT. ID NAME CPU % MEM USAGE / LIMIT MEM % NET I/O BLOCK I/O PIDS
4bf5... zen_bartik 0 .02% 48KiB / 3 .7GiB 0 .00% 27kB / 26 .4kB 0B / 0B 1
```
```
Here we see live resource consumption of this container; press CTRL+C when you’re done
watching this monitor.
```
```
Step 3: Retrieve the same information as the previous step, formatted as JSON and only
instantaneously, without streaming:
```
```
[ubuntu@node ~]$ docker container stats --no-stream \
--format '{{json .}}' <container ID>
```
```
{"BlockIO":"0B / 0B",
"CPUPerc":"0.02%",
"Container":"4bf",
"ID":"4bf570c09043",
"MemPerc":"0.00%",
"MemUsage":"48KiB / 3.7GiB",
"Name":"zen_bartik",
"NetIO":"47.8kB / 47.2kB",
"PIDs":"1"}
```
```
This option is useful for capturing consumption information by an external monitoring service
that knows how to ingest JSON.
```
```
Step 4: Retrieve the logs from your containerized process:
```
1. The Container Lifecycle


```
[ubuntu@node ~]$ docker container logs <container ID>
```
```
PING 8 .8.8.8 ( 8 .8.8.8): 56 data bytes
64 bytes from 8 .8.8.8: seq= 0 ttl= 109 time= 1 .500 ms
64 bytes from 8 .8.8.8: seq= 1 ttl= 109 time= 1 .183 ms
64 bytes from 8 .8.8.8: seq= 2 ttl= 109 time= 1 .095 ms
```
```
Here we see the STDOUT and STDERR of the primary process in our container -
ping 8.8.8.8 in this case. Note that if you launch other processes in a container, their
output will not be captured in the container logs! Only the process with PID 1 inside a
container is logged in this fashion; this is one of the simplest reasons why it’s often a good
idea to strictly run one process within a container, rather than a complicated process tree.
```
Step 5: Get a list of processes running in your container:

```
[ubuntu@node ~]$ docker container top <container ID>
```
```
UID PID PPID C STIME TTY TIME CMD
root 3312 3293 0 15 :47? 00 :00:00 ping 8 .8.8.
```
```
Our container is running just one process, ping 8.8.8.8. The PID column in this output
indicates the PID of each process on the host. Remember that if this process exits, the
container will exit. Try this yourself by listing containers and then killing the host process:
```
```
[ubuntu@node ~]$ docker container ls
```
```
CONTAINER ID IMAGE COMMAND
4bf570c09043 alpine "ping 8.8.8.8"
```
```
[ubuntu@node ~]$ sudo kill -9 <PID from container top command above>
```
```
[ubuntu@node ~]$ docker container ls
```
```
CONTAINER ID IMAGE COMMAND
```
```
Killing the host process and exiting a container are functionally equivalent, as we see here.
```
```
Notes
Warning: do not use kill to stop containers! This was just an example to show the
relationship between host processes and container state. This method can lead to unintended
consequences with more sophisticated containers.
```
### 1.3. Launching New Processes in Old Containers

Step 1: Restart your ping container, exactly as you did before:

1. The Container Lifecycle


```
[ubuntu@node ~]$ docker container start <container ID>
```
```
Remember from our use of docker container top before that there’s just one process
running inside this container. Sometimes, especially when debugging, it can be helpful to be
able to launch additional processes ‘inside’ a container.
```
```
Step 2: Look at the PID tree of your container from the container’s perspective by running ps
inside your container:
```
```
[ubuntu@node ~]$ docker container exec <container ID> ps
```
```
PID USER TIME COMMAND
1 root 0 :00 ping 8 .8.8.
11 root 0 :00 ps
```
```
docker container exec launches a new process inside an already running container.
Note the output of ps in this case: it sees the PID tree as it appears inside the container’s
kernel namespaces. So from that perspective, ping looks like PID 1 since it is the primary
process inside this container, rather than the host system PID returned by
docker container top. Despite the different PIDs, these pings are the exact same
process, as we saw previously when killing the host ping exited the container; this is the
kernel PID namespace in action.
```
```
Step 3: Launch an interactive shell inside your running container:
```
```
[ubuntu@node ~]$ docker container exec -it <container ID> sh
/ #
```
```
From here, you have an interactive prompt you can use to explore your container’s
filesystem and namespaces, similar to if you SSHed into a remote host. Try out some
common commands:
```
```
/ # ls
```
```
bin dev etc home lib media mnt opt proc root
run sbin srv sys tmp usr var
```
```
/ # ps
```
```
PID USER TIME COMMAND
1 root 0 :00 ping 8 .8.8.
16 root 0 :00 sh
22 root 0 :00 ps
```
```
/ # whoami
```
```
root
```
```
When you’re done practicing, type exit to return to your host.
```
### 1.4. Cleaning up Containers

1. The Container Lifecycle


Step 1: List all of your containers one more time:

```
[ubuntu@node ~]$ docker container ls -a
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 37 minutes ago Up 10 minutes
81484551f69b alpine "ping 8.8.8.8" 41 minutes ago Exited ( 0 ) 41 minutes ago
```
Step 2: Remove the exited container:

```
[ubuntu@node ~]$ docker container rm <container ID of Exited container>
```
Step 3: Attempt to remove the running container:

```
[ubuntu@node ~]$ docker container rm <container ID>
```
```
Error response from daemon: You cannot remove a running container
4bf570c09043c0094fef87e9cad7e94e20b2b2c8bd1029bb49def581cdcb8864.
Stop the container before attempting removal or force remove
```
```
As displayed in the error message, docker container rm will decline to remove a
running container. We could stop it then remove it as we did above, or we could force
removal:
```
```
[ubuntu@node ~]$ docker container rm -f <container ID>
```
```
At this point, all of your containers from this exercise should be gone. Use
docker container ls -a to confirm this. If any containers remain, use the commands
you learned during these exercises to remove them.
```
### 1.5. Optional: Independent Container Filesystems

One important detail to understand about container filesystems is that each container has an
independent filesystem, even if they’re started from the same image. We’ll study how these
filesystems are implemented in the next chapter, but for now it’s worth exploring how they appear
in practice:

Step 1: Create a container using the centos:7 image and connect to its bash shell in interactive
mode:

```
[ubuntu@node ~]$ docker container run -it centos:7 bash
```
Step 2: Explore your container’s filesystem with ls, and then create a new file. Use ls again to
confirm you have successfully created your file. Use the -l option with ls to list the files and
directories in a long list format.

```
[root@2b8de2ffdf85 /]# ls -l
[root@2b8de2ffdf85 /]# echo 'Hello there...' > test.txt
[root@2b8de2ffdf85 /]# ls -l
```
Step 3: Exit the connection to the container:

```
[root@2b8de2ffdf85 /]# exit
```
Step 4: Run the same command as before to start a container using the centos:7 image:

1. The Container Lifecycle


```
[ubuntu@node ~]$ docker container run -it centos:7 bash
```
```
Step 5: Use ls to explore your container. You will see that your previously created test.txt is
nowhere to be found in your new container; while both containers were based on the same
centos:7 image, changes made to the filesystem inside a container (like adding test.txt) are
local only to the container that made the change, preserving independence between containers.
Step 6: Challenge: Using the commands you learned previously, restart the container you
created test.txt in, connect to it, and prove that that file is still present in that container.
Step 7: Remember to clean up by deleting the containers created in this section.
```
### 1.6. Conclusion

```
In this exercise we learned the basic commands to start, stop, restart and investigate a container.
But beyond basic syntax, we learned some examples of the importance of the primary, PID 1
process inside a container. The state of this process determines the liveness of our container, the
STDOUT and STDERR of this process is what’s logged by container logs, and this process’
response to SIGTERM determines how our container behaves during a controlled shutdown.
```

1. The Container Lifecycle


```
Created ---> Running ---> Stopped
   ^          |  ^          |
   |          |  |          |
   |          v  |          v
   +----- Paused |      Removed
                 |          ^
                 |          |
                 +----------+
```

States and Transitions

1. **Created**
   - Initial state after `docker create`
   - Can transition to:
     - Running (via `docker start`)
     - Removed (via `docker rm`)

2. **Running**
   - Container is executing
   - Reached via `docker start` from Created or Stopped state
   - Can transition to:
     - Stopped (via `docker stop` or when process completes)
     - Paused (via `docker pause`)

3. **Stopped**
   - Container has been stopped
   - Can transition to:
     - Running (via `docker start`)
     - Removed (via `docker rm`)

4. **Paused**
   - Container execution is paused
   - Can transition to:
     - Running (via `docker unpause`)

5. **Removed**
   - Container is deleted
   - Final state, reached via `docker rm` from Created or Stopped state

Key Docker Commands

- `docker create`: Create a new container (Created state)
- `docker start`: Start a container (transition to Running)
- `docker stop`: Stop a running container (transition to Stopped)
- `docker pause`: Pause a running container (transition to Paused)
- `docker unpause`: Unpause a paused container (return to Running)
- `docker rm`: Remove a stopped or created container (transition to Removed)

## 2. Interactive Image Creation

By the end of this exercise, you should be able to:

- Capture a container’s filesystem state as a new docker image
- Read and understand the output of docker container diff

### 2.1. Modifying a Container

Step 1: Start a bash terminal in a CentOS container:

```
[ubuntu@node ~]$ docker container run -it centos:7 bash
```
Step 2: Install a couple pieces of software in this container - there’s nothing special about wget,
any changes to the filesystem will do. Afterwards, exit the container:

```
[root@dfe86ed42be9 /]# yum install -y which wget
[root@dfe86ed42be9 /]# exit
```
Step 3: Finally, try docker container diff to see what’s changed about a container relative
to its image; you’ll need to get the container ID via docker container ls -a first:

```
[ubuntu@node ~]$ docker container ls -a
[ubuntu@node ~]$ docker container diff <container ID>
```
```
C /root
A /root/.bash_history
C /usr
C /usr/bin
A /usr/bin/gsoelim
```
```
Those C at the beginning of lines stand for files changed, and A for added; lines that start
with D indicate deletions.
```
### 2.2. Capturing Container State as an Image

Step 1: Installing which and wget in the last step wrote information to the container’s read/write
layer; now let’s save that read/write layer as a new read-only image layer in order to create a new
image that reflects our additions, via the docker container commit:

```
[ubuntu@node ~]$ docker container commit <container ID> myapp:1.
```
Step 2: Check that you can see your new image by listing all your images:

```
[ubuntu@node ~]$ docker image ls
```
```
REPOSITORY TAG IMAGE ID CREATED SIZE
myapp 1 .0 34f97e0b087b 8 seconds ago 300MB
centos 7 5182e96772bf 44 hours ago 200MB
```
Step 3: Create a container running bash using your new image, and check that which and wget
are installed:

2. Interactive Image Creation


```
[ubuntu@node ~]$ docker container run -it myapp:1.0 bash
[root@2ecb80c76853 /]# which wget
```
```
The which commands should show the path to the specified executable, indicating they
have been installed in the image. Exit your container when done by typing exit.
```
### 2.3. Conclusion

```
In this exercise, you learned how to inspect the contents of a container’s read / write layer with
docker container diff, and then commit those changes to a new image layer with
docker container commit. Committing a container as an image in this fashion can be useful
when developing an environment inside a container, when you want to capture that environment
for reproduction elsewhere.
```
2. Interactive Image Creation


## 3. Creating Images with Dockerfiles (1/2)

By the end of this exercise, you should be able to:

- Write a Dockerfile using the FROM and RUN commands
- Build an image from a Dockerfile
- Anticipate which image layers will be fetched from the cache at build time
- Fetch build history for an image

### 3.1. Writing and Building a Dockerfile

Step 1: Create a folder called myimage, and a text file called Dockerfile within that folder. In
Dockerfile, include the following instructions:

```
FROM centos:
```
```
RUN yum update -y
RUN yum install -y wget
```
```
This serves as a recipe for an image based on centos:7, that has all of its default packages
updated and wget installed on top.
```
Step 2: Build your image with the build command. Don’t miss the. at the end; that’s the path to
your Dockerfile. Since we’re currently in the directory myimage which contains it, the path is
just. (here).

```
[ubuntu@node myimage]$ docker image build -t myimage.
```
```
You’ll see a long build output describing each step of the build. The builder goes through the
following build steps:
```
- Creates a container based on centos:7 (the FROM image).
- Runs the first Dockerfile command (yum update -y) inside that container, and then
    saves the resulting container layer as a new image layer.
- Destroys this intermediate container.
- Creates another container based on centos:7 PLUS the new image layer created
    above.
- Runs the next Dockerfile command (yum install -y wget) in this new
    intermediate container, saves the result as another image layer, and destroys this
    second intermediate container.
In general: each Dockerfile command gets run in a container based on the image up to that
point; the command adds another layer to the image if it made any filesystem changes.

```
Your image creation was successful if the output ends with
Successfully tagged myimage:latest.
```
Step 3: Verify that your new image exists with docker image ls, then use your new image to
run a container and wget something from within that container, just to confirm that everything
worked as expected:

3. Creating Images with Dockerfiles (1/2)


```
[ubuntu@node myimage]$ docker container run -it myimage bash
[root@1d86d4093cce /]# wget example.com
[root@1d86d4093cce /]# cat index.html
[root@1d86d4093cce /]# exit
```
```
You should see the HTML from example.com, downloaded by wget from within your
container.
```
```
Step 4: It’s also possible to pipe a Dockerfile in from STDIN; try rebuilding your image with the
following:
```
```
[ubuntu@node myimage]$ cat Dockerfile | docker image build -t myimage -f -.
```
```
(This is useful when reading a Dockerfile from a remote location with curl, for example).
```
### 3.2. Using the Build Cache

```
In the previous step, the second time you built your image it should have completed immediately,
with each step except the first reporting using cache. Cached build steps will be used until a
change in the Dockerfile is found by the builder.
Step 1: Open your Dockerfile and add another RUN step at the end to install vim:
```
```
FROM centos:
```
```
RUN yum update -y
RUN yum install -y wget
RUN yum install -y vim
```
```
Step 2: Build the image again as before; which steps is the cache used for?
Step 3: Build the image again; which steps use the cache this time?
Step 4: Swap the order of the two RUN commands for installing wget and vim in the Dockerfile:
```
```
FROM centos:
```
```
RUN yum update -y
RUN yum install -y vim
RUN yum install -y wget
```
```
Build one last time. Which steps are cached this time?
```
### 3.3. Using the history Command

```
Step 1: The docker image history command allows us to inspect the build cache history of
an image. Try it with your new image:
```
3. Creating Images with Dockerfiles (1/2)


```
[ubuntu@node myimage]$ docker image history myimage:latest
```
```
IMAGE CREATED CREATED BY SIZE
f2e85c162453 8 seconds ago /bin/sh -c yum install -y wget 87 .2MB
93385ea67464 12 seconds ago /bin/sh -c yum install -y vim 142MB
27ad488e6b79 3 minutes ago /bin/sh -c yum update -y 86 .5MB
5182e96772bf 44 hours ago /bin/sh -c #(nop) CMD ["/bin/bash"] 0B
<missing> 44 hours ago /bin/sh -c #(nop) LABEL org.label-schema.... 0B
<missing> 44 hours ago /bin/sh -c #(nop) ADD file:6340c690b08865d... 200MB
```
```
Note the image id of the layer built for the yum update command.
```
Step 2: Replace the two RUN commands that installed wget and vim

```
with a single command:
```
```
RUN yum install -y wget vim
```
Step 3: Build the image again, and run docker image history on this new image. How has
the history changed?

### 3.4. Conclusion

In this exercise, we’ve seen how to write a basic Dockerfile using FROM and RUN commands,
some basics of how image caching works, and seen the docker image history command.
Using the build cache effectively is crucial for images that involve lengthy compile or download
steps. In general, moving commands that change frequently as late as possible in the Dockerfile
will minimize build times. We’ll see some more specific advice on this later in this lesson.

3. Creating Images with Dockerfiles (1/2)


## 4. Creating Images with Dockerfiles (2/2)

```
By the end of this exercise, you should be able to:
```
- Define a default process for an image to containerize by using the ENTRYPOINT or CMD
    Dockerfile commands
- Understand the differences and interactions between ENTRYPOINT and CMD
- Ensure that a containerized process doesn’t run as root by default.

### 4.1. Setting Default Commands

```
Step 1: Add the following line to the bottom of your Dockerfile from the last exercise:
```
```
...
CMD ["ping", "127.0.0.1", "-c", "5"]
```
```
This sets ping as the default command to run in a container created from this image, and
also sets some parameters for that command.
```
```
Step 2: Rebuild your image:
```
```
[ubuntu@node myimage]$ docker image build -t myimage.
```
```
Step 3: Run a container from your new image with no command provided:
```
```
[ubuntu@node myimage]$ docker container run myimage
```
```
You should see the command provided by the CMD parameter in the Dockerfile running.
```
```
Step 4: Try explicitly providing a command when running a container:
```
```
[ubuntu@node myimage]$ docker container run myimage echo "hello world"
```
```
Providing a command in docker container run overrides the command defined by CMD.
```
```
Step 5: Replace the CMD instruction in your Dockerfile with an
ENTRYPOINT:
```
```
...
ENTRYPOINT ["ping"]
```
```
Step 6: Build the image and use it to run a container with no process arguments:
```
```
[ubuntu@node myimage]$ docker image build -t myimage.
[ubuntu@node myimage]$ docker container run myimage
```
```
You’ll get an error. What went wrong?
```
```
Step 7: Try running with an argument after the image name:
```
```
[ubuntu@node myimage]$ docker container run myimage 127 .0.0.
```
```
You should see a successful ping output. Tokens provided after an image name are sent as
arguments to the command specified by ENTRYPOINT.
```
4. Creating Images with Dockerfiles (2/2)


### 4.2. Combining Default Commands and Options

Step 1: Open your Dockerfile and modify the ENTRYPOINT instruction to include 2 arguments for
the ping command:

```
ENTRYPOINT ["ping", "-c", "3"]
```
Step 2: If CMD and ENTRYPOINT are both specified in a Dockerfile, tokens listed in CMD are used
as default parameters for the ENTRYPOINT command. Add a CMD with a default IP to ping:

#### CMD ["127.0.0.1"]

Step 3: Build the image and run a container with the defaults:

```
[ubuntu@node myimage]$ docker image build -t myimage.
[ubuntu@node myimage]$ docker container run myimage
```
```
You should see it pinging the default IP, 127.0.0.1.
```
Step 4: Run another container with a custom IP argument:

```
[ubuntu@node myimage]$ docker container run myimage 8 .8.8.
```
```
This time, you should see a ping to 8.8.8.8. Explain the difference in behavior between
these two last containers.
```
### 4.3. Running as Non-Root by Default

Step 1: Make a new directory for this example, and move there:

```
[ubuntu@node ~]$ mkdir ~/user ; cd ~/user
```
Step 2: Define a simple pinging container in a Dockerfile:

```
FROM centos:
CMD ["ping", "8.8.8.8"]
```
Step 3: Build and run your image, and check the user ID of the ping process:

```
[ubuntu@node user]$ docker image build -t pinger:root.
[ubuntu@node user]$ docker container run --name rootdemo -d pinger:root
[ubuntu@node user]$ docker container exec rootdemo ps -aux
```
```
USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
root 1 0 .8 0 .0 24856 1800? Ss 17 :52 0 :00 ping 8 .8.8.
root 7 0 .0 0 .0 51748 3364? Rs 17 :52 0 :00 ps -aux
```
```
As we can see, ping and its child processes are running as root.
```
Step 4: There’s no need for ping to run as root. Set it to run as uid 1000 (or any other
unprivileged user) by amending your Dockerfile:

4. Creating Images with Dockerfiles (2/2)


```
FROM centos:
USER 1000
CMD ["ping", "8.8.8.8"]
```
```
Step 5: Build, run, and check your process tree again:
```
```
[ubuntu@node user]$ docker container rm -f rootdemo
[ubuntu@node user]$ docker image build -t pinger:user.
[ubuntu@node user]$ docker container run --name userdemo -d pinger:user
[ubuntu@node user]$ docker container exec userdemo ps -aux
```
```
USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
1000 1 0 .7 0 .0 24856 1908? Ss 17 :55 0 :00 ping 8 .8.8.
1000 7 0 .0 0 .0 51748 3468? Rs 17 :55 0 :00 ps -aux
```
```
This is a simple way to tighten the security of any image that doesn’t need containerized root
privileges.
```
```
Step 6: Clean up your container:
```
```
[ubuntu@node user]$ docker container rm -f userdemo
```
### 4.4. Conclusion

```
CMD, ENTRYPOINT and USER all share one thing in common: they’re all optional Dockerfile
commands, but they should be present in virtually all Dockerfiles. CMD and ENTRYPOINT help
clarify for future users of your image just what process your image is meant to containerize; since
images should be built to containerize exactly one specific process in almost all cases, capturing
this as part of the image helps communicate the design intention of the image to users. The USER
directive is an easy way to avoid security risks presented by running processes with unnecessary
root privileges; just like you’d never run a process as root unnecessarily in a VM, the same
precautions should be taken in a container.
```
4. Creating Images with Dockerfiles (2/2)


## 5. Multi-Stage Builds

By the end of this exercise, you should be able to:

- Write a Dockerfile that describes multiple images, which can copy files from one image to
    the next.
- Enable BuildKit for faster build times

### 5.1. Defining a multi-stage build

Step 1: Make a new folder named multi to do this exercise in, and cd into it.

Step 2: Add a file hello.c to the multi folder containing Hello World in C:

```
#include <stdio.h>
```
```
int main (void)
{
printf ("Hello, world!\n");
return 0 ;
}
```
Step 3: Try compiling and running this right on the host OS:

```
[ubuntu@node multi]$ gcc -Wall hello.c -o hello
[ubuntu@node multi]$ ./hello
```
Step 4: Now let’s Dockerize our hello world application. Add a Dockerfile to the multi folder
with this content:

```
FROM alpine:3.
RUN apk update && \
apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
COPY hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
CMD /app/bin/hello
```
Step 5: Build the image and note its size:

```
[ubuntu@node multi]$ docker image build -t my-app-large.
[ubuntu@node multi]$ docker image ls | grep my-app-large
```
```
REPOSITORY TAG IMAGE ID CREATED SIZE
my-app-large latest a7d0c6fe0849 3 seconds ago 189MB
```
Step 6: Test the image to confirm it was built successfully:

```
[ubuntu@node multi]$ docker container run my-app-large
```
```
It should print “hello world” in the console.
```
5. Multi-Stage Builds


```
Step 7: Update your Dockerfile to use an AS clause on the first line, and add a second stanza
describing a second build stage:
```
```
FROM alpine:3.5 AS build
RUN apk update && \
apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
COPY hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
```
```
FROM alpine:3.5
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello
```
```
Step 8: Build the image again and compare the size with the previous version:
```
```
[ubuntu@node multi]$ docker image build -t my-app-small.
[ubuntu@node multi]$ docker image ls | grep 'my-app-'
```
```
REPOSITORY TAG IMAGE ID CREATED SIZE
my-app-small latest f49ec3971aa6 6 seconds ago 4 .01MB
my-app-large latest a7d0c6fe0849 About a minute ago 189MB
```
```
As expected, the size of the multi-stage build is much smaller than the large one since it
does not contain the Alpine SDK.
```
```
Step 9: Finally, make sure the app works:
```
```
[ubuntu@node multi]$ docker container run --rm my-app-small
```
```
You should get the expected ‘Hello, World!’ output from the container with just the required
executable.
```
### 5.2. Building Intermediate Images

```
In the previous step, we took our compiled executable from the first build stage, but that image
wasn’t tagged as a regular image we can use to start containers with; only the final FROM
statement generated a tagged image. In this step, we’ll see how to persist whichever build stage
we like.
Step 1: Build an image from the build stage in your Dockerfile using the --target flag:
```
```
[ubuntu@node multi]$ docker image build -t my-build-stage --target build.
```
```
Notice all its layers are pulled from the cache; even though the build stage wasn’t tagged
originally, its layers are nevertheless persisted in the cache.
```
```
Step 2: Run a container from this image and make sure it yields the expected result:
```
```
[ubuntu@node multi]$ docker container run -it --rm my-build-stage /app/bin/hello
```
5. Multi-Stage Builds


Step 3: List your images again to see the size of my-build-stage compared to the small
version of the app.

### 5.3. Optional: Building from Scratch

So far, every image we’ve built has been based on a pre-existing image, referenced in the FROM
command. But what if we want to start from nothing, and build a completely original image? For
this, we can build FROM scratch.

Step 1: In a new directory ~/scratch, create a file named sleep.c that just launches a
sleeping process for an hour:

```
#include <stdio.h>
#include <unistd.h>
int main()
{
int delay = 3600 ; //sleep for 1 hour
printf ("Sleeping for %d second(s)...\n", delay);
sleep(delay);
return 0 ;
}
```
Step 2: Create a file named Dockerfile to build this sleep program in a build stage, and then
copy it to a scratch-based image:

```
FROM alpine:3.8 AS build
RUN ["apk", "update"]
RUN ["apk", "add", "--update", "alpine-sdk"]
COPY sleep.c /
RUN ["gcc", "-static", "sleep.c", "-o", "sleep"]
```
```
FROM scratch
COPY --from=build /sleep /sleep
CMD ["/sleep"]
```
```
This image will contain nothing but our executable and the bare minimum file structure
Docker needs to stand up a container filesystem. Note we’re statically linking the sleep.c
binary, so it will have everything it needs bundled along with it, not relying on the rest of the
container’s filesystem for anything.
```
Step 3: Build your image:

```
[ubuntu@node scratch]$ docker image build -t sleep:scratch.
```
Step 4: List your images, and search for the one you just built:

```
[ubuntu@node scratch]$ docker image ls | grep scratch
```
```
REPOSITORY TAG IMAGE ID CREATED SIZE
sleep scratch 1b68b20a85a8 9 minutes ago 128kB
```
```
This image is only 128 kB, as tiny as possible.
```
5. Multi-Stage Builds


```
Step 5: Run your image, and check out its filesystem; we can’t list directly inside the container,
since ls isn’t installed in this ultra-minimal image, so we have to find where this container’s
filesystem is mounted on the host. Start by finding the PID of your sleep process after its running:
```
```
[ubuntu@node scratch]$ docker container run --name sleeper -d sleep:scratch
[ubuntu@node scratch]$ docker container top sleeper
```
```
UID PID PPID C STIME TTY TIME CMD
root 1190 1174 0 15 :21? 00 :00:00 /sleep
```
```
In this example, the PID for sleep is 1190.
```
```
Step 6: List your container’s filesystem from the host using this PID:
```
```
[ubuntu@node scratch]$ sudo ls /proc/<PID>/root
```
```
dev etc proc sleep sys
```
```
We see not only our binary sleep but a bunch of other folders and files. Where does these
come from? runC, the tool for spawning and running containers, requires a json config of the
container and a root file system. At execution, the container runtime adds these minimum
requirements to form the most minimal container filesystem possible.
```
```
Step 7: Clean up by deleting your container:
```
```
[ubuntu@node scratch]$ docker container rm -f sleeper
```
### 5.4. Optional: Enabling BuildKit

```
In addition to the default builder, BuildKit can be enabled to take advantages of some
optimizations of the build process.
Step 1: Back in the ~/multi directory, turn on BuildKit:
```
```
[ubuntu@node multi]$ export DOCKER_BUILDKIT= 1
```
```
Step 2: Add an AS label to the final stage of your Dockerfile (this is not strictly necessary, but will
make the output in the next step easier to understand):
```
```
...
```
```
FROM alpine:3.5 AS prod
RUN apk update
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello
```
```
Step 3: Re-build my-app-small, without the cache:
```
5. Multi-Stage Builds


```
[ubuntu@node multi]$ docker image build --no-cache -t my-app-small-bk.
```
```
[+] Building 15 .5s ( 14 /14) FINISHED
=> [internal] load Dockerfile
=> => transferring dockerfile: 97B
=> [internal] load .dockerignore
=> => transferring context: 2B
=> [internal] load metadata for docker.io/library/alpine:3.5
=> CACHED [prod 1 /3] FROM docker.io/library/alpine:3.5
=> [internal] load build context
=> => transferring context: 87B
=> CACHED [internal] helper image for file operations
=> [build 2 /6] RUN apk update && apk add --update alpine-sdk
=> [prod 2 /3] RUN apk update
=> [build 3 /6] RUN mkdir /app
=> [build 4 /6] COPY hello.c /app
=> [build 5 /6] RUN mkdir bin
=> [build 6 /6] RUN gcc -Wall hello.c -o bin/hello
=> [prod 3 /3] COPY --from=build /app/bin/hello /app/hello
=> exporting to image
=> => exporting layers
=> => writing image sha256:22de288...
=> => naming to docker.io/library/my-app-small-bk
```
```
Notice the lines marked like [prod 2/3] and [build 4/6]: prod and build in this
context are the AS labels you applied to the FROM lines in each stage of your build in the
Dockerfile; from the above output, you can see that the build stages were built in parallel.
Every step of the final image was completed while the build environment image was being
created; the prod environment image creation was only blocked at the COPY instruction
since it required a file from the completed build image.
```
Step 4: Comment out the COPY instruction in the prod image definition in your Dockerfile, and
rebuild; the build image is skipped. BuildKit recognized that the build stage was not
necessary for the image being built, and skipped it.

Step 5: Turn off BuildKit:

```
[ubuntu@node multi]$ export DOCKER_BUILDKIT= 0
```
### 5.5. Conclusion

In this exercise, you created a Dockerfile defining multiple build stages. Being able to take
artifacts like compiled binaries from one image and insert them into another allows you to create
very lightweight images that do not include developer tools or other unnecessary components in
your production-ready images, just like how you currently probably have separate build and run
environments for your software. This will result in containers that start faster, and are less
vulnerable to attack.

5. Multi-Stage Builds


## 6. Managing Images

```
By the end of this exercise, you should be able to:
```
- Rename and retag an image
- Push and pull images from the public registry
- Delete image tags and image layers, and understand the difference between the two
    operations

### 6.1. Making an Account on Docker’s Hosted Registry

```
Step 1: If you don’t have one already, head over to https://hub.docker.com and make an account.
```
```
For the rest of this workshop, <Docker ID> refers to the username you chose for this
account.
```
### 6.2. Tagging and Listing Images

```
Step 1: Download the centos:7 image from Docker Hub:
```
```
[ubuntu@node ~]$ docker image pull centos:7
```
```
Step 2: Make a new tag of this image:
```
```
[ubuntu@node ~]$ docker image tag centos:7 my-centos:dev
```
```
Note no new image has been created; my-centos:dev is just a pointer pointing to the
same image as centos:7.
```
```
Step 3: List your images:
```
```
[ubuntu@node ~]$ docker image ls
```
```
You should have centos:7 and my-centos:dev both listed, but they ought to have the
same hash under image ID, since they’re actually the same image.
```
### 6.3. Sharing Images on Docker Hub

```
Step 1: Push your image to Docker Hub:
```
```
[ubuntu@node ~]$ docker image push my-centos:dev
```
```
You should get a denied: requested access to the resource is denied error.
```
```
Step 2: Login by doing docker login, and try pushing again. The push fails again because we
haven’t namespaced our image correctly for distribution on Docker Hub; all images you want to
share on Docker Hub must be named like <Docker ID>/<repo name>[:<optional tag>].
Step 3: Retag your image to be namespaced properly, and push again:
```
```
[ubuntu@node ~]$ docker image tag my-centos:dev <Docker ID>/my-centos:dev
[ubuntu@node ~]$ docker image push <Docker ID>/my-centos:dev
```
```
Step 4: Search Docker Hub for your new <Docker ID>/my-centos repo, and confirm that you
can see the :dev tag therein.
```
6. Managing Images


Step 5: Next, make a new directory called hubdemo, and in it create a Dockerfile that uses
<Docker ID>/my-centos:dev as its base image, and installs any application you like on top
of that. Build the image, and simultaneously tag it as :1.0:

```
[ubuntu@node hubdemo]$ docker image build -t <Docker ID>/my-centos:1.0.
```
Step 6: Push your :1.0 tag to Docker Hub, and confirm you can see it in the appropriate
repository.

Step 7: Finally, list the images currently on your node with docker image ls. You should still
have the version of your image that wasn’t namespaced with your Docker Hub user name; delete
this using docker image rm:

```
[ubuntu@node ~]$ docker image rm my-centos:dev
```
```
Only the tag gets deleted, not the actual image. The image layers are still referenced by
another tag.
```
### 6.4. Conclusion

In this exercise, we practiced tagging images and exchanging them on the public registry. The
namespacing rules for images on registries are mandatory: user-generated images to be
exchanged on the public registry must be named like
<Docker ID>/<repo name>[:<optional tag>]; official images in the Docker registry just
have the repo name and tag.

Also note that as we saw when building images, image names and tags are just pointers; deleting
an image with docker image rm just deletes that pointer if the corresponding image layers are
still being referenced by another such pointer. Only when the last pointer is deleted are the image
layers actually destroyed by docker image rm.

6. Managing Images


## 7. Managing Container Logs

```
By default, the STDOUT and STDERR of the PID 1 process inside a container is captured in a
single JSON file by the Docker engine; these logs are not compressed and not rotated by default.
By the end of this exercise, you should be able to:
```
- Configure Docker Engine’s logging driver
- Interpret the output of logs generated by the json-file and journald log drivers
- Configure log compression and rotation

### 7.1. Setting the Logging Driver

```
Docker offers a number of different logging drivers for recording the STDOUT and STDERR of
PID 1 processes in a container; below we’ll explore the defaults which correspond to the
json-file driver, and the journald driver.
Step 1: Run a simple container with the default logging configuration, and inspect its logs:
```
```
[ubuntu@node ~]$ docker container run -d centos:7 ping 8 .8.8.8
[ubuntu@node ~]$ docker container logs <container ID>
```
```
PING 8 .8.8.8 ( 8 .8.8.8) 56 ( 84 ) bytes of data.
64 bytes from 8 .8.8.8: icmp_seq= 1 ttl= 113 time= 0 .631 ms
64 bytes from 8 .8.8.8: icmp_seq= 2 ttl= 113 time= 0 .652 ms
64 bytes from 8 .8.8.8: icmp_seq= 3 ttl= 113 time= 0 .646 ms
```
```
Step 2: Examine these same logs directly on disk; note <container ID> here is the full,
untruncated container ID returned when you created the container above, or findable via
docker container ls --no-trunc:
```
```
[ubuntu@node ~]$ sudo head -5 \
/var/lib/docker/containers/<container ID>/<container ID>-json.log
```
```
{"log":"PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.\n","stream":"stdout",
"time":"2018-09-17T17:29:35.263052015Z"}
{"log":"64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=0.631 ms\n","stream":"stdout",
"time":"2018-09-17T17:29:35.263086694Z"}
{"log":"64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=0.652 ms\n","stream":"stdout",
"time":"2018-09-17T17:29:36.263133476Z"}
{"log":"64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=0.646 ms\n","stream":"stdout",
"time":"2018-09-17T17:29:37.263125448Z"}
{"log":"64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=0.577 ms\n","stream":"stdout",
"time":"2018-09-17T17:29:38.263049365Z"}
```
```
By default, logs are recorded as per the json-file driver format.
```
```
Step 3: Configure your logging driver to send logs to the system journal by updating
/etc/docker/daemon.json to look like this (note you’ll need to open this file with sudo
permissions in order to edit it):
```
```
{
"log-driver": "journald"
}
```
```
Step 4: Restart Docker so the new logging configuration takes effect:
```
```
[ubuntu@node ~]$ sudo service docker restart
```
7. Managing Container Logs


Step 5: Run another container, just like the one you ran above, but this time name it demo:

```
[ubuntu@node ~]$ docker container run -d --name demo centos:7 ping 8 .8.8.8
```
Step 6: Inspect the system journal for messages from the demo container:

```
[ubuntu@node ~]$ journalctl CONTAINER_NAME=demo
-- Logs begin at Wed 2021 -05-19 15 :03:26 UTC, end at Wed 2021 -05-19 15 :11:09 UTC. --
May 19 15 :11:02 node 138194df21dc[ 1701 ]: PING 8 .8.8.8 ( 8 .8.8.8) 56 ( 84 ) bytes of data.
May 19 15 :11:02 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 1 ttl= 113 time= 1 .14 ms
May 19 15 :11:03 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 2 ttl= 113 time= 1 .14 ms
May 19 15 :11:04 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 3 ttl= 113 time= 1 .19 ms
```
```
In this way, container logs can be sent to the system journal for ingestion by a centralized
logging framework along with the rest of the journal messages.
```
### 7.2. Configuring Log Compression and Rotation

By default, container logfiles can grow unbounded until all host disk is consumed. Many
file-based logging drivers like json-file support automatic log rotation and compression.

Step 1: Configure the Docker engine on node to create a json file of logs, swapping to a new
file every 5 kb, preserving a maximum of 3 files, by changing your /etc/docker/daemon.json
to look like this:

```
{
"log-driver": "json-file",
"log-opts": {
"max-size": "5k",
"max-file": "3",
"compress": "true"
}
}
```
Step 2: Restart Docker so the new logging configuration takes effect:

```
[ubuntu@node ~]$ sudo service docker restart
```
Step 3: Start another container generating logs:

```
[ubuntu@node ~]$ docker container run --name logdemo -d centos:7 ping 8 .8.8.8
```
Step 4: Find the container’s log files under /var/lib/docker/containers.

7. Managing Container Logs


```
When running a container or listing running containers, docker will typically return a
shortened container ID such as bbe74cd96891. In order to locate the appropriate directory
for your container logs, you will need to the full container ID, such as
bbe74cd968911071ac8a67b21bb0ba4396d546958af143a49692442907fdb261. To get the
full cotnainer ID you can use docker inspect command. example:
```
```
#the bellow command will return the full ID of the container matching the shortened ID
docker inspect --format="{{.Id}}” bbe74cd96891
```
```
Find the full container ID for your logdemo container, and locate the log files:
```
```
[ubuntu@node ~]$ sudo ls -lsh /var/lib/docker/containers/<container ID>
```
```
<container ID>-json.log
<container ID>-json.log.1.gz
<container ID>-json.log.2.gz
```
```
At first you’ll probably only see the -json.log file; the .1.gz and .2.gz will appear as log
files get rotated out.
```
```
Step 5: Keep listing the above directory every few seconds; you should see the original log file
get rotated to <container ID>-json.log.1.gz once it reaches about 5 kb in size. Also,
once it gets rotated out to .1.gz, it will be automatically compressed.
Step 6: Clean up by removing this container:
```
```
[ubuntu@node ~]$ docker container rm -f logdemo
```
### 7.3. Conclusion

```
In this exercise, we reconfigured the Docker Engine’s default logging options, and rotated out and
compressed logfiles once they reached a certain size. An important aspect of cluster design is
allocating and managing disk space for logs; while we can’t provision an unlimited amount of disk
on each of our nodes for logs, the more logs we’re able to keep, the further back in history we can
look when troubleshooting our deployments.
```
7. Managing Container Logs


## 8. Sharing and Streaming Logs

In the event that a containerized process is writing its logs to files rather than streaming them to
STDOUT, we need a technique to expose those logs to our container logging driver so they can
be read in the same way as all our other container logs. By the end of this exercise, you should
be able to:

- Stream logfiles from one container into the container logs of another container.

### 8.1. Setup

Our strategy for streaming logs will be to share the logfile between two containers: the container
creating the logfile, and a second container whose only job is to stream that logfile on its
STDOUT so the container logging driver can catch it.

Step 1: Start by creating a volume that we’ll mount into both containers so they can share the
logs:

```
[ubuntu@node ~]$ docker volume create streamer
```
Step 2: Next let’s create an example container that writes something to a file in its filesystem.
This is obviously a simple example, but imagine this is any containerized application writing a log
or any other file to its filesystem:

```
[ubuntu@node ~]$ docker container run -d --name myapp -v streamer:/tmp \
alpine:3.5 sh -c "while true; do date >> /tmp/logs ; sleep 1; done"
```
```
Notice the flag -v streamer:/tmp: we’ve mounted our streamer volume to the directory
where our process is writing its logfiles.
```
Step 3: Try and read the logs for this container in the usual manner:

```
[ubuntu@node ~]$ docker container logs myapp
```
```
You’ll see nothing, of course - the shell command we’ve containerized doesn’t write anything
to STDOUT, so there’s nothing to see in the logs.
```
```
But, check out the contents of your mounted volume:
```
```
[ubuntu@node ~]$ sudo cat /var/lib/docker/volumes/streamer/_data/logs
```
```
Wed May 19 15 :40:03 UTC 2021
Wed May 19 15 :40:04 UTC 2021
Wed May 19 15 :40:05 UTC 2021
...
```
```
Our container has been logging timestamps to its logfile, invisibly to the container logging
driver. These are what we want to extract into the regular logs.
```
Step 4: Create another container that mounts the streamer volume, and which containerizes a
simple process that writes any updates it finds to the logs file in that volume to STDOUT:

```
[ubuntu@node ~]$ docker container run -d --name streamcontainer -v streamer:/tmp \
alpine:3.5 tail -f /tmp/logs
```
8. Sharing and Streaming Logs


```
Step 5: Check the logs of this new container in the usual fashion:
```
```
[ubuntu@node ~]$ docker container logs streamcontainer
```
```
Wed May 19 15 :48:18 UTC 2021
Wed May 19 15 :48:19 UTC 2021
Wed May 19 15 :48:20 UTC 2021
```
```
Now we can fetch the contents of our logfile using the usual container logging API.
```
### 8.2. Conclusion

```
In this exercise, you assembled a minimal example of streaming a file from one container into the
logs of another. This is particularly important as you start to scale up the number of containers
you’re running, because you’ll want a standardized way of consuming logs from all these
processes. Once all relevant logs are available via the container logging API, it becomes
relatively straightforward to integrate these logs with whichever logging aggregator you prefer.
```
8. Sharing and Streaming Logs