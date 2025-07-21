# Nextcloud Desktop Client in Xcode

This is an Xcode project which builds upon the Nextcloud desktop client repository to enable building and debugging in an Xcode project.
Consider this project as a portable workspace to bring the Nextcloud desktop client in the environment you are familiar with.

## Requirements

- See [the Nextcloud desktop client repository](https://github.com/nextcloud/desktop).
- You must have an Apple Development certificate for signing in your keychain.

## Usage

1. Clone this repository to wherever you want to have it.
2. Clone [the Nextcloud desktop client repository](https://github.com/nextcloud/desktop) into `Upstream` within this repository clone. 
3. Copy [`Build.xcconfig.template`](Build.xcconfig.template) to `Build.xcconfig` and adjust the values in it to your local setup.
4. Build or run the product.

## How It Works

- This started as an empty Xcode project with a single target for an external build system.
- The target runs the [Craft.sh](Craft.sh) shell script which is part of this Xcode project.
- `Craft.sh` prepares the execution of and finally runs [`mac-crafter`](https://github.com/nextcloud/desktop/tree/master/admin/osx/mac-crafter) which is part of the Nextcloud desktop client repository to simplify builds on macOS.
- By running `mac-crafter` with the right arguments and options, Xcode can attach to the built app with its debugger and stop at breakpoints. One of the key factors is the `Debug` build type which flips certain switches in the CMake build scripts ([in example: app hardening or get-task-allow entitlement](https://github.com/nextcloud/desktop/pull/8474/files)).
- The built Nextcloud desktop client app bundle is not placed into a derived data directory of Xcode but [`Build`](./Build) to enable the Xcode scheme included in this project refer to it with a path relative to the workspace. Otherwise Xcode would write an absolute path into the scheme file which is not portable across development machines. 
