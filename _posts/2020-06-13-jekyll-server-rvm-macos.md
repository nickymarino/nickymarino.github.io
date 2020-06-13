---
title: How to Use Jekyll on macOS Catalina with RVM
description: This article explains the steps to set up Ruby and Jekyll using RVM on macOS Catalina
layout: post
---

Apple bundles a system version of the Ruby programming language on macOS. Because system Ruby is used by the inner workings of the operating system, this version is not meant to be upgraded or modified by a user. With the Ruby Version Manager [RVM](https://rvm.io/), you can install an additional Ruby version for personal use. 

Similar to [pyenv](https://github.com/pyenv/pyenv), you can install multiple versions of Ruby with RVM and change the version you’re using on the fly. You can also install gems without `sudo`. 

## Installing RVM and Ruby

Before downloading RVM, first install [gpg](http://en.wikipedia.org/wiki/GNU_Privacy_Guard) and the mpapis public key:

```
$ brew install gnupg
$ gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

The keys (`xxxx...`) change often, so you will need to copy the most recent ones from the [RVM install page](https://rvm.io/rvm/install#install-gpg-keys).

Next, download the most recent stable version of RVM:

```
$ \curl -sSL https://get.rvm.io | bash -s stable --ruby
```

After installation, RVM will tell you to either open a new terminal or source `rvm`, so run the  command it prints:

```
$ source ~/.rvm/scripts/rvm
```

You will also want to add `rvm` to your `~/.zshrc` or `~/.bashrc` to load when you open a terminal:

```
# Add this to your ~/.zshrc or ~/.bashrc
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
```

Use `rvm list` to find a Ruby version you want to install, then tell RVM which version to use:

```
$ rvm list
$ rvm use 2.7.0
```

You can then verify that you’re using an RVM-managed version of Ruby:

```
$ which ruby
~/.rvm/rubies/ruby-2.7.0/bin/ruby
```

## Installing Jekyll

First, verify you’re using a Ruby version managed by RVM in the above step. Then, install the [Jekyll](https://jekyllrb.com) gem:

```
$ gem install jekyll bundler
```

If you’re already in a Jekyll website repo (or any folder with a `Rakefile`), you can use `bundle` to install your remaining requirements:

```
$ bundle install
```

You may then need to update Jekyll for your `Rakefile` requirements:

```
$ bundle update jekyll
```

Now you can up the Jekyll server:

```
$ bundle exec jekyll serve
```

Now check out your site at `http://localhost:4000`! See the [Jekyll Quickstart](https://jekyllrb.com/docs/) for more details on starting a Jekyll blog.
