###############################################################################################
# Copyright (C) 2024  Griefed
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA
#
# The full license can be found at https:github.com/Griefed/ServerPackCreator/blob/main/LICENSE
###############################################################################################
#
# Start script generated by ServerPackCreator SPC_SERVERPACKCREATOR_VERSION_SPC.
# The template which was used in the generation of this script can be found at:
#   https://github.com/Griefed/ServerPackCreator/blob/SPC_SERVERPACKCREATOR_VERSION_SPC/serverpackcreator-api/src/main/resources/de/griefed/resources/server_files/default_template.ps1
#
# By default, running Powershell scripts from untrusted sources is probably disabled on your system.
# As such, you will not be able to run the start.ps-scripts just yet. You need to allow running
# unsigned scripts first. See https://superuser.com/a/106363 for a short explanation on how to
# enable/allow running unsigned scripts with Powershell.
#   You may run `start-process PowerShell -verb runas "Set-ExecutionPolicy RemoteSigned"` from a regular
#   PowerShell to allow running of the start-script.
#   ATTENTION:
#       Bear in mind that this introduces a security risk on your system. After making the changes from the
#       link above, you can run any Powershell script you like, and as such, introduce any and all security
#       risk into your system. So, beware when running scripts from unknown sources.
#
# Powershell scripts by default can not be opened with a double-click if the path to said script
# contains spaces. If you wish to remedy this or want to read more about this behaviour, this article
# talks about it in great detail: https://blog.danskingdom.com/fix-problem-where-windows-powershell-cannot-run-script-whose-path-contains-spaces/
# You can thank Mircosoft for this. There is nothing the developers of ServerPackCreator can do about that.
# What you should do instead is:
#   In your explorer, browse into the directory which contains your server pack.
#   Shift-Rightclick into an empty space inside the directory
#   Click "Open PowerShell window here"
#   Type ".\start.ps1", without the "", and hit enter
#
#   ATTENTION:
#       Keep in mind though that things may still break when working with paths with spaces in them. If
#       things still break with a path with spaces, even after trying the fixes from the link above, then I
#       suggest moving things to a folder whose path contains no spaces.
#
# Depending on which modloader is set, different checks are run to ensure the server will start accordingly.
# If the modloader checks and setup are passed, Minecraft and EULA checks are run.
# If everything is in order, the server is started.
#
# Depending on the Minecraft version you will require a different Java version to run the server.
#   1.16.5 and older requires Java 8 (Java 11 will run better and work with 99% of mods, give it a try)
#     You may acquire a Java 8 install here: https://adoptium.net/temurin/releases/?variant=openjdk8&version=8&package=jdk&arch=x64&os=windows
#     You may acquire a java 11 install here: https://adoptium.net/temurin/releases/?variant=openjdk11&version=11&package=jdk&arch=x64&os=windows
#   1.18.2 and newer requires Java 17 (Java 18 will run better and work with 99% of mods, give it a try)
#     You may acquire a Java 17 install here: https://adoptium.net/temurin/releases/?variant=openjdk17&version=17&package=jdk&arch=x64&os=windows
#     You may acquire a Java 18 install here: https://adoptium.net/temurin/releases/?variant=openjdk18&version=18&package=jdk&arch=x64&os=windows
#   1.20.5 and newer require Java 21
#     You may acquire a Java 21 install here: https://adoptium.net/temurin/releases/?variant=openjdk21&version=21&package=jdk&arch=x64&os=windows
$BaseDir = Split-Path -parent $script:MyInvocation.MyCommand.Path
Push-Location $BaseDir

