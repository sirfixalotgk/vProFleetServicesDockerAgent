# Intel(R) vPro Fleet Services activation agent container

The Intel(R) vPro Fleet Services agent is used to provision Intel(R) AMT (Active Management Technologies, part of Intel(R) vPro) for use with the vPro Fleet Services cloud service.

Create an account at https://vprofleet.intel.com and use this container on your vPro Linux devices today!

NOTE: This container downloads, installs and uses applications/services from multiple sources.  By using this container, you agree to licenses, agreements, etc., without limitation, of any and all included items.

https://github.com/rgl/lms-binaries

https://github.com/device-management-toolkit/rpc-go

## Getting started:

```bash
git clone https://github.com/sirfixalotgk/vProFleetAgentServicesDocker
```
Download the pairing token for the endpoint group you wish the device to provision against and place it in your local clone of this repo.

NOTE: pairing tokens are unique to your VFS tenant and endpoint group BUT not to any device.  You can use the same pairing token to provision all of your vPro devices!

Rename the 'rename-to-.env' file to '.env' and edit it to reflect the FQDN and primary DNS suffix that you wish the device to use (per device)
```bash
mv rename-to-.env .env
vi .env
```
(I'll provide some examples of how this could be scripted for automation soon)


Execute the build.sh script to create the docker image.
```bash
chmod 755 build.sh
./build.sh
```
NOTE: You can use the build.sh script to clean the logs and data folders as well as update the image if you customize the Dockerfile.

## You're ready to activate!
The container can be launched via 'docker compose' or 'docker run'.  
From the local clone directory, execute the 'docker compose' command:
```bash
docker compose up -d
```
If you'd prefer to follow the log while it executes:
```bash
docker compose up
```
(docker run CLI example coming soon)

The container self-terminates upon completion and success/failure can easily be parsed from the container logs.

[docs]: https://device-management-toolkit.github.io/docs



_NOTE: This is a privately developed asset and there is no assumption of liability, implied or explicit, with the use of this as a whole or with the use of any of the components.  Neither author, nor any 3rd party assumes any liability for it's use, distribution, etc._
