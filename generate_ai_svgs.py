import google.generativeai as genai
import os
import time

# User provided API Key
API_KEY = "AIzaSyBks2DtQ1QI0H1Af3oHgTxeX6B0V3n_qbU"

# Configure the API
try:
    genai.configure(api_key=API_KEY)
except Exception as e:
    print(f"Configuration Error: {e}")
    exit(1)

# Initialize Model (Using Flash for speed and SVG gen capability)
model = genai.GenerativeModel('gemini-1.5-flash')

prompts = {
    "ghost_standard": (
        "Create a clean, minimal SVG code for a 'Cute Kawaii Ghost'. "
        "Shape: Simple blob/mochi shape. "
        "Color: Semi-transparent white (#FFFFFF with 0.8 opacity) and soft light blue stroke. "
        "Features: Small black dot eyes, pink cheeks, simple wavy mouth. "
        "Style: Flat vector art, ios game icon style. centered. 512x512 viewbox."
    ),
    "ghost_baby": (
        "Create a clean, minimal SVG code for a 'Cute Baby Kawaii Ghost'. "
        "Shape: Simple blob shape. "
        "Color: Pastel blue tint (#E1F5FE). "
        "Features: Big sparkle anime eyes, holding a dummy/pacifier. "
        "Style: Flat vector art, ios game icon style. centered. 512x512 viewbox."
    ),
    "ghost_rare": (
        "Create a clean, minimal SVG code for a 'Rare Premium Kawaii Ghost'. "
        "Shape: Simple blob shape. "
        "Color: Pastel lavender (#F3E5F5). "
        "Features: Star-shaped eyes, slight smirk, golden sparkles around. "
        "Style: Flat vector art, ios game icon style. centered. 512x512 viewbox."
    )
}

def extract_and_save_svg(name, content):
    # Find SVG block
    start_tag = "<svg"
    end_tag = "</svg>"
    
    start_idx = content.find(start_tag)
    end_idx = content.find(end_tag)
    
    if start_idx != -1 and end_idx != -1:
        svg_content = content[start_idx : end_idx + len(end_tag)]
        filename = f"{name}_ai.svg"
        with open(filename, "w") as f:
            f.write(svg_content)
        print(f"✅ Saved AI generated design to: {filename}")
    else:
        print(f"❌ Could not find valid SVG in response for {name}")
        # Debug: print(content[:200])

print("🍌 Connecting to Nano Banana (Gemini API)...")

for name, prompt in prompts.items():
    print(f"🎨 Generating {name}...")
    try:
        response = model.generate_content(prompt)
        if response.text:
            extract_and_save_svg(name, response.text)
        else:
            print(f"Empty response for {name}")
    except Exception as e:
        print(f"API Error for {name}: {e}")
    
    time.sleep(1) # Respect rate limits

print("Done! AI designs saved as .svg files.")
