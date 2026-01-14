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
