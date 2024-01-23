---
name: UI Translation
about: v2 UI localization
title: 'v2 Translations: Langauge (code)'
labels: 'localization'
---
**Add `v2/Localized/[language code]/installer.psd1`**

```powershell
# [Language Name] ([language code])
ConvertFrom-StringData -StringData @'
    package_name = BetterRTX
    ...
'@
```

### Required Labels
- [ ] backup
- [ ] backup_instance_location
- [ ] browse
- [ ] copying
- [ ] create_initial_backup
- [ ] deleting
- [ ] download
- [ ] downloading
- [ ] error
- [ ] error_copy_failed
- [ ] error_invalid_file_type
- [ ] error_no_installations_selected
- [ ] help
- [ ] install
- [ ] install_custom
- [ ] install_instance
- [ ] install_pack
- [ ] launchers
- [ ] package_name
- [ ] setup
- [ ] success
- [ ] uninstall
- [ ] uninstalled

_See [en-US](https://github.com/BetterRTX/BetterRTX-Installer/blob/main/v2/Localized/en-US/installer.psd1) for source._
