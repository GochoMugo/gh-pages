install:
	cp -rf gh-pages-lib gh-pages ~/Bin

clean:
	rm -rf .travis

.PHONY: install clean

