#!/usr/bin/env python3
"""
Shivering Ghosts - Sprite Generator
Generates PNG sprites for the game
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import json
import math

# Output directory
ASSETS_DIR = "Shivering Ghosts/Assets.xcassets"

# Colors (matching Swift code)
COLORS = {
    'red': (255, 107, 107),
    'yellow': (255, 230, 109),
    'green': (78, 205, 196),
    'blue': (69, 183, 209),
    'purple': (160, 108, 213),
    'orange': (255, 153, 51),
    'pink': (255, 181, 194),
}

def create_imageset_folder(name):
    """Create .imageset folder structure for Xcode"""
    folder = os.path.join(ASSETS_DIR, f"{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    
    # Create Contents.json
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

def draw_ghost(size, color=(245, 245, 245), alpha=230):
    """Draw a cute blob ghost"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Ghost body (rounded blob shape)
    body_color = (*color, alpha)
    
    # Main body ellipse
    body_rect = (width * 0.1, height * 0.05, width * 0.9, height * 0.7)
    draw.ellipse(body_rect, fill=body_color)
    
    # Bottom wavy part
    wave_y = height * 0.55
    wave_height = height * 0.35
    
    # Draw wavy bottom with polygons
    points = []
    segments = 5
    for i in range(segments + 1):
        x = width * 0.1 + (width * 0.8) * (i / segments)
        if i % 2 == 0:
            y = wave_y + wave_height * 0.8
        else:
            y = wave_y + wave_height * 0.3
        points.append((x, y))
    
    # Add sides to close the polygon
    points.append((width * 0.9, wave_y))
    points.append((width * 0.1, wave_y))
    
    draw.polygon(points, fill=body_color)
    
    # Eyes
    eye_y = height * 0.35
    eye_radius = width * 0.08
    eye_spacing = width * 0.15
    
    # Left eye
    left_eye_center = (width * 0.5 - eye_spacing, eye_y)
    draw.ellipse([
        left_eye_center[0] - eye_radius,
        left_eye_center[1] - eye_radius,
        left_eye_center[0] + eye_radius,
        left_eye_center[1] + eye_radius
    ], fill=(30, 30, 30, 255))
    
    # Right eye
    right_eye_center = (width * 0.5 + eye_spacing, eye_y)
    draw.ellipse([
        right_eye_center[0] - eye_radius,
        right_eye_center[1] - eye_radius,
        right_eye_center[0] + eye_radius,
        right_eye_center[1] + eye_radius
    ], fill=(30, 30, 30, 255))
    
    # Eye shine
    shine_radius = eye_radius * 0.3
    shine_offset = eye_radius * 0.3
    for eye_center in [left_eye_center, right_eye_center]:
        draw.ellipse([
            eye_center[0] - shine_offset - shine_radius,
            eye_center[1] - shine_offset - shine_radius,
            eye_center[0] - shine_offset + shine_radius,
            eye_center[1] - shine_offset + shine_radius
        ], fill=(255, 255, 255, 200))
    
    # Mouth (wavy for shivering)
    mouth_y = height * 0.5
    mouth_width = width * 0.2
    
    # Simple curved mouth
    draw.arc([
        width * 0.5 - mouth_width,
        mouth_y - mouth_width * 0.5,
        width * 0.5 + mouth_width,
        mouth_y + mouth_width * 0.5
    ], start=0, end=180, fill=(30, 30, 30, 255), width=3)
    
    # Add subtle glow effect
    img = img.filter(ImageFilter.GaussianBlur(1))
    
    return img