if ( (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Warning! Running with administrator-privileges is not recommended."
}

Write-Host "Start script generated by ServerPackCreator SPC_SERVERPACKCREATOR_VERSION_SPC."
Write-Host "To change the launch settings of this server, such as JVM args / flags, Minecraft version, modloader version etc., edit the variables.txt-file."

Function PauseScript
{
    Write-Host "Press any key to continue" -ForegroundColor Yellow
    $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown") > $null
}

Function CrashServer
{
    param ($Message)
    Write-Host "${Message}"
    PauseScript
    exit 1
}

$ExternalVariablesFile = -join ("${BaseDir}", "\variables.txt");

if (!(Test-Path -Path $ExternalVariablesFile -PathType Leaf))
{
    CrashServer "ERROR! variables.txt not present. Without it the server can not be installed, configured or started."
}

$ExternalVariables = Get-Content -raw -LiteralPath $ExternalVariablesFile | ConvertFrom-StringData
$MinecraftVersion = $ExternalVariables['MINECRAFT_VERSION']
$ModLoader = $ExternalVariables['MODLOADER']
$ModLoaderVersion = $ExternalVariables['MODLOADER_VERSION']
$LegacyFabricInstallerVersion = $ExternalVariables['LEGACYFABRIC_INSTALLER_VERSION']
$FabricInstallerVersion = $ExternalVariables['FABRIC_INSTALLER_VERSION']
$QuiltInstallerVersion = $ExternalVariables['QUILT_INSTALLER_VERSION']
$MinecraftServerUrl = $ExternalVariables['MINECRAFT_SERVER_URL']
$NeoForgeInstallerUrl = $ExternalVariables['NEOFORGE_INSTALLER_URL']
$JavaArgs = $ExternalVariables['JAVA_ARGS']
$Java = $ExternalVariables['JAVA']
$WaitForUserInput = $ExternalVariables['WAIT_FOR_USER_INPUT']
$AdditionalArgs = $ExternalVariables['ADDITIONAL_ARGS']
$Restart = $ExternalVariables['RESTART']
$SkipJavaCheck = $ExternalVariables['SKIP_JAVA_CHECK']
$RecommendedJavaVersion = $ExternalVariables['RECOMMENDED_JAVA_VERSION']

if ($Java[0] -eq '"')
{
    $Java = $Java.Substring(1, $Java.Length - 1)
}
if ($Java[$Java.Length - 1] -eq '"')
{
    $Java = $Java.Substring(0, $Java.Length - 1)
}

if ($JavaArgs[0] -eq '"')
{
    $JavaArgs = $JavaArgs.Substring(1, $JavaArgs.Length - 1)
}
if ($JavaArgs[$JavaArgs.Length - 1] -eq '"')
{
    $JavaArgs = $JavaArgs.Substring(0, $JavaArgs.Length - 1)
}

$MinecraftServerJarLocation = "do_not_manually_edit"
$LauncherJarLocation = "do_not_manually_edit"
$ServerRunCommand = "do_not_manually_edit"
$JavaVersion = "do_not_manually_edit"
$Semantics = ${MinecraftVersion}.Split(".")

Function CommandAvailable($cmdname)
{
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Function GetJavaVersion()
{
    $JavaFullversion = CMD /C "`"${Java}`" -fullversion 2>&1"
    $JavaFullversion = $JavaFullversion.Substring($JavaFullversion.IndexOf('"')+1).TrimEnd('"').Split('.')
    $script:JavaVersion = $JavaFullversion[0]

    if ([int]$JavaFullversion[0] -eq 1)
    {
        $script:JavaVersion = $JavaFullversion[1]
    }
}

Function InstallJava()
{
    Write-Host "No suitable Java installation was found on your system. Proceeding to Java installation."
    . .\install_java.ps1
    RunJavaInstallation
    if (!(CommandAvailable -cmdname "${Java}"))
    {
        CrashServer "Java installation failed. Couldn't find ${Java}."
    }
}

if ("${SkipJavaCheck}" -eq "true")
{
    "Skipping Java version check."
}
else
{
    if ("${Java}" -eq "java")
    {
        if (!(CommandAvailable -cmdname "${Java}"))
        {
            InstallJava
        }
        else
        {
            GetJavaVersion
            if ([int]$script:JavaVersion -le [int]$RecommendedJavaVersion)
            {
                InstallJava
            }
        }
    }
    else
    {
        GetJavaVersion
        Write-Host "Detected $($Semantics[0]).$($Semantics[1]).$($Semantics[2]) - Java $($JavaVersion)"
        if ([int]$script:JavaVersion -le [int]$RecommendedJavaVersion)
        {
            $script:Java = "java"
            InstallJava
        }
    }
}

Function DeleteFileSilently
{
    param ($FileToDelete)
    $ErrorActionPreference = "SilentlyContinue";
    if ((Get-Item "${FileToDelete}").PSIsContainer)
    {
        Remove-Item "${FileToDelete}" -Recurse
    }
    else
    {
        Remove-Item "${FileToDelete}"
    }
    $ErrorActionPreference = "Continue";
}

Function QuitServer
{
    Write-Host "Exiting..."
    if ("${WaitForUserInput}" -eq "true")
    {
        PauseScript
    }
    exit 0
}

Function global:RunJavaCommand
{
    param ($CommandToRun)
    CMD /C "`"${Java}`" ${CommandToRun}"
}

Function global:CheckJavaBitness
{
    $Bit = CMD /C "`"${Java}`" -version 2>&1"
    if (( ${Bit} | Select-String "32-Bit").Length -gt 0)
    {
        Write-Host "WARNING! 32-Bit Java detected! It is highly recommended to use a 64-Bit version of Java!"
    }
}

Function DownloadIfNotExists
{
    param ($FileToCheck, $FileToDownload, $DownloadURL)
    if (!(Test-Path -Path $FileToCheck -PathType Leaf))
    {
        Write-Host "${FileToCheck} could not be found."
        Write-Host "Downloading ${FileToDownload}"
        Write-Host "from ${DownloadURL}"
        Invoke-WebRequest -URI "${DownloadURL}" -OutFile "${FileToDownload}"
        if (Test-Path -Path "${FileToDownload}" -PathType Leaf)
        {
            Write-Host "Download complete."
            return $true
        }
        else
        {
            return $false
        }
    }
    else
    {
        Write-Host "${FileToCheck} present."
        return $false
    }
}

Function global:SetupForge
{
    ""
    "Running Forge checks and setup..."
    $ForgeInstallerUrl = "https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MinecraftVersion}-${ModLoaderVersion}/forge-${MinecraftVersion}-${ModLoaderVersion}-installer.jar"
    $ForgeJarLocation = "do_not_manually_edit"
    if ([int]$Semantics[1] -le 16)
    {
        $ForgeJarLocation = "forge.jar"
        $script:LauncherJarLocation = "forge.jar"
        $script:MinecraftServerJarLocation = "minecraft_server.${MinecraftVersion}.jar"
        $script:ServerRunCommand = "${JavaArgs} -jar ${LauncherJarLocation} nogui"
    }
    else
    {
        $ForgeJarLocation = "libraries/net/minecraftforge/forge/${MinecraftVersion}-${ModLoaderVersion}/forge-${MinecraftVersion}-${ModLoaderVersion}-server.jar"
        $script:MinecraftServerJarLocation = "libraries/net/minecraft/server/${MinecraftVersion}/server-${MinecraftVersion}.jar"
        $script:ServerRunCommand = "@user_jvm_args.txt @libraries/net/minecraftforge/forge/${MinecraftVersion}-${ModLoaderVersion}/win_args.txt nogui"
        Write-Host "Generating user_jvm_args.txt from variables..."
        Write-Host "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
        Write-Host "Manually made changes to user_jvm_args.txt will be lost in the nether!"
        DeleteFileSilently  'user_jvm_args.txt'
        "# Xmx and Xms set the maximum and minimum RAM usage, respectively.`n" +
                "# They can take any number, followed by an M or a G.`n" +
                "# M means Megabyte, G means Gigabyte.`n" +
                "# For example, to set the maximum to 3GB: -Xmx3G`n" +
                "# To set the minimum to 2.5GB: -Xms2500M`n" +
                "# A good default for a modded server is 4GB.`n" +
                "# Uncomment the next line to set it.`n" +
                "# -Xmx4G`n" +
                "${script:JavaArgs}" | Out-File user_jvm_args.txt -encoding utf8
    }
    if ((DownloadIfNotExists "${ForgeJarLocation}" "forge-installer.jar" "${ForgeInstallerUrl}"))
    {
        "Forge Installer downloaded. Installing..."
        RunJavaCommand "-jar forge-installer.jar --installServer"
        if ([int]$Semantics[1] -gt 16)
        {
            DeleteFileSilently  'run.bat'
            DeleteFileSilently  'run.sh'
        }
        else
        {
            "Renaming forge-${MinecraftVersion}-${ModLoaderVersion}.jar to forge.jar"
            Move-Item "forge-${MinecraftVersion}-${ModLoaderVersion}.jar" 'forge.jar'
            Move-Item "forge-${MinecraftVersion}-${ModLoaderVersion}-universal.jar" 'forge.jar'
        }
        if ((Test-Path -Path "${ForgeJarLocation}" -PathType Leaf))
        {
            DeleteFileSilently  'forge-installer.jar'
            "Installation complete. forge-installer.jar deleted."
        }
        else
        {
            DeleteFileSilently  'forge-installer.jar'
            CrashServer "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
        }
    }
}

# If modloader = NeoForge, run NeoForge-specific checks
Function global:SetupNeoForge
{
    ""
    "Running NeoForge checks and setup..."
    $ForgeJarLocation = "do_not_manually_edit"
    $JarFolder = "do_not_manually_edit"
    if ([int]$Semantics[1] -eq 20 -And [int]$Semantics[2] -gt 1)
    {
        $JarFolder = "libraries/net/neoforged/neoforge/${ModLoaderVersion}"
        $ForgeJarLocation = "${JarFolder}/neoforge-${ModLoaderVersion}-server.jar"
    }
    else
    {
        $JarFolder = "libraries/net/neoforged/forge/${MinecraftVersion}-${ModLoaderVersion}"
        $ForgeJarLocation = "${JarFolder}/forge-${MinecraftVersion}-${ModLoaderVersion}-server.jar"
    }
    $script:MinecraftServerJarLocation = "libraries/net/minecraft/server/${MinecraftVersion}/server-${MinecraftVersion}.jar"
    $script:ServerRunCommand = "@user_jvm_args.txt @${JarFolder}/win_args.txt nogui"
    Write-Host "Generating user_jvm_args.txt from variables..."
    Write-Host "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
    Write-Host "Manually made changes to user_jvm_args.txt will be lost in the nether!"
    DeleteFileSilently  'user_jvm_args.txt'
    "# Xmx and Xms set the maximum and minimum RAM usage, respectively.`n" +
            "# They can take any number, followed by an M or a G.`n" +
            "# M means Megabyte, G means Gigabyte.`n" +
            "# For example, to set the maximum to 3GB: -Xmx3G`n" +
            "# To set the minimum to 2.5GB: -Xms2500M`n" +
            "# A good default for a modded server is 4GB.`n" +
            "# Uncomment the next line to set it.`n" +
            "# -Xmx4G`n" +
            "${script:JavaArgs}" | Out-File user_jvm_args.txt -encoding utf8
    if ((DownloadIfNotExists "${ForgeJarLocation}" "neoforge-installer.jar" "${NeoForgeInstallerUrl}"))
    {
        "NeoForge Installer downloaded. Installing..."
        RunJavaCommand "-jar neoforge-installer.jar --installServer"
        "Renaming forge-${MinecraftVersion}-${ModLoaderVersion}.jar to forge.jar"
        Move-Item "forge-${MinecraftVersion}-${ModLoaderVersion}.jar" 'forge.jar'
        if ((Test-Path -Path "${ForgeJarLocation}" -PathType Leaf))
        {
            DeleteFileSilently  'neoforge-installer.jar'
            "Installation complete. forge-installer.jar deleted."
        }
        else
        {
            DeleteFileSilently  'neoforge-installer.jar'
            CrashServer "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
        }
    }
}

Function global:SetupFabric
{
    ""
    "Running Fabric checks and setup..."
    $FabricInstallerUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FabricInstallerVersion}/fabric-installer-${FabricInstallerVersion}.jar"
    $ImprovedFabricLauncherUrl = "https://meta.fabricmc.net/v2/versions/loader/${MinecraftVersion}/${ModLoaderVersion}/${FabricInstallerVersion}/server/jar"
    $ErrorActionPreference = "SilentlyContinue";
    $script:ImprovedFabricLauncherAvailable = [int][System.Net.WebRequest]::Create("${ImprovedFabricLauncherUrl}").GetResponse().StatusCode
    $ErrorActionPreference = "Continue";
    if ("${ImprovedFabricLauncherAvailable}" -eq "200")
    {
        "Improved Fabric Server Launcher available..."
        "The improved launcher will be used to run this Fabric server."
        $script:LauncherJarLocation = "fabric-server-launcher.jar"
        (DownloadIfNotExists "${script:LauncherJarLocation}" "${script:LauncherJarLocation}" "${ImprovedFabricLauncherUrl}") > $null
    }
    else
    {
        try
        {
            $ErrorActionPreference = "SilentlyContinue";
            $FabricAvailable = [int][System.Net.WebRequest]::Create("https://meta.fabricmc.net/v2/versions/loader/${MinecraftVersion}/${ModLoaderVersion}/server/json").GetResponse().StatusCode
            $ErrorActionPreference = "Continue";
        }
        catch
        {
            $FabricAvailable = "400"
        }
        if ("${FabricAvailable}" -ne "200")
        {
            CrashServer "Fabric is not available for Minecraft ${MinecraftVersion}, Fabric ${ModLoaderVersion}."
        }
        if ((DownloadIfNotExists "fabric-server-launch.jar" "fabric-installer.jar" "${FabricInstallerUrl}"))
        {
            "Installer downloaded..."
            $script:LauncherJarLocation = "fabric-server-launch.jar"
            $script:MinecraftServerJarLocation = "server.jar"
            RunJavaCommand "-jar fabric-installer.jar server -mcversion ${MinecraftVersion} -loader ${ModLoaderVersion} -downloadMinecraft"
            if ((Test-Path -Path 'fabric-server-launch.jar' -PathType Leaf))
            {
                DeleteFileSilently '.fabric-installer' -Recurse
                DeleteFileSilently 'fabric-installer.jar'
                "Installation complete. fabric-installer.jar deleted."
            }
            else
            {
                DeleteFileSilently  'fabric-installer.jar'
                CrashServer "fabric-server-launch.jar not found. Maybe the Fabric servers are having trouble. Please try again in a couple of minutes and check your internet connection."
            }
        }
        else
        {
            $script:LauncherJarLocation = "fabric-server-launcher.jar"
            $script:MinecraftServerJarLocation = "server.jar"
        }
    }
    $script:ServerRunCommand = "${script:JavaArgs} -jar ${script:LauncherJarLocation} nogui"
}

