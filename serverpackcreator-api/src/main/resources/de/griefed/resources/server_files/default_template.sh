#!/usr/bin/env bash
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
#   https://github.com/Griefed/ServerPackCreator/blob/SPC_SERVERPACKCREATOR_VERSION_SPC/serverpackcreator-api/src/jvmMain/resources/de/griefed/resources/server_files/default_template.sh
#
# The Linux scripts are intended to be run using bash (indicated by the `#!/usr/bin/env bash` at the top),
# i.e. by simply calling `./start.sh` or `bash start.sh`.
# Using any other method may work, but can also lead to unexpected behavior.
# Running the Linux scripts on MacOS has been done before, but is not tested by the developers of ServerPackCreator.
# Results may wary, no guarantees.
#
# Depending on which modloader is set, different checks are run to ensure the server will start accordingly.
# If the modloader checks and setup are passed, Minecraft and EULA checks are run.
# If everything is in order, the server is started.
#
# Depending on the Minecraft version you will require a different Java version to run the server.
#   1.16.5 and older requires Java 8 (Java 11 will run better and work with 99% of mods, give it a try)
#     Linux:
#       You may acquire a Java 8 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk8&version=8&package=jre&arch=x64&os=linux
#       You may acquire a java 11 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk11&version=11&package=jre&arch=x64&os=linux
#     macOS:
#       You may acquire a Java 8 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk8&version=8&package=jre&arch=x64&os=mac
#       You may acquire a java 11 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk11&version=11&package=jre&arch=x64&os=mac
#   1.18.2 and newer requires Java 17 (Java 18 will run better and work with 99% of mods, give it a try)
#     Linux:
#       You may acquire a Java 17 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk17&version=17&package=jre&arch=x64&os=linux
#       You may acquire a Java 18 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk18&version=18&package=jre&arch=x64&os=linux
#     macOS:
#       You may acquire a Java 17 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk17&version=17&package=jre&arch=x64&os=mac
#       You may acquire a Java 18 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk18&version=18&package=jre&arch=x64&os=mac

# Glorious StackOverflow to the rescue: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script/246128#246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd "${DIR}" >/dev/null 2>&1 || exit

if [[ "$(id -u)" == "0" ]]; then
  echo "Warning! Running with administrator-privileges is not recommended."
fi

echo "Start script generated by ServerPackCreator SPC_SERVERPACKCREATOR_VERSION_SPC."
echo "To change the launch settings of this server, such as JVM args / flags, Minecraft version, modloader version etc., edit the variables.txt-file."

pause() {
  read -n 1 -s -r -p "Press any key to continue"
}

crashServer() {
  echo "${1}"
  pause
  exit 1
}

if [[ ! -s "variables.txt" ]]; then
  echo "ERROR! variables.txt not present. Without it the server can not be installed, configured or started."
  pause
  exit 1
fi

source "variables.txt"

MINECRAFT_SERVER_JAR_LOCATION="do_not_manually_edit"
LAUNCHER_JAR_LOCATION="do_not_manually_edit"
SERVER_RUN_COMMAND="do_not_manually_edit"

IFS="." read -ra SEMANTICS <<<"${MINECRAFT_VERSION}"

