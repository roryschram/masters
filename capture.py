import subprocess

output = subprocess.run("make -C usrp_firmware_multi_capture/build/", shell=True, capture_output=True, text=True)
print(output.stdout)

output = subprocess.run("sudo usrp_firmware/build/N210_FIRMWARE usrp_firmware/config.json", shell=True, capture_output=True, text=True)