Function global:SetupQuilt
{
    ""
    "Running Quilt checks and setup..."
    $QuiltInstallerUrl = "https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/${QuiltInstallerVersion}/quilt-installer-${QuiltInstallerVersion}.jar"
    if ((ConvertFrom-JSON (Invoke-WebRequest -Uri "https://meta.fabricmc.net/v2/versions/intermediary/${MinecraftVersion}")).Length -eq 0)
    {
        CrashServer "Quilt is not available for Minecraft ${MinecraftVersion}, Quilt ${ModLoaderVersion}."
    }
    elseif ((DownloadIfNotExists "quilt-server-launch.jar" "quilt-installer.jar" "${QuiltInstallerUrl}"))
    {
        "Installer downloaded. Installing..."
        RunJavaCommand "-jar quilt-installer.jar install server ${MinecraftVersion} --download-server --install-dir=."
        if ((Test-Path -Path 'quilt-server-launch.jar' -PathType Leaf))
        {
            DeleteFileSilently 'quilt-installer.jar'
            "Installation complete. quilt-installer.jar deleted."
        }
        else
        {
            DeleteFileSilently 'quilt-installer.jar'
            CrashServer "quilt-server-launch.jar not found. Maybe the Quilt servers are having trouble. Please try again in a couple of minutes and check your internet connection."
        }
    }
    $script:LauncherJarLocation = "quilt-server-launch.jar"
    $script:MinecraftServerJarLocation = "server.jar"
    $script:ServerRunCommand = "${JavaArgs} -jar ${LauncherJarLocation} nogui"
}

