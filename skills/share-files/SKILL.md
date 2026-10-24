---
name: share-files
description: Serve files or folders as a temporary HTTPS link over Tailscale so any device on the tailnet can download them, including a phone. Use when the user says "share this file", "give me a download link", "send this to my phone", "make this downloadable", "host this folder", or wants a URL instead of copying files to a specific machine.
---

# Share Files

Hand out a temporary HTTPS URL backed by your machine. The file stays where it is; the link just exposes it for a while.

Use this instead of `send-files` when the destination machine is not known or the user is on a phone. `send-files` copies to one machine over SSH; this one gives a link anyone on the tailnet can open in a browser.

## Run it

```bash
scripts/share.sh <path>... [--ttl 30m]
scripts/share.sh --list
scripts/share.sh --stop <token>
```

The script copies nothing. It serves a folder of symlinks under `~/share-work/<token>/`, so downloads are byte-identical to the original and edits to the original show up immediately.

The token is random, so the URL is unguessable but not private from other tailnet users. Say that plainly when the user asks whether the link is secret.

Report back the URL, the file names, and when it expires. Do not paste the whole script output.

## Behavior you can rely on

- Port defaults to 8450, override with `SHARE_PORT`. Avoid 443 and 8443, those are Funnel ranges and 443 is usually already in use.
- Expiry defaults to 30 minutes, override with `SHARE_TTL` or `--ttl`. A systemd user timer removes the route and the folder.
- Several shares can be active at once on the same port because each gets its own path.
- If `systemd-run` is unavailable, the script prints a warning and the share stays up until `--stop`.
- `--stop` is safe to run twice and safe when other shares are still active.
- Missing `tailscale` or a stopped daemon fails fast with a clear message.

## Constraints

- Requires Tailscale on both ends. The phone must have the app and be logged in.
- Do not expose anything private by accident. Share the specific file or folder the user named, not a parent directory.
- The link is plain HTTPS on the tailnet's MagicDNS name. It does not work off the tailnet, and it does not survive a reboot because the folder lives in `$HOME`.
- Never point it at a directory containing credentials or SSH keys.

## Cleanup

Shares are cleaned by their timer. If a share is abandoned, `scripts/share.sh --list` shows what is still up and `--stop <token>` removes it. Remove `~/share-work` entirely only after listing first.
