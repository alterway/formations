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

![class](images/cl-1.jpeg)



## Docker Container Fundamentals

```text
Docker Container Fundamentals
```

## 0. Docker installation


To quickly setup a dev environment, Docker provides a convenience install script:


### Using quick install script

```shell
# Get installer and install docker engine
curl -fsSL get.docker.com | sh


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
Step 1</b></p>

**Let’s begin by containerizing a simple ping process on your node:**


```shell
docker container run alpine ping 8.8.8.8.
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

<p style="color: purple"><b>
Step 2</b></p>

**List all of the containers on your node host:**


```shell
docker container ls -a
```

```text
CONTAINER ID IMAGE COMMAND ... STATUS ...
81484551f69b alpine "ping 8.8.8.8" ... Exited ( 0 ) 50 seconds ago ...
```


We can see our container and its status. Sending a CTRL+C to the ping process that was
attached to our terminal killed the ping, and since ping was the primary process in our
container, it caused the container itself to exit.


<p style="color: purple"><b>
Step 3</b></p>

**Let’s run the same container again, this time with the -d flag to detach the ping process from our shell so it can run in the background:**


1. The Container Lifecycle


```shell
docker container run -d alpine ping 8 .8.8.
```

```text
4bf570c09043c0094fef87e9cad7e94e20b2b2c8bd1029bb49def581cdcb
```


This time we just get the container ID back (4bf5... in my case, yours will be different), but
the ping output isn’t streaming to the terminal this time.


```text
List your running containers:
```

```shell
docker container ls
```

```text
CONTAINER ID IMAGE COMMAND STATUS ...
4bf570c09043 alpine "ping 8.8.8.8" Up About a minute ...
```

By omitting the -a flag, we get only our running containers - so only the one we just started
and which is still running in the background.


<p style="color: purple"><b>
Step 4</b></p>

**Stop your running container:**

```shell
docker container stop <container ID of running container>
```


>Notice it takes a long time (about 10 seconds) to return. When a container is stopped, there
>is a two step process:

- A SIGTERM is sent to the PID 1 process in the container, asking but not forcing it to
    stop
- After 10 seconds, a SIGKILL is sent to the PID 1 process, forcing it to return and the
    container to enter its EXITED state.


<p style="color: purple"><b>
Step 5</b></p>

**Run the docker container ls again, and you’ll see nothing; there are no running containers. To see our stopped containers, again use:**

```shell
docker container ls -a
```

```shell
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 4 minutes ago Exited ( 137 ) a minute ago
81484551f69b alpine "ping 8.8.8.8" 8 minutes ago Exited ( 0 ) 8 minutes ago
```

The exit codes presented (137 and 0) are the exit codes of the ping process when it was
terminated.


<p style="color: purple"><b>
Step 6</b></p>

**Restart the container you just exited (it should be the one more recently created, with the 137 exit code), and list containers one more time:**

```shell
docker container start <container ID>
```

```shell
docker container ls
```

```shell
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 11 minutes ago Up 25 seconds
```


Even when a container exits, its filesystem and configuration information are preserved so
that it can be restarted later.

### 1.2. Interrogating Containers

1. The Container Lifecycle


<p style="color: purple"><b>
Step 1</b></p>

**Retrieve your state and config information about your running container:**



```shell
docker container inspect <container ID>
```

```json
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


This output provides a wealth of information about how your container is configured, as well
as state conditions and error messages. This is one of the first places to look when
debugging a malfunctioning container. Take some time to read through the fields now so you
have a rough idea of the information available here.

<p style="color: purple"><b>
Step 2</b></p>

**Retrieve your resource consumption stats about your container:**


```shell
docker container stats <container ID>
```

```shell
CONT. ID NAME CPU % MEM USAGE / LIMIT MEM % NET I/O BLOCK I/O PIDS
4bf5... zen_bartik 0 .02% 48KiB / 3 .7GiB 0 .00% 27kB / 26 .4kB 0B / 0B 1
```


Here we see live resource consumption of this container; press CTRL+C when you’re done
watching this monitor.

<p style="color: purple"><b>
Step 3</b></p>

**Retrieve the same information as the previous step, formatted as JSON and only instantaneously, without streaming:**


```shell
docker container stats --no-stream \
--format '{{json .}}' <container ID>
```

```json
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


This option is useful for capturing consumption information by an external monitoring service
that knows how to ingest JSON.

<p style="color: purple"><b>
Step 6</b></p>

**Retrieve the logs from your containerized process:**

1. The Container Lifecycle


```shell
docker container logs <container ID>
```

```shell
PING 8 .8.8.8 ( 8 .8.8.8): 56 data bytes
64 bytes from 8 .8.8.8: seq= 0 ttl= 109 time= 1 .500 ms
64 bytes from 8 .8.8.8: seq= 1 ttl= 109 time= 1 .183 ms
64 bytes from 8 .8.8.8: seq= 2 ttl= 109 time= 1 .095 ms
```


Here we see the STDOUT and STDERR of the primary process in our container -
ping 8.8.8.8 in this case. Note that if you launch other processes in a container, their
output will not be captured in the container logs! Only the process with PID 1 inside a
container is logged in this fashion; this is one of the simplest reasons why it’s often a good
idea to strictly run one process within a container, rather than a complicated process tree.


<p style="color: purple"><b>
Step 5</b></p>

**Get a list of processes running in your container:**

```shell
docker container top <container ID>
```

```shell
UID PID PPID C STIME TTY TIME CMD
root 3312 3293 0 15 :47? 00 :00:00 ping 8 .8.8.
```


