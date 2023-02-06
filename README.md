# My Ideal Kionote OSTree customizations for Gaming/Development Use 

## Important Disclaimer
This image is in active development! (Read: likely to mess stuff up) 

I would definitely NOT recommend rebasing to it in its current form!

In addition, I have concerns about licensing for something like this. This image contains the steps to be built with nvidia drivers and proprietary codecs. 

I make no claims or promises.


## What's Different From Kionite?

Kionite combines the wonderfulness of Fedora and OSTree, but fails the "immediate layering" test. The first thing I have to do after installing just about any image based OS is immediately layer RPMFusion, codecs, drivers, and even basic administration utilities, which I feel like defeats a large part of the whole idea.

As such, I would like to create an image for me to use which covers most use cases out of the box, through careful choice of pre-installed apps and tools.

I am a big fan of the [Nobara Project](https://nobaraproject.org), much of the source of knowledge and optimizations come from that project. <3

This image is based on the work of [aleskandro's OSTree Config](https://github.com/aleskandro/my-ostree-config) and [ublue-os](https://github.com/ublue-os/base). For more info about how this works and reference materials, look at their awesome stuff!

# Customizations

## Patched Kernel
This image uses the ["Fsync Kernel"](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) (no longer has to do with fsync) and all of its patches.

Notable Differences:
- Zen patches
- OpenRGB Support
- ASUS Device Patches
- Steam Deck Device Patches
- Microsoft Surface Device Patches
- Various Nvidia installation patches
- amdgpu set as default for pre-polaris cards

Plus more, see the [Nobara changelist](https://nobaraproject.org). These changes make some games "just work" that don't on vanilla Fedora, and generally makes the whole OS a bit more snappy (in my experience).

This does come with the caveat that a non-standard kernel disables any hope of secure boot. This may change, see [this stale issue](https://bugzilla.redhat.com/show_bug.cgi?id=2070866)

## Drivers and Dependencies Included
This image ships with mesa-git for AMD graphics, and the Nobara packaged Nvidia drivers.

As always, [Nvidia is a pain to work with](https://nobaraproject.org/docs/nvidia-troubleshooting/the-never-ending-nvidia-driver-story/), hopefully the image-based updates can make this easier.

I'll add more here as I run into it.

## Expanded Repositories and Default Apps
RPM Fusion and Flathub are installed by default, and the Fedora Flatpaks are replaced by their Flathub counterparts.

In addition I have added some apps which I feel are severely lacking in base fedora, which make the experience for every user better.

- [List of included Flatpaks](root/usr/share/ensure-flatpak/applications.list)
- A list of added packages can be found in the [Containerfile](Containerfile).

<hr>