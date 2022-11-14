# SSH Jumpbox

SSH Jumpbox is a hardened dockerized OpenSSH server that can be used as a bastion SSH server. 

## Usage

It's simple to start this up, simply run:

```bash
docker run --rm -p 2222:2222 --name jumpbox \ 
 -v "$(pwd)":/etc/ssh/keys.d \
 ghcr.io/willfantom/jumpbox
```

To have users with mapped keys, you should create an `authorized_keys.json` file in the mounted directory. The format of the file is as follows:
```json
{
  "usera": [
    "ka1",
    "ka2",
  ],
  "userb": [
    "kb1",
    "kb2",
    "kb3"
  ]
}
```


## Build

You can use the image pushed to the GitHub Container Registry, but if you want to build the image yourself: 

From the root of this repository run the following command:
```bash
docker build --rm -f build/Dockerfile -t jumpbox:latest .
```