Our container is running just one process, ping 8.8.8.8. The PID column in this output
indicates the PID of each process on the host. Remember that if this process exits, the
container will exit. Try this yourself by listing containers and then killing the host process:

```shell
docker container ls
```

```shell
CONTAINER ID IMAGE COMMAND
4bf570c09043 alpine "ping 8.8.8.8"
```

```shell
sudo kill -9 <PID from container top command above>
```

```shell
docker container ls
```

```
CONTAINER ID IMAGE COMMAND
```


Killing the host process and exiting a container are functionally equivalent, as we see here.


**Notes**

>Warning: do not use kill to stop containers! This was just an example to show the
>relationship between host processes and container state. This method can lead to unintended
>consequences with more sophisticated containers.



### 1.3. Launching New Processes in Old Containers

<p style="color: purple"><b>
Step 1</b></p>

**Restart your ping container, exactly as you did before:**

1. The Container Lifecycle


```shell
docker container start <container ID>
```


Remember from our use of docker container top before that there’s just one process
running inside this container. Sometimes, especially when debugging, it can be helpful to be
able to launch additional processes ‘inside’ a container.

<p style="color: purple"><b>
Step 2</b></p>

**Look at the PID tree of your container from the container’s perspective by running ps inside your container:**

```shell
docker container exec <container ID> ps
```

```shell
PID USER TIME COMMAND
1 root 0 :00 ping 8 .8.8.
11 root 0 :00 ps
```


docker container exec launches a new process inside an already running container.
Note the output of ps in this case: it sees the PID tree as it appears inside the container’s
kernel namespaces. So from that perspective, ping looks like PID 1 since it is the primary
process inside this container, rather than the host system PID returned by
docker container top. Despite the different PIDs, these pings are the exact same
process, as we saw previously when killing the host ping exited the container; this is the
kernel PID namespace in action.


<p style="color: purple"><b>
Step 3</b></p>

***Launch an interactive shell inside your running container:***

```shell
docker container exec -it <container ID> sh
/ #
```


From here, you have an interactive prompt you can use to explore your container’s
filesystem and namespaces, similar to if you SSHed into a remote host. Try out some
common commands:

```shell
/ # ls
```

```shell
bin dev etc home lib media mnt opt proc root
run sbin srv sys tmp usr var
```

```shell
/ # ps
```

```shell
PID USER TIME COMMAND
1 root 0 :00 ping 8 .8.8.
16 root 0 :00 sh
22 root 0 :00 ps
```

```shell
/ # whoami
root
```


When you’re done practicing, type exit to return to your host.


### 1.4. Cleaning up Containers

1. The Container Lifecycle


<p style="color: purple"><b>
Step 1</b></p>

**List all of your containers one more time:**

```shell
docker container ls -a
CONTAINER ID IMAGE COMMAND CREATED STATUS
4bf570c09043 alpine "ping 8.8.8.8" 37 minutes ago Up 10 minutes
81484551f69b alpine "ping 8.8.8.8" 41 minutes ago Exited ( 0 ) 41 minutes ago
```

<p style="color: purple"><b>
Step 2</b></p>

**Remove the exited container:**

```shell
docker container rm <container ID of Exited container>
```

<p style="color: purple"><b>
Step 3</b></p>

**Attempt to remove the running container:**

```shell
docker container rm <container ID>
```

```shell
Error response from daemon: You cannot remove a running container
4bf570c09043c0094fef87e9cad7e94e20b2b2c8bd1029bb49def581cdcb8864.
Stop the container before attempting removal or force remove
```


As displayed in the error message, docker container rm will decline to remove a
running container. We could stop it then remove it as we did above, or we could force
removal:

```shell
docker container rm -f <container ID>
```


At this point, all of your containers from this exercise should be gone. Use
docker container ls -a to confirm this. If any containers remain, use the commands
you learned during these exercises to remove them.


### 1.5. Optional: Independent Container Filesystems

One important detail to understand about container filesystems is that each container has an
independent filesystem, even if they’re started from the same image. We’ll study how these
filesystems are implemented in the next chapter, but for now it’s worth exploring how they appear
in practice:

<p style="color: purple"><b>
Step 1</b></p>

**Create a container using the centos:7 image and connect to its bash shell in interactive mode:**

```shell
docker container run -it centos:7 bash
```

<p style="color: purple"><b>
Step 2</b></p>

**Explore your container’s filesystem with ls, and then create a new file. Use ls again to confirm you have successfully created your file. Use the -l option with ls to list the files and directories in a long list format.**

```shell
[root@2b8de2ffdf85 /]# ls -l
[root@2b8de2ffdf85 /]# echo 'Hello there...' > test.txt
[root@2b8de2ffdf85 /]# ls -l
```

<p style="color: purple"><b>
Step 3</b></p>

**Exit the connection to the container:**

```shell
[root@2b8de2ffdf85 /]# exit
```

<p style="color: purple"><b>
Step 4</b></p>

**Run the same command as before to start a container using the centos:7 image:**

1. The Container Lifecycle


```shell
docker container run -it centos:7 bash
```

<p style="color: purple"><b>
Step 5</b></p>

**Use ls to explore your container. You will see that your previously created test.txt is nowhere to be found in your new container; while both containers were based on the same centos:7 image, changes made to the filesystem inside a container (like adding test.txt) are local only to the container that made the change, preserving independence between containers.**

<p style="color: purple"><b>
Step 6</b></p>

**Challenge: Using the commands you learned previously, restart the container you created test.txt in, connect to it, and prove that that file is still present in that container.**

<p style="color: purple"><b>
Step 7</b></p>
**Remember to clean up by deleting the containers created in this section.**

