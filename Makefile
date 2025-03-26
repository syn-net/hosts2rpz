
all: clean lint test

clean:
	rm -rf build/*
test:
	./hosts2rpz.pl --in "./tests/dating-services-extended.txt" --out "./build/dating-services-extended.rpz"
	./hosts2rpz.pl --in "./tests/facebook-extended.txt" --out "./build/facebook-extended.rpz"
lint:
	$(perl hosts2rpz.pl)
count:
	wc -l build/*.rpz
# TODO(JEFF): Verify that `install`, `uninstall`, `remove` and `dist-clean`
# targets do as we intend.
#
# FIXME(JEFF): Add commonly used options to `install`
install:
	install ./hosts2rpz.pl /usr/local/bin/hosts2rpz.pl
uninstall:
remove:
dist-clean:
	rm /usr/local/bin/hosts2rpz.pl
