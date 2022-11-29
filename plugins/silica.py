from typing import Text, final
from beet import Context, Texture
from PIL import Image

def generateImage(overlay):
    print(overlay)
    #, save:str, cdMax:float, shape:str="linear", size:tuple[int,int]=(16,16)
    size = tuple(overlay.get('size', [16, 16]))
    cdMax = overlay.get('cdMax', 15)
    shape = overlay.get('shape', "linear")


    green = 0
    if cdMax < 10:
        green = int(cdMax * 10 + 0.5)
    elif cdMax > 60:
        green = int((cdMax - 60) * 0.2 + 150 + 0.999)
    else:
        green = int(cdMax + 90);

    r = Image.new(mode="L", size=size, color=(15))
    g = Image.new(mode="L", size=size, color=(green))
    a = Image.new(mode="L", size=size, color=(19))

    if shape == "linear":
        b = Image.linear_gradient("L").resize(size)
    elif shape == "radial":
        b = Image.radial_gradient("L").resize(size)
    else:
        b = Image.open(shape).getchannel("B")

    overlay = Image.merge("RGBA", [r, g, b, a])

    return Texture(overlay)

def generateOverlay(ctx: Context):
    overlays = ctx.meta.get('mc-silica', [])

    for overlay in overlays:
        save = overlay.get('save', "")
        if save == "": continue
        ctx.assets.textures[save] = generateImage(overlay)