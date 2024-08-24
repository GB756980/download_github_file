# download_github_file：下载Github的最新文件


## 注意
本项目以后将不再更新，因为功能已合并至：
- [download_form_github（从 Github 更新 Release 或下载文件）](https://github.com/GB756980/download_form_github)

## 项目说明

初心是为了下载GTA5 YimMenu的Lua脚本，修改github_files_info.txt也可以下载其他文件使用。


双击download_github_file.bat，即可从github下载指定的文件，如果下载的文件是zip格式，将会自动解压，解压后自动删除压缩包。

需要下载的文件信息都存储在github_files_info.txt中，每行代表一个文件。

可自行修改github_files_info.txt文件。


github_files_info.txt文件中的信息，示例如下：

true,TCRoid/YimMenu-Lua-RScript,null,RScript.lua,%APPDATA%\YimMenu\scripts

true,TCRoid/YimMenu-Lua-RScript,RScript,null,%APPDATA%\YimMenu\scripts\RScript


示例的说明，如下：

是否下载(true下载，false不下载),仓库所有者/仓库名,需要下载的文件夹,需要下载的文件,下载到本机的地址

（五个信息，用四个英文逗号分隔）


如果“需要下载的文件夹”为空，则下载仓库根目录的“需要下载的文件”文件。

如果“需要下载的文件夹”不为空，“需要下载的文件”不为空，则下载“需要下载的文件夹”下的“需要下载的文件”文件。

如果“需要下载的文件夹”不为空，“需要下载的文件”为空，则下载“需要下载的文件夹”文件夹下的全部文件（不包括子文件夹）。