### 1.6. Conclusion

>In this exercise we learned the basic commands to start, stop, restart and investigate a container.
>But beyond basic syntax, we learned some examples of the importance of the primary, PID 1
>process inside a container. The state of this process determines the liveness of our container, the
>STDOUT and STDERR of this process is what’s logged by container logs, and this process’
>response to SIGTERM determines how our container behaves during a controlled shutdown.


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

<p style="color: purple"><b>
Step 1</b></p>

**Start a bash terminal in a CentOS container:**

```shell
docker container run -it centos:7 bash
```

<p style="color: purple"><b>
Step 2</b></p>

**Install a couple pieces of software in this container - there’s nothing special about wget, any changes to the filesystem will do. Afterwards, exit the container:**

```shell
[root@dfe86ed42be9 /]# yum install -y which wget
[root@dfe86ed42be9 /]# exit
```

<p style="color: purple"><b>
Step 3</b></p>

**Finally, try docker container diff to see what’s changed about a container relative to its image; you’ll need to get the container ID via docker container `ls -a` first:**

```shell
docker container ls -a
docker container diff <container ID>
```

```shell
C /root
A /root/.bash_history
C /usr
C /usr/bin
A /usr/bin/gsoelim
```


Those C at the beginning of lines stand for files changed, and A for added; lines that start
with D indicate deletions.


### 2.2. Capturing Container State as an Image

<p style="color: purple"><b>
Step 1</b></p>

**Installing which and wget in the last step wrote information to the container’s read/write layer; now let’s save that read/write layer as a new read-only image layer in order to create a new image that reflects our additions, via the docker container commit:**

```shell
docker container commit <container ID> myapp:1.
```


<p style="color: purple"><b>
Step 2</b></p>

**Check that you can see your new image by listing all your images:**

```shell
docker image ls
```


```shell
REPOSITORY TAG IMAGE ID CREATED SIZE
myapp 1 .0 34f97e0b087b 8 seconds ago 300MB
centos 7 5182e96772bf 44 hours ago 200MB
```

<p style="color: purple"><b>
Step 3</b></p>

**Create a container running bash using your new image, and check that which and wget are installed:**

2. Interactive Image Creation


```shell
docker container run -it myapp:1.0 bash
[root@2ecb80c76853 /]# which wget
```

The which commands should show the path to the specified executable, indicating they
have been installed in the image. Exit your container when done by typing exit.


### 2.3. Conclusion


>In this exercise, you learned how to inspect the contents of a container’s read / write layer with
>docker container diff, and then commit those changes to a new image layer with
>docker container commit. Committing a container as an image in this fashion can be useful
>when developing an environment inside a container, when you want to capture that environment
>for reproduction elsewhere.


## 3. Creating Images with Dockerfiles (1/2)

By the end of this exercise, you should be able to:

- Write a Dockerfile using the FROM and RUN commands
- Build an image from a Dockerfile
- Anticipate which image layers will be fetched from the cache at build time
- Fetch build history for an image

### 3.1. Writing and Building a Dockerfile

<p style="color: purple"><b>
Step 1</b></p>

**Create a folder called myimage, and a text file called Dockerfile within that folder. In Dockerfile, include the following instructions:**

```dockerfile
FROM centos:

RUN yum update -y
RUN yum install -y wget
```


This serves as a recipe for an image based on centos:7, that has all of its default packages
updated and wget installed on top.


<p style="color: purple"><b>
Step 2</b></p>

**Build your image with the build command. Don’t miss the. at the end; that’s the path to your Dockerfile. Since we’re currently in the directory myimage which contains it, the path is just. (here).**

```shell
[ubuntu@node myimage]$ docker image build -t myimage.
```


You’ll see a long build output describing each step of the build. The builder goes through the
following build steps:

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


Your image creation was successful if the output ends with
Successfully tagged myimage:latest.


<p style="color: purple"><b>
Step 3</b></p>

**Verify that your new image exists with docker image ls, then use your new image to run a container and wget something from within that container, just to confirm that everything worked as expected:**

3. Creating Images with Dockerfiles (1/2)


```shell
[ubuntu@node myimage]$ docker container run -it myimage bash
[root@1d86d4093cce /]# wget example.com
[root@1d86d4093cce /]# cat index.html
[root@1d86d4093cce /]# exit
```


You should see the HTML from example.com, downloaded by wget from within your
container.

<p style="color: purple"><b>
Step 4</b></p>

**It’s also possible to pipe a Dockerfile in from STDIN; try rebuilding your image with the following:**

```shell
[ubuntu@node myimage]$ cat Dockerfile | docker image build -t myimage -f -.
```

(This is useful when reading a Dockerfile from a remote location with curl, for example).


### 3.2. Using the Build Cache


In the previous step, the second time you built your image it should have completed immediately,
with each step except the first reporting using cache. Cached build steps will be used until a
change in the Dockerfile is found by the builder.

<p style="color: purple"><b>
Step 1</b></p>

**Open your Dockerfile and add another RUN step at the end to install vim:**


```dockerfile
FROM centos
RUN yum update -y
RUN yum install -y wget
RUN yum install -y vim
```

<p style="color: purple"><b>
Step 2</b></p>

**Build the image again as before; which steps is the cache used for?**

<p style="color: purple"><b>
Step 3</b></p>
**Build the image again; which steps use the cache this time?**

<p style="color: purple"><b>
Step 4</b></p>

**Swap the order of the two RUN commands for installing wget and vim in the Dockerfile:**

```dockerfile
FROM centos:

RUN yum update -y
RUN yum install -y vim
RUN yum install -y wget
```

