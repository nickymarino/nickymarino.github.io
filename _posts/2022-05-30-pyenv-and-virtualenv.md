---
layout: post
title: Use Pyenv to Streamline your Python Projects
description: A walk through of pyenv and virtualenv to run multiple Python versions in parallel.
cover_image: 2022/pyenv-and-virtualenv/cover.png
---

> *There are two hard problems to solve in a Python project: installing packages, and installing packages in other projects.*

Over the years, the challenges I've come across in Python projects has narrowed down to two topics [^python2] :

1. Installing packages for *just* my current project -- not for all projects using that version of Python
2. Using different Python versions for different projects

[^python2]: The rest are `python` vs `python3` compatibility problems.

Problem (1) can be solved with Python's built in [virtual environments](https://docs.python.org/3/library/venv.html), but they don't automatically activate when you enter a project folder. As a result, I often forget to run `source venv/activate` and then accidentally install a bunch of packages to my system Python.

I highly recommend [Pyenv](https://github.com/pyenv/pyenv) to solve both problems. Pyenv is a fantastic tool for managing Python environments simply by changing your current folder. Pyenv also integrates with `virtualenv` so that you can create virtual environments for any Python version you'd like to use.

## Overview

By the end of this post you will know how to:

- Install `pyenv` on your computer
- Build a version of Python with `pyenv`
- Change your global and local folder settings to run the new version of Python
- Connect `pyenv` to `virtualenv` to create a new virtual environment

## Install Pyenv


First, install Xcode tools and a few development libraries that the Python build step will need:

```bash
# Note: These are macOS specific commands

# Update XCode and Homebrew
xcode-select --install
brew update

# Install libraries you'll need to build Python from source
brew install openssl readline sqlite3 xz zlib

# Install pyenv
brew install pyenv
```

***Note:*** *The installation instructions for `pyenv` change frequently. These are the steps for `pyenv==2.3.1` on macOS. If you are using a different version or OS, see the `pyenv` [installation guide](https://github.com/pyenv/pyenv#installation).*

If you're using a zsh shell, run these commands to add `pyenv` to your dot files. If you're using another shell, follow the installation steps for your shell under the [Shell environment section of the pyenv README](https://github.com/pyenv/pyenv#set-up-your-shell-environment-for-pyenv).

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

Restart your terminal for the changes to take effect, and verify your installation by entering the command `which python3` and confirming that `pyenv/.shims` is somewhere in the output:

```
$ which python3

/Users/nicky/.pyenv/shims/python3
```

## Install Python 3.8.2

Next let's install Python 3.8.2. I chose this particular version of Python because I use it in a few of my side projects, so you can use any other version of Python if you'd like.

Recently, I came across a bug in macOS Big Sur that prevents libraries like `numpy` and `pandas` to use the `lzma` package. Credit to the thread for [pyenv Issue #1737](https://github.com/pyenv/pyenv/issues/1737#issuecomment-738080459) for the below instructions to correct the 3.8.2 build.

To install Python 3.8.2, first reinstall the `zlib` and `bzip2` libraries via Homebrew:

```
brew reinstall zlib bzip2
```

In your `~/.zshrc` (or `~/.bashrc` if you're using bash), add the below flags for the Python compiler to read:

```bash
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
```

Then install Python 3.8.2 using the below command. This may take some time to compile.

```bash
CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix bzip2)/include -I$(brew --prefix readline)/include -I$(xcrun --show-sdk-path)/usr/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib" \
pyenv install --patch 3.8.2 < <(curl -sSL https://github.com/python/cpython/commit/8ea6353.patch\?full_index\=1)
```

Verify that you built and installed Python 3.8.2 by checking what versions of Python `pyenv` has:

```
$ pyenv versions
  system
  3.8.2
```

## Manage Pyenv Versions

Pyenv has two types of versions:

1. `local` -- the Python version for your current directory
1. `global` -- the default Python version to use if no `local` version is set.

When you switch directories in your terminal, Pyenv checks for a `.python-version` file in the root of that directory. If there's no `.python-version`, Pyenv will search each parent folder until one is found.[^global]

[^global]: The `.python-version` at the root of your home folder sets your `global` Python version.

You can set what version of Python `pyenv` will use in your current folder with `pyenv local`:

```
$ pyenv local 3.8.2
```

You can check `.python-version` to see what version is used:

```
$ cat .python-version
3.8.2
```

And `pyenv version` will also tell you what version of Python you're currently using as well as what config file set it:

```
$ pyenv version
3.8.2 (set by /Users/nicky/Developer/my-project/.python-version)
```

If you move to a different folder without a `.python-version`, Pyenv will use your `global` setting, which is `system` by default:

```
$ cd /path/to/other/folder

$ pyenv version
system (set by /Users/nicky/.python-version)
```

## How to Use Pyenv Virtual Environments

Give `pyenv` superpowers by installing [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv). With this plugin, `pyenv` can manage virtual environments like `venv` and Conda environments.

Install the plugin with Homebrew:

```
brew install pyenv-virtualenv
```

And add the following to your shell's `.rc` file (such as `.zshrc` or `.bashrc`):

```bash
eval "$(pyenv virtualenv-init -)"
```

To create a virtual environment for the Python version you're using with `pyenv`, run `pyenv virtualenv [version] [new environment name]`. For example, to create a new `venv` for a sample project using 3.8.2:

```
pyenv virtualenv 3.8.2 my-project-3.8.2
```

While not required, I recommend adding the Python version to your environment names to manage them easier.

You can also create a new virtual environment using the current `pyenv` Python version:

```
pyenv virtualenv my-default-venv
```

Just like `pyenv`, your virtual environment will automatically activate whenever you move into that folder!

## Helpful Commands

Below is a list of commands for `pyenv` that I use often.

To show all of your Python versions and all virtual environments:

```
pyenv versions
```

To set a different version for the `python` and `python3` commands for your `global` settings:

```
# (This works the same with `local` as well)
pyenv global [python version] [python3 version]
```

To create a new virtual environment and use it locally:

```
pyenv virtualenv [python version] [new environment name]
pyenv local [new environment name]
```
