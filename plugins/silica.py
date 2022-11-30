from typing import List, overload
from beet import Context, Texture
from PIL import Image
from beet.library.resource_pack import Model

def generateImage(sizeIn: list, cdMax: float, shape: str):
    if sizeIn is None or cdMax is None or shape is None: return None
    size = tuple(sizeIn)

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
        b = Image.open(shape).convert("L").resize(size, Image.Resampling.NEAREST)

    overlay = Image.merge("RGBA", [r, g, b, a])

    return Texture(overlay)

def generateTexture(ctx: Context):
    meta = ctx.meta.get('mc-silica')
    if meta is None: return
    overlays = meta.get('textures')
    if not isinstance(overlays, list): return

    for overlay in overlays:
        path = overlay.get('path')
        if path is None: continue

        texture = generateImage(
            overlay.get('size'),
            overlay.get('cdMax'),
            overlay.get('shape'))
        if texture is None: continue
        ctx.assets.textures[path] = texture

def insertPlane(model: Model, overlay: str):
    model.data['textures']['layer0'] = overlay

    # SHOULD ONLY WORK FOR MODELS WITH
    # at max 2 rotations set to a multiple of 22.5
    # negative values are the same spiel
    # 3rd rotation can be any multiple of 90

    return model

def generateModel(ctx: Context):
    meta = ctx.meta.get('mc-silica')
    if meta is None: return
    models = meta.get('models')
    if not isinstance(models, list): return

    for model in models:
        path = model.get('path')
        overlay = model.get('overlay')
        if path is None or overlay is None: continue
        newModel = ctx.assets.models[path]
        newModel = insertPlane(newModel, overlay)



