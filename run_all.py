import subprocess

output = subprocess.run("usrp_firmware/build/N210_FIRMWARE usrp_firmware/config.json", shell=True, capture_output=True, text=True)
print(output.stdout)

output = subprocess.run("home/usrp/Desktop/masters/.venv/bin/python /home/usrp/Desktop/masters/waveform_processing/ofdm/ingest_ofdm.py", shell=True, capture_output=True, text=True)
print(output.stdout)
