# Better RTX Installer

### Prerequisites

- Use software like
  [MCLauncher](https://github.com/MCMrARM/mc-w10-version-launcher) or
  [Bedrock Launcher](https://github.com/BedrockLauncher/BedrockLauncher) to
  easily create a side-loaded Minecraft installation.
- **OR** download [IOBit Unlocker](https://www.iobit.com/en/iobit-unlocker.php)
  to allow copying to Minecraft Launcher/Windows Store installations.

## Launch Installer GUI
Copy and paste the following line into a command terminal to start the installer. _(English version)_

```
powershell -c "iwr https://bedrock.graphics/installer -useb | iex"
```

## Translations

With help from several [contributors](https://github.com/BetterRTX/BetterRTX-Installer/graphs/contributors), the installer interface has been translated into [multiple languages](https://github.com/BetterRTX/BetterRTX-Installer/tree/prerelease/v2/Localized).

Enter this command in a __64-bit PowerShell__ terminal to launch the installer in your preferred language (if available).

```powershell
iwr https://bedrock.graphics/installer/v2/$PsUICulture | iex
```

---

## Help

![Discord](https://img.shields.io/discord/691547840463241267?style=flat-square&logo=discord&logoColor=%23ffffff&label=Minecraft%20RTX%20Discord)

Join the
[Minecraft RTX Discord](https://discord.com/invite/minecraft-rtx-691547840463241267)
or
[open an Issue on GitHub](https://github.com/BetterRTX/BetterRTX-Installer/issues)
for additional help.

[Read the Wiki](https://github.com/BetterRTX/BetterRTX-Installer/wiki) for more details and instructions.

---

**[Credits](CREDITS.md) | [Contribute](CONTRIBUTING.md) | [Code of Conduct](CODE_OF_CONDUCT.md) | [Changelogs](CHANGELOGS.md) | [Security Policy](SECURITY.md)**

Licensed under a [GNU GENERAL PUBLIC LICENSE](LICENSE.md)

**_BetterRTX_ is not affiliated with NVIDIA or Mojang.**
