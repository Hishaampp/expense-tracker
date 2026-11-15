# Renders the Ample mark PNGs in assets/brand from the brand geometry.
# Run with Pillow: python3 tool/render_brand_mark.py assets/brand
# Renders the Ample mark (brand kit, logos/ample-mark.svg geometry) to PNG.
import sys
from PIL import Image, ImageDraw

def mark(size, frac, ring=(255,255,255,255), honey=(0xF2,0xB3,0x3D,255), bg=(0,0,0,0)):
    """The mark (viewBox 17..83) drawn so its 66-unit extent spans frac of size."""
    ss = 4
    S = size*ss
    img = Image.new('RGBA', (S,S), bg)
    d = ImageDraw.Draw(img)
    unit = S*frac/66.0
    ox = S/2 - 50*unit
    oy = S/2 - 50*unit
    P = lambda x,y: (ox+x*unit, oy+y*unit)
    # ring: circle r28, stroke 10
    cx,cy = P(50,50)
    r_out, r_in = 33*unit, 23*unit
    d.ellipse([cx-r_out,cy-r_out,cx+r_out,cy+r_out], fill=ring)
    d.ellipse([cx-r_in,cy-r_in,cx+r_in,cy+r_in], fill=bg)
    # bar: x73 y17 w10 h66 rx5
    x0,y0 = P(73,17); x1,y1 = P(83,83)
    d.rounded_rectangle([x0,y0,x1,y1], radius=5*unit, fill=ring)
    # honey: circle r19.5 below y=40
    hr = 19.5*unit
    honey_layer = Image.new('L', (S,S), 0)
    hd = ImageDraw.Draw(honey_layer)
    hd.ellipse([cx-hr,cy-hr,cx+hr,cy+hr], fill=255)
    _,yc = P(50,40)
    hd.rectangle([0,0,S,yc], fill=0)
    img.paste(Image.new('RGBA',(S,S),honey), (0,0), honey_layer)
    return img.resize((size,size), Image.LANCZOS)

out = sys.argv[1]
mark(1024, 0.42).save(f'{out}/ample-foreground.png')
mark(1024, 0.42, ring=(255,255,255,255), honey=(255,255,255,255)).save(f'{out}/ample-monochrome.png')
mark(768, 0.62, honey=(0,0,0,0)).save(f'{out}/ample-splash.png')
# Android 12 splash icon: the mark inside the 2/3 circle of a 960 canvas.
mark(960, 0.44, honey=(0,0,0,0)).save(f'{out}/ample-splash-android12.png')
print('ok')