Build one last time. Which steps are cached this time?


### 3.3. Using the history Command

<p style="color: purple"><b>
Step 1</b></p>

**The docker image history command allows us to inspect the build cache history of an image. Try it with your new image:**

3. Creating Images with Dockerfiles (1/2)


```shell
[ubuntu@node myimage]$ docker image history myimage:latest
```

```shell
IMAGE CREATED CREATED BY SIZE
f2e85c162453 8 seconds ago /bin/sh -c yum install -y wget 87 .2MB
93385ea67464 12 seconds ago /bin/sh -c yum install -y vim 142MB
27ad488e6b79 3 minutes ago /bin/sh -c yum update -y 86 .5MB
5182e96772bf 44 hours ago /bin/sh -c #(nop) CMD ["/bin/bash"] 0B
<missing> 44 hours ago /bin/sh -c #(nop) LABEL org.label-schema.... 0B
<missing> 44 hours ago /bin/sh -c #(nop) ADD file:6340c690b08865d... 200MB
```

Note the image id of the layer built for the yum update command.

<p style="color: purple"><b>
Step 2</b></p> 

**Replace the two RUN commands that installed wget and vim**


with a single command:


```shell
RUN yum install -y wget vim
```



<p style="color: purple"><b>
Step 3</b></p>

**Build the image again, and run docker image history on this new image. How has the history changed?**

### 3.4. Conclusion

>In this exercise, we’ve seen how to write a basic Dockerfile using FROM and RUN commands,
>some basics of how image caching works, and seen the docker image history command.
>Using the build cache effectively is crucial for images that involve lengthy compile or download
>steps. In general, moving commands that change frequently as late as possible in the Dockerfile



## 4. Creating Images with Dockerfiles (2/2)


By the end of this exercise, you should be able to:

- Define a default process for an image to containerize by using the ENTRYPOINT or CMD
    Dockerfile commands
- Understand the differences and interactions between ENTRYPOINT and CMD
- Ensure that a containerized process doesn’t run as root by default.

### 4.1. Setting Default Commands

<p style="color: purple"><b>
Step 1</b></p>

**Add the following line to the bottom of your Dockerfile from the last exercise:**


```dockerfile
...
CMD ["ping", "127.0.0.1", "-c", "5"]
```

This sets ping as the default command to run in a container created from this image, and
also sets some parameters for that command.

<p style="color: purple"><b>
Step 2</b></p>

**Rebuild your image:**

```shell
[ubuntu@node myimage]$ docker image build -t myimage.
```

<p style="color: purple"><b>
Step 3</b></p>

**Run a container from your new image with no command provided:**

```shell
[ubuntu@node myimage]$ docker container run myimage
```


You should see the command provided by the CMD parameter in the Dockerfile running.

<p style="color: purple"><b>
Step 4</b></p>

**Try explicitly providing a command when running a container:**

```shell
[ubuntu@node myimage]$ docker container run myimage echo "hello world"
```

Providing a command in docker container run overrides the command defined by CMD.

<p style="color: purple"><b>
Step 5</b></p>

**Replace the CMD instruction in your Dockerfile with an ENTRYPOINT:**

```dockerfile
...
ENTRYPOINT ["ping"]
```

<p style="color: purple"><b>
Step 6</b></p>

**Build the image and use it to run a container with no process arguments:**

```shell
[ubuntu@node myimage]$ docker image build -t myimage.
[ubuntu@node myimage]$ docker container run myimage
```


You’ll get an error. What went wrong?

<p style="color: purple"><b>
Step 7</b></p>

**Try running with an argument after the image name:**

```shell
[ubuntu@node myimage]$ docker container run myimage 127 .0.0.
```

You should see a successful ping output. Tokens provided after an image name are sent as
arguments to the command specified by ENTRYPOINT.



4. Creating Images with Dockerfiles (2/2)


### 4.2. Combining Default Commands and Options


<p style="color: purple"><b>
Step 1</b></p>

**Open your Dockerfile and modify the ENTRYPOINT instruction to include 2 arguments for the ping command:**

```dockerfile
ENTRYPOINT ["ping", "-c", "3"]
```

<p style="color: purple"><b>
Step 2</b></p>

**If `CMD` and ENTRYPOINT are both specified in a Dockerfile, tokens listed in CMD are used as default parameters for the ENTRYPOINT command. Add a CMD with a default IP to ping:**

#### CMD ["127.0.0.1"]

<p style="color: purple"><b>
Step 3</b></p>

**Build the image and run a container with the defaults:**

```shell
[ubuntu@node myimage]$ docker image build -t myimage.
[ubuntu@node myimage]$ docker container run myimage
```


You should see it pinging the default IP, 127.0.0.1.

<p style="color: purple"><b>
Step 4</b></p>

**Run another container with a custom IP argument:**

```shell
[ubuntu@node myimage]$ docker container run myimage 8 .8.8.
```


This time, you should see a ping to 8.8.8.8. Explain the difference in behavior between
these two last containers.

### 4.3. Running as Non-Root by Default

<p style="color: purple"><b>
Step 1</b></p>

**Make a new directory for this example, and move there:**

```shell
mkdir ~/user ; cd ~/user
```

<p style="color: purple"><b>
Step 2</b></p>

**Define a simple pinging container in a Dockerfile:**

```dockerfile
FROM centos:
CMD ["ping", "8.8.8.8"]
```


<p style="color: purple"><b>
Step 3</b></p>

**Build and run your image, and check the user ID of the ping process:**

