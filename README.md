# Nextcloud Desktop Client in Xcode

This is an Xcode project which builds upon the Nextcloud desktop client repository to enable building and debugging in an Xcode project.
Consider this project as a portable workspace to bring the Nextcloud desktop client in the environment you are familiar with.

## Known Issues

- Right now, the project does not support signing a different app identity than the default one (`com.nextcloud.desktopclient`) which is owned by the Nextcloud GmbH development team registered with Apple. This means that you have to be signed in with a developer account in Xcode which is part of that development team when building. ([#4](https://github.com/i2h3/nextcloud-desktop-client-xcode/issues/4))
- Even when building successfully, Xcode may conclude that the build failed or at least some errors occurred during the build. During the build, some command outputs messages with an "Error: " prefix. Since this is the same way the compiler usually reports errors to Xcode, the latter assumes something might have gone wrong. But no invocation exits with an error code. Hence, the build can still complete successfully while Xcode might just misinterpret the console output. You will see at the end of the build output log in Xcode. ([#5](https://github.com/i2h3/nextcloud-desktop-client-xcode/issues/5))
- The developer build may be fragile and its file provider extension sometimes fails to create the Realm database file in the sandbox container even though it should be abled to. This might be related to an entitlement present in the standard build but still missing in the developer build. Using the standard build first to set up an account appears to be a workaround for now. ([#6](https://github.com/i2h3/nextcloud-desktop-client-xcode/issues/6))

## Requirements

- See [the Nextcloud desktop client repository](https://github.com/nextcloud/desktop).
- You must have an Apple Development certificate for signing in your keychain.

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
2. Enter `FileProviderExt`. If you would also like to debug the file provider UI extension, then you can additionally specify `FileProviderUIExt`.
3. Confirm.
4. If no process is already running, then Xcode will wait for it to be launched to attach automatically. This usually happens when you launch the main app or set up a new account with file provider enabled.

### Work on NextcloudFileProviderKit

You can directly debug changes to the NextcloudFileProviderKit edited from this project.
You have to have a local repository clone of the package somewhere locally, though.
Then, you have to open the NextcloudIntegration.xcodeproj project from the upstream repository clone in Xcode.
Drag and drop the package folder into the project navigator of the NextcloudIntegration project.
This will cause Xcode to resolve to the local and editable package instead of a cached clone from remote.
When you then run the build action of this root project, the local dependency is built as well.
