# 下载Github的最新文件


初心是为了下载GTA5 YimMenu的Lua脚本，修改github_files_info.txt也可以下载其他文件使用。


双击download_github_file.bat，即可从github下载指定的文件，如果下载的文件是zip格式，将会自动解压，解压后自动删除压缩包。

需要下载的文件信息都存储在github_files_info.txt中，每行代表一个文件。

可自行修改github_files_info.txt文件。


github_files_info.txt文件中的信息，示例如下：

TCRoid/YimMenu-Lua-RScript,null,RScript.lua,%APPDATA%\YimMenu\scripts

TCRoid/YimMenu-Lua-RScript,RScript,null,%APPDATA%\YimMenu\scripts\RScript


示例的说明，如下：

仓库所有者/仓库名,需要下载的文件夹,需要下载的文件,下载到本机的地址

（四个信息，用三个英文逗号分隔）


如果“需要下载的文件夹”为空，则下载仓库根目录的“需要下载的文件”文件。

如果“需要下载的文件夹”不为空，“需要下载的文件”不为空，则下载“需要下载的文件夹”下的“需要下载的文件”文件。

如果“需要下载的文件夹”不为空，“需要下载的文件”为空，则下载“需要下载的文件夹”文件夹下的全部文件（不包括子文件夹）。




来做个示范：https://github.com/TCRoid/YimMenu-Lua-RScript/tree/main

此脚本需要下载的文件如下：

根目录下的RScript.lua

RScript文件夹下的functions.lua和tables.lua

TCRoid/YimMenu-Lua-RScript 是仓库所有者/仓库名


下载根目录下的RScript.lua，如下所示：
根目录为就是null（空），文件名就是RScript.lua，保存路径是%APPDATA%\YimMenu\scripts（YimMenu脚本目录）

拼接以上信息，组成所需格式，如下所示：

TCRoid/YimMenu-Lua-RScript,null,RScript.lua,%APPDATA%\YimMenu\scripts


下载RScript文件夹下的functions.lua和tables.lua，如下所示：

根目录为就是RScript，下载其下所有的文件，文件名就是null（空），保存路径是%APPDATA%\YimMenu\scripts\RScript（YimMenu脚本目录下的RScript文件夹）

拼接以上信息，组成所需格式，如下所示：

TCRoid/YimMenu-Lua-RScript,RScript,null,%APPDATA%\YimMenu\scripts\RScript