Function global:SetupLegacyFabric
{
    ""
    "Running LegacyFabric checks and setup..."
    $LegacyFabricInstallerUrl = "https://maven.legacyfabric.net/net/legacyfabric/fabric-installer/${LegacyFabricInstallerVersion}/fabric-installer-${LegacyFabricInstallerVersion}.jar"
    if ((ConvertFrom-JSON (Invoke-WebRequest -Uri "https://meta.legacyfabric.net/v2/versions/loader/${MinecraftVersion}")).Length -eq 0)
    {
        CrashServer "LegacyFabric is not available for Minecraft ${MinecraftVersion}, LegacyFabric ${ModLoaderVersion}."
    }
    elseif ((DownloadIfNotExists "fabric-server-launch.jar" "legacyfabric-installer.jar" "${LegacyFabricInstallerUrl}"))
    {
        "Installer downloaded. Installing..."
        RunJavaCommand "-jar legacyfabric-installer.jar server -mcversion ${MinecraftVersion} -loader ${ModLoaderVersion} -downloadMinecraft"
        if ((Test-Path -Path 'fabric-server-launch.jar' -PathType Leaf))
        {
            DeleteFileSilently 'legacyfabric-installer.jar'
            "Installation complete. legacyfabric-installer.jar deleted."
        }
        else
        {
            DeleteFileSilently 'legacyfabric-installer.jar'
            CrashServer "fabric-server-launch.jar not found. Maybe the LegacyFabric servers are having trouble. Please try again in a couple of minutes and check your internet connection."
        }
    }
    $script:LauncherJarLocation = "fabric-server-launch.jar"
    $script:MinecraftServerJarLocation = "server.jar"
    $script:ServerRunCommand = "${JavaArgs} -jar ${LauncherJarLocation} nogui"
}

