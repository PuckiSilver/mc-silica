# mc-silica

Dynamically **display cool down** on each **item** using vanilla shaders.

## **Overview**

This project uses [beet](https://github.com/mcbeet/beet).
Beet is **not needed** for functionality and if you don't want to use beet you can just take [the shaders](src/assets/minecraft/shaders/core/) and follow the manual steps in this README to create the textures and models.

Because these shaders only modify rendering of the GUI, they are **fully compatible with modded shaders** (Optifine and Sodium/Iris).

To communicate with the shader, the **tint** of the item is used.
Therefore cool down can **only display on items that can be colored** (Leather Horse Armor, Potions, Tipped Arrows, ...).

Please only **modify the shaders** if you are working on an **isolated project** since it hinders compatibility if the shaders overwrite each other.

 ## **Configure**

This project uses a texture to set the **maximum cool down** and the **shape of the visual cool down**.

The [silica plugin](plugins/silica.py) of this project can [generate such a texture](#generate-the-texture) from human readable input but you can also [create the texture manually](#manually-create-the-texture).

### **Generating the Texture**

To generate a texture you just need to include the plugin, and provide the following information, in the [beet.yml](beet.yml) file:

`size`, an array holding 2 integers.
This will determine the size of the output texture.

`cdMax`, the maximum cool down of the item in seconds.
You can put any number here, the plugin will snap it to the nearest possible value.
> **Note**: The maximum cool down has limited precision<br>
> From 0.0s to 10.0s precision of 1/10th of a second<br>
> From 10s to 60s precision of 1 second<br>
> From 60s to 585s (9.75min) precision of 5 seconds<br>

`shape`, the shape how the cool down is displayed.
This can be either `linear`, `radial` or a path to any black and white gradient file relative to the [beet.yml](beet.yml) file.

`path`, the path this texture is saved to.
This is the same path you add to your model as the texture of `layer0`.
You can use [this refence](src/assets/minecraft/models/item/item_on_cd.json) as a guide.

### **Manually creating the Texture**

To identify a texture usnig mc-silica, all pixels have to have the red channel set to 🔴**15** and the alpha channel set to ⚪**19**

The **green channel** of the corner pixels determines the maximum cool down:
- 🟢 Green from **1** to **99** maps to 0.1s to 9.9s
- 🟢 Green from **100** to **150** maps to 10.0s - 60.0s
- 🟢 Green from **151** to **255** maps to 65.0s - 585.0s (9,75min)

> **Note**: The maximum cool down has limited precision<br>
> From 0.0s to 10.0s precision of 1/10th of a second<br>
> From 10s to 60s precision of 1 second<br>
> From 60s to 585s (9.75min) precision of 5 seconds<br>

The **blue channel** detemines the shape how the cool down is displayed:
- Pixels with blue set to 🔵**255** are always displayed when the item is on cool down
- Pixels with blue set to 🔵**0** will only be displayed if the item is at its maximum cool down
- All pixels in between are shown accordingly, so a pixel with a blue value of 🔵**127** will be displayed at half cool down and above

Now reference this texture as `layer0` in any colored item's model.
You can use [this refence](src/assets/minecraft/models/item/item_on_cd.json) as a guide.

## **Set runtime variables**

### **Tint**

The shader reads the **time until it is on cool down** and a **cool down reduction** applied to the maximum cool down from its tint/color value.

The **time until it is on cool down** has to be a value **between 0 and 12000**.
- This value has a precision of 1/10th of a second and is calculated like this:
    ```ini
    time_until = ( gametime/2 + cool_down ) % 12000
    ```
    Where `gametime` is the result of `time query gametime` and the `cool_down` is the time the item is on cool down for with a precision of 1/10th of a second.

The **cool down reduction** is a reduction to the maximum cool down set by the texture.
- This is a value **between 0 and 1000**, where 1000 means 100% of the maximum cool down is displayed and 0 means the item has no maximum cool down at all.
- This again works with all values in between, giving you a precision of 1/10th of a percent.

These two values are combined as the **tint of the item** to be read by the shader like this:
-   ```ini
    tint = time_until + ( cool_down_reduction * 16384 )
    ```

### **Functions**

Included with this project are [functions](src/data/silica/modules/main.bolt) to **set a cool down** and **reset a cool down**.
These functions are written in [bolt](https://github.com/mcbeet/bolt) but should easily be understandable even if you have never used bolt.

Since the `GameTime` in vanilla shaders resets once every 24000 ticks (20 minutes), you need to periodically **reset the last cool down** so the cool down ins't shown twice.
- Because of this, the **real gametime that the item is on cool down until** is also stored when setting the cool down.
- When executing the function to **reset the cool down**, that information is used to see if any particular item's cool down can be cleared.

You can see these functions as a template of how you could implement a cool down system in your data pack, feel free to use anything from these function and implement them in your own data pack.

---
[![PuckiSilver on GitHub](https://raw.githubusercontent.com/PuckiSilver/static-files/main/link_logos/GitHub.png)](https://github.com/PuckiSilver)[![PuckiSilver on modrinth](https://raw.githubusercontent.com/PuckiSilver/static-files/main/link_logos/modrinth.png)](https://modrinth.com/user/PuckiSilver)[![PuckiSilver on PlanetMinecraft](https://raw.githubusercontent.com/PuckiSilver/static-files/main/link_logos/PlanetMinecraft.png)](https://planetminecraft.com/m/PuckiSilver)[![PuckiSilver on PayPal](https://raw.githubusercontent.com/PuckiSilver/static-files/main/link_logos/PayPal.png)](https://paypal.me/puckisilver)
