import os
import subprocess

def convert_mp3_to_m4a():
    root_dir = "Shivering Ghosts"
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".mp3"):
                mp3_path = os.path.join(root, file)
                m4a_path = os.path.splitext(mp3_path)[0] + ".m4a"
                
                print(f"Converting {mp3_path} -> {m4a_path}")
                
                # Convert using afconvert (macOS built-in)
                # m4af = MPEG-4 Audio File, aac = Advanced Audio Coding, 64000 = 64kbps
                cmd = [
                    "afconvert",
                    "-f", "m4af",
                    "-d", "aac", 
                    "-b", "48000", # 48kbps is sufficient for casual SFX, 64kbps for music
                    mp3_path,
                    m4a_path
                ]
                
                # Use slightly higher bitrate for music if filename suggests it
                if "music" in file.lower():
                    cmd[6] = "64000"
                
                result = subprocess.run(cmd, capture_output=True, text=True)
                
                if result.returncode == 0:
                    print(f"✅ Success. Removed original.")
                    os.remove(mp3_path)
                else:
                    print(f"❌ Failed: {result.stderr}")

if __name__ == "__main__":
    convert_mp3_to_m4a()
