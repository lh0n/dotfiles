#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "requests",
# ]
# ///

import os
import sys
import subprocess
import hashlib
import shutil
import requests

# Configuration
DOWNLOAD_DIR = os.path.expanduser("~/Downloads")
DEST_DIR = "/usr/local"
GO_API_URL = "https://go.dev/dl/?mode=json"

def get_latest_go_info():
    response = requests.get(GO_API_URL)
    response.raise_for_status()
    releases = response.json()

    # Filter for Linux amd64
    files = releases[0]['files']
    match = next(f for f in files if f['os'] == 'linux' and f['arch'] == 'amd64' and f['kind'] == 'archive')
    return match['filename'], match['sha256']

def update_go():
    try:
        filename, expected_sum = get_latest_go_info()
        file_path = os.path.join(DOWNLOAD_DIR, filename)

        print(f"Downloading {filename}...")
        with requests.get(f"https://go.dev/dl/{filename}", stream=True) as r:
            with open(file_path, 'wb') as f:
                shutil.copyfileobj(r.raw, f)

        print("Verifying integrity...")
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                sha256.update(chunk)

        if sha256.hexdigest() != expected_sum:
            print("Checksum mismatch!", file=sys.stderr)
            sys.exit(1)

        print("Installing to /usr/local/go...")
        subprocess.run(["sudo", "rm", "-rf", os.path.join(DEST_DIR, "go")], check=True)
        subprocess.run(["sudo", "tar", "-C", DEST_DIR, "-xzf", file_path], check=True)

        # Cleanup
        os.remove(file_path)
        print("Update complete.")
    except Exception as e:
        print(f"Update failed: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    update_go()
