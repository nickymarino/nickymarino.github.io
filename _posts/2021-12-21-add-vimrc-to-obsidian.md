---
layout: post
title: Add Your Vimrc to Obsidian
description: Learn how to enable vim bindings in Obsidian and use a vimrc file in your Obsidian vault.
cover_image: 2021/add-vimrc-to-obsidian/cover.png
image_folder: 2021/add-vimrc-to-obsidian
---

I've migrated my note taking system from [Craft](https://www.craft.do) to [Obsidian](https://www.craft.do) over the past few weeks, and it's been great so far. One major advantage of Obsidian is its amazing developer community and wide, wide universe of [community plugins](https://obsidian.md/plugins). I use quite a few community plugins:

![My community plugins]({% include _functions/image_path.html name='img1.png' %}){: .center}

One of my favorite features of Obsidian is its support for vim bindings. I use vim  and VS Code's vim bindings all the time, and I'm able to context switch much faster between coding and note writing when all of my editors use vim keys.[^google-docs]

[^google-docs]: The only downside is that I start typing gibberish whenever I open Google Docs or Word, but that's a sacrifice I'm willing to make.

You can turn on vim bindings in your own Obsidian vault by going to "Settings" > "Editor" and toggling "Vim key bindings":

![Enable vim bindings]({% include _functions/image_path.html name='img2.png' %}){: .center}

The only downside to Obsidian's default vim bindings is the lack of `.vimrc` support out of the box. My personal `.vimrc` has a few shortcuts that I rely on:

* I map `;` to `:` in normal mode so that I don't rely on the shift key
* I map `j` to `gj` (and `k` to `gk`) to jump by visual lines instead of logical lines by default

The `;` mapping isn't a deal breaker in Obsidian; I'm not using vim commands that often. However, the `j` and `k` remaps are critical! Obsidian wraps text much more than a terminal thanks to its generous padding. Even on this "simple" post with just a lot of text, one line turns into four in Obsidian:

![Long text line example]({% include _functions/image_path.html name='img3.png' %}){: .center}

Luckily, there's plugin for Obsidian `.vimrc` files: [Obsidian Vimrc Support Plugin](https://github.com/esm7/obsidian-vimrc-support). To add this to your Obsidian vault, go to "Settings" > "Community plugins" > "Browse" and search for "vimrc":

![Searching for vimrc plugin]({% include _functions/image_path.html name='img4.png' %}){: .center}

Then click "Vimrc Support", "Install" and "Enable":

![Enabling vimrc support plugin]({% include _functions/image_path.html name='img5.png' %}){: .center}

At the root of your Obsidian vault (the root folder for all of your `.md` files), create a new file named `.obsidian.vimrc`. You can paste any of your `~/.vimrc` into your `.obsidian.vimrc`.

Here's my `.obsidian.vimrc` that remaps `;`, `j`, and `k` in normal mode:

````vim
" .obsidian.vimrc
"
" A small .vimrc for Obsidian vim bindings
"
" To enable this file, you must install the Vimrc Support plugin for Obsidian:
" https://github.com/esm7/obsidian-vimrc-support
"_________________________________________________________________________

" ; (semicolon) - same as : (colon)
nmap ; :

" (space) - same as : (colon)
nmap <SPACE> :

" j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk
````

Once you write your `.obsidian.vimrc`, reload Obsidian and your new vim bindings will load!
