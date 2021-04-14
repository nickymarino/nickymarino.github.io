.PHONY: up clean update

up:
	bundle exec jekyll serve --incremental

clean:
	bundle exec jekyll clean

update:
	bundle update