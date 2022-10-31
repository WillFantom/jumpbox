# SSH Jumpbox

## Usage

```bash
docker run --rm -p 2222:222 --name jumpbox \ 
 -v "$(pwd)":/etc/ssh/keys.d \
 ghcr.io/willfantom/jumpbox
```