Function global:Minecraft
{
    if (($ModLoader -eq "Fabric") -and (${ImprovedFabricLauncherAvailable} -eq "200"))
    {
        "Skipping Minecraft Server JAR checks because we are using the improved Fabric Server Launcher."
    }
    else
    {
        (DownloadIfNotExists "${MinecraftServerJarLocation}" "${MinecraftServerJarLocation}" "${MinecraftServerUrl}") > $null
    }
}

Function Eula
{
    if (!(Test-Path -Path 'eula.txt' -PathType Leaf))
    {
        "Mojang's EULA has not yet been accepted. In order to run a Minecraft server, you must accept Mojang's EULA."
        "Mojang's EULA is available to read at https://aka.ms/MinecraftEULA"
        "If you agree to Mojang's EULA then type 'I agree'"
        $Answer = Read-Host -Prompt 'Answer'
        if (${Answer} -eq "I agree")
        {
            "User agreed to Mojang's EULA."
            "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).`n" +
                    "eula=true" | Out-File eula.txt -encoding utf8
        }
        else
        {
            CrashServer "User did not agree to Mojang's EULA. Entered: ${Answer}. You can not run a Minecraft server unless you agree to Mojang's EULA."
        }
    }
}

if ( ${BaseDir}.Contains(" "))
{
    "WARNING! The current location of this script contains spaces. This may cause this server to crash!"
    "It is strongly recommended to move this server pack to a location whose path does NOT contain SPACES!"
    "Current path: ${BaseDir}"
    $WhyMustPowerShellBeThisWayLikeSeriouslyWhatTheFrag = Read-Host -Prompt 'Are you sure you want to continue? (Yes/No): '
    if (${WhyMustPowerShellBeThisWayLikeSeriouslyWhatTheFrag} -eq "Yes")
    {
        "Alrighty. Prepare for unforseen consequences, Mr. Freeman..."
    }
    else
    {
        CrashServer "User did not desire to run the server in a directory with spaces in its path."
    }
}