JAVA_VERSION=$("${JAVA}" -fullversion 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [[ "$JAVA_VERSION" -eq 1 ]];then
  JAVA_VERSION=$("${JAVA}" -fullversion 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f2)
fi

echo "Detected ${SEMANTICS[0]}.${SEMANTICS[1]}.${SEMANTICS[2]} - Java ${JAVA_VERSION}"

if [[ "${SKIP_JAVA_CHECK}" == "true" ]]; then
  echo "Skipping Java version check."
else
  if [[ ${SEMANTICS[1]} -le 16 ]];then
    if [[ ! "$JAVA_VERSION" -eq 8 ]] && [[ ! "$JAVA_VERSION" -eq 11 ]]; then
        crashServer "Minecraft 1.16 and older requires Java 8 or 11 - found Java $JAVA_VERSION"
    fi
  elif [[ ${SEMANTICS[1]} -le 20 ]];then
    if [[ ${SEMANTICS[2]} -eq 20 ]];then

      if [[ ${#SEMANTICS[@]} -eq 2 ]] || [[ ${SEMANTICS[2]} -le 4 ]];then
        if [[ "$JAVA_VERSION" -lt 17 ]]; then
          crashServer "Minecraft 1.17 until 1.20.4 requires Java 17 or newer - found Java $JAVA_VERSION"
        fi
      elif [[ "$JAVA_VERSION" -lt 21 ]]; then
          crashServer "Minecraft 1.20.5 and newer requires Java 21 or newer - found Java $JAVA_VERSION"
      fi

    else
      if [[ "$JAVA_VERSION" -lt 17 ]]; then
          crashServer "Minecraft 1.17 until 1.20.4 requires Java 17 or newer - found Java $JAVA_VERSION"
      fi
    fi
  else
    if [[ "$JAVA_VERSION" -lt 21 ]]; then
        crashServer "Minecraft 1.20.5 and newer requires Java 21 or newer - found Java $JAVA_VERSION"
    fi
  fi
fi

quitServer() {
  echo "Exiting..."
  if [[ "${WAIT_FOR_USER_INPUT}" == "true" ]]; then
    pause
  fi
  exit 0
}

downloadIfNotExist() {
  if [[ ! -s "${1}" ]]; then

    echo "${1} could not be found." >&2
    echo "Downloading ${2}" >&2
    echo "from ${3}" >&2
    curl -# -L -o "./${2}" "${3}"

    if [[ -s "${2}" ]]; then
      echo "Download complete." >&2
      echo "true"
    else
      echo "false"
    fi

  else
    echo "${1} present." >&2
    echo "false"
  fi
}

runJavaCommand() {
  "$JAVA" ${1}
}

checkJavaBitness() {
  "$JAVA" "-version" 2>&1 | grep -i "32-Bit" && echo "WARNING! 32-Bit Java detected! It is highly recommended to use a 64-Bit version of Java!"
}

setup_forge() {
  echo ""
  echo "Running Forge checks and setup..."
  FORGE_INSTALLER_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-installer.jar"
  FORGE_JAR_LOCATION="do_not_manually_edit"

  if [[ ${SEMANTICS[1]} -le 16 ]]; then
    FORGE_JAR_LOCATION="forge.jar"
    LAUNCHER_JAR_LOCATION="forge.jar"
    MINECRAFT_SERVER_JAR_LOCATION="minecraft_server.${MINECRAFT_VERSION}.jar"
    SERVER_RUN_COMMAND="${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
  else
    FORGE_JAR_LOCATION="libraries/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-server.jar"
    MINECRAFT_SERVER_JAR_LOCATION="libraries/net/minecraft/server/${MINECRAFT_VERSION}/server-${MINECRAFT_VERSION}.jar"
    SERVER_RUN_COMMAND="@user_jvm_args.txt @libraries/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/unix_args.txt nogui"

    echo "Generating user_jvm_args.txt from variables..."
    echo "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
    echo "Manually made changes to user_jvm_args.txt will be lost in the nether!"
    rm -f user_jvm_args.txt
    {
      echo "# Xmx and Xms set the maximum and minimum RAM usage, respectively."
      echo "# They can take any number, followed by an M or a G."
      echo "# M means Megabyte, G means Gigabyte."
      echo "# For example, to set the maximum to 3GB: -Xmx3G"
      echo "# To set the minimum to 2.5GB: -Xms2500M"
      echo "# A good default for a modded server is 4GB."
      echo "# Uncomment the next line to set it."
      echo "# -Xmx4G"
      echo "${JAVA_ARGS}"
    } >>user_jvm_args.txt
  fi

  if [[ $(downloadIfNotExist "${FORGE_JAR_LOCATION}" "forge-installer.jar" "${FORGE_INSTALLER_URL}") == "true" ]]; then

    echo "Forge Installer downloaded. Installing..."
    runJavaCommand "-jar forge-installer.jar --installServer"

    if [[ ${SEMANTICS[1]} -gt 16 ]]; then
      rm -f run.bat
      rm -f run.sh
    else
      echo "Renaming forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}.jar to forge.jar"
      mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}".jar forge.jar
      mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}-universal".jar forge.jar
    fi

    if [[ -s "${FORGE_JAR_LOCATION}" ]]; then
      rm -f forge-installer.jar
      echo "Installation complete. forge-installer.jar deleted."
    else
      rm -f forge-installer.jar
      crashServer "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
    fi

  fi
}

setup_neoforge() {
  echo ""
  echo "Running NeoForge checks and setup..."

  FORGE_JAR_LOCATION="do_not_manually_edit"
  JAR_FOLDER="do_not_manually_edit"
  if [[ ${SEMANTICS[1]} -eq 20 ]] && [[ ${SEMANTICS[2]} -gt 1 ]]; then
        JAR_FOLDER="libraries/net/neoforged/neoforge/${MODLOADER_VERSION}"
        FORGE_JAR_LOCATION="${JAR_FOLDER}/neoforge-${MODLOADER_VERSION}-server.jar"
  else
        JAR_FOLDER="libraries/net/neoforged/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}"
        FORGE_JAR_LOCATION="${JAR_FOLDER}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-server.jar"
  fi

  MINECRAFT_SERVER_JAR_LOCATION="libraries/net/minecraft/server/${MINECRAFT_VERSION}/server-${MINECRAFT_VERSION}.jar"
  SERVER_RUN_COMMAND="@user_jvm_args.txt @${JAR_FOLDER}/unix_args.txt nogui"

  echo "Generating user_jvm_args.txt from variables..."
  echo "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
  echo "Manually made changes to user_jvm_args.txt will be lost in the nether!"
  rm -f user_jvm_args.txt
  {
    echo "# Xmx and Xms set the maximum and minimum RAM usage, respectively."
    echo "# They can take any number, followed by an M or a G."
    echo "# M means Megabyte, G means Gigabyte."
    echo "# For example, to set the maximum to 3GB: -Xmx3G"
    echo "# To set the minimum to 2.5GB: -Xms2500M"
    echo "# A good default for a modded server is 4GB."
    echo "# Uncomment the next line to set it."
    echo "# -Xmx4G"
    echo "${JAVA_ARGS}"
  } >>user_jvm_args.txt


  if [[ $(downloadIfNotExist "${FORGE_JAR_LOCATION}" "neoforge-installer.jar" "${NEOFORGE_INSTALLER_URL}") == "true" ]]; then

    echo "NeoForge Installer downloaded. Installing..."
    runJavaCommand "-jar neoforge-installer.jar --installServer"
    echo "Renaming forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}.jar to forge.jar"
    mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}".jar forge.jar

    if [[ -s "${FORGE_JAR_LOCATION}" ]]; then
      rm -f neoforge-installer.jar
      echo "Installation complete. neoforge-installer.jar deleted."
    else
      rm -f neoforge-installer.jar
      crashServer "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
    fi

  fi
}

setup_fabric() {
  echo ""
  echo "Running Fabric checks and setup..."

  FABRIC_INSTALLER_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar"
  FABRIC_CHECK_URL="https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${MODLOADER_VERSION}/server/json"
  FABRIC_AVAILABLE="$(curl -LI ${FABRIC_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"
  IMPROVED_FABRIC_LAUNCHER_URL="https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${MODLOADER_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar"
  IMPROVED_FABRIC_LAUNCHER_AVAILABLE="$(curl -LI ${IMPROVED_FABRIC_LAUNCHER_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "$IMPROVED_FABRIC_LAUNCHER_AVAILABLE" == "200" ]]; then
    echo "Improved Fabric Server Launcher available..."
    echo "The improved launcher will be used to run this Fabric server."
    LAUNCHER_JAR_LOCATION="fabric-server-launcher.jar"
    downloadIfNotExist "fabric-server-launcher.jar" "fabric-server-launcher.jar" "${IMPROVED_FABRIC_LAUNCHER_URL}" >/dev/null
  elif [[ "${FABRIC_AVAILABLE}" != "200" ]]; then
    crashServer "Fabric is not available for Minecraft ${MINECRAFT_VERSION}, Fabric ${MODLOADER_VERSION}."
  elif [[ $(downloadIfNotExist "fabric-server-launch.jar" "fabric-installer.jar" "${FABRIC_INSTALLER_URL}") == "true" ]]; then

    echo "Installer downloaded..."
    LAUNCHER_JAR_LOCATION="fabric-server-launch.jar"
    MINECRAFT_SERVER_JAR_LOCATION="server.jar"
    runJavaCommand "-jar fabric-installer.jar server -mcversion ${MINECRAFT_VERSION} -loader ${MODLOADER_VERSION} -downloadMinecraft"

    if [[ -s "fabric-server-launch.jar" ]]; then
      rm -rf .fabric-installer
      rm -f fabric-installer.jar
      echo "Installation complete. fabric-installer.jar deleted."
    else
      rm -f fabric-installer.jar
      crashServer "fabric-server-launch.jar not found. Maybe the Fabric servers are having trouble. Please try again in a couple of minutes and check your internet connection."
    fi

  else
    echo "fabric-server-launch.jar present. Moving on..."
    LAUNCHER_JAR_LOCATION="fabric-server-launcher.jar"
    MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  fi

  SERVER_RUN_COMMAND="${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

setup_quilt() {
  echo ""
  echo "Running Quilt checks and setup..."

  QUILT_INSTALLER_URL="https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/${QUILT_INSTALLER_VERSION}/quilt-installer-${QUILT_INSTALLER_VERSION}.jar"
  QUILT_CHECK_URL="https://meta.fabricmc.net/v2/versions/intermediary/${MINECRAFT_VERSION}"
  QUILT_AVAILABLE="$(curl -LI ${QUILT_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "${#QUILT_AVAILABLE}" -eq "2" ]]; then
    crashServer "Quilt is not available for Minecraft ${MINECRAFT_VERSION}, Quilt ${MODLOADER_VERSION}."
  elif [[ $(downloadIfNotExist "quilt-server-launch.jar" "quilt-installer.jar" "${QUILT_INSTALLER_URL}") == "true" ]]; then
    echo "Installer downloaded. Installing..."
    runJavaCommand "-jar quilt-installer.jar install server ${MINECRAFT_VERSION} --download-server --install-dir=."

    if [[ -s "quilt-server-launch.jar" ]]; then
      rm quilt-installer.jar
      echo "Installation complete. quilt-installer.jar deleted."
    else
      rm -f quilt-installer.jar
      crashServer "quilt-server-launch.jar not found. Maybe the Quilt servers are having trouble. Please try again in a couple of minutes and check your internet connection."
    fi

  fi

  LAUNCHER_JAR_LOCATION="quilt-server-launch.jar"
  MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  SERVER_RUN_COMMAND="${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

setup_legacyfabric() {
  echo ""
  echo "Running LegacyFabric checks and setup..."

  LEGACYFABRIC_INSTALLER_URL="https://maven.legacyfabric.net/net/legacyfabric/fabric-installer/${LEGACYFABRIC_INSTALLER_VERSION}/fabric-installer-${LEGACYFABRIC_INSTALLER_VERSION}.jar"
  LEGACYFABRIC_CHECK_URL="https://meta.legacyfabric.net/v2/versions/loader/${MINECRAFT_VERSION}"
  LEGACYFABRIC_AVAILABLE="$(curl -LI ${LEGACYFABRIC_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "${#LEGACYFABRIC_AVAILABLE}" -eq "2" ]]; then
    crashServer "LegacyFabric is not available for Minecraft ${MINECRAFT_VERSION}, LegacyFabric ${MODLOADER_VERSION}."
  elif [[ $(downloadIfNotExist "fabric-server-launch.jar" "legacyfabric-installer.jar" "${LEGACYFABRIC_INSTALLER_URL}") == "true" ]]; then
    echo "Installer downloaded. Installing..."
    runJavaCommand "-jar legacyfabric-installer.jar server -mcversion ${MINECRAFT_VERSION} -loader ${MODLOADER_VERSION} -downloadMinecraft"

    if [[ -s "fabric-server-launch.jar" ]]; then
      rm legacyfabric-installer.jar
      echo "Installation complete. legacyfabric-installer.jar deleted."
    else
      rm -f legacyfabric-installer.jar
      crashServer "fabric-server-launch.jar not found. Maybe the LegacyFabric servers are having trouble. Please try again in a couple of minutes and check your internet connection."
    fi

  fi

  LAUNCHER_JAR_LOCATION="fabric-server-launch.jar"
  MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  SERVER_RUN_COMMAND="${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

minecraft() {
  echo ""
  if [[ "${MODLOADER}" == "Fabric" && "$IMPROVED_FABRIC_LAUNCHER_AVAILABLE" == "200" ]]; then
    echo "Skipping Minecraft Server JAR checks because we are using the improved Fabric Server Launcher."
  else
    downloadIfNotExist "${MINECRAFT_SERVER_JAR_LOCATION}" "${MINECRAFT_SERVER_JAR_LOCATION}" "${MINECRAFT_SERVER_URL}" >/dev/null
  fi
}

eula() {
  echo ""
  if [[ ! -s "eula.txt" ]]; then

    echo "Mojang's EULA has not yet been accepted. In order to run a Minecraft server, you must accept Mojang's EULA."
    echo "Mojang's EULA is available to read at https://aka.ms/MinecraftEULA"
    echo "If you agree to Mojang's EULA then type 'I agree'"
    echo -n "Response: "
    read -r ANSWER

    if [[ "${ANSWER}" == "I agree" ]]; then
      echo "User agreed to Mojang's EULA."
      echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA)." >eula.txt
      echo "eula=true" >>eula.txt
    else
      crashServer "User did not agree to Mojang's EULA. Entered: ${ANSWER}. You can not run a Minecraft server unless you agree to Mojang's EULA."
    fi

  fi
}

if [[ "${PWD}" == *" "*  ]]; then

    echo "WARNING! The current location of this script contains spaces. This may cause this server to crash!"
    echo "It is strongly recommended to move this server pack to a location whose path does NOT contain SPACES!"
    echo ""
    echo "Current path:"
    echo "${PWD}"
    echo ""
    echo -n "Are you sure you want to continue? (Yes/No): "
    read -r WHY

    if [[ "${WHY}" == "Yes" ]]; then
        echo "Alrighty. Prepare for unforseen consequences, Mr. Freeman..."
    else
        crashServer "User did not desire to run the server in a directory with spaces in its path."
    fi
fi

case ${MODLOADER} in
  "Forge")
    setup_forge
    ;;
  "NeoForge")
    setup_neoforge
    ;;
  "Fabric")
    setup_fabric
    ;;
  "Quilt")
    setup_quilt
    ;;
  "LegacyFabric")
    setup_legacyfabric
    ;;
  *)
    crashServer "Incorrect modloader specified: ${MODLOADER}"
