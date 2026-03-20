# SSH Low-Latency Guide (Ubuntu Server / Headless)

## Client Side (~/.ssh/config)

```
Host <name>
    HostName <ip>
    User <user>
    GSSAPIAuthentication no
    ForwardX11 no
    Compression no
    ServerAliveInterval 30
    ServerAliveCountMax 3
    IPQoS lowdelay throughput
    AddKeysToAgent yes
```

## Server Side

```bash
# 1. Disable reverse DNS and GSSAPI in sshd
sudo sed -i 's/#UseDNS no/UseDNS no/' /etc/ssh/sshd_config
sudo sed -i 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 2. Disable WiFi power management (if on WiFi)
sudo iwconfig $(iw dev | awk '$1=="Interface"{print $2}') power off
echo -e '[connection]\nwifi.powersave=2' | sudo tee /etc/NetworkManager/conf.d/no-powersave.conf
sudo systemctl restart NetworkManager

# 3. Disable suspend/sleep
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## Verify

```bash
# Latency (should be <10ms on LAN)
ping -c 5 <ip>

# WiFi power management (should say "off")
iwconfig <interface> | grep Power

# Suspend (should say "masked")
systemctl is-enabled suspend.target

# SSH debug (find slow steps)
ssh -v <host> "echo ok"
```

## What each fix does

| Fix | Why |
|---|---|
| `GSSAPIAuthentication no` | Skips Kerberos negotiation (biggest single lag fix) |
| `UseDNS no` | Stops sshd from doing reverse DNS on every connection |
| `ForwardX11 no` | Skips X11 forwarding handshake |
| `Compression no` | Avoids CPU overhead on LAN (only helps on slow WAN) |
| `ServerAliveInterval 30` | Prevents idle connection drops |
| `wifi.powersave=2` | Stops WiFi adapter from sleeping between packets |
| `systemctl mask sleep/suspend` | Prevents OS from sleeping when idle |
