#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

#define PROOT_PATH "proot"
#define RUN_PATH "/run.sh"
#define APP_DIR app_dir

#define PRINT_MACRO(x) fprintf(stderr, "%s: %s\n", # x, x)
#define LENGTH(arr) (sizeof(arr) / sizeof(arr[0]))

// To add a new mount path, use the MNT macro below
#define MNT(x) "-b", x ":" x
char* proot_args[] = {
    PROOT_PATH,
    "-R", "root",
    "-w", "/",
    "-b", "/:/mnt",
    MNT("/etc/passwd"),
    MNT("/etc/shadow"),
    MNT("/etc/group"),
    RUN_PATH,
    "--",
};
#undef MNT

int main(int argc, char** argv) {
    // Get the app directory
    char* app_dir = getenv("APPDIR");
    size_t app_dir_len = strlen(app_dir);

    // Change directory to app dir
    chdir(app_dir);

    // Get arg list
    char* args[argc + LENGTH(proot_args)];
    for(int i = 0; i < LENGTH(proot_args); i++)
        args[i] = proot_args[i];
    for(int i = 0; i < argc+1; i++)
        args[i+LENGTH(proot_args)] = argv[i];
    args[LENGTH(proot_args)] = RUN_PATH;

    // Exec shell
    execv(PROOT_PATH, args);

    // Ruh roh
    perror("Unable to exec shell");
    PRINT_MACRO(RUN_PATH);
    PRINT_MACRO(PROOT_PATH);
    PRINT_MACRO(APP_DIR);

    return 1;
}