switch (${ModLoader})
{
    Forge
    {
        SetupForge
    }
    NeoForge
    {
        SetupNeoForge
    }
    Fabric
    {
        SetupFabric
    }
    Quilt
    {
        SetupQuilt
    }
    LegacyFabric
    {
        SetupLegacyFabric
    }
    default
    {
        CrashServer "Incorrect modloader specified: ${ModLoader}"
    }
}

CheckJavaBitness
Minecraft
Eula

""
"Starting server..."
"Minecraft version:              ${MinecraftVersion}"
"Modloader:                      ${ModLoader}"
"Modloader version:              ${ModLoaderVersion}"
"LegacyFabric Installer Version: ${LegacyFabricInstallerVersion}"
"Fabric Installer Version:       ${FabricInstallerVersion}"
"Quilt Installer Version:        ${QuiltInstallerVersion}"
"NeoForge Installer URL:         ${NeoForgeInstallerUrl}"
"Minecraft Server URL:           ${MinecraftServerUrl}"
"Java Args:                      ${JavaArgs}"
"Additional Args:                ${AdditionalArgs}"
"Java Path:                      ${Java}"
"Wait For User Input:            ${WaitForUserInput}"
if (!("${LauncherJarLocation}" -eq "do_not_manually_edit"))
{
    "Launcher JAR:                   ${LauncherJarLocation}"
}
"Run Command:       ${Java} ${AdditionalArgs} ${ServerRunCommand}"
"Java version:"
RunJavaCommand "-version"
""

while ($true)
{
    RunJavaCommand "${AdditionalArgs} ${ServerRunCommand}"
    if ("${SkipJavaCheck}" -eq "true")
    {
        "Java version check was skipped. Did the server stop or crash because of a Java version mismatch?"
        "Detected $($Semantics[0]).$($Semantics[1]).$($Semantics[2]) - Java $($JavaVersion), recommended $($RecommendedJavaVersion)"
    }
    if (!("${Restart}" -eq "true"))
    {
        QuitServer
    }
    "Automatically restarting server in 5 seconds. Press CTRL + C to abort and exit."
    Start-Sleep -Seconds 5
}

""