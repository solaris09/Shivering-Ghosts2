#!/usr/bin/env python3
"""
Shivering Ghosts - Custom Asset Generator
Generates perfectly fitting vector-style assets using Python PIL.
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import json
import math

# Output directory
ASSETS_DIR = "Shivering Ghosts/Assets.xcassets"
ASSETS_CLOTHING_DIR = os.path.join(ASSETS_DIR, "kiyafet")

# Ensure directories exist
os.makedirs(ASSETS_DIR, exist_ok=True)
os.makedirs(ASSETS_CLOTHING_DIR, exist_ok=True)

# Colors
COLORS = {
    'red': (231, 76, 60),      # Alizarin
    'blue': (52, 152, 219),    # Peter River
    'green': (46, 204, 113),   # Emerald
    'purple': (155, 89, 182),  # Amethyst
    'orange': (243, 156, 18),  # Orange
    'yellow': (241, 196, 15),  # Sun Flower
    'white': (236, 240, 241),  # Clouds
    'black': (44, 62, 80)      # Midnight Blue
}

def create_imageset(name, directory=ASSETS_DIR):
    """Create .imageset folder structure"""
    folder = os.path.join(directory, f"{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    
    contents = {
        "images": [
            {"filename": f"{name}.png", "idiom": "universal", "scale": "1x"},
            {"filename": f"{name}@2x.png", "idiom": "universal", "scale": "2x"},
            {"filename": f"{name}@3x.png", "idiom": "universal", "scale": "3x"}
        ],
        "info": {"author": "xcode", "version": 1}
    }
    
    with open(os.path.join(folder, "Contents.json"), 'w') as f:
        json.dump(contents, f, indent=2)
    
    return folder

def save_sprite(img, name, directory=ASSETS_DIR):
    """Save sprite at 1x, 2x, 3x scales"""
    # Create standard imageset structure
    folder = create_imageset(name, directory)
    
    # Save 3x (Original High Res)
    img.save(os.path.join(folder, f"{name}@3x.png"))
    
    # Save 2x
    size_2x = (int(img.width * 0.66), int(img.height * 0.66))
    img.resize(size_2x, Image.Resampling.LANCZOS).save(os.path.join(folder, f"{name}@2x.png"))
    
    # Save 1x
    size_1x = (int(img.width * 0.33), int(img.height * 0.33))
    img.resize(size_1x, Image.Resampling.LANCZOS).save(os.path.join(folder, f"{name}.png"))
    print(f"  Generated: {name}")

# --- Drawing Constants for FIT ---
GHOST_W, GHOST_H = 300, 400
HEAD_W = GHOST_W * 0.8  # 240
HEAD_H = GHOST_H * 0.4  # 160
BODY_W = GHOST_W * 0.9  # 270

def draw_ghost():
    """Draw the base naked ghost"""
    img = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Body color
    white = (245, 245, 255, 255)
    shadow = (220, 220, 240, 255)
    outline = (40, 40, 60, 255)
    
    # Main Body Shape (Pear/Blob)
    # Top Circle
    draw.ellipse([30, 20, 270, 260], fill=white, outline=outline, width=8)
    # Bottom Rect
    draw.rectangle([30, 140, 270, 320], fill=white)
    # Draw side lines to connect
    draw.line([30, 140, 30, 320], fill=outline, width=8)
    draw.line([270, 140, 270, 320], fill=outline, width=8)
    
    # Wavy Bottom
    wave_y = 320
    wave_h = 40
    points = [(30, wave_y)]
    for i in range(1, 7):
        x = 30 + (240 * i / 6)
        y = wave_y + (wave_h if i % 2 != 0 else 0)
        points.append((x, y))
    
    # Close shape for fill
    fill_points = [(30, 140), (270, 140)] + points[::-1] + [(30, wave_y)]
    draw.polygon(fill_points, fill=white)
    # Draw bottom outline
    for i in range(len(points)-1):
        draw.line([points[i], points[i+1]], fill=outline, width=8)

    # Face using simple shapes
    # Eyes
    eye_y = 130
    draw.ellipse([90, eye_y, 115, eye_y+35], fill=(30, 30, 40, 255)) # Left
    draw.ellipse([185, eye_y, 210, eye_y+35], fill=(30, 30, 40, 255)) # Right
    # Blush
    draw.ellipse([70, 150, 90, 170], fill=(255, 200, 200, 100))
    draw.ellipse([210, 150, 230, 170], fill=(255, 200, 200, 100))
    
    # Mouth (Shivering)
    mouth_y = 165
    draw.arc([130, mouth_y, 170, mouth_y+20], start=0, end=180, fill=outline, width=5)
    
    # Arms (Nubs)
    draw.arc([10, 180, 50, 230], start=90, end=270, fill=white, width=10) # Left nub fake
    # Actually just simple side bumps
    draw.ellipse([10, 180, 50, 220], fill=white, outline=outline, width=6)
    draw.ellipse([250, 180, 290, 220], fill=white, outline=outline, width=6)
    
    return img

def draw_beanie(color_name):
    """Draw a beanie that fits the ghost head"""
    img = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = COLORS[color_name]
    darker = tuple(max(0, c-40) for c in color)
    
    # Beanie Position: Top of head (y=20 to y=100)
    # Width matches head width ~240
    
    # Dome
    rect = [40, 10, 260, 150]
    draw.chord(rect, start=180, end=0, fill=(*color, 255), outline=(*darker, 255), width=6)
    
    # Cuff
    draw.rounded_rectangle([35, 80, 265, 120], radius=10, fill=(*color, 255), outline=(*darker, 255), width=6)
    
    # Striping on cuff
    for x in range(50, 250, 20):
        draw.line([x, 80, x, 120], fill=(*darker, 100), width=2)
        
    # Pom-pom
    draw.ellipse([125, -5, 175, 45], fill=(*color, 255), outline=(*darker, 255), width=4)
                 
    return img

def draw_witch_hat():
    """Draw a witch hat for purple (special case)"""
    img = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = COLORS['purple']
    band_color = COLORS['orange']
    darker = tuple(max(0, c-40) for c in color)
    
    # Cone
    points = [(150, 10), (220, 100), (80, 100)]
    draw.polygon(points, fill=(*color, 255), outline=(*darker, 255))
    draw.line([(150, 10), (220, 100)], fill=(*darker, 255), width=6)
    draw.line([(150, 10), (80, 100)], fill=(*darker, 255), width=6)
    
    # Brim
    draw.ellipse([20, 90, 280, 140], fill=(*color, 255), outline=(*darker, 255), width=6)
    
    # Band
    draw.rectangle([95, 90, 205, 105], fill=(*band_color, 255))
    
    return img

def draw_scarf(color_name):
    """Draw a scarf around the neck"""
    img = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = COLORS[color_name]
    darker = tuple(max(0, c-40) for c in color)
    
    # Neck Position: y ~180-220
    
    # Main wrap
    draw.rounded_rectangle([45, 180, 255, 230], radius=15, fill=(*color, 255), outline=(*darker, 255), width=6)
    
    # Stripes
    for x in range(60, 240, 25):
        draw.line([x, 180, x, 230], fill=(*darker, 100), width=3)
        
    # Hanging tail (Left side)
    points = [(60, 220), (100, 220), (100, 300), (60, 300)]
    draw.polygon(points, fill=(*color, 255), outline=(*darker, 255))
    # Outline manually to match style
    draw.line([(60, 220), (60, 300), (100, 300), (100, 220)], fill=(*darker, 255), width=6)

    # Fringe
    for x in range(65, 100, 10):
        draw.line([x, 300, x, 315], fill=(*color, 255), width=4)
        
    return img

def draw_sweater(color_name):
    """Draw a sweater for the body"""
    img = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = COLORS[color_name]
    darker = tuple(max(0, c-40) for c in color)
    rib_color = tuple(max(0, c-20) for c in color)
    
    # Body Position: y ~230 down to 320
    
    # Main Body Block
    # Slightly wider at bottom
    body_points = [(50, 230), (250, 230), (260, 310), (40, 310)]
    draw.polygon(body_points, fill=(*color, 255))
    draw.line(body_points + [body_points[0]], fill=(*darker, 255), width=6)
    
    # Collar
    draw.ellipse([80, 220, 220, 250], fill=(*rib_color, 255), outline=(*darker, 255), width=5)
    
    # Bottom Ribbing
    draw.rectangle([42, 300, 258, 320], fill=(*rib_color, 255), outline=(*darker, 255), width=5)
    
    # Texture (Knitting V's)
    for y in range(250, 300, 20):
        for x in range(70, 230, 20):
            draw.line([x, y, x+5, y+5], fill=(*darker, 100), width=2)
            draw.line([x+5, y+5, x+10, y], fill=(*darker, 100), width=2)
            
    return img

def main():
    print("🎨 Generating Shivering Ghosts Assets...")
    
    # 1. Ghost
    ghost = draw_ghost()
    save_sprite(ghost, "ghost_standard")
    
    # 2. Hats
    save_sprite(draw_beanie('red'), "kirmizi_sapka")
    save_sprite(draw_beanie('blue'), "mavi_sapka")
    save_sprite(draw_witch_hat(), "cadi_sapkasi") # Purple/Witch
    
    # 3. Scarves
    save_sprite(draw_scarf('red'), "kirmizi_atki")
    save_sprite(draw_scarf('blue'), "mavi_atki")
    save_sprite(draw_scarf('green'), "yesil_atki")
    
    # 4. Sweaters
    save_sprite(draw_sweater('purple'), "mor_kazak")
    save_sprite(draw_sweater('orange'), "turuncu_kazak")
    save_sprite(draw_sweater('green'), "yesil_kazak")
    
    print("✅ Done!")

if __name__ == "__main__":
    main()
