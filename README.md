# scripts

## Use case
- As a developer, I need a to have docker on my local laptop
- But my laptop is running on Windows 7
- And I am behind a massive corporate proxy
- Last not least, have a docker host vm different from boot2docker could be great

## Vagrant
- use a vagrant to have a box with a running docker engine
- need to configure the vm to add the proxy capabilities (apt-get, docker  ...) + proxy ca certificates

## Vagrant up assumptions 
- all the ca certificates must be located in a subdir ../data (see Vagrantfile)
- the proxy configuration must be set in the env : PROXY\_USER, PROXY\_PASS, .. (see Vagrantfile)

## Notes
- the Vagrant contains an IP and the VBox name (can be replaced with other values)

## Operating method

### Create the vm

- Vagrant init

### Docker-machine

- Use the docker-machine to create/register your docker instance.
- Example : vm=dockervm, ip=192.168.33.10, dir=./.vagrant.d/machines/default/virtualbox

```
docker-machine --debug create -d generic \
--generic-ssh-user vagrant \
--generic-ssh-key private_key \
--generic-ip-address 192.168.33.10 \
--engine-env HTTP_PROXY=http://... \
--engine-env HTTPS_PROXY=http://... \
dockervm
```

- If no proxy concerns, no need to provide --engine-env HTTP_PROXY=... and --engine-env HTTPS_PROXY=...


