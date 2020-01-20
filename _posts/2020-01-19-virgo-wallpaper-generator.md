---
layout: post
title: Virgo&#58; Ruby Wallpaper Generator
description: Virgo is a terminal wallpaper generator in Ruby
image_folder: 2020/virgo-wallpaper-generator
---

There are many galaxies with strange, funny, or mysterious names, such as the [Sombrero Galaxy](https://en.wikipedia.org/wiki/Sombrero_Galaxy) or the [Cartwheel Galaxy](https://en.wikipedia.org/wiki/Cartwheel_Galaxy). Inspired by these galaxies I wanted to be able to make space-like wallpapers for my devices.

![The Thousand Ruby Galaxy]({% include _functions/image_path.html name='galaxy.jpg' %}){: .center}

As a result, I've written [Virgo](https://github.com/nickymarino/virgo), a wallpaper generator CLI written in Ruby. Virgo is great for creating PNG OLED phone wallpapers with a true black background. Let's create an iPhone 11 size wallpaper:

```
$ cd ~/virgo
$ ./virgo.rb --width 828 --height 1792
```

![Virgo Example Output]({% include _functions/image_path.html name='1.png' %}){: width="50%"}{: .center}

Virgo has many options for creating wallpapers, including the image dimension, colors, and pixel properties:

```
./virgo.rb save PATH [options]

OPTIONS:
    --background BACKGROUND
        Wallpaper background as a hexcode. Use list-backgrounds to list predefined background names

    --foregrounds FOREGROUNDS
        Wallpaper foregrounds as hexcodes separated by commans. Use list-foregrounds to list predefined f

    --width PIXELS
        Width of the wallpaper

    --height PIXELS
        Height of the wallpaper

    --density RATIO
        Ratio of pixels to size of the image, as a percent integer

    --diameter PIXELS
        Diameter of each pixel drawn on the wallpaper
```

There are also many predefined backgrounds and foregrounds for you to explore! Use the following commands to list some options:

```
$ ./virgo.rb list_backgrounds

black: #000000
white: #ffffff
dark_blue: #355c7d
chalkboard: #2a363b
peach: #ff8c94
gray: #363636
teal: #2f9599
orange: ff4e50
brown: #594f4f
gray_green: #83af9b
```

```
$ ./virgo.rb list_foregrounds

white: ["#ffffff"]
ruby: ["#8d241f", "#a22924", "#b72f28", "#cc342d", "#d4453e", "#d95953", "#de6d68"]
sunset: ["#f8b195", "#f67280", "#c06c84", "#6c5b7b"]
primaries: ["#99b898", "#feceab", "#ff847c", "#e84a5f"]
primaries_light: ["#a8e6ce", "#bcedc2", "#ffd3b5", "#ffaaa6"]
gothic: ["#a8a7a7", "#cc527a", "#e8175d", "#474747"]
solar: ["#a7226e", "#ec2049", "#f26b38", "#9dedad"]
yellows: ["#e1f5c4", "#ede574", "#f9d423", "#fc913a"]
earth: ["#e5fcc2", "#9de0ad", "#45ada8", "#547980"]
faded: ["#fe4365", "#fc9d9a", "#f9cdad", "#c8c8a9"]
```

[ChunkyPNG](https://chunkypng.com) was used to manage and save the wallpaper images, and [Commander](https://github.com/commander-rb/commander) enabled terminal argument parsing and help documentation. For optimization, I plan to use [NArray](https://masa16.github.io/narray/) for creating the pixel locations in the wallpaper and writing a custom PNG encoder. Here are a few example wallpapers created by Virgo:

![Virgo Example Output]({% include _functions/image_path.html name='2.png' %}){: .center}
![Virgo Example Output]({% include _functions/image_path.html name='4.png' %}){: .center}
![Virgo Example Output]({% include _functions/image_path.html name='1.png' %}){: .center}
![Virgo Example Output]({% include _functions/image_path.html name='5.png' %}){: .center}
![Virgo Example Output]({% include _functions/image_path.html name='3.png' %}){: .center}

You can find Virgo on GitHub [here](https://github.com/nickymarino/virgo).