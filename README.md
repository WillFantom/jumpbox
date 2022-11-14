# SSH Jumpbox

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
   docker run --rm -p 2222:2222 --name jumpbox \ 
    -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
    -v "$(pwd)/keys":/etc/ssh/keys.d \
    ghcr.io/willfantom/jumpbox
  ```


2. To use volume mounting, mount the directory containing your keys file to `/etc/ssh/keys.d`.

```bash
docker run --rm -p 2222:2222 --name jumpbox \
 -v "$(pwd)/hostkeys":/etc/ssh/hostkeys.d \
 -v "$(pwd)/keys":/etc/ssh/keys.d \
 ghcr.io/willfantom/jumpbox
```


## Build

You can use the image pushed to the GitHub Container Registry, but if you want to build the image yourself: 

From the root of this repository run the following command:
```bash
docker build --rm -f build/Dockerfile -t jumpbox:latest .
```
