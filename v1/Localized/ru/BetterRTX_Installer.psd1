ConvertFrom-StringData -StringData @'
logo1 =  \u200b_________________________________________________________________________
logo2 =  |    ____           _     _                   _____    _______  __   __   |
logo3 =  |   |  _ \\         | |   | |                 |  __ \\  |__   __| \\ \\ \/ \/   |
logo4 =  |   | |_) |   ___  | |_  | |_    ___   _ __  | |__) |    | |     \\ V \/    |
logo5 =  |   |  _ <   / _ \\ | __| | __|  / _ \\ | '__| |  _  /     | |      > <     |
logo6 =  |   | |_) | |  __/ | |_  | |_  |  __/ | |    | | \\ \\     | |     / . \\    |
logo7 =  |   |____\/   \\___|  \\__|  \\__|  \\___| |_|    |_|  \\_\\    |_|    \/_\/ \\_\\   |
logo8 =  |_____________________________QUICK INSTALLER_____________________________|
logo9 =                                                                         
logo10 =   \u200b_________________________________________________________________________
logo11 =  |                                                                         |
logo12 =  |               Быстрый установщик v1.1.3 для Minecraft RTX               |         
logo12prerelease =  |        Быстрый установщик v1.1.3 (Пре-релиз) для Minecraft RTX        |
logo13 =  |         ОФИЦИАЛЬНЫЙ УСТАНОВЩИК BetterRTX | НЕ РАСПРОСТРАНЯТЬ            |
logo14 =  |_________________________________________________________________________|

installerLocationChoice = Выберете версию игры для установки:
installerLocationChoice1 = 1): Minecraft Bedrock Edition (По умолчанию)
installerLocationChoice2 = 2): Minecraft Preview Edition (Продвинутый) (Не рекомендуется к использованию, так как функционал может измениться до того, как мы сможем обновить BetterRTX для него)
installerLocationInvalid = Неверный выбор
installerLocationPrompt = Выбор
installerLocationChoice1Numeral = 1
installerLocationChoice2Numeral = 2

checkingForIOBitUnlocker = Проверка наличия IOBit Unlocker...
IOBitUnlockerCheckPass = IObit Unlocker установлен, продолжаем...
IOBitUnlockerCheckFail = IObit Unlocker не установлен
IOBitUnlockerPleaseInstall = Пожалуйста установите IObit Unlocker и попробуйте еще раз

checkingForMinecraft = Проверка наличия Minecraft...
MinecraftCheckPass = Minecraft установлен, продолжаем...
MinecraftCheckFail = Minecraft не установлен
MinecraftPleaseInstall = Пожалуйста установите Minecraft и попробуйте еще раз

installationMethod = Выберете метод установки:
serverInstall = 1): Установка с сервера (Рекомендовано)
localInstall = 2): Установить из локального хранилища (Продвинутый) (Предполагается, что у вас есть файлы последней версии в той же папке, что и программа установки)
uninstall = 3): Удалить BetterRTX
exit = 4): Выйти
installationMethodInvalid = Неверный выбор
installationMethodPrompt = Выбор
installationMethod1Numeral = 1
installationMethod2Numeral = 2
installationMethod3Numeral = 3
installationMethod4Numeral = 4
installSelectionKeyword = Выберете

downloadingFromServer = Скачивание последней версии с сервера
versionSelect = Выберете пресет для установки!
selectVersionPrompt = Выберете версию
downloadingBins = Скачивание последнего RTXStub.material.bin и RTXPostFX.Tonemapping.material.bin с сервера
doneDownloading = Скачивание завершено. Продолжаем...

uninstalling = Удаление BetterRTX...
downloadingVanilla = Скачивание последнего Ванильного RTXStub.material.bin и RTXPostFX.Tonemapping.material.bin

removingStub = Удаление старого RTXStub.material.bin
removingTonemapping = Удаление старого RTXPostFX.Tonemapping.material.bin
insertingVanillaStub = Перемещение Ванильного RTXStub.material.bin
insertingVanillaTonemapping = Перемещение Ванильного RTXPostFX.Tonemapping.material.bin

doneSadFace = Готово :(
sorryToSeeYouGo = Нам жаль, что вы уходите. Если у вас есть какие-либо предложения или проблемы, напишите сообщение в форум канале #betterrtx-help на Discord сервере Minecraft RTX.
installerOptionNotFound = Опция не найдена. Перезапустите программу и повторите попытку. Выходим...
inviteLink = Приглашение: https://discord.gg/minecraft-rtx
helpChannelLink = Ссылка на чат помощи: https://discord.com/channels/691547840463241267/1101280299427561523

stubFound = RTXStub.material.bin уже есть, Продолжаем...
stubNotFound = RTXStub.material.bin не найден
tonemappingFound = RTXPostFX.Tonemapping.material.bin уже есть, Продолжаем...
tonemappingNotFound = RTXPostFX.Tonemapping.material.bin не найден, Выходим...
insertingStub = Inserting BetterRTX RTXStub.material.bin
insertingTonemapping = Перемещение BetterRTX версии файла RTXPostFX.Tonemapping.material.bin

doneHappyFace = Готово :)
thanks = Спасибо за установку BetterRTX! Если у вас есть какие-либо предложения или проблемы, напишите сообщение в форум канале #betterrtx-help на Discord сервере Minecraft RTX!
resourcePackNotice = ВАМ ТРЕБУЕТСЯ RTX-СОВМЕСТИМЫЙ ТЕКСТУРПАК ДЛЯ РАБОТЫ BetterRTX!
translator = Перевел KoshakMineDev
'@