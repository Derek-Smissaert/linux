todo:
facetimehd
gpu / graphics
keyboard fn as ctrl


# Terminal
## aliases
copy the `.bashrc.d` folder from this repo to your home folder

the folder includes the file `ls-goto.bashrc` which provides a `goto` function, which `cd`'s into the last `ls`'ed directory
```
[derek@fedora ~]$ ls /
afs  bin  boot  dev  etc  home  image  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
[derek@fedora ~]$ goto
[derek@fedora /]$
```

theres an ```alias diff=icdiff``` for which you need to install icdiff:
```
python3 -m pip install icdiff
```

## tmux
copy `.tmux.conf` and `.tmux/toggle-terminal.sh` into your home directory
`ctrl-j` now opens a terminal at the bottom like vscode

# Electron
Electron just does not want to play nice with wayland, so here is a list of command line args I collected over the years
Some are wayland related, some gpu, some are for the trackpad, just search for each in google and check if you need it.
```
--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=TouchpadOverscrollHistoryNavigation --password-store=gnome-libsecret --enable-chrome-browser-cloud-management --use-gl=egl
```

## Best practice for command line args
I would recommend to copy a `.desktop` file from either `/usr/share/applications/` or `/usr/local/share/applications/` to `~/.local/share/applications/`.
And then add the command line args to the `Exec=` calls in the copied `.desktop` file.

I did find this annoying when calling vscode from the terminal, because then the args are not applied, but I made an alias that has the args applied.

# Browser
## Zen
get from copr repo

### Extensions
- Adblocker: uBlock Origin

### If you get problems with context menus (ex. right-click menu) not working / flickering / scaled weirdly
Go to `about:config`
Set `widget.wayland.fractional-scale.enabled` to `false`

This is a Firefox setting that enables support for Wayland's native fractional scaling protocol, allowing crisp, pixel-perfect scaling (e.g., 125%, 150%) on high-DPI displays, fixing blurriness seen with older scaling methods by leveraging `wp-fractional-scale-v1` for better performance and sharpness, though users might encounter UI glitches like flickering menus or cut-off elements depending on their DE and Firefox version, requiring careful testing.

# Wireless
## Bluetooth
### Connect to a device (eg. Airpods)
Below is a reliable, step-by-step pairing flow for **AirPods 4** on Fedora

#### 1) Put AirPods 4 into pairing mode

1. Put both AirPods in the case.
2. Close the lid for **15 seconds**, then open the lid.
3. **Double-tap the front of the case** until the **status light flashes white** (this is AirPods 4 pairing mode).
   * Keep the lid open and the case near the laptop while you pair.

If you need a full reset (only if pairing is stuck), Apple’s reset procedure for AirPods 4 is a sequence of front-case double taps until the light flashes amber then white.

#### 2) Pair and connect using `bluetoothctl`
1. Open `bluetoothctl`

2. Ensure the controller is available:
```
list
power on
```

3. Enable agent (safe even if already on):
```
agent on
default-agent
```

4. Start discovery:
```
scan on
```

5. Watch for a line like: `[NEW] Device XX:XX:XX:XX:XX:XX AirPods ...`

Then pair using the MAC address you see:
```
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

6. Stop scanning and exit:
```
scan off
quit
```

#### 3) Select AirPods as the audio output (PipeWire/WirePlumber on Fedora)

Use the GUI:

* **Settings → Sound → Output** and pick your AirPods.

Or CLI:

```bash
wpctl status
```

Find the AirPods sink and set it as default:

```bash
wpctl set-default <SINK_ID>
```

#### Common gotchas (specific to AirPods)

* If they don’t show up in the scan: repeat the **close lid 15s → open → double-tap front until white flashing** step.
* If connect fails but pairing succeeded: try:

```
disconnect XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
```

This “disconnect then connect” retry is a known practical fix for flaky headset connects on Fedora/BlueZ.

* If they keep connecting to your phone/tablet instead: disconnect/disable Bluetooth on the other device during the initial pairing attempt.

### Sometimes my bluetooth just doesn't load, maybe try this:
Found everywhere on the internet that disabling btusb autosuspend can help and that Broadcom/Apple internal USB Bluetooth controllers are frequently sensitive to USB power management. A common mitigation is disabling btusb autosuspend.
I don't know if it really works for me, but this modification is pretty harmless.

#### method 1
(this includes some gpu stuff, TODO: create gpu paragraph)
Add `btusb.enable_autosuspend=n` to `/etc/default/grub`
```
GRUB_CMDLINE_LINUX="rhgb quiet amdgpu.si_support=1 radeon.si_support=0 acpi_backlight=native btusb.enable_autosuspend=n"
```

#### method 2
Create a modprobe config:
```
echo 'options btusb enable_autosuspend=0' | sudo tee /etc/modprobe.d/btusb-no-autosuspend.conf
```

Then reload the module (do this only when you can temporarily lose Bluetooth):
```bash
sudo systemctl stop bluetooth
sudo modprobe -r btusb
sudo modprobe btusb
sudo systemctl start bluetooth
```

## Eduroam
You probably already have this installed
```
sudo dnf install -y NetworkManager-wifi wpa_supplicant python3
```

### Connect with eduroam installer
Using an official eduroam installer is strongly preferred over fully manual profiles because it sets correct server validation and reduces exposure to rogue hotspots.

Download your institution’s Linux installer from `cat.eduroam.org`, pick your institution, download the Linux installer (a `.py` script).

```
python3 ~/Downloads/eduroam-linux-*.py
```

### find the connection name geteduroam created (often "eduroam")
```
nmcli -g NAME connection show | grep -i eduroam
```

### assume it is named "eduroam" (adjust if yours differs)
Some AP/client combinations behave poorly with 802.11w PMF negotiation.
NetworkManager lets you set PMF to `default|disable|optional|required`
```
nmcli con mod "eduroam" 802-11-wireless-security.pmf disable
```

### Connect to eduroam
```
nmcli --ask con up "eduroam"
```


### If it still doesn't work
Try with these settings:
- Disable Wi-Fi power saving for eduroam:
  ```nmcli con mod "eduroam" 802-11-wireless.powersave 2```
  Value `2` = disable Wi-Fi power saving.
- Make eduroam use your permanent (hardware) MAC:
  ```nmcli con mod "eduroam" 802-11-wireless.cloned-mac-address permanent```
  NetworkManager supports values like `permanent`, `random`, `stable` for cloned MAC behavior
  `permanent` is what you want for eduroam troubleshooting.
