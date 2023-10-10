# Auth Management

To have users be auth'd in the jumpbox, it expects an `auth.json` file to be
located at `/etc/ssh/keys.d/auth.json` in the container's filesystem.

> ⚠️ This file must exist during the startup of the jumpbox container as to
> automatically create all the users in the jumpbox.

The format of the `auth.json` is as below:

```json
{
  "settings": {
    "github_enable": true,
    "github_required_org": "my-org"
  },
  "users": [
    {
      "username": "usera",
      "github": "agithubusername",
      "keys": [
        "kb1",
        "kb2",
        "kb3"
      ]
    }
  ]
}
```

## Settings

This can be used to dictate what auth types can be used and apply global
constraints.

|         Value         |                                                                                                                             Description                                                                                                                              | Default  |
| :-------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :------: |
|    `github_enable`    |                                                                              Allow users to auth using their keys found on GitHub (provided the user also has a given GitHub username)                                                                               |  false   |
| `github_required_org` | Only allow GitHub auth if both the `github_enable` setting is true and the given GitHub username for a user is also publically associated with the named organization. If no org is set, then the user requires no membership to any org. **this is case sensitive** | **none** |


## Users

|   Value    |                                                                     Description                                                                     |
| :--------: | :-------------------------------------------------------------------------------------------------------------------------------------------------: |
| `username` |                                                  The username for the locally created system user                                                   |
|  `github`  | The GitHub username associated with the user. This forces their GitHub keys to be imported and usable for auth provided the settings allow for this |
|   `keys`   |                                           A list of SSH pub keys for the user that they can use for auth                                            |


## Troubleshooting

1. As usernames will be directly mapped to generated Linux users, must be UNIX compliant usernames. This means that they should match the following regex: `^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$`

2. When using volume mapping for the `auth.json`,settings, keys and github usernames can be added and removed whilst the jumpbox is running. However, new users will not be updated until the container is restarted.

3. When using a baked in `auth.json` file, for obvious reasons the container image must be rebuilt, and the container restarted with the new image for changes to take effect.

