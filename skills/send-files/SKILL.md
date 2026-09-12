---
name: send-files
description: Send files or folders to a remote machine over SSH with scp. Use when the user says "send this over", "scp this to some host", "transfer this file", "copy this to my server/laptop", or asks to push files to another machine. Defaults to ~/Downloads on the remote.
---

# Send Files

Copy files to a remote machine with `scp`. The user supplies the target; never assume a hostname, user, or IP.

```bash
scp -r <path>... <user@host>:~/Downloads/
```

- Default destination is `~/Downloads` on the remote.
- If the user gives another destination, use it.
- If the remote user is unclear, use the current username and ask if auth fails.
- Quote paths with spaces.
- Verify with `ssh <user@host> 'ls -la <dest>/<name>'` and report the remote path.
- If connection or auth fails, check `~/.ssh/config` for a matching alias and tell the user what's missing.
