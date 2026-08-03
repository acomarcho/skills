---
name: manage-t3code
description: Run, expose, pair, inspect, and troubleshoot T3 Code servers on Linux. Use when the user asks to start, stop, restart, update, or debug T3 Code; run it in tmux; clean up duplicate, systemd, SSH-launched, or stale-version servers; expose it through Tailscale HTTPS; pair a browser, phone, or tablet; locate T3 threads or worktrees; or diagnose remote connections that keep disconnecting.
---

# Manage T3 Code

Operate one T3 Code server at a time. Preserve its data, pin the requested version, and prove the browser-facing endpoint works before reporting success.

## Safety Rules

- Treat `~/.t3` as user data. Do not delete or replace it while cleaning up servers.
- Preserve `~/.t3/userdata`, especially `state.sqlite`, attachments, secrets, and settings.
- Preserve `~/.t3/worktrees` and the user's original repositories.
- Resolve exact process IDs and launchers before stopping anything. Do not use broad commands such as `pkill -f t3`.
- Stop with `SIGTERM`, wait, then verify. Use stronger signals only when a confirmed T3 process refuses to stop.
- Remove only T3-owned Tailscale Serve routes. Do not run `tailscale serve reset`, because the machine may expose unrelated services.
- Treat pairing credentials and URLs as passwords. Do not put them in persistent logs or repository files.
- Ask before changing the user's Tailscale exit node, login, routes, DNS, or unrelated Serve configuration.

## Find the Current State

Inspect before making changes:

```bash
ps -eo user,pid,ppid,lstart,cmd --sort=start_time |
  rg 'node_modules/(\.bin/t3|t3/dist/bin\.mjs) serve'

systemctl --user list-unit-files --no-pager | rg '^t3code\.service' || true
systemctl --user status t3code.service --no-pager -l 2>&1 || true
tmux list-sessions 2>&1 || true
ss -lntp | rg ':3773|:3774' || true
tailscale status
tailscale serve status
```

For each server, inspect its parent, process tree, cgroup, command, base directory, host, port, and package version:

```bash
ps -fp <pid>,<parent-pid>
pstree -aps <pid>
cat /proc/<pid>/cgroup
readlink /proc/<pid>/cwd
jq -r '.name + "@" + .version' <package-path>/package.json
```

Look for startup paths:

- `~/.config/systemd/user/t3code.service`
- `~/.t3/ssh-launch/*/run-t3.sh`
- cron, desktop autostart, tmux, containers, and login scripts
- desktop-managed SSH sessions that run `npx t3@<version> serve`

Do not assume Tailscale disconnected because the browser lost T3. Check the daemon separately:

```bash
tailscale status --json | jq '{BackendState,Online:.Self.Online,Health}'
systemctl status tailscaled --no-pager -l
journalctl -u tailscaled --since '2 hours ago' --no-pager
tailscale netcheck
```

If Tailscale is `Running`, the device is online, and `Health` is empty, debug the T3 processes and proxy first.

## Choose One Server Owner

Keep exactly one owner for the server:

1. Reuse a healthy desktop-managed SSH server when the desktop client is actively launching it.
2. Otherwise use tmux for a manual server that should survive terminal disconnects but not reboot.
3. Use the T3 systemd service only when the user explicitly wants boot-time auto-start.

Do not start tmux beside an active SSH-managed or systemd server that uses the same base directory. Multiple servers can bind the same port on different interfaces while writing to the same SQLite state, so checking only the port is not enough.

An SSH desktop client may relaunch its managed server immediately after it is killed. Do not fight that loop. Either reuse that server and point Tailscale Serve at it, or have the user remove or disconnect that remote environment before switching to tmux.

## Pin and Verify the Version

Use the version requested by the user or required by the client. Never use an unpinned `t3@latest` when exact version matching matters.

Prefer an installed runtime:

```bash
T3_VERSION='0.0.30'
T3_BASE_DIR="${HOME}/.t3"
T3_NODE="$(command -v node)"
T3_ENTRY="${T3_BASE_DIR}/runtime/versions/${T3_VERSION}/node_modules/t3/dist/bin.mjs"

"${T3_NODE}" "${T3_ENTRY}" --version
```

Fall back to `npx --yes "t3@${T3_VERSION}" --version` when that runtime is absent. Confirm the actual server version later through its HTTP endpoint; a CLI version check alone does not prove which process is serving traffic.

To update a manual or SSH-managed server, stop that exact process and relaunch it with the required version. For a user-approved systemd setup, run the matching version's `service update`. Updating restarts the server but should not remove threads, settings, or project files.

## Remove Duplicate or Background Servers

For an installed T3 systemd service, use the matching T3 CLI:

```bash
"${T3_NODE}" "${T3_ENTRY}" service uninstall --base-dir "${T3_BASE_DIR}"
```

Then verify that the unit file is gone:

```bash
systemctl --user status t3code.service --no-pager 2>&1 || true
test ! -e "${HOME}/.config/systemd/user/t3code.service"
```

For confirmed stale processes, send `SIGTERM` to the exact server PID, wait for its children to exit, and check whether a launcher brings it back. Remove a stale T3-specific Serve route by port:

```bash
tailscale serve --https=<old-port> off
```

Leave every unrelated Serve route unchanged.

