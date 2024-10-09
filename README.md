# SCARF 🧣
SCARF (Self-Contained Alpine Root Filesystem) is a tool for packaging an [Alpine Linux](https://www.alpinelinux.org/) root filesystem into an [AppImage](https://appimage.org/) that is capable of mounting itself and running programs installed in the Alpine root filesystem on other Linux systems.
This isn't a containerization tool intended for security, but rather a way to quickly create portable bundles for one or more applications.

## How does it work?
When an AppImage is executed, it mounts an internal filesystem as read-only, and executes a program from it.
SCARF takes advantage of this to mount an entire Alpine root filesystem as read-only, and then uses [PRoot](https://proot-me.github.io/) to start a process effectively chroot'ed inside of it.
This allows anything installed in the Alpine filesystem to execute on any other Linux installation, regardless of installed libc versions, shared libraries, etc.

## Mounted directories
Various directories from the host filesystem are transparently mounted over the read-only filesystem, such as the user's home directory, and the entire host filesystem is available inside of `/mnt` in the read-only filesystem.
Additional mounts can be specified in `AppRun.c`.

## Invocation
When the built AppImage is executed and mounted, it checks the name it was invoked with.
If the name ends with `.AppImage`, a default shell is started in the current directory.
If the name doesn't end with `.AppImage`, then it attempts to find a command in the root filesystem with the same name as the invoked name.
For example, if the executable is named `printf`, it will execute the `printf` command from the read-only filesystem.

## Building
- In order to successfully build an executable, you will need to following things:
  - A statically linked binary for `proot`. This is copied into the read-only filesystem to allow for chroot'ing.
    - Instructions for downloading/building are available on the [PRoot website](https://proot-me.github.io/#downloads).
  - A copy of `appimagetool`, to actually build the resulting AppImage.
    - You can probably find it on their [website](https://appimage.github.io/appimagetool/) or [GitHub](https://github.com/AppImage/AppImageKit)
  - A statically linked version of `apk`, the Alpine package manager, for bootstrapping the system.
    - Build instructions and releases can be found on the [apk-tools repository](https://gitlab.alpinelinux.org/alpine/apk-tools)
  - `gcc`, for compiling the `AppRun.c`.
  - Some method of privilege escalation if not running as root. This could be `sudo`, `doas`, etc. Some operations require root permissions to execute properly.
- Once you have all the prerequisites, you'll need to configure the `Makefile` to use the correct binaries.
It has the variables and instructions on how to set them.
- If you need to, you can also configure what paths are mounted by modifying `AppRun.c` and what commands are executed on startup in `run.sh`.
  - `run.sh` runs inside the AppImage environment, so it has access to the AppImage environment variables, such as `ARGV0`, `APPDIR`, `OWD`, etc.
- You can change the list of packages to be installed in `packages.txt`.
- Changes to the root filesystem (Deleting the cache, installing extra software, copying files in, etc) can be put in `overlay` and `prebuild.sh`.
  - First, `overlay` is copied over the root filesystem.
  - Next, `prebuild.sh` is run __inside__ the chroot in the root directory.
- Once properly configured, run `make` to build the executable.
