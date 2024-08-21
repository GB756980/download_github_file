@echo off
setlocal enabledelayedexpansion

rem GitHub Token (如果为空则不使用)
set "github_token="

rem 设置 GitHub 的基础 URL
set github_raw_base_url=https://raw.githubusercontent.com
set github_api_base_url=https://api.github.com/repos

rem 获取当前批处理脚本的目录
set "script_dir=%~dp0"

rem 配置文件的绝对路径
set "config_file=%script_dir%github_files_info.txt"

rem 检查配置文件是否存在
if not exist "%config_file%" (
	echo =====================================================
    echo [ERROR] Configuration file "%config_file%" not found!
    echo =====================================================
    exit /b 1
)

rem 读取配置并处理每一行
call :ProcessConfigFile "%config_file%"

echo -----------------------------------------------------
echo [INFO] All download tasks completed.
echo -----------------------------------------------------

pause
endlocal
exit /b 0

rem 函数：读取配置文件并处理每一行
:ProcessConfigFile
set "config_file=%~1"

for /f "usebackq tokens=1-5 delims=, eol=#" %%a in ("%config_file%") do (
	echo =====================================================
    set "enabled=%%a"
    set "repository=%%b"
    set "folder_to_download=%%c"
    set "file_to_download=%%d"
    set "local_download_path=%%e"

    rem 替换路径中的环境变量
    call set "local_download_path=!local_download_path!"

    rem 调用决定下载类型的函数
    call :DecideDownload !enabled! !repository! !folder_to_download! !file_to_download! !local_download_path!
)

goto :eof

rem 函数：决定是下载文件还是文件夹
:DecideDownload
set "enabled=%~1"
set "repository=%~2"
set "folder_to_download=%~3"
set "file_to_download=%~4"
set "local_download_path=%~5"

if /i "!enabled!"=="false" (
    echo [INFO] Skipping download for repository: "!repository!"
	echo =====================================================
	echo.
    goto :eof
)

if not exist "!local_download_path!" (
    mkdir "!local_download_path!"
    echo [INFO] Directory created: "!local_download_path!"
)

if "!folder_to_download!"=="null" (
    if "!file_to_download!"=="null" (
        echo [ERROR] No file or folder specified for download!
    ) else (
        call :DownloadFile "!repository!" "!file_to_download!" "!local_download_path!"
    )
) else (
    if "!file_to_download!"=="null" (
        call :DownloadFolder "!repository!" "!folder_to_download!" "!local_download_path!"
    ) else (
        call :DownloadFile "!repository!" "!folder_to_download!/!file_to_download!" "!local_download_path!"
    )
)

goto :eof

rem 函数：解压文件
:UnzipFile
echo [INFO] Unzipping file "%~1"
powershell -command "Expand-Archive -Path '%~1' -DestinationPath '%~2' -Force"
if !errorlevel! neq 0 (
    echo [ERROR] File unzip failed: "%~1"
) else (
    echo [SUCCESS] File unzipped: "%~1"
    echo [INFO] Deleting ZIP file "%~1"
    del "%~1"
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to delete ZIP file: "%~1"
    ) else (
        echo [SUCCESS] ZIP file deleted: "%~1"
    )
)
exit /b 0

rem 函数：下载文件
:DownloadFile
set "file_url=%github_raw_base_url%/%~1/main/%~2"
echo [INFO] Downloading file "%~2" from "%~1"
echo [INFO] Saving to: "%~3"
echo -----------------------------------------------------

set "auth_header="
if defined github_token (
    set "auth_header=-Headers @{Authorization='token %github_token%'}"
)

echo [INFO] Requesting URL: "%file_url%"

powershell -command "Invoke-WebRequest -Uri '%file_url%' -OutFile '%~3\%~nx2' %auth_header%"
if !errorlevel! neq 0 (
    echo [ERROR] File download failed: "%~2" from "%~1"
) else (
    echo [SUCCESS] File downloaded: "%~2" from "%~1"
    if "%~x2"==".zip" (
        call :UnzipFile "%~3\%~nx2" "%~3"
    )
)
echo =====================================================
echo.
exit /b 0

rem 函数：下载文件夹
:DownloadFolder
set "file_list_url=%github_api_base_url%/%~1/contents/%~2"
echo [INFO] Download folder "%~2" from "%~1"
echo [INFO] Saving to: "%~3"
echo -----------------------------------------------------

set "auth_header="
if defined github_token (
    set "auth_header=-Headers @{Authorization='token %github_token%'}"
)

echo [INFO] Requesting folder list URL: "%file_list_url%"

powershell -command "$files = Invoke-RestMethod -Uri '%file_list_url%' %auth_header%; $files | ForEach-Object { if ($_.type -eq 'file') { $filePath = Join-Path -Path '%~3' -ChildPath $_.name; Invoke-WebRequest -Uri $_.download_url -OutFile $filePath; if ($_.name.EndsWith('.zip')) { Expand-Archive -Path $filePath -DestinationPath '%~3' -Force; Remove-Item -Path $filePath -Force } } }"
if !errorlevel! neq 0 (
    echo [ERROR] Folder download failed: "%~2" from "%~1"
) else (
    echo [SUCCESS] Folder downloaded: "%~2" from "%~1"
)
echo =====================================================
echo.
exit /b 0