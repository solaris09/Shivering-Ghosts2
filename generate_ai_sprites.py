#!/usr/bin/env python3
"""
Nano Banana (Gemini API) ile Kawaii Ghost Sprite Üretici
Doğrudan REST API kullanarak - kütüphane bağımlılığı yok
"""

import requests
import json
import base64
import os
from PIL import Image
from io import BytesIO

# User's API Key
API_KEY = "AIzaSyBks2DtQ1QI0H1Af3oHgTxeX6B0V3n_qbU"

# Gemini API Endpoint for image generation
# Using gemini-2.0-flash-exp which supports image generation
API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={API_KEY}"

ASSETS_DIR = "Shivering Ghosts/Assets.xcassets"

def create_imageset(name):
    """Create imageset directory and Contents.json"""
    imageset_dir = os.path.join(ASSETS_DIR, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    
    return os.path.join(imageset_dir, f"{name}.png")

def generate_image_with_gemini(prompt, output_name):
    """Generate image using Gemini API"""
    
    headers = {
        "Content-Type": "application/json"
    }
    
    # Request payload for image generation
    payload = {
        "contents": [{
            "parts": [{
                "text": prompt
            }]
        }],
        "generationConfig": {
            "responseModalities": ["TEXT", "IMAGE"]
        }
    }
    
    print(f"🎨 Generating {output_name}...")
    
    try:
        response = requests.post(API_URL, headers=headers, json=payload, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            
            # Check for image in response
            if "candidates" in result and len(result["candidates"]) > 0:
                parts = result["candidates"][0].get("content", {}).get("parts", [])
                
                for part in parts:
                    if "inlineData" in part:
                        # Found image data
                        image_data = part["inlineData"]["data"]
                        mime_type = part["inlineData"].get("mimeType", "image/png")
                        
                        # Decode base64 image
                        image_bytes = base64.b64decode(image_data)
                        image = Image.open(BytesIO(image_bytes))
                        
                        # Convert to RGBA if needed
                        if image.mode != "RGBA":
                            image = image.convert("RGBA")
                        
                        # Resize to game asset size (300x400)
                        image = image.resize((300, 400), Image.LANCZOS)
                        
                        # Save to assets
                        output_path = create_imageset(output_name)
                        image.save(output_path, "PNG")
                        print(f"✅ Saved: {output_path}")
                        return True
                
                # No image found, check for text response
                for part in parts:
                    if "text" in part:
                        print(f"📝 Text response: {part['text'][:200]}...")
                
                print(f"❌ No image data in response for {output_name}")
                return False
        else:
            error_msg = response.json().get("error", {}).get("message", response.text)
            print(f"❌ API Error ({response.status_code}): {error_msg}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"⏱️ Timeout for {output_name}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

# Helper to reposition clothing to fit the ghost
def reposition_clothing(img, clothing_type):
    """
    Repositions the clothing item to align with the ghost's body parts.
    Ghost is approx 300x400.
    """
    img = img.convert("RGBA")
    bbox = img.getbbox()
    if not bbox:
        return img
    
    content = img.crop(bbox)
    content_w, content_h = content.size
    
    CANVAS_W, CANVAS_H = 300, 400
    new_img = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    
    # Target positions and sizes ADJUSTED for separation
    if clothing_type == "hat":
        # Hat: Move to TOP edge to clear the eyes
        target_w = 120 # Smaller
        ratio = target_w / content_w
        target_h = int(content_h * ratio)
        content = content.resize((target_w, target_h), Image.LANCZOS)
        
        # Paste at top center (y=5)
        paste_x = (CANVAS_W - target_w) // 2
        paste_y = 5 
        new_img.paste(content, (paste_x, paste_y), content)
        
    elif clothing_type == "scarf":
        # Scarf: Move to middle/neck, ensure gap from hat
        target_w = 140 # Smaller
        ratio = target_w / content_w
        target_h = int(content_h * ratio)
        content = content.resize((target_w, target_h), Image.LANCZOS)
        
        paste_x = (CANVAS_W - target_w) // 2
        paste_y = 165 # Lowered neck position
        new_img.paste(content, (paste_x, paste_y), content)
        
    elif clothing_type == "sweater":
        # Sweater: Move to BOTTOM body, ensure gap from scarf
        target_w = 160
        ratio = target_w / content_w
        target_h = int(content_h * ratio)
        content = content.resize((target_w, target_h), Image.LANCZOS)
        
        paste_x = (CANVAS_W - target_w) // 2
        paste_y = 230 # Lowered to bottom body
        new_img.paste(content, (paste_x, paste_y), content)
        
    return new_img

# Helper to remove background (Smart detection)
def remove_background(img):
    """
    Detects the background color from the top-left pixel and removes it.
    """
    img = img.convert("RGBA")
    datas = img.getdata()
    
    # Get background color sample from top-left (usually corner is bg)
    bg_sample = datas[0] 
    bg_r, bg_g, bg_b = bg_sample[:3]
    
    new_data = []
    threshold = 50 # Increased tolerance just in case
    
    for item in datas:
        r, g, b = item[:3]
        if abs(r - bg_r) < threshold and abs(g - bg_g) < threshold and abs(b - bg_b) < threshold:
            new_data.append((255, 255, 255, 0)) 
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    return img

# Ghost prompts
ghosts = {
    "ghost_standard": (
        "Cute kawaii ghost character, simple blob/mochi shape, semi-transparent white body, "
        "small black dot eyes, wavy shivering mouth, cold expression, soft glow, "
        "2D vector game sprite, pastel colors, clean lines, centered. "
        "IMPORTANT: Isolated on SOLID BLACK background."
    ),
    "ghost_baby": (
        "Cute kawaii baby ghost character, simple blob shape, semi-transparent pastel blue body, "
        "big sparkly anime eyes, holding pacifier, shivering, soft glow, "
        "2D vector game sprite, pastel colors, clean lines. "
        "IMPORTANT: Isolated on SOLID BLACK background."
    ),
    "ghost_rare": (
        "Cute kawaii rare ghost character, simple blob shape, semi-transparent pastel lavender body, "
        "star eyes, golden sparkles, soft glow, "
        "2D vector game sprite, pastel colors, clean lines. "
        "IMPORTANT: Isolated on SOLID BLACK background."
    )
}

# Clothing prompts - Adapted to 'Sound Park style'
base_clothing_prompt = "Sound Park style, 2D vector game sprite, clean outlines, front view, centered, no character, no background, isolated on SOLID BLACK background."

clothing = {
    # HATS
    "kirmizi_sapka": f"Cute winter beanie hat accessory, simple rounded shape, soft knitted texture, pastel RED color, {base_clothing_prompt}",
    "mavi_sapka":    f"Cute winter beanie hat accessory, simple rounded shape, soft knitted texture, pastel BLUE color, {base_clothing_prompt}",
    "sari_sapka":    f"Cute winter beanie hat accessory, simple rounded shape, soft knitted texture, pastel YELLOW color, {base_clothing_prompt}",
    
    # SCARVES
    "kirmizi_atki":  f"Cute winter scarf accessory, simple rounded loop shape, soft knitted texture, pastel RED color, {base_clothing_prompt}",
    "mavi_atki":     f"Cute winter scarf accessory, simple rounded loop shape, soft knitted texture, pastel BLUE color, {base_clothing_prompt}",
    "yesil_atki":    f"Cute winter scarf accessory, simple rounded loop shape, soft knitted texture, pastel GREEN color, {base_clothing_prompt}",
    
    # SWEATERS
    "mor_kazak":     f"Cute winter sweater accessory, simple rounded shape, soft knitted texture, pastel PURPLE color, {base_clothing_prompt}",
    "turuncu_kazak": f"Cute winter sweater accessory, simple rounded shape, soft knitted texture, pastel ORANGE color, {base_clothing_prompt}",
    "pembe_kazak":   f"Cute winter sweater accessory, simple rounded shape, soft knitted texture, pastel PINK color, {base_clothing_prompt}"
}

def main():
    print("🍌 Nano Banana (Gemini API) Sprite Generator v3")
    print("==================================================")
    print("⚠️  Mode: Smart Positioning (Fit Fix) & Sound Park Style")
    
    success_count = 0
    total = len(ghosts) + len(clothing)
    
    # Generate ghosts
    print("\n👻 Generating Kawaii Ghosts...")
    for name, prompt in ghosts.items():
        if generate_image_with_gemini(prompt, name):
            try:
                path = os.path.join(ASSETS_DIR, f"{name}.imageset", f"{name}.png")
                if os.path.exists(path):
                    img = Image.open(path)
                    img = remove_background(img)
                    img.save(path, "PNG")
                    print(f"   ✂️  Background removed for {name}")
                    success_count += 1
            except Exception as e:
                print(f"   ⚠️ Processing error: {e}")
    
    # Generate clothing with REPOSITIONING
    print("\n👕 Generating Clothing Items (Smart Fit)...")
    for name, prompt in clothing.items():
        if generate_image_with_gemini(prompt, name):
            try:
                path = os.path.join(ASSETS_DIR, f"{name}.imageset", f"{name}.png")
                if os.path.exists(path):
                    img = Image.open(path)
                    img = remove_background(img)
                    
                    # Determine type for positioning
                    ctype = "sweater"
                    if "sapka" in name: ctype = "hat"
                    elif "atki" in name: ctype = "scarf"
                    
                    img = reposition_clothing(img, ctype)
                    
                    img.save(path, "PNG")
                    print(f"   🎯 Repositioned & Fit: {name}")
                    success_count += 1
            except Exception as e:
                print(f"   ⚠️ Processing error: {e}")
    
    print("\n" + "=" * 50)
    print(f"✨ Complete! {success_count}/{total} assets generated and processed.")

if __name__ == "__main__":
    main()