```shell
[ubuntu@node user]$ docker image build -t pinger:root.
[ubuntu@node user]$ docker container run --name rootdemo -d pinger:root
[ubuntu@node user]$ docker container exec rootdemo ps -aux
```

```shell
USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
root 1 0 .8 0 .0 24856 1800? Ss 17 :52 0 :00 ping 8 .8.8.
root 7 0 .0 0 .0 51748 3364? Rs 17 :52 0 :00 ps -aux
```


As we can see, ping and its child processes are running as root.

<p style="color: purple"><b>
Step 4</b></p>

**There’s no need for ping to run as root. Set it to run as uid 1000 (or any other unprivileged user) by amending your Dockerfile:**

4. Creating Images with Dockerfiles (2/2)


```dockerfile
FROM centos:
USER 1000
CMD ["ping", "8.8.8.8"]
```

<p style="color: purple"><b>
Step 5</b></p>

**Build, run, and check your process tree again:**



```shell
[ubuntu@node user]$ docker container rm -f rootdemo
[ubuntu@node user]$ docker image build -t pinger:user.
[ubuntu@node user]$ docker container run --name userdemo -d pinger:user
[ubuntu@node user]$ docker container exec userdemo ps -aux
```

```shell
USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
1000 1 0 .7 0 .0 24856 1908? Ss 17 :55 0 :00 ping 8 .8.8.
1000 7 0 .0 0 .0 51748 3468? Rs 17 :55 0 :00 ps -aux
```

This is a simple way to tighten the security of any image that doesn’t need containerized root
privileges.

<p style="color: purple"><b>
Step 6</b></p>

**Clean up your container:**


```shell
[ubuntu@node user]$ docker container rm -f userdemo
```

### 4.4. Conclusion


>CMD, ENTRYPOINT and USER all share one thing in common: they’re all optional Dockerfile
>commands, but they should be present in virtually all Dockerfiles. CMD and ENTRYPOINT help
>clarify for future users of your image just what process your image is meant to containerize; since
>images should be built to containerize exactly one specific process in almost all cases, capturing
>this as part of the image helps communicate the design intention of the image to users. The USER
>directive is an easy way to avoid security risks presented by running processes with unnecessary
>root privileges; just like you’d never run a process as root unnecessarily in a VM, the same
>precautions should be taken in a container.



## 5. Multi-Stage Builds

By the end of this exercise, you should be able to:

- Write a Dockerfile that describes multiple images, which can copy files from one image to
    the next.
- Enable BuildKit for faster build times

### 5.1. Defining a multi-stage build

<p style="color: purple"><b>
Step 1</b></p>

**Make a new folder named multi to do this exercise in, and cd into it.**

<p style="color: purple"><b>
Step 2</b></p> 

**Add a file hello.c to the multi folder containing Hello World in C:**

```c
#include <stdio.h>
int main (void)
{
printf ("Hello, world!\n");
return 0 ;
}
```

<p style="color: purple"><b>
Step 3</b></p>

**Try compiling and running this right on the host OS:**

```shell
gcc -Wall hello.c -o hello
./hello
```

<p style="color: purple"><b>
Step 4</b></p>

**Now let’s Dockerize our hello world application. Add a Dockerfile to the multi folder with this content:**

```dockerfile
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

<p style="color: purple"><b>
Step 5</b></p>

**Build the image and note its size:**

```shell
docker image build -t my-app-large.
docker image ls | grep my-app-large
```

```shell
REPOSITORY TAG IMAGE ID CREATED SIZE
my-app-large latest a7d0c6fe0849 3 seconds ago 189MB
```

<p style="color: purple"><b>
Step 6</b></p>

**Test the image to confirm it was built successfully:**

```shell
docker container run my-app-large
```

It should print “hello world” in the console.

5. Multi-Stage Builds


<p style="color: purple"><b>
Step 7</b></p>

**Update your Dockerfile to use an AS clause on the first line, and add a second stanza describing a second build stage:**

```dockerfile
FROM alpine:3.5 AS build
RUN apk update && \
apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
COPY hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
```


```dockerfile
FROM alpine:3.5
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello
```

<p style="color: purple"><b>
Step 8</b></p>

**Build the image again and compare the size with the previous version:**

```shell
docker image build -t my-app-small.
docker image ls | grep 'my-app-'
```

```shell
REPOSITORY TAG IMAGE ID CREATED SIZE
my-app-small latest f49ec3971aa6 6 seconds ago 4 .01MB
my-app-large latest a7d0c6fe0849 About a minute ago 189MB
```


As expected, the size of the multi-stage build is much smaller than the large one since it
does not contain the Alpine SDK.

<p style="color: purple"><b>
Step 9</b></p>Finally, make sure the app works:

```shell
docker container run --rm my-app-small
```


You should get the expected ‘Hello, World!’ output from the container with just the required
executable.

### 5.2. Building Intermediate Images


In the previous step, we took our compiled executable from the first build stage, but that image
wasn’t tagged as a regular image we can use to start containers with; only the final FROM
statement generated a tagged image. In this step, we’ll see how to persist whichever build stage
we like.

<p style="color: purple"><b>
Step 1</b></p>

**Build an image from the build stage in your Dockerfile using the --target flag:**

```shell
docker image build -t my-build-stage --target build.
```


Notice all its layers are pulled from the cache; even though the build stage wasn’t tagged
originally, its layers are nevertheless persisted in the cache.

<p style="color: purple"><b>
Step 2</b></p>

**Run a container from this image and make sure it yields the expected result:**

```shell
docker container run -it --rm my-build-stage /app/bin/hello
```

5. Multi-Stage Builds


<p style="color: purple"><b>
Step 3</b></p>

**List your images again to see the size of my-build-stage compared to the small version of the app.**

### 5.3. Optional: Building from Scratch

So far, every image we’ve built has been based on a pre-existing image, referenced in the FROM
command. But what if we want to start from nothing, and build a completely original image? For
this, we can build FROM scratch.

<p style="color: purple"><b>
Step 1</b></p>

**In a new directory ~/scratch, create a file named sleep.c that just launches a sleeping process for an hour:**

```c
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

