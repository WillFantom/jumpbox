# Keys

To add users and keys, use the following format:

```json
{
  "USERNAME": [
    "SOME SSH KEY",
    "SOME OTHER SSH KEY"
  ],
  "ANOTHER-USERNAME": [
    "ANOTHER SSH KEY"
  ]
}
```

---

## Troubleshooting

1. As usernames will be directly mapped to generated Linux users, must be UNIX compliant usernames. This means that they should match the following regex: `^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$`

2. When using volume mapping for the `authorized_keys.json`, keys can be added and removed whilst the jumpbox is running. However, new users will not be updated until the container is restarted.

3. When using a baked in `authorized_keys.json` file, for obvious reasons the container image must be rebuilt, and the container restarted with the new image for changes to take effect.

