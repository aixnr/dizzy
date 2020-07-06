# Dizzy

Aizan's custom Debian installer ISO, built by using the `live-build` tool, based on Debian 10 "Buster". Official project start date was on 04 July 2020.

```bash
# Install live-build binary
$ sudo apt install live-build

# Additional packages
$ sudo apt install debian-archive-keyring
```

According to Debian manpage, [live-build](https://manpages.debian.org/testing/live-build/index.html) is a set of scripts to build live system images and it uses a configuration directory to completely automate and customize all aspects of building a live CD image.

## Motivation

First, why not. Second, I got proprietary hardware (Broadcom and Nvidia chips) on my primary workstation so having a customized live CD installer would make live easier.

## Note on Host OS

I learned a hard lesson.

I was trying to generate Debian custom live CD image on a Ubuntu host. I did so by using the `live-build` tool that is already present on Ubuntu repository. Turned out, that was a mistake. I kept bumping into this error:

```
[2020-07-05 09:27:01] lb_chroot_linux-image 
--2020-07-05 09:27:02--  http://ftp.debian.org/debian//dists/buster/Contents-amd64.gz
Resolving ftp.debian.org (ftp.debian.org)... 2001:67c:2564:a119::148:12, 130.89.148.12
Connecting to ftp.debian.org (ftp.debian.org)|2001:67c:2564:a119::148:12|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
2020-07-05 09:27:02 ERROR 404: Not Found.
```

That caused the image generation to abort because `live-build` could not fetch `Contents-amd64.gz`. I soon found out the correct URL was supposed to be `http://ftp.debian.org/debian//dists/buster/main/`, where `main` was missing as you can see in the terminal output above.

To remedy this situation, I uninstalled `live-build` (`sudo apt remove live-build`), downloaded the source code for Debian's version of `live-build` from their [Salsa GitLab source code server](https://salsa.debian.org/live-team/live-build), and run `make install` (`make uninstall` to remove), and tried running `sudo lb build` again. It worked and I was able to generate a live CD image.

## Readings

I read a bunch before trying this and here are some reading materials that might be relevant.

1. [Live-build - how to build an installable debian live cd](https://terkeyberger.wordpress.com/2016/05/14/live-build-how-to-build-an-installable-debian-live-cd/)
2. [Create a custom live Debian 9 and 10 the pro way](https://www.bustawin.com/create-a-custom-live-debian-9-the-pro-way/)
3. [Live Build a Custom Kali ISO](https://www.kali.org/docs/development/live-build-a-custom-kali-iso/)
4. [How to create a custom Debian ISO with DWM](https://jacekkowalczyk82.github.io/update/manuals/linux/2019/05/29/how-to-create-a-custom-debian-iso-with-dwm.html)
5. [How to create a custom Ubuntu live from scratch](https://itnext.io/how-to-create-a-custom-ubuntu-live-from-scratch-dd3b3f213f81)
6. [nodiscc/debian-live-config](https://github.com/nodiscc/debian-live-config) (GitHub repo)
7. [Create a Custom Debian Live Environment (CD or USB)](https://willhaley.com/blog/custom-debian-live-environment/)

## Building A Live CD Image

The build directive is specified in `dizzy.sh` file. Ensure that it is an executable by running the following commands:

```bash
# Make executable
$ chmod +x dizzy.sh

# Before building, clean first (optional)
$ sudo lb clean

# Then, run the dizzy.sh file
$ ./dizzy.sh
```

See a section on [skeleton](#skeleton) below before moving forward.

```bash
# No error? Run the build
$ sudo lb build
```

This would generate an ISO file `*.hybrid.iso`. To clean work environment, run the following commands:

```bash
# Soft nuke
$ sudo lb clean

# Hard nuke
$ sudo lb clean --all
$ sudo lb clean --purge
```

## Skeleton

The directory `config` is what we call as **skeleton**. `lb config` dumps *files* here while `lb build` uses them to generate the final ISO.

* The sub-directory `config/includes.chroot` represents the `/` of the final ISO. By creating a new folder in it (e.g. `config/includes.chroot/opt`), it would generate `/opt/` folder inside the final ISO.
* Default user is called `user`. Its home directory is located at `config/includes.chroot/home/user`.
* To install additional packages at build time, create a file inside the `config/package-list` (e.g. `main.list.chroot`), one package per line. Multiple package lists are allowed, which is good for organization.

## Troubleshooting

I thought it was going to be easy. Never assume anything easy unless you have tried it.

**Live session**, at boot the screen presented 5 options: Live (amd64), Live (amd64 failsafe), Install, Graphical install, and Advanced options. The *Live (amd64)* has been iffy to be, while the *Graphical install* seemed to work fine and I was able to install the OS without issues. It almost feels like the Live session is buggy.

**Changing to Debian Testing, failed**. Before starting this, I deleted everything including the `config` directory (backed up important files first), then changed the distribution flags to `testing`. Unfortunately, it did not quite work for me. The error message:

```
E: The repository 'http://security.debian.org testing/updates Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
P: Begin unmounting filesystems...
P: Saving caches...
```

It seemed like an issue with the `--security true` flag. I guess the best way would be using Buster as the base, then switch to Testing post-install. To remedy this situation, I tried the following flags:

```bash
  --security false \
```

This is due to the fact that Debian Testing handles security updates differently than Debian Stable. However, it still failed with:

```
[2020-07-05 11:38:53] lb binary_disk 
P: Begin installing disk information...
cp: cannot stat '/usr/share/live/build/data/debian-cd/testing/amd64_netinst_udeb_include': No such file or directory
```

Debian Stable, then.
