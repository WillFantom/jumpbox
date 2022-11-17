# SSH Jumpbox    ![GitHub release (latest SemVer)](https://img.shields.io/github/v/tag/willfantom/jumpbox?display_name=tag&label=%20&sort=semver)  ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/WillFantom/jumpbox/Release?label=%20&logo=github)

SSH Jumpbox is a hardened dockerized OpenSSH server that can be used as a bastion SSH server. 

## Usage

You can add users with associated keys via 2 methods, volume mounting or baking them directly into the docker image. Either way, an `authorized_keys.json` file is needed. The format of this file is like so:
```json
{
  "usera": [
    "ka1",
    "ka2"
  ],
  "userb": [
    "kb1",
    "kb2",
    "kb3"
  ]
}
```

1. To bake them into the docker image, edit the `keys/authorized_keys.json` file and rebuild the image, making sure to use the image that is built by this process.

   ```bash
   docker build --rm -f build/Dockerfile -t jumpbox:latest .
   ```

   ```bash
   docker run --rm -p 2222:2222 --name jumpbox \ 
    -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
    jumpbox:latest
   ```


2. To use volume mounting, mount the directory containing your keys file to `/etc/ssh/keys.d`.

   ```bash
   docker run --rm -p 2222:2222 --name jumpbox \
    -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
    -v "$(pwd)/keys":/etc/ssh/keys.d \
    ghcr.io/willfantom/jumpbox
   ```

### Configuration

To configure the SSH server, simply edit the [`sshd_config`](sshd/sshd_config) file with the desired settings and rebuild the container image.

To modify the port that the SSH server is internally listening on, you can set the environment variable `SSHD_PORT` when running the container. Although, it is expected that the port shall not change internally, and alternative ports are set via the docker port mappings.

### Endlessh

This jumpbox comes with [Endlessh](https://github.com/skeeto/endlessh) baked in, a simple SSH tarpit that can keep clients locked up pre auth. By default this listens internally on port 22, but can be set via the `ENDLESSH_PORT` environment variable. If you do not want Endlessh to run, set this variable to `0`.

To use Endlessh, make sure to map the port in your docker run (e.g. `-p 22:22`).

### Policy

To ensure the SSH server being deployed is hardened as desired, you can use [`ssh-audit`](https://github.com/jtesta/ssh-audit), a tool that can check if an SSH server meets a given configuration security policy. Included is a good starting policy for an SSH server using OpenSSH 9, ensuring the all and only the recommended key types (Host, Kex, Macs) are supported.

## Actions 🚀

The dockerized jumpbox here, along with [`watchtower`](https://containrrr.dev/watchtower/) can create an SSH server managed by GitHub Actions. Provided the SSH users and keys are [baked in](#usage), the Release workflow provided with this repository will:
 - Validate the `authorized_keys` JSON file
 - Ensure all provided users are valid usernames
 - Build the SSH server docker image, including building `endlessh`
 - Test the server against the given [`policy.txt`](#policy)
 - Provided all other steps are successful, push an x86 and ARM version to the GitHub container registry

For example, if a new key is added to the `authorized_keys.json` file, the image will be rebuilt and pushed in the actions workflow. Next, the `watchtower` instance on your server will notice the updated image on the next poll interval. Once the image is then pulled, it will replace your currently running server so your changes from GitHub are included. This process will be transparent provided the host keys directory is correctly mapped.

## Build

You can use the image pushed to the GitHub Container Registry, but if you want to build the image yourself: 

From the root of this repository run the following command:
```bash
docker build --rm -f build/Dockerfile -t jumpbox:latest .
```
