# SSH Jumpbox    ![GitHub release (latest SemVer)](https://img.shields.io/github/v/tag/willfantom/jumpbox?display_name=tag&label=%20&sort=semver)  ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/willfantom/jumpbox/release.yml?label=%20&logo=github)

SSH Jumpbox is a hardened dockerized OpenSSH server that can be used as a multi-user bastion SSH server. Whilst other great tools such as [`sshportal`](https://github.com/moul/sshportal) exist, they can be overcomplicated for many use cases, leading to a more complex security auditing process. This jumpbox is somewhat simple, and importantly uses a vanilla OpenSSH server rather than a custom-built server.

## Features

 - Vanilla OpenSSH server for regular security updates
 - Easy JSON based configuration
 - Automated host key generation (persistence once generated optional)
 - Hardened server configuration:
   - No TTY for connecting clients (jump box only)
   - Using recommended secure key algorithms
   - No login command forced
 - Docker images for x86 and ARM

Whilst the objective of this project was to keep things simple (a large motivator for the use of a vanilla OpenSSH server), included are some light added-value features:

- **Endlessh**: This jumpbox comes with [Endlessh](https://github.com/skeeto/endlessh) baked in, a simple SSH tarpit that can keep clients locked up pre auth. By default this listens internally on port 22, but can be set via the `ENDLESSH_PORT` environment variable. If you do not want Endlessh to run, set this variable to `0`.

- **Policy**: To ensure the SSH server being deployed is hardened as desired, you can use [`ssh-audit`](https://github.com/jtesta/ssh-audit), a tool that can check if an SSH server meets a given configuration security policy. Included is a good starting policy for an SSH server using OpenSSH 9, ensuring all and only the recommended key types (Host, Kex, Macs) are supported.

- **Fail2Ban**: Writes logs to a file via a syslog server, in turn allowing [Fail2Ban](https://www.fail2ban.org/wiki/index.php/Main_Page) to block malicious connections. As Fail2Ban is expected to exist outside the jumpbox container (either on the host system or in a different container), the jumpbox itself needs no extra permissions to support this. See the example [docker-compose](./example/docker-compose.yml) for a way to set this up.

- **Actions**: The dockerized jumpbox here, along with [`watchtower`](https://containrrr.dev/watchtower/) can create an SSH server managed by GitHub Actions. Provided the SSH users and keys are [baked in](#full-usage), the Release workflow provided with this repository will:
   - Validate the `authorized_keys` JSON file
   - Ensure all provided users are valid usernames
   - Build the SSH server docker image, including building `endlessh`
   - Test the server against the given [`policy.txt`](./policy/policy.txt)
   - Provided all other steps are successful, push an x86 and ARM version to the GitHub container registry

---

## Usage

Below are 3 different ways of running Jumpbox, along with multiple [configuration options](#configuration) that can be applied to all 3.

### Quick Start

This method gets you started a fast as possible with Jumpbox, using the SSH server configuration found [here](./sshd/sshd_config).

> Although you can get going with Jumpbox quickly if you already have Docker installed, Jumpbox can be more beneficial if you follow the [full usage](#full-usage).

1. Create an `authorized_keys.json` file and add your username -> keys mappings. For more on this see [here](example/keys/README.md).

2. Run the container, making sure the new `authorized_keys.json` is in the `"$(pwd)/keys"` directory (if copying the below command exactly).
   ```
   docker run --rm -p 2222:2222 --name jumpbox \
     -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
     -v "$(pwd)/keys":/etc/ssh/keys.d \
     ghcr.io/willfantom/jumpbox
   ```

> Mapping the host keys is **not** essential. However, it ensures that the server will use the same host keys each time it is started, saving users from having to frequently edit their known hosts file. If you would like new host keys on 

### Full Usage

This method is a more production friendly approach. This also allows you to modify the given or use a custom SSH server configuration.

> To really get the most out of Jumpbox, you can automate the full usage with GitHub Actions. See [automated usage](#automated-usage) for a guide on how.

1. Clone this repository or your fork to your Jumpbox server host.

2. Modify the already existing `authorized_keys.json` found in [`./keys`](./keys/) using the format as outlined [here](example/keys/README.md).

3. Build the Jumpbox container image by running the following command from the repository root.
   ```
   docker build --rm -f build/Dockerfile -t jumpbox:latest .
   ```

4. Run the Jumpbox container using the following command:
   ```
   docker run --rm -p 2222:2222 -p 22:22 --name jumpbox \
    -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
    -e SSHD_PORT=2222 -e ENDLESSH_PORT=22 \
    jumpbox:latest
   ```

5. Check the running server against your ssh server configuration policy using [`ssh-audit`](https://github.com/jtesta/ssh-audit):
   ```
   docker run -it --rm --name ssh-audit --network host \
     -v "$(pwd)/policy":/policy positronsecurity/ssh-audit \
     -P /policy/policy.txt \
     127.0.0.1:2222
   ```
   
6. To update users and keys etc... repeat steps 2-5

### Automated Usage

This is perhaps the best way to use Jumpbox, especially if it is for an organization!

1. Fork this repository to your (or your orgs) GitHub account.

2. Add your users and associated keys to the baked in [`authorized_keys.json`](./keys/authorized_keys.json) file. This can be done easily in the GitHub web editor/GitHub Codespaces.

3. Commit (and push/save) your changes to the main branch. Provided actions is enabled for your repository, the pipeline will now:
     - Check for common errors in the `authorized_keys` file
     - Check the server against the policy found in [`policy.txt`](./policy/policy.txt)
     - Build the Docker image and push it to GitHub container registry

4. Pull and run the docker image that was generated via your GitHub actions pipeline.

5. Setup some mechanism alongside your Jumpbox to pull and run more recent images as they are available. For this I suggest watchtower as it works behind NAT and doesn't require deploy keys. See the example [docker compose](./example/docker-compose.yml) file for more on this.

  > A caveat with Watchtower is that there may be some time delay between a new image being pushed, and the server pulling it due to the polling nature of watchtower. Use a low polling interval to reduce the impact of this.

6. To add/remove a user, add/remove keys, or modify the SSH server configuration etc... simply make the changes on the GitHub repository, and the Actions workflow + Watchtower should take care of the testing, rebuild, and deployment.

---

## Configuration

- **SSH Server**: Configure the SSH server by modifying the [`sshd_config`](sshd/sshd_config) file. Included is a sensible default for a Jumpbox host as of November 2022. To modify the internal port used for the SSH server, make sure to use the `SSHD_PORT` environment variable. Also, always ensure that the internal SSH server port is the same as the exposed port. Having a port mapping where the internal and external ports are different will break some features. See the example docker-compose file for more on how to do this easily.

- **Users & Keys**: Regardless of if you are using baked in keys or mounted, the format anc common issues are the same. See [here](./example/keys/README.md) for more.

- **Banner**: To change the banner used by the Jumpbox, add your desired banner to the [`banner`](./sshd/banner) file. Tip: `figlet` can be a super useful tool for creating terminal friendly banner text.

- **Policy**: You can modify the audit policy to your liking by updating the [`policy.txt`](./policy/policy.txt) file to your requirements.

- **Endlessh**: To disable endlessh, set the `ENDLESSH_PORT` environment variable to `0`. Otherwise, set it to your desired internal port (default: `22`).

- **Host Keys**: Host keys are auto generated as needed. However, as it is unnecessary to present clients with new host keys on each release of the container image (e.g. all that may have changed is a user's key removed) mounting the internal host keys directory (`/etc/ssh/hostkeys.d`) is always recommended. If you feel the host keys should be refreshed, simply delete them from the mounted directory and restart the Jumpbox container.

---

## Alternatives

This is just an SSH server and bash script here and there really. There are other options that can do a lot more (such as Access Control) if you're up for a little more maintenance: 

 - [sshportal](https://github.com/moul/sshportal)
 - [the bastion](https://github.com/ovh/the-bastion)
