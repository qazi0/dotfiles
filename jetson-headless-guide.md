# Jetson Orin Nano - Always-On Headless Setup

Everything needed to keep a Jetson (Ubuntu Desktop) permanently SSH-accessible without a monitor or keyboard.

## 1. Static IP via NetworkManager

```bash
sudo nmcli connection modify '<SSID>' \
  ipv4.method manual \
  ipv4.addresses <IP>/24 \
  ipv4.gateway <GATEWAY> \
  ipv4.dns "8.8.8.8,1.1.1.1" \
  connection.autoconnect yes \
  wifi.powersave 2

# Restart to apply
sudo nmcli connection down '<SSID>' && sudo nmcli connection up '<SSID>'
```

## 2. WiFi password at system level (not GNOME keyring)

Without this, WiFi won't connect until someone logs in at the GUI.

```bash
sudo nmcli connection modify '<SSID>' 802-11-wireless-security.psk-flags 0
```

## 3. Disable WiFi power management

WiFi power saving causes the adapter to sleep between packets, resulting in 1000ms+ latency spikes.

```bash
# Immediate
sudo iwconfig <interface> power off

# Permanent (survives reboot)
echo -e '[connection]\nwifi.powersave=2' | sudo tee /etc/NetworkManager/conf.d/no-powersave.conf
sudo systemctl restart NetworkManager
```

Find interface name: `ip link show | grep wl`

## 4. Disable GNOME auto-suspend (user session)

Ubuntu Desktop suspends after idle by default.

```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
```

## 5. Disable GDM auto-suspend (login screen)

GDM runs as a separate user with its own power settings. If no one is logged in, GDM's suspend policy takes over. This is the most commonly missed step.

```bash
sudo apt-get install -y dbus-x11
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
```

## 6. Mask suspend at systemd level

Belt-and-suspenders: block anything from triggering sleep.

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## 7. SSH server config

```bash
sudo sed -i 's/#UseDNS no/UseDNS no/' /etc/ssh/sshd_config
sudo sed -i 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## 8. SSH client config (on your machine)

```
Host jetson
    HostName <IP>
    User <user>
    GSSAPIAuthentication no
    ForwardX11 no
    Compression no
    ServerAliveInterval 30
    ServerAliveCountMax 3
    IPQoS lowdelay throughput
    AddKeysToAgent yes
```

## 9. Optional - reduce resource usage

```bash
sudo systemctl disable --now gnome-remote-desktop.service
sudo systemctl disable --now snapd.service snapd.socket snapd.seeded.service
sudo systemctl mask tracker-miner-fs-3.service
```

## Note on Jetson power modes

None of the above affects Jetson hardware power management (nvpmodel, jetson_clocks, GPU/CPU governors). Those are separate from OS-level suspend. Verify with:

```bash
sudo nvpmodel -q          # Should show MAXN or desired mode
sudo jetson_clocks --show  # Shows CPU/GPU frequencies
```

## Verify everything

```bash
# Ping latency (<10ms on LAN WiFi)
ping -c 5 <IP>

# WiFi power management (should say "off")
iwconfig <interface> | grep Power

# Suspend masked
systemctl is-enabled suspend.target

# GDM suspend disabled
sudo -u gdm dbus-launch gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type

# User suspend disabled
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type

# WiFi password storage (should say "0 (none)")
nmcli -s connection show '<SSID>' | grep psk-flags
```