esac

checkJavaBitness
minecraft
eula

echo ""
echo "Starting server..."
echo "Minecraft version:              ${MINECRAFT_VERSION}"
echo "Modloader:                      ${MODLOADER}"
echo "Modloader version:              ${MODLOADER_VERSION}"
echo "LegacyFabric Installer Version: ${LEGACYFABRIC_INSTALLER_VERSION}"
echo "Fabric Installer Version:       ${FABRIC_INSTALLER_VERSION}"
echo "Quilt Installer Version:        ${QUILT_INSTALLER_VERSION}"
echo "NeoForge Installer URL:         ${NEOFORGE_INSTALLER_URL}"
echo "Minecraft Server URL:           ${MINECRAFT_SERVER_URL}"
echo "Java Args:                      ${JAVA_ARGS}"
echo "Additional Args:                ${ADDITIONAL_ARGS}"
echo "Java Path:                      ${JAVA}"
echo "Wait For User Input:            ${WAIT_FOR_USER_INPUT}"
if [[ "${LAUNCHER_JAR_LOCATION}" != "do_not_manually_edit" ]];then
    echo "Launcher JAR:                   ${LAUNCHER_JAR_LOCATION}"
fi
echo "Run Command:       ${JAVA} ${ADDITIONAL_ARGS} ${SERVER_RUN_COMMAND}"
echo "Java version:"
"${JAVA}" -version
echo ""

while true
do
  runJavaCommand "${ADDITIONAL_ARGS} ${SERVER_RUN_COMMAND}"
  if [[ "${SKIP_JAVA_CHECK}" == "true" ]]; then
    echo "Java version check was skipped. Did the server stop or crash because of a Java version mismatch?"
    echo "Detected ${SEMANTICS[0]}.${SEMANTICS[1]}.${SEMANTICS[2]} - Java ${JAVA_VERSION}"
  fi
  if [[ "${RESTART}" != "true" ]]; then
    quitServer
  fi
  echo "Automatically restarting server in 5 seconds. Press CTRL + C to abort and exit."
  sleep 5
done

echo ""