<p style="color: purple"><b>
Step 2</b></p>

**Create a file named Dockerfile to build this sleep program in a build stage, and then copy it to a scratch-based image:***

```dockerfile
FROM alpine:3.8 AS build
RUN ["apk", "update"]
RUN ["apk", "add", "--update", "alpine-sdk"]
COPY sleep.c /
RUN ["gcc", "-static", "sleep.c", "-o", "sleep"]

FROM scratch
COPY --from=build /sleep /sleep
CMD ["/sleep"]
```


This image will contain nothing but our executable and the bare minimum file structure
Docker needs to stand up a container filesystem. Note we’re statically linking the sleep.c
binary, so it will have everything it needs bundled along with it, not relying on the rest of the
container’s filesystem for anything.

<p style="color: purple"><b>
Step 3</b></p>

**Build your image:**

```shell
[ubuntu@node scratch]$ docker image build -t sleep:scratch.
```

<p style="color: purple"><b>
Step 4</b></p>

**List your images, and search for the one you just built:**

```shell
[ubuntu@node scratch]$ docker image ls | grep scratch
```

```shell
REPOSITORY TAG IMAGE ID CREATED SIZE
sleep scratch 1b68b20a85a8 9 minutes ago 128kB
```

This image is only 128 kB, as tiny as possible.



<p style="color: purple"><b>
Step 5</b></p>

**Run your image, and check out its filesystem; we can’t list directly inside the container, since ls isn’t installed in this ultra-minimal image, so we have to find where this container’s filesystem is mounted on the host. Start by finding the PID of your sleep process after its running:**

```shell
[ubuntu@node scratch]$ docker container run --name sleeper -d sleep:scratch
[ubuntu@node scratch]$ docker container top sleeper
```

```shell
UID PID PPID C STIME TTY TIME CMD
root 1190 1174 0 15 :21? 00 :00:00 /sleep
```


In this example, the PID for sleep is 1190.

<p style="color: purple"><b>
Step 6</b></p>

**List your container’s filesystem from the host using this PID:**

```shell
[ubuntu@node scratch]$ sudo ls /proc/<PID>/root
```

```shell
dev etc proc sleep sys
```


We see not only our binary sleep but a bunch of other folders and files. Where does these
come from? runC, the tool for spawning and running containers, requires a json config of the
container and a root file system. At execution, the container runtime adds these minimum
requirements to form the most minimal container filesystem possible.

<p style="color: purple"><b>
Step 7</b></p>

**Clean up by deleting your container:**

```shell
[ubuntu@node scratch]$ docker container rm -f sleeper
```


### 5.4. Optional: Enabling BuildKit

In addition to the default builder, BuildKit can be enabled to take advantages of some
optimizations of the build process.
<p style="color: purple"><b>
Step 1</b></p>

**Back in the ~/multi directory, turn on BuildKit:**

```shell
export DOCKER_BUILDKIT= 1
```

<p style="color: purple"><b>
Step 2</b></p>

**Add an AS label to the final stage of your Dockerfile (this is not strictly necessary, but will make the output in the next step easier to understand):**

```dockerfile
...
FROM alpine:3.5 AS prod
RUN apk update
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello
```

```
<p style="color: purple"><b>
Step 3</b></p>
**Re-build my-app-small, without the cache:**


```shell
docker image build --no-cache -t my-app-small-bk.
```

```shell
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


Notice the lines marked like [prod 2/3] and [build 4/6]: prod and build in this
context are the AS labels you applied to the FROM lines in each stage of your build in the
Dockerfile; from the above output, you can see that the build stages were built in parallel.
Every step of the final image was completed while the build environment image was being
created; the prod environment image creation was only blocked at the COPY instruction
since it required a file from the completed build image.

<p style="color: purple"><b>
Step 4</b></p>

**Comment out the COPY instruction in the prod image definition in your Dockerfile, and rebuild; the build image is skipped. BuildKit recognized that the build stage was not necessary for the image being built, and skipped it.**

<p style="color: purple"><b>
Step 5</b></p>

**Turn off BuildKit:**

```shell
export DOCKER_BUILDKIT= 0
```


### 5.5. Conclusion

>In this exercise, you created a Dockerfile defining multiple build stages. Being able to take
>artifacts like compiled binaries from one image and insert them into another allows you to create
>very lightweight images that do not include developer tools or other unnecessary components in
>your production-ready images, just like how you currently probably have separate build and run
>environments for your software. This will result in containers that start faster, and are less
>vulnerable to attack.


## 6. Managing Images


By the end of this exercise, you should be able to:


- Rename and retag an image
- Push and pull images from the public registry
- Delete image tags and image layers, and understand the difference between the two
    operations

### 6.1. Making an Account on Docker’s Hosted Registry

<p style="color: purple"><b>
Step 1</b></p>

**If you don’t have one already, head over to https://hub.docker.com and make an account.**



For the rest of this workshop, <Docker ID> refers to the username you chose for this
account.


### 6.2. Tagging and Listing Images

<p style="color: purple"><b>
Step 1</b></p>

**Download the centos:7 image from Docker Hub:**

```shell
docker image pull centos:7
```

<p style="color: purple"><b>
Step 2</b></p>

