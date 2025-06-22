#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

def convert_svg_to_png(svg_path, png_path):
    """SVG dosyasını PNG'ye dönüştürür"""
    try:
        # rsvg-convert kullanarak SVG'yi PNG'ye dönüştür
        cmd = ['rsvg-convert', '-w', '256', '-h', '256', '-f', 'png', '-o', png_path, svg_path]
        subprocess.run(cmd, check=True)
        print(f"✅ {svg_path} -> {png_path}")
    except subprocess.CalledProcessError:
        print(f"❌ Dönüştürme hatası: {svg_path}")
    except FileNotFoundError:
        print("❌ rsvg-convert bulunamadı. Lütfen librsvg2-bin paketini yükleyin.")
        print("   macOS: brew install librsvg")
        print("   Ubuntu: sudo apt-get install librsvg2-bin")

def main():
    # Assets klasörünü bul
    assets_dir = Path("assets/images")
    
    # Tüm SVG dosyalarını bul
    svg_files = list(assets_dir.rglob("*.svg"))
    
    if not svg_files:
        print("❌ SVG dosyası bulunamadı!")
        return
    
    print(f"🔍 {len(svg_files)} SVG dosyası bulundu")
    
    # Her SVG'yi PNG'ye dönüştür
    for svg_file in svg_files:
        png_file = svg_file.with_suffix('.png')
        convert_svg_to_png(str(svg_file), str(png_file))
    
    print("🎉 Dönüştürme tamamlandı!")

if __name__ == "__main__":
    main() 