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

# Colors (Pastel Kawaii Palette)
COLORS = {
    'red': (231, 76, 60),      # Alizarin
    'blue': (52, 152, 219),    # Peter River
    'green': (46, 204, 113),   # Emerald
    'purple': (155, 89, 182),  # Amethyst
    'orange': (243, 156, 18),  # Orange
    'yellow': (241, 196, 15),  # Sun Flower
    'pink': (255, 182, 193),   # Light Pink
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

# --- Helper Functions for Kawaii Style ---
def add_glow(img, color, radius=15):
    """Add a soft glow effect behind the image"""
    # Create a glow layer
    glow = img.copy()
    # Extract alpha
    alpha = glow.split()[-1]
    # Blur the alpha channel to create transparency mask for glow
    blurred_alpha = alpha.filter(ImageFilter.GaussianBlur(radius))
    
    # Create solid color image
    glow_color = Image.new("RGB", img.size, color)
    # Apply blurred alpha as mask to solid color
    glow_layer = Image.new("RGBA", img.size, (0,0,0,0))
    glow_layer.paste(glow_color, (0,0), mask=blurred_alpha)
    glow_layer.putalpha(blurred_alpha)
    
    # Composite: Glow -> Image
    ids = Image.new("RGBA", img.size, (0,0,0,0))
    ids.alpha_composite(glow_layer)
    ids.alpha_composite(img)
    return ids

def draw_kawaii_body(draw, color, outline, w=GHOST_W, h=GHOST_H):
    """Draws the cute simple blob shape"""
    # Shape: Round top, slightly wider bottom, wavy skirt
    # Using a series of curves for a "Mochi" blob look
    
    # Coordinates
    marg_x = 40
    marg_y = 50
    bot_y = 350
    
    # Main body path
    # Top arc
    draw.chord([marg_x, marg_y, w-marg_x, 250], start=180, end=0, fill=color, outline=outline, width=8)
    # Side lines (slightly curved outwards for cuteness)
    # Left
    draw.line([marg_x, 150, marg_x-10, bot_y-20], fill=outline, width=8)
    # Right
    draw.line([w-marg_x, 150, w-marg_x+10, bot_y-20], fill=outline, width=8)
    
    # Fill middle rect-ish area
    draw.rectangle([marg_x, 150, w-marg_x, bot_y-20], fill=color)
    # Fill sides gaps
    draw.polygon([(marg_x, 150), (marg_x-10, bot_y-20), (marg_x, bot_y-20)], fill=color)
    draw.polygon([(w-marg_x, 150), (w-marg_x+10, bot_y-20), (w-marg_x, bot_y-20)], fill=color)

    # Wavy Bottom
    wave_count = 5
    wave_w = (w - 2 * (marg_x-10)) / wave_count
    start_x = marg_x - 10
    
    points = []
    for i in range(wave_count):
        wx = start_x + i * wave_w
        # Quadratic curve points for wave
        # This is hard with polygon, so we draw circles or arcs for the "skirt" ends
        # Simplified: Draw rounded line
        draw.chord([wx, bot_y-30, wx+wave_w, bot_y+10], start=0, end=180, fill=color, outline=outline, width=8)
        # Cover the top stroke of the chord to blend
        draw.rectangle([wx+4, bot_y-30, wx+wave_w-4, bot_y-20], fill=color)

def draw_kawaii_face(draw, happy=True, shiver=True):
    """Draws cute dot eyes and mouth"""
    # Eyes: Small black dots, wide set
    eye_y = 160
    eye_radius = 8
    eye_spacing = 70
    center_x = GHOST_W // 2
    
    # Left Eye
    draw.ellipse([center_x - eye_spacing - eye_radius, eye_y - eye_radius, 
                  center_x - eye_spacing + eye_radius, eye_y + eye_radius], fill='black')
    # Right Eye
    draw.ellipse([center_x + eye_spacing - eye_radius, eye_y - eye_radius, 
                  center_x + eye_spacing + eye_radius, eye_y + eye_radius], fill='black')
    
    # Cheeks (Pastel Pink)
    blush_y = 175
    draw.ellipse([center_x - eye_spacing - 20, blush_y, center_x - eye_spacing, blush_y+10], fill=(255, 182, 193, 150))
    draw.ellipse([center_x + eye_spacing, blush_y, center_x + eye_spacing + 20, blush_y+10], fill=(255, 182, 193, 150))

    # Mouth
    mouth_y = 180
    if happy:
        # Tiny 'u' shape
        draw.arc([center_x - 10, mouth_y, center_x + 10, mouth_y + 15], start=0, end=180, fill='black', width=4)
    else:
        # Wavy shivering line (~ ~)
        # Draw manually
        mx, my = center_x, mouth_y + 10
        draw.line([mx-15, my, mx-5, my-5], fill='black', width=3)
        draw.line([mx-5, my-5, mx+5, my+5], fill='black', width=3)
        draw.line([mx+5, my+5, mx+15, my], fill='black', width=3)

# --- Updated Ghost Functions ---

def draw_ghost():
    """Draw Standard Kawaii Ghost"""
    base = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    
    # Pastel Colors
    body_color = (255, 255, 255, 230) # Milky White, semi-transparent
    outline_color = (100, 100, 120, 200) # Soft Grey-Blue Outline
    
    draw_kawaii_body(draw, body_color, outline_color)
    draw_kawaii_face(draw, happy=False, shiver=True)
    
    # Add Glow
    final = add_glow(base, (200, 230, 255), radius=20)
    return final

def draw_baby_ghost():
    """Draw Baby Kawaii Ghost"""
    base = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    
    # Pastel Blue Tint
    body_color = (225, 245, 254, 230) # Light Pastel Blue
    outline_color = (70, 130, 180, 200)
    
    draw_kawaii_body(draw, body_color, outline_color)
    
    # Big Sparkly Eyes
    eye_y = 165
    eye_r = 12
    spacing = 65
    cx = GHOST_W // 2
    
    # Eyes
    draw.ellipse([cx-spacing-eye_r, eye_y-eye_r, cx-spacing+eye_r, eye_y+eye_r], fill='black')
    draw.ellipse([cx+spacing-eye_r, eye_y-eye_r, cx+spacing+eye_r, eye_y+eye_r], fill='black')
    # Sparkles
    draw.ellipse([cx-spacing, eye_y-5, cx-spacing+5, eye_y], fill='white')
    draw.ellipse([cx+spacing, eye_y-5, cx+spacing+5, eye_y], fill='white')
    
    # Pacifier
    mouth_y = 190
    draw.ellipse([cx-15, mouth_y-10, cx+15, mouth_y+10], fill=(255, 175, 175, 255), outline=outline_color, width=2)
    draw.arc([cx-10, mouth_y, cx+10, mouth_y+15], start=0, end=180, fill=outline_color, width=2)

    final = add_glow(base, (173, 216, 230), radius=20)
    return final

def draw_rare_ghost():
    """Draw Rare (Premium) Kawaii Ghost"""
    base = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    
    # Pastel Purple/Gold Gradient feel (Solid for PIL)
    body_color = (250, 240, 255, 235) # Pastel Lavender
    outline_color = (147, 112, 219, 255) # Medium Purple
    
    draw_kawaii_body(draw, body_color, outline_color)
    
    # Star Eyes
    eye_y = 160
    s_size = 15
    spacing = 70
    cx = GHOST_W // 2
    
    def draw_star(x, y, s, c):
        angles = [i * 4 * math.pi / 10 for i in range(5)]
        pts = [(x + math.cos(a)*s, y + math.sin(a)*s) for a in angles]
        draw.polygon(pts, fill=c)
        
    draw_star(cx-spacing, eye_y, s_size, outline_color)
    draw_star(cx+spacing, eye_y, s_size, outline_color)
    
    # Smirk
    draw.arc([cx-5, 190, cx+25, 205], start=20, end=160, fill=outline_color, width=3)
    
    # Sparkles around
    for pos in [(80, 100), (220, 80), (250, 250)]:
        draw_star(pos[0], pos[1], 10, (255, 215, 0, 255))

    final = add_glow(base, (230, 230, 250), radius=25)
    return final

def draw_dead_ghost():
    """Draw Dead Ghost (Burnt Mochi)"""
    base = Image.new('RGBA', (GHOST_W, GHOST_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(base)
    
    body_color = (100, 100, 100, 240) # Grey
    outline_color = (50, 50, 50, 255)
    
    draw_kawaii_body(draw, body_color, outline_color)
    
    # X Eyes
    eye_y = 160
    spacing = 70
    cx = GHOST_W // 2
    s = 10
    
    def draw_x(x, y):
        draw.line([x-s, y-s, x+s, y+s], fill='black', width=4)
        draw.line([x+s, y-s, x-s, y+s], fill='black', width=4)
        
    draw_x(cx-spacing, eye_y)
    draw_x(cx+spacing, eye_y)
    
    # Frown
    draw.arc([cx-15, 190, cx+15, 210], start=180, end=0, fill='black', width=4)
    
    return base

def draw_dead_baby_ghost():
    """Dead Baby"""
    # Just reuse dead logic with pacifier
    img = draw_dead_ghost()
    draw = ImageDraw.Draw(img)
    cx = GHOST_W // 2
    draw.ellipse([cx-15, 200, cx+15, 220], fill=(80, 40, 40), outline='black', width=2)
    return img

def draw_dead_rare_ghost():
    """Dead Rare"""
    # Reuse dead logic
    img = draw_dead_ghost()
    # Add broken star eyes maybe? Kept simple X for now as it's clear
    return img

def draw_leaf():
    """Draw a simple autumn leaf"""
    # Size 64x64 is enough for particle
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Orange/Brown color
    color = (211, 84, 0, 255) # Pumpkin
    darker = (160, 64, 0, 255)
    
    # Shape: teardropish
    # x,y points
    points = [(32, 5), (55, 20), (45, 50), (32, 60), (19, 50), (9, 20)]
    draw.polygon(points, fill=color, outline=darker)
    
    # Veins
    draw.line([(32, 5), (32, 60)], fill=darker, width=2)
    draw.line([(32, 35), (50, 25)], fill=darker, width=1)
    draw.line([(32, 35), (14, 25)], fill=darker, width=1)
    draw.line([(32, 50), (40, 45)], fill=darker, width=1)
    draw.line([(32, 50), (24, 45)], fill=darker, width=1)
    
    return img

def draw_heart():
    """Draw a simple red heart"""
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Heart shape using bezier-ish
    # Or just two circles and a triangle
    color = (231, 76, 60, 255) # Red
    
    # Left circle
    draw.ellipse([5, 5, 35, 35], fill=color)
    # Right circle
    draw.ellipse([29, 5, 59, 35], fill=color)
    # Bottom triangle
    draw.polygon([(8, 25), (56, 25), (32, 60)], fill=color)
    
    return img

def draw_sweat():
    """Draw a blue ice teardrop/sweat"""
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    color = (135, 206, 250, 255) # Light Blue
    outline = (70, 130, 180, 255)
    
    points = [(32, 5), (50, 45), (32, 60), (14, 45)]
    draw.polygon(points, fill=color, outline=outline)
    return img

def draw_hot_chocolate():
    """Powerup: Mug of cocoa"""
    img = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Mug
    mug_color = (236, 240, 241, 255)
    draw.rounded_rectangle([30, 40, 98, 110], radius=10, fill=mug_color, outline=(189, 195, 199, 255), width=4)
    # Handle
    draw.arc([90, 50, 115, 90], start=270, end=90, fill=(189, 195, 199, 255), width=6)
    
    # Cocoa
    draw.ellipse([35, 42, 93, 58], fill=(139, 69, 19, 255))
    
    # Marshmallows
    draw.rectangle([50, 45, 60, 55], fill=(255, 255, 255, 255))
    draw.rectangle([70, 48, 80, 58], fill=(255, 255, 255, 255))
    
    # Steam
    draw.line([50, 30, 50, 10], fill=(200, 200, 200, 150), width=3)
    draw.line([78, 30, 78, 10], fill=(200, 200, 200, 150), width=3)
    
    return img

def draw_campfire():
    """Powerup: Campfire"""
    img = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Logs
    brown = (101, 67, 33, 255)
    draw.line([20, 100, 108, 100], fill=brown, width=12) # Horizontal
    draw.line([30, 110, 90, 80], fill=brown, width=10) # Cross
    draw.line([90, 110, 30, 80], fill=brown, width=10) # Cross
    
    # Fire
    # Outer Orange
    draw.ellipse([40, 40, 88, 100], fill=(255, 140, 0, 220))
    # Inner Yellow
    draw.ellipse([50, 60, 78, 95], fill=(255, 215, 0, 255))
    
    return img

def draw_magnet():
    """Powerup: Magnet"""
    img = Image.new('RGBA', (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # U shape
    red = (231, 76, 60, 255)
    gray = (149, 165, 166, 255)
    
    # Draw thick arc
    # Bounding box for outer circle
    bbox = [24, 24, 104, 104]
    draw.arc(bbox, start=180, end=0, fill=red, width=20)
    
    # Legs
    draw.line([24, 64, 24, 100], fill=red, width=20)
    draw.line([104, 64, 104, 100], fill=red, width=20)
    
    # Tips
    draw.rectangle([14, 100, 34, 115], fill=gray)
    draw.rectangle([94, 100, 114, 115], fill=gray)
    
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


def save_cropped_clothing(img, name):
    """Save cropped version of clothing for UI use"""
    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        
    # Scale up slightly to add padding if needed, or just save
    save_sprite(img, name)

def main():
    print("🎨 Generating Shivering Ghosts Assets...")
    
    # 1. Ghost
    ghost = draw_ghost()
    save_sprite(ghost, "ghost_standard")
    
    save_sprite(draw_baby_ghost(), "ghost_baby")
    save_sprite(draw_rare_ghost(), "ghost_rare")
    save_sprite(draw_dead_ghost(), "ghost_dead")
    save_sprite(draw_dead_baby_ghost(), "ghost_baby_dead")
    save_sprite(draw_dead_rare_ghost(), "ghost_rare_dead")
    
    # 2. Hats (3 colors: Red, Blue, Yellow)
    save_sprite(draw_beanie('red'), "kirmizi_sapka")
    save_sprite(draw_beanie('blue'), "mavi_sapka")
    save_sprite(draw_beanie('yellow'), "sari_sapka")
    
    # 3. Scarves (3 colors: Red, Blue, Green)
    save_sprite(draw_scarf('red'), "kirmizi_atki")
    save_sprite(draw_scarf('blue'), "mavi_atki")
    save_sprite(draw_scarf('green'), "yesil_atki")
    
    # 4. Sweaters (3 colors: Purple, Orange, Pink)
    save_sprite(draw_sweater('purple'), "mor_kazak")
    save_sprite(draw_sweater('orange'), "turuncu_kazak")
    save_sprite(draw_sweater('pink'), "pembe_kazak")
    
    # 5. Effects & Power-ups
    save_sprite(draw_leaf(), "leaf")
    save_sprite(draw_heart(), "heart")
    save_sprite(draw_sweat(), "icicle_sweat")
    
    save_sprite(draw_hot_chocolate(), "powerup_cocoa")
    save_sprite(draw_campfire(), "powerup_campfire")
    save_sprite(draw_magnet(), "powerup_magnet")
    
    print("✅ Done!")

if __name__ == "__main__":
    main()