**Make a new tag of this image:**

```shell
docker image tag centos:7 my-centos:dev
```

Note no new image has been created; my-centos:dev is just a pointer pointing to the
same image as centos:7.

<p style="color: purple"><b>
Step 3</b></p>

**List your images:**

```shell
docker image ls
```



You should have centos:7 and my-centos:dev both listed, but they ought to have the
same hash under image ID, since they’re actually the same image.


### 6.3. Sharing Images on Docker Hub

<p style="color: purple"><b>
Step 1</b></p>

**Push your image to Docker Hub:**

```
docker image push my-centos:dev
```

You should get a denied: requested access to the resource is denied error.

<p style="color: purple"><b>
Step 2</b></p>

**Login by doing docker login, and try pushing again. The push fails again because we haven’t namespaced our image correctly for distribution on Docker Hub; all images you want to share on Docker Hub must be named like <Docker ID>/<repo name>[:<optional tag>].**

<p style="color: purple"><b>
Step 3</b></p>

**Retag your image to be namespaced properly, and push again:**

```shell
docker image tag my-centos:dev <Docker ID>/my-centos:dev
docker image push <Docker ID>/my-centos:dev
```

<p style="color: purple"><b>
Step 4</b></p>

**Search Docker Hub for your new <Docker ID>/my-centos repo, and confirm that you can see the :dev tag therein.**

6. Managing Images


<p style="color: purple"><b>
Step 5</b></p>**Next, make a new directory called hubdemo, and in it create a Dockerfile that uses
<Docker ID>/my-centos:dev as its base image, and installs any application you like on top
of that. Build the image, and simultaneously tag it as :1.0:**

```shell
[ubuntu@node hubdemo]$ docker image build -t <Docker ID>/my-centos:1.0.
```

<p style="color: purple"><b>
Step 6</b></p>

**Push your :1.0 tag to Docker Hub, and confirm you can see it in the appropriate repository.**

<p style="color: purple"><b>
Step 7</b></p>

**Finally, list the images currently on your node with docker image ls. You should still have the version of your image that wasn’t namespaced with your Docker Hub user name; delete this using docker image rm:**

```shell
docker image rm my-centos:dev
```


Only the tag gets deleted, not the actual image. The image layers are still referenced by
another tag.

### 6.4. Conclusion

>In this exercise, we practiced tagging images and exchanging them on the public registry. The
>namespacing rules for images on registries are mandatory: user-generated images to be
>exchanged on the public registry must be named like
><Docker ID>/<repo name>[:<optional tag>]; official images in the Docker registry just
>have the repo name and tag.

Also note that as we saw when building images, image names and tags are just pointers; deleting
an image with docker image rm just deletes that pointer if the corresponding image layers are
still being referenced by another such pointer. Only when the last pointer is deleted are the image
layers actually destroyed by docker image rm.



## 7. Managing Container Logs


By default, the STDOUT and STDERR of the PID 1 process inside a container is captured in a
single JSON file by the Docker engine; these logs are not compressed and not rotated by default.
By the end of this exercise, you should be able to:

- Configure Docker Engine’s logging driver
- Interpret the output of logs generated by the json-file and journald log drivers
- Configure log compression and rotation

### 7.1. Setting the Logging Driver


Docker offers a number of different logging drivers for recording the STDOUT and STDERR of
PID 1 processes in a container; below we’ll explore the defaults which correspond to the
json-file driver, and the journald driver.

<p style="color: purple"><b>
Step 1</b></p>

**Run a simple container with the default logging configuration, and inspect its logs:**


```shell
docker container run -d centos:7 ping 8 .8.8.8
docker container logs <container ID>
```

```shell
PING 8 .8.8.8 ( 8 .8.8.8) 56 ( 84 ) bytes of data.
64 bytes from 8 .8.8.8: icmp_seq= 1 ttl= 113 time= 0 .631 ms
64 bytes from 8 .8.8.8: icmp_seq= 2 ttl= 113 time= 0 .652 ms
64 bytes from 8 .8.8.8: icmp_seq= 3 ttl= 113 time= 0 .646 ms
```

<p style="color: purple"><b>
Step 2</b></p>

**Examine these same logs directly on disk; note <container ID> here is the full, untruncated container ID returned when you created the container above, or findable via**

```shall
docker container ls --no-trunc:**
```

```shell
sudo head -5 \
/var/lib/docker/containers/<container ID>/<container ID>-json.log
```

