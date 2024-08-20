@echo off
setlocal enabledelayedexpansion

rem GitHub Token (如果为空则不使用)
rem GitHub Token (not used if empty)
set "github_token="

rem 设置 GitHub 的基础 URL
rem Set the base URL for GitHub
set github_raw_base_url=https://raw.githubusercontent.com
set github_api_base_url=https://api.github.com/repos





rem 获取当前批处理脚本的目录
rem Get the directory of the current batch script
set "script_dir=%~dp0"

rem 配置文件的绝对路径
rem Absolute path of the configuration file
set "config_file=%script_dir%github_files_info.txt"

rem 检查配置文件是否存在
rem Check if the configuration file exists
if not exist "%config_file%" (
    echo [ERROR] Configuration file "%config_file%" not found!
    echo =====================================================
    exit /b 1
)

rem 读取配置文件并处理每一行，跳过注释行和空行
rem Read the configuration file line by line, skipping comments and empty lines
for /f "usebackq tokens=1-4 delims=, eol=#" %%a in ("%config_file%") do (
    set "repository=%%a"           rem 设置 GitHub 仓库
    rem Set the GitHub repository
    set "folder_to_download=%%b"   rem 设置要下载的文件夹
    rem Set the folder to download
    set "file_to_download=%%c"     rem 设置要下载的文件
    rem Set the file to download
    set "local_download_path=%%d"   rem 设置本地下载路径
    rem Set the local download path

    rem 替换路径中的环境变量
    rem Replace environment variables in the path
    call set "local_download_path=!local_download_path!"

    rem 确保本地保存路径存在，如果不存在则创建
    rem Ensure the local save path exists, create if not
    if not exist "!local_download_path!" (
        mkdir "!local_download_path!"
        echo [INFO] Directory created: "!local_download_path!"
    )

    rem 检查文件夹或文件下载
    rem Check whether to download a folder or a file
    if "!folder_to_download!"=="null" (
        if "!file_to_download!"=="null" (
            echo [ERROR] No file or folder specified for download!
            echo =====================================================
            echo.
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
)

echo -----------------------------------------------------
echo [INFO] All download tasks completed.
echo -----------------------------------------------------

pause
endlocal
exit /b 0

rem 函数：解压文件
rem Function: Unzip file
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
rem Function: Download file
:DownloadFile
set "file_url=%github_raw_base_url%/%~1/main/%~2"
echo =====================================================
echo [INFO] Downloading file "%~2" from "%~1"
echo [INFO] Saving to: "%~3"
echo -----------------------------------------------------

rem 使用 PowerShell 的 Invoke-WebRequest 下载文件，附带 GitHub Token（如果存在）
rem Use PowerShell's Invoke-WebRequest to download the file with GitHub Token if it exists
set "auth_header="
if defined github_token (
    set "auth_header=-Headers @{Authorization='token %github_token%'}"
)

rem 输出请求链接（不包括 auth_header）
rem Output the request URL (excluding auth_header)
echo [INFO] Requesting URL: "%file_url%"

rem 使用 PowerShell 的 Invoke-WebRequest 下载文件
rem Use PowerShell's Invoke-WebRequest to download the file
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
rem Function: Download folder
:DownloadFolder
set "file_list_url=%github_api_base_url%/%~1/contents/%~2"
echo =====================================================
echo [INFO] Download folder "%~2" from "%~1"
echo [INFO] Saving to: "%~3"
echo -----------------------------------------------------

rem 使用 PowerShell 的 Invoke-WebRequest 下载文件，附带 GitHub Token（如果存在）
rem Use PowerShell's Invoke-WebRequest to fetch file list with GitHub Token if it exists
set "auth_header="
if defined github_token (
    set "auth_header=-Headers @{Authorization='token %github_token%'}"
)

rem 输出请求链接（不包括 auth_header）
rem Output the request URL (excluding auth_header)
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