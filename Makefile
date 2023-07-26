
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
