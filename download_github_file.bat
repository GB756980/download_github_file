@echo off
setlocal enabledelayedexpansion

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

rem 设置 GitHub 的基础 URL
rem Set the base URL for GitHub
set github_raw_base_url=https://raw.githubusercontent.com
set github_base_url=https://api.github.com/repos

rem 读取配置文件并处理每一行，跳过注释行和空行
rem Read the configuration file and process each line, skipping comment and empty lines
for /f "usebackq tokens=1-4 delims=, eol=#" %%a in ("%config_file%") do (
    set "repository=%%a"
    set "folder_to_download=%%b"
    set "file_to_download=%%c"
    set "local_download_path=%%d"

    rem 替换路径中的环境变量
    rem Replace environment variables in the path
    call set "local_download_path=!local_download_path!"

    rem 确保本地保存路径存在，如果不存在则创建
    rem Ensure the local save path exists, create it if it doesn't
    if not exist "!local_download_path!" (
        mkdir "!local_download_path!"
        echo [INFO] Directory created: "!local_download_path!"
    )

    rem 检查文件夹或文件下载
    rem Check for folder or file download
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

rem 函数：下载文件
rem Function: Download a file
:DownloadFile
rem 参数：%1 = repository, %2 = file_to_download, %3 = local_download_path
rem Arguments: %1 = repository, %2 = file_to_download, %3 = local_download_path
set "file_url=%github_raw_base_url%/%~1/main/%~2"
echo =====================================================
echo [INFO] Downloading file "%~2" from "%~1"
echo [INFO] Download URL: "%file_url%"
echo [INFO] Saving to: "%~3"
echo -----------------------------------------------------
rem 使用 PowerShell 的 Invoke-WebRequest 下载文件
rem Use PowerShell's Invoke-WebRequest to download the file
powershell -command "Invoke-WebRequest -Uri '%file_url%' -OutFile '%~3\%~nx2'"
if !errorlevel! neq 0 (
    echo [ERROR] File download failed: "%~2" from "%~1"
) else (
    echo [SUCCESS] File downloaded: "%~2" from "%~1"
    rem 如果下载的文件是 ZIP 文件，则解压
    rem If the downloaded file is a ZIP file, then unzip it
    if "%~x2"==".zip" (
        call :UnzipFile "%~3\%~nx2" "%~3"
    )
)
echo =====================================================
echo.
exit /b 0

rem 函数：下载文件夹
rem Function: Download a folder
:DownloadFolder
rem 参数：%1 = repository, %2 = folder_to_download, %3 = local_download_path
rem Arguments: %1 = repository, %2 = folder_to_download, %3 = local_download_path
set "file_list_url=%github_base_url%/%~1/contents/%~2"
echo =====================================================
echo [INFO] Downloading folder and files under "%~2" from "%~1"
echo -----------------------------------------------------
echo [INFO] Fetching file list: "%file_list_url%"
rem 使用 PowerShell 的 Invoke-RestMethod 获取文件列表并下载文件
rem Use PowerShell's Invoke-RestMethod to get the file list and download files
powershell -command "$files = Invoke-RestMethod -Uri '%file_list_url%'; $files | ForEach-Object { if ($_.type -eq 'file') { $filePath = Join-Path -Path '%~3' -ChildPath $_.name; Invoke-WebRequest -Uri $_.download_url -OutFile $filePath; if ($_.name.EndsWith('.zip')) { Expand-Archive -Path $filePath -DestinationPath '%~3' -Force; Remove-Item -Path $filePath -Force } } }"
if !errorlevel! neq 0 (
    echo [ERROR] Folder download failed: "%~2" from "%~1"
) else (
    echo [SUCCESS] Folder downloaded: "%~2" from "%~1"
)
echo =====================================================
echo.
exit /b 0

rem 函数：解压文件
rem Function: Unzip a file
:UnzipFile
rem 参数：%1 = zip_file_path, %2 = destination_path
rem Arguments: %1 = zip_file_path, %2 = destination_path
echo [INFO] Unzipping file "%~1"
rem 使用 PowerShell 的 Expand-Archive 解压文件
rem Use PowerShell's Expand-Archive to unzip the file
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