## Run Manually in tmux

Use the Tailnet IPv4 address for direct private access:

```bash
T3_HOST="$(tailscale ip -4)"
T3_PORT='3773'
T3_SESSION="t3code-${T3_VERSION//./_}"

tmux new-session -d -s "${T3_SESSION}" -c "${HOME}" \
  "${T3_NODE} ${T3_ENTRY} serve --host ${T3_HOST} --port ${T3_PORT} --base-dir ${T3_BASE_DIR}"
```

Inspect or stop it with:

```bash
tmux attach -t "${T3_SESSION}"
tmux kill-session -t "${T3_SESSION}"
```

A tmux server does not survive reboot. Restart it after reboot, or install the systemd service only if the user changes their mind about auto-start.

## Expose HTTPS Through Tailscale

The hosted web app cannot connect from HTTPS to a plain HTTP backend because browsers block mixed content. Add a Tailnet-only HTTPS endpoint:

```bash
T3_MAGICDNS="$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')"
T3_TARGET="http://${T3_HOST}:${T3_PORT}"

tailscale serve --bg --https=443 "${T3_TARGET}"
tailscale serve status
```

For an SSH-managed server bound to loopback, use its real port instead:

```bash
T3_TARGET='http://127.0.0.1:3773'
tailscale serve --bg --https=443 "${T3_TARGET}"
```

Test the public path and read the served version:

```bash
curl --silent --show-error --fail --max-time 10 \
  "https://${T3_MAGICDNS}/.well-known/t3/environment" |
  jq '{environmentId,label,serverVersion,capabilities}'
```

Do not report success until `serverVersion` matches the requested version.

## Pair a Browser, Phone, or Tablet

Create a separate one-time token for each device:

```bash
T3_PUBLIC_URL="https://${T3_MAGICDNS}"

"${T3_NODE}" "${T3_ENTRY}" auth pairing create \
  --base-dir "${T3_BASE_DIR}" \
  --ttl 1h \
  --label '<device-label>' \
  --base-url "${T3_PUBLIC_URL}" \
  --json
```

Give the user the returned direct `pairUrl`. The device must be connected to the same Tailnet.

Prefer the direct backend URL:

```text
https://<machine>.<tailnet>.ts.net/pair#token=<one-time-token>
```

The hosted form can redirect to `https://app.t3.codes/` without consuming the token on some browsers:

```text
https://app.t3.codes/pair?host=https://<machine>.<tailnet>.ts.net#token=<token>
```

If that happens, check whether the token remains active:

```bash
"${T3_NODE}" "${T3_ENTRY}" auth pairing list \
  --base-dir "${T3_BASE_DIR}" \
  --json
```

If it is still listed, pairing did not happen. Reuse the still-valid token with the direct backend URL or create a fresh one if expired. Do not revoke existing browser sessions unless the user asks.

## Verify Stability

Check the HTTPS endpoint and Tailscale state several times:

```bash
for T3_CHECK in $(seq 1 5); do
  curl --silent --show-error --fail --max-time 5 \
    "https://${T3_MAGICDNS}/.well-known/t3/environment" |
    jq -r '.serverVersion'
  tailscale status --json |
    jq -r '.BackendState + ":" + (.Self.Online | tostring)'
  sleep 2
done
```

Finally verify:

- Exactly one `t3 serve` process owns the chosen base directory.
- No unwanted `t3code.service` remains.
- Tailscale Serve points at the live server interface and port.
- The HTTPS endpoint reports the requested version.
- Saved threads and worktrees remain present.

## Data Locations

Use these paths when the user asks where T3 stores data:

```text
~/.t3/userdata/state.sqlite       chat threads and app state
~/.t3/userdata/attachments        chat attachments
~/.t3/userdata/logs               server and provider logs
~/.t3/worktrees/<project>/t3code-* managed Git worktrees
~/.t3/runtime/versions/<version>  installed T3 runtimes
~/.t3/caches                      provider caches
~/.t3/ssh-launch                  desktop-managed SSH launcher state
```

Original repositories remain where the user cloned them. T3-managed Git worktrees live under `~/.t3/worktrees`.

## Common Failures

- **Two servers or version mismatch:** Stop stale processes and launch one server at the required version.
- **Server returns after being killed:** Trace its parent. An SSH desktop client or systemd may be relaunching it.
- **HTTPS proxy returns an error:** Compare `tailscale serve status` with `ss -lntp`; fix the target host or port.
- **Hosted pairing redirects without pairing:** Use the direct `/pair#token=...` URL and confirm whether the token was consumed.
- **Server disappeared after reboot:** tmux does not survive reboot. Relaunch it or use the explicit systemd option.
- **Cloud relay reports QUIC timeouts:** Check whether the machine uses a Tailscale exit node. Do not disable it without permission; direct Tailnet HTTPS can avoid the relay.
- **Tailscale logs ACL rejects or router port-mapping failures:** Do not assume they caused T3 failure. Prove the T3 endpoint, daemon health, and actual disconnections first.

Refer to T3 Code's remote-access and background-service docs when CLI behavior differs by release:

- <https://github.com/pingdotgg/t3code/blob/main/docs/user/remote-access.md>
- <https://github.com/pingdotgg/t3code/blob/main/docs/user/background-service.md>
