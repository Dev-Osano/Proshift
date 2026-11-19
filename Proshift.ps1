$user = $Env:username1
$docs = $Env:documents
$desk = $Env:desktop
$pics = $Env:pictures
$dls = $Env:downloads
$browse = $Env:browsers
$vids = $env:videos
$email = $env:outlook
$cust = $Env:custom
$daysBack = $Env:age
$printers = $env:printers
$quickaccess = $env:quickaccess
if ($printers -eq $all)
{
$nobin = "-NOBIN"
}
elseif ($printers -eq "Yes")
{
$nobin = ""
}
#calculate maxage and store it in a string
if ($daysBack) {
    $maxAgeDate = (Get-Date).AddDays(-[int]$daysBack).ToString("yyyyMMdd")
    $maxAgeParam = "/MAXAGE:$maxAgeDate"
} else {
    $maxAgeParam = ""
}
#Install USMT and then run it, placing it in C:\SNS
$adkurl = "https://go.microsoft.com/fwlink/?linkid=2289980"
$destination = "C:\SNS\adksetup.exe"
$7zipurl = "https://www.7-zip.org/a/7z2501-x64.exe"
$destination2 = "C:\SNS\7zip.exe"
#create working directory
New-Item -ItemType Directory -path "C:\SNS" -Force | Out-Null
New-Item -ItemType Directory -path "C:\SNS\User" -Force | Out-Null
$migwin = @"
<?xml version="1.0" encoding="UTF-8"?>
<migration urlid="http://www.microsoft.com/migration/1.0/migxmlext/migwin">

  <component type="System" context="User">
    <displayName>CustomWindowsSettings</displayName>
    <role role="Settings">
      <rules context="User">

        <!-- ===================================================== -->
        <!-- 1. WALLPAPER & THEME                                   -->
        <!-- ===================================================== -->
        <include>
          <objectSet>
            <!-- Desktop background, colors, lock screen -->
            <pattern type="Registry">HKCU\Control Panel\Desktop\*</pattern>
            <pattern type="Registry">HKCU\Control Panel\Colors\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\DWM\*</pattern>
            <!-- Theme and wallpaper files - FIXED: Added recurse="false" -->
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\Windows\Themes [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows\Themes [*]</pattern>
          </objectSet>
        </include>

        <!-- ===================================================== -->
        <!-- 2. DESKTOP LAYOUT (Icons & Shortcuts)                 -->
        <!-- ===================================================== -->
        <include>
          <objectSet>
            <!-- Desktop icon positions and layout -->
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\Shell\Bags\1\Desktop\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop\*</pattern>
            <!-- Desktop shortcuts and files - FIXED: Made more specific -->
            <pattern type="File">%CSIDL_DESKTOP% [*]</pattern>
          </objectSet>
        </include>

        <!-- ===================================================== -->
        <!-- 3. MAPPED NETWORK DRIVES & SHARES                      -->
        <!-- ===================================================== -->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Network\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU\*</pattern>
          </objectSet>
        </include>

        <!-- ===================================================== -->
        <!-- 4. TASKBAR & START MENU LAYOUT                         -->
        <!-- ===================================================== -->
        <include>
          <objectSet>
            <!-- Taskbar settings and pinned items -->
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Search\*</pattern>
            <!-- Start Menu layout (Win 10) -->
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Start\*</pattern>
            <!-- Pinned items - FIXED: Made more specific -->
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu [*]</pattern>
          </objectSet>
        </include>

        <!-- ===================================================== -->
        <!-- 5. OTHER ESSENTIAL USER SETTINGS                       -->
        <!-- ===================================================== -->
        <include>
          <objectSet>
            <!-- Mouse, keyboard, accessibility -->
            <pattern type="Registry">HKCU\Control Panel\Mouse\*</pattern>
            <pattern type="Registry">HKCU\Control Panel\Keyboard\*</pattern>
            <pattern type="Registry">HKCU\Control Panel\Accessibility\*</pattern>
            
            <!-- Sound scheme -->
            <pattern type="Registry">HKCU\AppEvents\Schemes\*</pattern>
            
            <!-- Time zone and regional settings -->
            <pattern type="Registry">HKCU\Control Panel\International\*</pattern>
            <pattern type="Registry">HKCU\Control Panel\TimeDate\*</pattern>
            
            <!-- File Explorer settings (folder views, etc) -->
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\Shell\Bags\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\Shell\BagMRU\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\ShellNoRoam\Bags\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\ShellNoRoam\BagMRU\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\*</pattern>
            
            <!-- Screen saver -->
            <pattern type="Registry">HKCU\Control Panel\ScreenSaver\*</pattern>
            
            <!-- Notification settings -->
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\*</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications\*</pattern>
          </objectSet>
        </include>

      </rules>
    </role>
  </component>

</migration>
"@
Set-Content -Path "C:\SNS\migwin.xml" -Value $migwin
Set-Content -Path "C:\SNS\username.txt" -Value $user
#store custom location in txt only if custom is used
if ($cust -ne "")
{
Set-Content -Path "C:\SNS\custom.txt" -Value $cust
}
#download adk
Invoke-WebRequest -uri $adkurl -OutFile $destination
#install USMT
Start-Process -FilePath "C:\SNS\adksetup.exe" -ArgumentList "/quiet /features OptionId.UserStateMigrationTool /norestart" -Wait
# Switch directory
cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\User State Migration Tool\amd64"

# *** RUN SCANSTATE 
.\ScanState.exe "C:\SNS\USMT" /i:C:\SNS\migwin.xml /ue:* /ui:"$user" /o /c /v:13 /l:C:\SNS\USMT\ScanState.log

#download 7zip for compression over 4gb
Invoke-WebRequest $7zipurl -OutFile $destination2
#install 7zip
Start-Process -FilePath "C:\SNS\7zip.exe" -ArgumentList "/S" -Wait
#move xml into folder with usmt.mig
Move-Item -Path "C:\SNS\migwin.xml" -Destination "C:\SNS\USMT\USMT"
Move-Item -Path "C:\SNS\username.txt" -Destination "C:\SNS\USMT\USMT"
if ($printers -eq "Yes" -or $printers -eq "all")
{
cd "C:\Windows\System32\spool\tools"
New-Item -ItemType Directory -path "C:\SNS\User\Printers" -Force | Out-Null
.\PrintBrm.exe -b -f "C:\SNS\User\Printers\backup.printerExport" $nobin
}
if ($cust -ne "")
{
Move-Item -Path "C:\SNS\custom.txt" -Destination "C:\SNS\USMT\USMT"
}
#get user's folders
if ($docs -eq $true)
{
robocopy "C:\users\$user\documents" "C:\SNS\User\Documents" /R:4 /W:4 /E /XJ $maxAgeParam
}
if ($desk -eq $true)
{
robocopy "C:\users\$user\desktop" "C:\SNS\User\Desktop" /R:4 /W:4 /E /XJ
}
if ($pics -eq $true)
{
robocopy "C:\users\$user\pictures" "C:\SNS\User\Pictures" /R:4 /W:4 /E /XJ
}
if ($dls -eq $true)
{
robocopy "C:\users\$user\downloads" "C:\SNS\User\Downloads" /R:4 /W:4 /E /XJ $maxAgeParam
}
if ($vids -eq $true)
{
robocopy "C:\users\$user\Videos" "C:\SNS\User\Videos" /R:4 /W:4 /E /XJ
}
if ($browse -eq $true)
{
robocopy "C:\users\$user\AppData\Local\Google" "C:\SNS\User\Chrome" /R:4 /W:4 /E
robocopy "C:\users\$user\AppData\Local\Microsoft\Edge" "C:\SNS\User\Edge" /R:4 /W:4 /E
robocopy "C:\users\$user\AppData\Local\BraveSoftware" "C:\SNS\User\Brave" /R:4 /W:4 /E
}
if ($email -eq $true)
{
robocopy "C:\users\$user\AppData\Local\Microsoft\Outlook" "C:\SNS\User\Outlook" /R:4 /W:4 /E
}
if ($cust -eq $true)
{
robocopy "$cust" "C:\SNS\User\Custom" /R:4 /W:4 /E
}
if ($quickaccess)
{
        robocopy "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" "C:\SNS\User\AutomaticDestinations" /R:4 /W:4 /E /NP | Out-Null
        robocopy "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations" "C:\SNS\User\CustomDestinations" /R:4 /W:4 /E /NP | Out-Null
}
Move-Item -Path "C:\SNS\User" -Destination "C:\SNS\USMT\USMT"
#compress USMT
cd "C:\Program Files\7-Zip"
.\7z.exe a -mx=9 -sdel "C:\SNS\$user.7z" "C:\SNS\USMT\*"
#remove uncompressed mig
start-sleep -seconds 60
Remove-Item -Path "C:\SNS\USMT" -Recurse -Force
Remove-Item -Path "C:\SNS\7zip.exe" -Force
Remove-Item -Path "C:\SNS\adksetup.exe" -Force
