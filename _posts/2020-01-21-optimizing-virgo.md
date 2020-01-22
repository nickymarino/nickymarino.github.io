---
layout: post
title: Optimizing Virgo Using NArray
description: How to improve the runtime Virgo using Ruby NArray
image_folder: 2020/optimizing-virgo
---

![Virgo Example Output]({% include _functions/image_path.html name='example_11.png' %}){: .center}

[Earlier this week]({{ site.baseurl }}/2020/01/19/virgo-wallpaper-generator/), I had released [Virgo](https://github.com/nickymarino/virgo), a Ruby CLI to generate wallpapers (including the one above). My goal was to be able to create beautiful OLED wallpapers for my phone, but unfortunately, the first version of Virgo would take about 15 seconds to generate a wallpaper the size of an iPhone 11. The first version of Virgo used [`ChunkyPNG::Image`](https://www.rubydoc.info/github/wvanbergen/chunky_png/ChunkyPNG/Image) to place pixels on the background, and the author of ChunkyPNG alludes to this possible problem [in his README](https://github.com/wvanbergen/chunky_png):

> Also, have a look at [OilyPNG](http://github.com/wvanbergen/oily_png) which is a mixin module that implements some of the ChunkyPNG algorithms in C, which provides a massive speed boost to encoding and decoding.

## Improvement Goal

My goal was to reduce the time to generate an iPhone-sized wallpaper (about 1200 by 2200 pixels) in under one second. I chose this constraint so that I can eventually write a web frontend in [Sinatra](http://sinatrarb.com). Users won't wait 15 seconds for an image to be generated, especially if the file is being provided by a server without any loading indication on the page.

## Thinking of a Solution

When thinking of optimization ideas, two options stood out to me from Willem's [README](https://github.com/wvanbergen/chunky_png):

1.  Can I adapt Virgo to use OilyPNG instead of ChunkyPNG?
2.  Is there another library that implements array manipulation in C?

After some research into OilyPNG, I found that the functions I used with ChunkyPNG weren't implemented in OilyPNG[^not-really-implemented], so I was left to find another library that enabled a faster manipulation of integer arrays. I knew that in the Python world, [NumPy](https://numpy.org) would be the immediate answer. After some research for a Ruby alternative to NumPy, I came across [NArray](https://github.com/masa16/narray), which [appeared](https://stackoverflow.com/questions/5653994/ruby-equivalent-of-numpy) to be a solution [others](https://dev.to/kojix2/narray-ruby-equivalent-of-numpy-30ji) had relied on in the past. I alluded to this possible approach in my [original post]({{ site.baseurl }}/2020/01/19/virgo-wallpaper-generator/):

> [ChunkyPNG](https://chunkypng.com) was used to manage and save the wallpaper images, and [Commander](https://github.com/commander-rb/commander) enabled terminal argument parsing and help documentation. For optimization, I plan to use [NArray](https://masa16.github.io/narray/) for creating the pixel locations in the wallpaper and writing a custom PNG encoder.

# Fast Pixel Placement

After some profiling, the section of code that could be improved the most was overlaying pixels on the background image:

```ruby
def place_pixel
  # Create a new canvas
  pixel = Image.new(@pixel_diameter, @pixel_diameter, @theme.foreground)

  # Replace the old image with the new canvas at the pixel coordinate
  @image = @image.replace(pixel, pixel_coordinate.x, pixel_coordinate.y)
end
```

Rather than creating new `ChunkyPNG::Images` and overlaying them on a master `Image`, I decided to use a new data structure for the image. Instead, Virgo now uses an `NArray` to represent the image, where each item is the `Integer` representation of the pixel `ChunkyPNG::Color`. For every pixel, a portion of the array is replaced with the integer color:

```ruby
def create_map
  # Start with each pixel in the image as the background color
  map = NArray.int(@width, @height).fill!(@theme.background)

  # Place each pixel in the map
  count = number_pixels_to_place
  (1..count).each do
    # Determine pixel location
    x = @x_distribution.random_point
    x_max = x + @pixel_diameter
    y = @y_distribution.random_point
    y_max = y + @pixel_diameter

    # Replace the pixel in the map with a new (random) color
    map[x..x_max, y..y_max] = @theme.random_foreground
  end
end
```

Then, to create save a `Wallpaper` instance, a `ChunkyPNG::Image` is created by inserting rows of the `NArray` into the `Image`:

```ruby
def image
  img = Image.new(@width, @height, Color::TRANSPARENT)

  # Put each row of @map into the image
  num_rows = @map.shape[1]
  (0...num_rows).each do |row_idx|
    # Replace the row in the image with the new colors
    img.replace_row!(row_idx, @map[true, row_idx])
  end

  img
end
```

## `int` vs `Integer`

There was only one problem with this solution: the range of values for `ChunkyPNG::Image` would often exceed the range of the `int` type used by `NArray`. Therefore, most of the colors in the predefined themes could not be placed into the color map as-is.

I decided to implement a color hash (enum) for a `Theme` instance, where every key is a unique (low `Integer` value identifier), and each value is the (large `Integer`) `ChunkyPNG::Image` value. The background color (`@background`) will always have the identifier `0`, and the foreground colors (`@foregrounds`) have identifiers from `1` to `n`. The color hash is created in `Theme.initialize`:

```ruby
def initialize(background = BACKGROUNDS[:black],
               foregrounds = FOREGROUNDS[:ruby])
  @background = Color.from_hex(background)
  @foregrounds = foregrounds.map { |x| Color.from_hex(x) }

  # Because NArray can't handle the size of some ChunkyPNG::Color
  # values, create a Hash of the background and foreground colors,
  # where the key of the hash is an Integer, and the
  # value is the value of the color
  # Background has a key of 0, foregrounds have keys from 1..n
  colors = [@background] + @foregrounds
  colors_with_indices = colors.each_with_index.map do |color, idx|
    [idx, color]
  end
  @color_hash = Hash[colors_with_indices]
end
```

Let's look at an example:

```
2.6.3 :001 > # Construct a theme using predefined color names
2.6.3 :002 > t = Theme.from_syms(:black, :ruby)
 => #<Theme:0x00007f861f8c2128
      @background=255,
      @foregrounds=[
        2367954943,
        2720605439,
        3073321215,
        3425971711,
        3561307903,
        3646510079,
        3731712255],
      @color_hash={
        0=>255,
        1=>2367954943,
        2=>2720605439,
        3=>3073321215,
        4=>3425971711,
        5=>3561307903,
        6=>3646510079,
        7=>3731712255}>
```

Note that the `@background` color `255` is in `@color_hash` as `0=>255`, which means it has an identifier of `0`. The second color in `@foregrounds`, `2720605439`, is in `@color_hash` as `2=>2720605439`, meaning that color has an identifier of `2`.

Therefore, if the `Wallpaper` map has the following values:

```
[ [0, 0, 0],
  [0, 2, 0],
  [0, 0, 0] ]
```

Then the middle pixel is red (a value of `2720605439`), and the border pixels are black (a value of `255`).

Next, we add a few helper functions to `Theme` for retrieving a random foreground (pixel) color and color keys/values:

```ruby
# Returns the key for the background color
def background_key
  # The background always has a key of 0
  0
end

# Returns a random @color_hash foreground key
def random_foreground_key
  # (Slightly) speed up getting a foreground by returning the first
  # item if only one exists
  color = if @foregrounds.length == 1
            @foregrounds[0]
          else
            @foregrounds.sample
          end

  key_from_color(color)
end

# Returns the ChunkyPNG::Color value for a color key
def color_from_key(key)
  @color_hash[key]
end

# Returns the key (in @color_hash) for a color value
def key_from_color(color)
  @color_hash.key(color)
end
```

And `create_map` is updated to use the color keys rather than the large values:

```ruby
def create_map
  # Start with each pixel in the image as the background color
  map = NArray.int(@width, @height).fill!(@theme.background_key)

  # Place each pixel in the map
  count = number_pixels_to_place
  (1..count).each do
    # Determine pixel location
    x = @x_distribution.random_point
    x_max = x + @pixel_diameter
    y = @y_distribution.random_point
    y_max = y + @pixel_diameter

    # Replace the pixel in the map with a new (random) color
    map[x..x_max, y..y_max] = @theme.random_foreground_key
  end

  map
end
```

Now we can test whether using `NArray` vs `ChunkyPNG::Image` reduced the time to generate large wallpapers.

## Results

Using `NArray` _significantly_ improved Virgo's speed:

![Virgo Example Output]({% include _functions/image_path.html name='speed-chart.png' %}){: .center}

Note the exponential time complexity of the original implementation, and the linear time complexity.[^linear-time] With 10 trials, `NArray` Virgo took 0.5 seconds on average to generate a 1000x1000 wallpaper, while the original implementation of Virgo takes 15.1 seconds on average. **That's a a 30x improvement!** Even better, these updates will allow me to make a responsive Sinatra web frontend, without worrying about user retention or delays.

## Future Improvements

I believe more improvements could be made to Virgo, especially since I plan on writing a web frontend. In particular, I've added a `Distribution` class to enable both normal and uniform pixel distributions, but I have not added it as a feature to the CLI. Further, there is a new version of `NArray` called [`Numo::NArray`](https://github.com/ruby-numo/numo-narray) that supports `UInt64` values, so there will no longer be a need to map each color in a `Theme` to unique identifiers.

[Virgo](https://github.com/nickymarino/virgo) is available on my [GitHub profile](https://github.com/nickymarino), and it's open to pull requests!

![Virgo Example Output]({% include _functions/image_path.html name='example_13.png' %}){: .center}

[^not-really-implemented]: In fact, the [library](https://github.com/wvanbergen/oily_png) didn't seem to have implemented much, if any, of the ChunkyPNG functionality.
[^linear-time]: Well, `O(n)` at least comparative to the `ChunkyPNG` implementation and tests I conducted up to an image size of 5000x5000.