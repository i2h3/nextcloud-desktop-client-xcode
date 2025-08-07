# Nextcloud Desktop Client in Xcode

This is an Xcode project which builds upon the Nextcloud desktop client repository to enable building and debugging in an Xcode project.
Consider this project as a portable workspace to bring the Nextcloud desktop client in the environment you are familiar with.

## Requirements

- See [the Nextcloud desktop client repository](https://github.com/nextcloud/desktop).
- You must have an Apple Development certificate for signing in your keychain.

**Known limitation**: Right now, the project does not support signing a different app identity than the default one (`com.nextcloud.desktopclient`) which is owned by the Nextcloud GmbH development team registered with Apple. This means that you have to be signed in with a developer account in Xcode which is part of that development team when building. This problem is tracked as [issue #4](https://github.com/i2h3/nextcloud-desktop-client-xcode/issues/4).

## Usage

1. Clone this repository to wherever you want to have it.
2. **Optional** (the `Craft.sh` script will do so otherwise): Clone [the Nextcloud desktop client repository](https://github.com/nextcloud/desktop) as `Upstream` within the root of this repository clone where `NextcloudDesktopClient.xcodeproj` is located, in example with `git clone https://github.com/nextcloud/desktop.git Upstream`.
3. Copy [`Build.xcconfig.template`](Build.xcconfig.template) to `Build.xcconfig` and adjust the values in it to your local setup.
4. Build or run the product.

## How It Works

- This started as an empty Xcode project with a single target for an external build system.
- The target runs the [Craft.sh](Craft.sh) shell script which is part of this Xcode project.
- `Craft.sh` prepares the execution of and finally runs [`mac-crafter`](https://github.com/nextcloud/desktop/tree/master/admin/osx/mac-crafter) which is part of the Nextcloud desktop client repository to simplify builds on macOS.
- By running `mac-crafter` with the right arguments and options, Xcode can attach to the built app with its debugger and stop at breakpoints. One of the key factors is the `Debug` build type which flips certain switches in the CMake build scripts ([in example: app hardening or get-task-allow entitlement](https://github.com/nextcloud/desktop/pull/8474/files)).
- The built Nextcloud desktop client app bundle is not placed into a derived data directory of Xcode but `/Applications`. The standard behavior of placing the product into Xcode's derived data directory would result in absolute reference paths within the scheme file which are not portable across devices and users due to varying user names.

## Hints

Just for reference, a few helpful snippets for inspecting state on breakpoints with the Xcode debugger.

### Print a `QString`

```lldb
call someString.toStdString()
```

### Print a `QStringList`

```lldb
call someStrings.join("\n").toStdString()
```

### Attach to File Provider Extension Process

You can debug the file provider extension process(es) in Xcode by attaching to them by their binary name.

1. Select this menu item in Xcode: _Debug_ → _Attach to Process by PID or Name..._
2. Enter "FileProviderExt".
3. Confirm.
4. If no process is already running, then Xcode will wait for it to be launched to attach automatically.
5. This usually happens when you launch the main app or set up a new account with file provider enabled.