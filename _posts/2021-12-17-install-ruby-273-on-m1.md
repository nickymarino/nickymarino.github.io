---
layout: post
title: How to Install Ruby 2.7.3 on M1 Mac
description: In this post, I provide instructions on how to install Ruby 2.7.3 on an M1 Mac computer.
---

Installing Ruby or Python on M1 Macs is a nightmare. I've lost so many hours fighting compilers and Rosetta to these issues, so I'm documenting my installation steps to spare you[^and-me] a lot of headache.

[^and-me]: And future me

## Why 2.7.3?

First, why Ruby 2.7.3 specifically? Ruby 3.0.0+ works great on M1 using [my RVM install instructions post](https://nickymarino.com/2020/06/13/jekyll-server-rvm-macos/):

```
rvm install 3.0.0
```

Unfortunately, my website's host [GitHub Pages](https://pages.github.com) uses Ruby 2.7.3 according to their [dependency documentation](https://pages.github.com/versions/). And a bare-bones install of 2.7.3 blows up on my M1 machine:

```
rvm install 2.7.3
```

So I needed to find a way to install 2.7.3 on my Mac to build and run my website locally to preview new posts.

## The Solution

I'll put the winning command here at the top to keep things simple. Many thanks to [@d-lebed](https://github.com/d-lebed) for documenting their solution on this [GitHub issue](https://github.com/rvm/rvm/issues/5033#issuecomment-991949115). I lightly modified their code to use `$(brew --prefix)` instead of hardcoding where `homebrew` downloads `openssl@1.1`:

```bash
# Winning script!
brew install openssl@1.1

export PATH="$(brew --prefix)/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L$(brew --prefix)/opt/openssl@1.1/lib"
export CPPFLAGS="-I$(brew --prefix)/opt/openssl@1.1/include"
export PKG_CONFIG_PATH="$(brew --prefix)/opt/openssl@1.1/lib/pkgconfig"

rvm autolibs disable

export RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC
export optflags="-Wno-error=implicit-function-declaration"

rvm install 2.7.3 --with-openssl-dir=$(brew --prefix)/opt/openssl@1.1
```

This successfully installed Ruby 2.7.3 for me, and I was then able to run `bundle install` at the root of my website's repo!

## The Issue

I originally documented all of my problem solving steps and install attempts, but it grew too long and rambly for my liking. Instead, I'll give a brief summary of a few errors I came across.

### Flags

At one point, `rvm` was complaining about my `LDFLAGS`:

```
checking whether LDFLAGS is valid... no
configure: error: something wrong with LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
```

And setting `LDFLAGS=""` in front of `rvm install 2.7.3` only resulted in errors with the compiler missing `openssl` libraries. So I needed `LDFLAGS` set somehow, but not the way that works for Python and `pyenv`.

### Rosetta

In a few GitHub issues, people recommended opening the Terminal app via Rosetta and running commands that way such as in [this issue comment](https://github.com/rvm/rvm/issues/5146#issuecomment-967048308). However, I saw no difference in error outputs between Rosetta Terminal and iTerm. In the end, I used iTerm without Rosetta to successfully install Ruby 2.7.3.

### Usename Macro Error

I got *close* to a correct install when I added the openssl library to `LDFLAGS`, `CPPFLAGS`, and `PKG_CONFIG_PATH`:

```bash
PATH="/usr/local/opt/openssl@1.1/bin:$PATH" \
LDFLAGS="-L$(brew --prefix)/opt/openssl@1.1/lib" \
CPPFLAGS="-I$(brew --prefix)/opt/openssl@1.1/include" \
PKG_CONFIG_PATH="$(brew --prefix)/opt/openssl@1.1/lib/pkgconfig" \
arch -x86_64 rvm install 2.7.3 -j 1
```

But I then started seeing errors about some missing `rl_username_completion_function` macro:

```
214 warnings generated.
linking shared-object date_core.bundle
installing default date_core libraries
compiling readline.c
readline.c:1904:37: error: use of undeclared identifier 'username_completion_function'; did you mean 'rl_username_completion_function'?
                                    rl_username_completion_function);
                                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                    rl_username_completion_function
readline.c:79:42: note: expanded from macro 'rl_username_completion_function'
# define rl_username_completion_function username_completion_function
                                         ^
/opt/homebrew/opt/readline/include/readline/readline.h:485:14: note: 'rl_username_completion_function' declared here
extern char *rl_username_completion_function PARAMS((const char *, int));
             ^
1 error generated.
make[2]: *** [readline.o] Error 1
make[1]: *** [ext/readline/all] Error 2
make: *** [build-ext] Error 2
+__rvm_make:0> return 2
```

I then found the winning command (above) by googling for `rvm install 2.7.3 error extern char *rl_username_completion_function PARAMS((const char *, int));` and trying a few commands recommended on some GitHub issues.

## Next Steps

I recently figured out how to install Python 3.7, 3.8, and 3.9 on M1 Macs via `pyenv`, so keep an eye out for my post on how to install those.
