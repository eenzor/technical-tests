# Technical Test

## Building and Running the Container

### Building

To build the docker container run:

```
docker build . --tag golang-test:latest
```

This will build and tag the image as golang-test, with the version latest.  
If another version is required replace `latest` with the desired value.  


### Fresh Build

To force a fresh build (e.g. to make sure we have the latest alpine packages), run:

```
docker build . --no-cache --tag golang-test:latest
```

### Running

To run the container after building it, run:

```
docker run --publish 8000:8000 golang-test:latest
```

Then connect through http://localhost:8000/ 

## Multi-Stage Docker Build

This Dockerfile has been split into three sections.

1. A caching layer for all the alpine packages and go modules
2. A build layer with all of the build dependencies
3. A run layer from scratch with only the golang binary

This results in fast builds and a small image binary.  

Removing the unused build components from the image improves the security,  
however, it also makes interactive debugging much more difficult. As while  
an attacker can no longer launch a shell in the image, neither can we.  

## Build flags

The command we use to build the golang binary is:

```
GOOS=linux CGO_ENABLED=0 go build -ldflags "-s -w" -a -o golang-test .
```

`GOOS=linux`, tells go to compile the binary for linux. Not strictly necessary, but a habit from developing on MacOS and deploying to Linux  
`CGO_ENABLED=0`, this disables the use of shared C libraries and creates a static binary, this is necessary when running from scratch  
`-ldflags "-s -w"`, this magic incantation strips symbols (-s), and removes the DWARF debugging table (-w). This will stop debugging tools (gdb/pprof) from working, but results in ~2mb smaller binaries.  
`-a`, tells go to recompile all packages (even up to date ones), this is done as a precaution when disabling CGO.  
`-o`, the name of the binary to output  




## Initial misconfiguration

The initial HTTP server was configured to listen to the local loopback address only (127.0.0.1).
This was only accessible from within the container. Only the containers external address is  
available, even when the port is exposed and published. To fix the issue the HTTP server  
needed to be configured to listen on the external (or all through 0.0.0.0) interface.