def draw_yarn_ball(size, color):
    """Draw a yarn ball with texture lines"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Main circle
    margin = 4
    fill_color = (*color, 255)
    draw.ellipse([margin, margin, width - margin, height - margin], fill=fill_color)
    
    # Darker outline
    darker = tuple(max(0, c - 40) for c in color)
    draw.ellipse([margin, margin, width - margin, height - margin], outline=(*darker, 255), width=3)
    
    # Yarn texture lines (curved)
    lighter = tuple(min(255, c + 60) for c in color)
    center = width // 2
    
    for i in range(3):
        y_offset = (i - 1) * (height // 5)
        # Curved line effect
        points = []
        for x in range(margin + 5, width - margin - 5, 3):
            y = center + y_offset + int(math.sin((x - margin) * 0.15) * 8)
            points.append((x, y))
        
        if len(points) > 1:
            draw.line(points, fill=(*lighter, 180), width=2)
    
    # Highlight
    highlight_size = width // 4
    draw.ellipse([
        width * 0.25, height * 0.2,
        width * 0.25 + highlight_size, height * 0.2 + highlight_size
    ], fill=(255, 255, 255, 100))
    
    return img

def draw_sweater_stripe(size, color):
    """Draw a sweater stripe/layer"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    fill_color = (*color, 255)
    darker = tuple(max(0, c - 40) for c in color)
    
    # Rounded rectangle
    radius = height // 3
    draw.rounded_rectangle([2, 2, width - 2, height - 2], radius=radius, fill=fill_color, outline=(*darker, 255), width=2)
    
    # Knit pattern (small V shapes)
    pattern_color = tuple(min(255, c + 30) for c in color)
    for x in range(10, width - 10, 12):
        y_mid = height // 2
        draw.line([(x, y_mid - 3), (x + 4, y_mid + 3), (x + 8, y_mid - 3)], fill=(*pattern_color, 150), width=1)
    
    return img

