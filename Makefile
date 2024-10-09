# Path to the appimagetool to use to pack the final execuable.
# You don't need an explicit path if it's in your path
APPIMAGETOOL="./appimagetool-x86_64.AppImage"
# Path to the static apk executable to bootstrap.
# Once again, no explicit path needed if it's in your path
APK="./apk.static"
# Path to proot for copying into the final executable and running prebuild scripts
# This one HAS to be a path, since it gets copied
PROOT="./proot"
# Privilege escalabtion command to use for operations requiring it
# Leave blank if running as root
PRIVESC=sudo

MyApp-x86_64.AppImage: build/proot build/AppRun entry.desktop icon.png build/root build
	cp -t build -- entry.desktop icon.png
	$(PRIVESC) $(APPIMAGETOOL) build
	$(PRIVESC) chown "$$USER" MyApp-x86_64.AppImage

build:
	mkdir -p build

build/root: build packages.txt run.sh prebuild.sh
	$(PRIVESC) rm -rf ./build/root
	mkdir -p ./build/root
	grep -vE '^[ \t]*#' packages.txt | $(PRIVESC) xargs -- $(APK) --arch x86_64 $$(echo -X\ http://dl-cdn.alpinelinux.org/alpine/edge/{main,community,testing}/) -U --allow-untrusted --root ./build/root --initdb add
	cp run.sh build/root/run.sh
	chmod +x build/root/run.sh
	$(PRIVESC) cp -rvft build/root -- overlay/*

	cat prebuild.sh | $(PRIVESC) $(PROOT) -r build/root -w / env -i /bin/ash

clean:
	$(PRIVESC) rm -rf ./build/root
	rm -rf build

build/AppRun: AppRun.c build
	gcc AppRun.c -o build/AppRun

build/proot: build
	cp $(PROOT) build/proot