```shell
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


By default, logs are recorded as per the json-file driver format.

<p style="color: purple"><b>
Step 3</b></p>

**Configure your logging driver to send logs to the system journal by updating /etc/docker/daemon.json to look like this (note you’ll need to open this file with sudo permissions in order to edit it):**

```json
{
"log-driver": "journald"
}
```

<p style="color: purple"><b>
Step 5</b></p>

**Restart Docker so the new logging configuration takes effect:**

```shell
sudo service docker restart
```

1. Managing Container Logs

<p style="color: purple"><b>
Step 5</b></p>

**Run another container, just like the one you ran above, but this time name it demo:**

```shell
docker container run -d --name demo centos:7 ping 8 .8.8.8
```

<p style="color: purple"><b>
Step 5</b></p>

**Inspect the system journal for messages from the demo container:**

```shell
journalctl CONTAINER_NAME=demo
-- Logs begin at Wed 2021 -05-19 15 :03:26 UTC, end at Wed 2021 -05-19 15 :11:09 UTC. --
May 19 15 :11:02 node 138194df21dc[ 1701 ]: PING 8 .8.8.8 ( 8 .8.8.8) 56 ( 84 ) bytes of data.
May 19 15 :11:02 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 1 ttl= 113 time= 1 .14 ms
May 19 15 :11:03 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 2 ttl= 113 time= 1 .14 ms
May 19 15 :11:04 node 138194df21dc[ 1701 ]: 64 bytes from 8 .8.8.8: icmp_seq= 3 ttl= 113 time= 1 .19 ms
```


In this way, container logs can be sent to the system journal for ingestion by a centralized
logging framework along with the rest of the journal messages.

### 7.2. Configuring Log Compression and Rotation

By default, container logfiles can grow unbounded until all host disk is consumed. Many
file-based logging drivers like json-file support automatic log rotation and compression.

<p style="color: purple"><b>
Step 1</b></p>

**Configure the Docker engine on node to create a json file of logs, swapping to a new file every 5 kb, preserving a maximum of 3 files, by changing your /etc/docker/daemon.json to look like this:**

```json
{
"log-driver": "json-file",
"log-opts": {
"max-size": "5k",
"max-file": "3",
"compress": "true"
}
}
```

<p style="color: purple"><b>
Step 2</b></p>

**Restart Docker so the new logging configuration takes effect:**

```shell
sudo service docker restart
```

<p style="color: purple"><b>
Step 3</b></p>

**Start another container generating logs:**

```shell
docker container run --name logdemo -d centos:7 ping 8 .8.8.8
```

<p style="color: purple"><b>
Step 4</b></p>

**Find the container’s log files under /var/lib/docker/containers.**


When running a container or listing running containers, docker will typically return a
shortened container ID such as bbe74cd96891. In order to locate the appropriate directory
for your container logs, you will need to the full container ID, such as
bbe74cd968911071ac8a67b21bb0ba4396d546958af143a49692442907fdb261. To get the
full cotnainer ID you can use docker inspect command. example:

```shell
#the bellow command will return the full ID of the container matching the shortened ID
docker inspect --format="{{.Id}}” bbe74cd96891
```

Find the full container ID for your logdemo container, and locate the log files:

```shell
sudo ls -lsh /var/lib/docker/containers/<container ID>
```

```shell
<container ID>-json.log
<container ID>-json.log.1.gz
<container ID>-json.log.2.gz
```


At first you’ll probably only see the -json.log file; the .1.gz and .2.gz will appear as log
files get rotated out.

<p style="color: purple"><b>
Step 5</b></p>

**Keep listing the above directory every few seconds; you should see the original log file get rotated to <container ID>-json.log.1.gz once it reaches about 5 kb in size. Also, once it gets rotated out to .1.gz, it will be automatically compressed.**

<p style="color: purple"><b>
Step 6</b></p>

**Clean up by removing this container:**

```shell
docker container rm -f logdemo
```


### 7.3. Conclusion


>In this exercise, we reconfigured the Docker Engine’s default logging options, and rotated out and
>compressed logfiles once they reached a certain size. An important aspect of cluster design is
>allocating and managing disk space for logs; while we can’t provision an unlimited amount of disk
>on each of our nodes for logs, the more logs we’re able to keep, the further back in history we can
>look when troubleshooting our deployments.


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


<p style="color: purple"><b>
Step 5</b></p>

**Start by creating a volume that we’ll mount into both containers so they can share the logs:**

```shell
docker volume create streamer
```

<p style="color: purple"><b>
Step 2</b></p>

**Next let’s create an example container that writes something to a file in its filesystem. This is obviously a simple example, but imagine this is any containerized application writing a log or any other file to its filesystem:**

```shell
docker container run -d --name myapp -v streamer:/tmp \
alpine:3.5 sh -c "while true; do date > /tmp/logs ; sleep 1; done"
```


Notice the flag -v streamer:/tmp: we’ve mounted our streamer volume to the directory
where our process is writing its logfiles.

<p style="color: purple"><b>
Step 3</b></p>

**Try and read the logs for this container in the usual manner:**

```shell
docker container logs myapp
```


You’ll see nothing, of course - the shell command we’ve containerized doesn’t write anything
to STDOUT, so there’s nothing to see in the logs.

But, check out the contents of your mounted volume:

```shell
sudo cat /var/lib/docker/volumes/streamer/_data/logs
```

```shell
Wed May 19 15 :40:03 UTC 2021
Wed May 19 15 :40:04 UTC 2021
Wed May 19 15 :40:05 UTC 2021
...
```


Our container has been logging timestamps to its logfile, invisibly to the container logging
driver. These are what we want to extract into the regular logs.

<p style="color: purple"><b>
Step 4</b></p>

**Create another container that mounts the streamer volume, and which containerizes a simple process that writes any updates it finds to the logs file in that volume to STDOUT:**

```shell
docker container run -d --name streamcontainer -v streamer:/tmp \
alpine:3.5 tail -f /tmp/logs
```

8. Sharing and Streaming Logs


<p style="color: purple"><b>
Step 5</b></p>

**Check the logs of this new container in the usual fashion:**

```shell
docker container logs streamcontainer
```

```shell
Wed May 19 15 :48:18 UTC 2021
Wed May 19 15 :48:19 UTC 2021
Wed May 19 15 :48:20 UTC 2021
```


Now we can fetch the contents of our logfile using the usual container logging API.

### 8.2. Conclusion


>In this exercise, you assembled a minimal example of streaming a file from one container into the
>logs of another. This is particularly important as you start to scale up the number of containers
>you’re running, because you’ll want a standardized way of consuming logs from all these
>processes. Once all relevant logs are available via the container logging API, it becomes
>relatively straightforward to integrate these logs with whichever logging aggregator you prefer.



