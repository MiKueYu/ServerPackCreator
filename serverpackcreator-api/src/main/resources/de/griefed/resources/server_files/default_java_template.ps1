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
# Java Install script generated by ServerPackCreator SPC_SERVERPACKCREATOR_VERSION_SPC.
# The template which was used in the generation of this script can be found at:
#   https://github.com/Griefed/ServerPackCreator/blob/SPC_SERVERPACKCREATOR_VERSION_SPC/serverpackcreator-api/src/main/resources/de/griefed/resources/server_files/default_java_template.ps1
#
# By default, running Powershell scripts from untrusted sources is probably disabled on your system.
# As such, you will not be able to run the install_java.ps-scripts just yet. You need to allow running
# unsigned scripts first. See https://superuser.com/a/106363 for a short explanation on how to
# enable/allow running unsigned scripts with Powershell.
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
#   Type ".\install_java.ps1", without the "", and hit enter
#
#   ATTENTION:
#       Keep in mind though that things may still break when working with paths with spaces in them. If
#       things still break with a path with spaces, even after trying the fixes from the link above, then I
#       suggest moving things to a folder whose path contains no spaces.
#
# Depending on which Minecraft version is used in this server pack, a different Java version may be installed.
#
# ATTENTION:
#   This script will NOT modify the JAVA_HOME variable for your user.

$ExternalVariablesFile = -join ("${BaseDir}", "\variables.txt");

if (!(Test-Path -Path $ExternalVariablesFile -PathType Leaf))
{
    "ERROR! variables.txt not present. Without it the server can not be installed, configured or started."
    exit 1
}

$ExternalVariables = Get-Content -raw -LiteralPath $ExternalVariablesFile | ConvertFrom-StringData
$RecommendedJavaVersion = $ExternalVariables['RECOMMENDED_JAVA_VERSION']
$JabbaInstallURL = $ExternalVariables['JABBA_INSTALL_URL_PS']
$JDKVendor = $ExternalVariables['JDK_VENDOR']

Function CommandAvailable($cmdname)
{
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Function InstallJabba()
{
    Write-Host "Downloading and installing jabba."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-Expression (
    Invoke-WebRequest "${script:JabbaInstallURL}" -UseBasicParsing
    ).Content
}

if (!(CommandAvailable -cmdname 'jabba'))
{
    Write-Host "Automated Java installation requires a piece of Software called 'Jabba'."
    Write-Host "Type 'I agree' if you agree to the installation of the aforementioned software."
    $Answer = Read-Host -Prompt 'Response: '
    if (${Answer} -eq "I agree")
    {
        InstallJava
    }
    else
    {
        Write-Host "User did not agree to Jabba installation. Aborting Java installation process."
        exit 1
    }
}

Write-Host "Downloading and using Java ${JDKVendor}@${RecommendedJavaVersion}"
jabba install "${JDKVendor}@${RecommendedJavaVersion}"
jabba use "${JDKVendor}@${RecommendedJavaVersion}"

Write-Host "Installation finished. Returning to start-script."