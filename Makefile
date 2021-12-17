.PHONY: help install up clean update

help:  ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | awk '!/^\#/' | sed -e 's/##//' | column -t -s ':' | sort -k1

# This uses your post on installing Ruby 2.7.3 on M1
install:  ## Install Ruby via rvm and install required gems
	sh _scripts/install_ruby.sh
	bundle install

up:  ## Spin up the website locally
	bundle exec jekyll serve --incremental --config _config.yml,_config_local.yml

clean:  ## Clean the site's build directory
	bundle exec jekyll clean

update:  ## Update gems
	bundle update