def draw_background(size):
    """Draw night sky background"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Gradient background (dark blue to darker blue)
    for y in range(height):
        ratio = y / height
        r = int(20 + ratio * 10)
        g = int(20 + ratio * 15)
        b = int(50 + ratio * 20)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
    
    # Stars
    import random
    random.seed(42)  # Consistent stars
    for _ in range(80):
        x = random.randint(0, width)
        y = random.randint(0, int(height * 0.7))
        size_star = random.randint(1, 3)
        brightness = random.randint(150, 255)
        draw.ellipse([x, y, x + size_star, y + size_star], fill=(brightness, brightness, brightness, brightness))
    
    # Moon
    moon_x, moon_y = width - 80, 80
    moon_radius = 35
    moon_color = (255, 250, 230, 255)
    draw.ellipse([
        moon_x - moon_radius, moon_y - moon_radius,
        moon_x + moon_radius, moon_y + moon_radius
    ], fill=moon_color)
    
    # Moon glow
    for r in range(moon_radius + 5, moon_radius + 20, 3):
        alpha = int(50 * (1 - (r - moon_radius) / 20))
        draw.ellipse([
            moon_x - r, moon_y - r,
            moon_x + r, moon_y + r
        ], outline=(255, 250, 200, alpha), width=2)
    
    return img

def draw_snowflake(size):
    """Draw a small snowflake"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = width // 2
    color = (200, 230, 255, 200)
    
    # Six-pointed snowflake
    for angle in range(0, 360, 60):
        rad = math.radians(angle)
        x_end = center + int(math.cos(rad) * (width // 2 - 2))
        y_end = center + int(math.sin(rad) * (height // 2 - 2))
        draw.line([(center, center), (x_end, y_end)], fill=color, width=2)
    
    # Center dot
    draw.ellipse([center - 2, center - 2, center + 2, center + 2], fill=color)
    
    return img

def draw_heart(size):
    """Draw a heart for warm-up effect"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Heart shape using circles and triangle
    color = (255, 105, 140, 230)
    
    radius = width // 4
    # Left circle
    draw.ellipse([width * 0.15, height * 0.2, width * 0.5, height * 0.55], fill=color)
    # Right circle
    draw.ellipse([width * 0.5, height * 0.2, width * 0.85, height * 0.55], fill=color)
    # Bottom triangle
    draw.polygon([
        (width * 0.15, height * 0.4),
        (width * 0.85, height * 0.4),
        (width * 0.5, height * 0.85)
    ], fill=color)
    
    # Highlight
    draw.ellipse([width * 0.25, height * 0.25, width * 0.4, height * 0.4], fill=(255, 200, 210, 150))
    
    return img

def draw_button(size, color, text=""):
    """Draw a UI button"""
    width, height = size
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    fill_color = (*color, 255)
    darker = tuple(max(0, c - 40) for c in color)
    
    # Rounded button
    radius = height // 2
    draw.rounded_rectangle([0, 0, width, height], radius=radius, fill=fill_color, outline=(*darker, 255), width=3)
    
    # Inner highlight
    lighter = tuple(min(255, c + 40) for c in color)
    draw.rounded_rectangle([4, 4, width - 4, height // 2], radius=radius - 4, fill=(*lighter, 100))
    
    return img

def save_sprite(img, name, scales=[1, 2, 3]):
    """Save sprite at multiple scales for Xcode"""
    folder = create_imageset_folder(name)
    base_size = img.size
    
    for scale in scales:
        if scale == 1:
            scaled_img = img
            filename = f"{name}.png"
        else:
            new_size = (base_size[0] * scale, base_size[1] * scale)
            scaled_img = img.resize(new_size, Image.Resampling.LANCZOS)
            filename = f"{name}@{scale}x.png"
        
        filepath = os.path.join(folder, filename)
        scaled_img.save(filepath, 'PNG')
        print(f"  ✓ {filepath}")

def main():
    print("🎨 Shivering Ghosts - Sprite Generator")
    print("=" * 40)
    
    # Create assets directory if needed
    os.makedirs(ASSETS_DIR, exist_ok=True)
    
    # 1. Ghost sprites
    print("\n👻 Creating ghost sprites...")
    
    ghost_standard = draw_ghost((120, 150))
    save_sprite(ghost_standard, "ghost_standard")
    
    ghost_baby = draw_ghost((80, 100))
    save_sprite(ghost_baby, "ghost_baby")
    
    ghost_elder = draw_ghost((140, 180))
    save_sprite(ghost_elder, "ghost_elder")
    
    # Rare ghost (slightly purple tint)
    ghost_rare = draw_ghost((120, 150), color=(240, 235, 255), alpha=240)
    save_sprite(ghost_rare, "ghost_rare")
    
    # 2. Yarn ball sprites
    print("\n🧶 Creating yarn ball sprites...")
    
    for color_name, color_rgb in COLORS.items():
        yarn = draw_yarn_ball((60, 60), color_rgb)
        save_sprite(yarn, f"yarn_{color_name}")
    
    # 3. Sweater stripes
    print("\n👕 Creating sweater stripe sprites...")
    
    for color_name, color_rgb in COLORS.items():
        stripe = draw_sweater_stripe((80, 20), color_rgb)
        save_sprite(stripe, f"sweater_{color_name}")
    
    # 4. Background
    print("\n🌙 Creating background...")
    
    background = draw_background((390, 844))  # iPhone size
    save_sprite(background, "background_night")
    
    # 5. Effects
    print("\n✨ Creating effect sprites...")
    
    snowflake = draw_snowflake((24, 24))
    save_sprite(snowflake, "snowflake")
    
    heart = draw_heart((30, 30))
    save_sprite(heart, "heart")
    
    # 6. UI Elements
    print("\n🎮 Creating UI sprites...")
    
    button_green = draw_button((200, 60), COLORS['green'])
    save_sprite(button_green, "button_green")
    
    button_blue = draw_button((200, 60), COLORS['blue'])
    save_sprite(button_blue, "button_blue")
    
    button_red = draw_button((180, 50), COLORS['red'])
    save_sprite(button_red, "button_red")
    
    print("\n" + "=" * 40)
    print("✅ All sprites generated successfully!")
    print(f"📁 Output: {ASSETS_DIR}")

if __name__ == "__main__":
    main()
