ConvertFrom-StringData -StringData @'
logo1 =  \u200b_________________________________________________________________________
logo2 =  |    ____           _     _                   _____    _______  __   __   |
logo3 =  |   |  _ \\         | |   | |                 |  __ \\  |__   __| \\ \\ \/ \/   |
logo4 =  |   | |_) |   ___  | |_  | |_    ___   _ __  | |__) |    | |     \\ V \/    |
logo5 =  |   |  _ <   / _ \\ | __| | __|  / _ \\ | '__| |  _  /     | |      > <     |
logo6 =  |   | |_) | |  __/ | |_  | |_  |  __/ | |    | | \\ \\     | |     / . \\    |
logo7 =  |   |____\/   \\___|  \\__|  \\__|  \\___| |_|    |_|  \\_\\    |_|    \/_\/ \\_\\   |
logo8 =  |_____________________________便捷安装器_____________________________|
logo9 =                                                                         
logo10 =   \u200b_________________________________________________________________________
logo11 =                                                                            
logo12 =                             betterRTX便捷安装器v1.1.3                       
logo12prerelease =               betterRTX便捷安装器v1.1.3（预览版）               
logo13 =                           BetterRTX 官方安装器 |  禁止转发                  
logo14 =   _________________________________________________________________________

installerLocationChoice = 您要让那个国际版的MCBE使用betterRTX?:
installerLocationChoice1 = 1): 正式版MCBE (默认方式)
installerLocationChoice2 = 2): 预览版的MCBE (进阶选项) (不推荐，若预览版的一些特性在我们为其更新betterRTX之前就发生改变,将会导致不适配)
installerLocationInvalid = 无效的选项
installerLocationPrompt = 为那个版本的MCBE安装betterRTX?
installerLocationChoice1Numeral = 1
installerLocationChoice2Numeral = 2

checkingForIOBitUnlocker = 检查是否安装IOBit Unlocker中...
IOBitUnlockerCheckPass = IObit Unlocker 已安装, betterRTX安装继续...(请手动点击IOBit Unlocker的弹窗以继续)
IOBitUnlockerCheckFail = IObit Unlocker 未安装
IOBitUnlockerPleaseInstall = 请点击下方链接先安装 IObit Unlocker,并重试

checkingForMinecraft = 检查是否已安装国际版MCBE中...
MinecraftCheckPass = 国际版MCBE已安装, betterRTX安装继续...(请手动点击IOBit Unlocker的弹窗以继续)
MinecraftCheckFail = 国际版MCBE未安装,请从微软商店下载国际版MCBE
MinecraftPleaseInstall = 请从下方的链接前往微软商店下载MCBE,并重试

installationMethod = betterRTX安装选项:
serverInstall = 1): 在线安装 (推荐选项)(从服务器一站式安装betterRTX,若您位于中国的大陆境内，则需要魔法才可访问)
localInstall = 2): 通过本地的betterRTX文件安装 (进阶选项) (确保你拥有最新版betterRTX文件，并将其已经放在本脚本的同一目录下)
uninstall = 3): 将betterRTX还原为原版RTX（若您位于中国的大陆境内，同样需要使用魔法才可使用该选项）
exit = 4):退出安装
installationMethodInvalid = 无效的选项
installationMethodPrompt = 选择您的安装方式：
installationMethod1Numeral = 1
installationMethod2Numeral = 2
installationMethod3Numeral = 3
installationMethod4Numeral = 4
installSelectionKeyword = 选择

downloadingFromServer =正在从服务器上下载最新版betterRTX...
versionSelect = 选择您要安装的betterRTX版本!
selectVersionPrompt = 您要安装什么版本的betterRTX?
downloadingBins = 正在从服务器中下载最新的betterRTX文件( 由社区优化的RTXStub.material.bin 和 RTXPostFX.Tonemapping.material.bin)
doneDownloading = 下载完成. betterRTX安装继续...

uninstalling = 正在移除 BetterRTX...
downloadingVanilla = 正在下载最新的原版RTX文件(英伟达原版 RTXStub.material.bin 和 RTXPostFX.Tonemapping.material.bin)

removingStub = 正在移除原先的 RTXStub.material.bin...
removingTonemapping = 正在移除原先的 RTXPostFX.Tonemapping.material.bin...
insertingVanillaStub = 正在还原为 原版的 RTXStub.material.bin
insertingVanillaTonemapping = 正在还原为 原版的 RTXPostFX.Tonemapping.material.bin

doneSadFace = 还原完成 :(
sorryToSeeYouGo = 我们对您的离开感到很抱歉. 若您对betterRTX有什么建议或者想参与betterRTX的问题讨论, 可以点击下方discord邀请链接前往minecraftRTX服务器，并进入#betterrtx-help频道来提交它们.
installerOptionNotFound = 安装选项未找到. 请重启本程序并重试. 退出中...
inviteLink = 点我加入服务器: https://discord.gg/minecraft-rtx
helpChannelLink =点我加入betterRTX问题互助频道 : https://discord.com/channels/691547840463241267/1101280299427561523

stubFound = RTXStub.material.bin 正确存放, betterRTX安装继续...(请手动点击IOBit Unlocker的弹窗以继续)
stubNotFound = RTXStub.material.bin 不存在，或未将其放于本脚本的同一目录下
tonemappingFound = RTXPostFX.Tonemapping.material.bin 正确存放, 安装继续...(请手动点击IOBit Unlocker的弹窗以继续)
tonemappingNotFound = RTXPostFX.Tonemapping.material.bin 不存在，或未将其放于本脚本的同一目录下, 安装退出中...

insertingTonemapping =向您的MC写入BetterRTX的 RTXPostFX.Tonemapping.material.bin 中
insertingStub = 向您的MC写入BetterRTX的 BetterRTX RTXStub.material.bin
doneHappyFace = betterRTX安装完成!(ᗒᗨᗕ)
thanks = 感谢您使用betterRTX! 诚邀您点击下方的discord邀请链接加入minecraftRTX服务器,并进入服务器子频道 #betterrtx-help 参与问题讨论!
resourcePackNotice = 请注意， 你依然需要先拥有支持RTX的资源包才可使用RTX!！！！！！！！
translator=译者:discord:Tasreader,bilibili:澪憬
'@
