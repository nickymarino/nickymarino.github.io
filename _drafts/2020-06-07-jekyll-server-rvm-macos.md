how to run a jekyll server using rvm on macos

https://usabilityetc.com/articles/ruby-on-mac-os-x-with-rvm/

brew install gnupg

# Blank these out, use [rvm install page](https://rvm.io/rvm/install) to find actual keys#
# but add the ipv4 becuase I had to
gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable --ruby

# per instlal instructions, run
source /Users/nmarino/.rvm/scripts/rvm
# or open new terminal

# add
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
# to bashrc or zshrc

rvm list

rvm use 2.7.0



# based on the [quickstart](https://jekyllrb.com/docs/)

gem install jekyll bundler

bundle install (to catch anything else in Rakefile)

bundle exec jekyll serve

# if get warnings
/Users/nmarino/.rvm/gems/ruby-2.7.0/gems/jekyll-4.0.0/lib/jekyll/tags/include.rb:179: warning: Using the last argument as keyword parameters is deprecated
                    done in 2.492 seconds.
 Auto-regeneration: enabled for '/Users/nmarino/Developer/nickymarino.github.io'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.

# run
bundle update jekyll
bundle exec jekyll serve

localhost 4000
