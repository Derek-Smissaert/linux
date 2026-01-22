## Bluetooth

If you want to reduce recurrence: disable btusb autosuspend

Broadcom/Apple internal USB Bluetooth controllers are frequently sensitive to USB power management. A common mitigation is disabling btusb autosuspend.

Create a modprobe config:
```
echo 'options btusb enable_autosuspend=0' | sudo tee /etc/modprobe.d/btusb-no-autosuspend.conf
```

Then reload the module (do this only when you can temporarily lose Bluetooth):
```
sudo systemctl stop bluetooth
sudo modprobe -r btusb
sudo modprobe btusb
sudo systemctl start bluetooth
```

## Eduroam
You probably already have this installed  
`sudo dnf install -y NetworkManager-wifi wpa_supplicant python3`

### Connect with eduroam installer
Using an official eduroam installer is strongly preferred over fully manual profiles because it sets correct server validation and reduces exposure to rogue hotspots.

Download your institution’s Linux installer from `cat.eduroam.org`, pick your institution, download the Linux installer (a `.py` script).

`python3 ~/Downloads/eduroam-linux-*.py`

### find the connection name geteduroam created (often "eduroam")
`nmcli -g NAME connection show | grep -i eduroam`

### assume it is named "eduroam" (adjust if yours differs)
Some AP/client combinations behave poorly with 802.11w PMF negotiation.  
NetworkManager lets you set PMF to `default|disable|optional|required`

`nmcli con mod "eduroam" 802-11-wireless-security.pmf disable`

### Connect to eduroam
`nmcli --ask con up "eduroam"`


### If it still doesn't work
Try with these settings:
- Disable Wi-Fi power saving for eduroam:  
  `nmcli con mod "eduroam" 802-11-wireless.powersave 2`  
  Value `2` = disable Wi-Fi power saving.
- Make eduroam use your permanent (hardware) MAC:  
  `nmcli con mod "eduroam" 802-11-wireless.cloned-mac-address permanent`  
  NetworkManager supports values like `permanent`, `random`, `stable` for cloned MAC behavior; `permanent` is what you want for eduroam troubleshooting.
