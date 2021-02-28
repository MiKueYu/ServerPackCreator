package de.griefed.serverPackCreator;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Stream;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

public class Copy {

    public static final File configFile = new File("creator.conf");
    public static final File propertiesFile = new File("server.properties");
    public static final File iconFile = new File("server-icon.png");
    public static final File forgeWindowsFile = new File("start-forge.bat");
    public static final File forgeLinuxFile = new File("start-forge.sh");
    public static final File fabricWindowsFile = new File("start-fabric.bat");
    public static final File fabricLinuxFile = new File("start-fabric.sh");
    private static final Logger appLogger = LogManager.getLogger("Copy");
    private static final Logger errorLogger = LogManager.getLogger("CopyError");

    // Copy all default files to base directory where jar resides.
    public static void filesSetup() {
        appLogger.info("Setting up default files...");
        boolean firstRun = true;
        // Create directory for server files for customization
        try {
            Files.createDirectories(Paths.get("server_files"));
        } catch (IOException ex) {
            errorLogger.error("Could not create server_files directory.", ex);
        }
        // Copy config file in case it does not exist yet
        if (!configFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/" + configFile.getName()));
                Files.copy(link, configFile.getAbsoluteFile().toPath());
                link.close();
                appLogger.info("Default config file generated. Please customize.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default config-file", ex);
                }
            }
        } else { firstRun = false; }
        // Copy Forge related start scripts
        if (!forgeWindowsFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + forgeWindowsFile.getName()));
                Files.copy(link, Paths.get("server_files/" + forgeWindowsFile));
                link.close();
                appLogger.info("Default Forge Windows start file generated.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default Forge Windows start file", ex);
                }
            }
        }
        if (!forgeLinuxFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + forgeLinuxFile.getName()));
                Files.copy(link, Paths.get("server_files/" + forgeLinuxFile));
                link.close();
                appLogger.info("Default Forge Linux start file generated.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default Forge Linux start file", ex);
                }
            }
        }
        // Copy Fabric related start scripts
        if (!fabricWindowsFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + fabricWindowsFile.getName()));
                Files.copy(link, Paths.get("server_files/" + fabricWindowsFile));
                link.close();
                appLogger.info("Default Fabric Windows start file generated.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default Fabric Windows start file", ex);
                }
            }
        }
        if (!fabricLinuxFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + fabricLinuxFile.getName()));
                Files.copy(link, Paths.get("server_files/" + fabricLinuxFile));
                link.close();
                appLogger.info("Default Fabric Linux start file generated.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default Fabric Linux start file", ex);
                }
            }
        }
        // Copy server.properties if it does not exist
        if (!propertiesFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + propertiesFile.getName()));
                Files.copy(link, Paths.get("server_files/" + propertiesFile));
                link.close();
                appLogger.info("Default server.properties file generated. Please customize if you intend on using it.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default server.properties file", ex);
                }
            }
        }
        // Copy server icon file if it does not exist
        if (!iconFile.exists()) {
            try {
                InputStream link = (Copy.class.getResourceAsStream("/server_files/" + iconFile.getName()));
                Files.copy(link, Paths.get("server_files/" + iconFile));
                link.close();
                appLogger.info("Default server-icon.png file generated. Please customize if you intend on using it.");
            } catch (IOException ex) {
                if (!ex.toString().startsWith("java.nio.file.FileAlreadyExistsException")) {
                    errorLogger.error("Could not extract default server-icon.png file", ex);
                }
            }
        }
        // If the config file was just generated because it did not exist yet, then exit and tell user to customize
        if (firstRun) {
            appLogger.info("################################################################");
            appLogger.info("#                                                              #");
            appLogger.info("#       FIRST RUN. CUSTOMIZE YOUR CREATOR.CONF FILE NOW.       #");
            appLogger.info("#        THE DEFAULTS ARE MEANT TO SHOW HOW IT'S DONE.         #");
            appLogger.info("#    THE DEFAULTS WILL MOST LIKELY NOT WORK ON YOUR SYSTEM.    #");
            appLogger.info("#                                                              #");
            appLogger.info("################################################################");
            appLogger.warn("First run! Default files generated. Please customize and run again.");
            System.exit(0);
        } else {
            appLogger.info("Setup completed.");
        }
    }

    // Copy forge/fabric start scripts to serverpack, depending on modLoader config.
    public static void copyStartScripts(String modpackDir, String modLoader, boolean includeStartScripts) {
        if (modLoader.equals("Forge") && includeStartScripts) {
            appLogger.info("Copying Forge start scripts...");
            try {
                Files.copy(Paths.get("server_files/" + forgeWindowsFile), Paths.get(modpackDir + "/server_pack/" + forgeWindowsFile), REPLACE_EXISTING);
                Files.copy(Paths.get("server_files/" + forgeLinuxFile), Paths.get(modpackDir + "/server_pack/" + forgeLinuxFile), REPLACE_EXISTING);
            } catch (IOException ex) {
                errorLogger.error("An error occurred while copying files: ", ex);
            }
        } else if (modLoader.equals("Fabric") && includeStartScripts) {
            appLogger.info("Copying Fabric start scripts...");
            try {
                Files.copy(Paths.get("server_files/" + fabricWindowsFile), Paths.get(modpackDir + "/server_pack/" + fabricWindowsFile), REPLACE_EXISTING);
                Files.copy(Paths.get("server_files/" + fabricLinuxFile), Paths.get(modpackDir + "/server_pack/" + fabricLinuxFile), REPLACE_EXISTING);
            } catch (IOException ex) {
                errorLogger.error("An error occurred while copying files: ", ex);
            }
        } else {
            appLogger.info("Specified invalid modloader. Must be either Forge or Fabric.");
        }
    }

    // Copy all specified directories from modpack to serverpack.
    public static void copyFiles(String modpackDir, List<String> copyDirs) throws IOException {
        String serverPath = modpackDir + "/server_pack";
        Files.createDirectories(Paths.get(serverPath));
        for (int i = 0; i<copyDirs.toArray().length; i++) {
            String clientDir = modpackDir + "/" + copyDirs.get(i);
            String serverDir = serverPath + "/" + copyDirs.get(i);
            appLogger.info("Setting up " + serverDir + " files.");
            if (copyDirs.get(i).startsWith("saves/")) {
                String savesDir = serverPath + "/" + copyDirs.get(i).substring(6);
                try {
                    Stream<Path> files = Files.walk(Paths.get(clientDir));
                    files.forEach(file -> {
                        try {
                            Files.copy(file, Paths.get(savesDir).resolve(Paths.get(clientDir).relativize(file)), REPLACE_EXISTING);
                            appLogger.info("Copying: " + file.toAbsolutePath().toString());
                        } catch (IOException ex) {
                            if (!ex.toString().startsWith("java.nio.file.DirectoryNotEmptyException")) {
                                errorLogger.error(ex);
                            }
                        }
                    });
                } catch (IOException ex) {
                    errorLogger.error("An error occurred copying the specified world.", ex);
                }
            } else {
                try {
                    Stream<Path> files = Files.walk(Paths.get(clientDir));
                    files.forEach(file -> {
                        try {
                            Files.copy(file, Paths.get(serverDir).resolve(Paths.get(clientDir).relativize(file)), REPLACE_EXISTING);
                            appLogger.info("Copying: " + file.toAbsolutePath().toString());
                        } catch (IOException ex) {
                            if (!ex.toString().startsWith("java.nio.file.DirectoryNotEmptyException")) {
                                errorLogger.error("An error occurred copying files to the serverpack.", ex);
                            }
                        }
                    });
                    files.close();
                } catch (IOException ex) {
                    errorLogger.error("An error occurred during the copy-procedure to the serverpack.", ex);
                }
            }
        }
    }

    // If true, copy server-icon to serverpack.
    public static void copyIcon(String modpackDir) {
        appLogger.info("Copying server-icon.png...");
        try {
            Files.copy(Paths.get("server_files/" + iconFile), Paths.get(modpackDir + "/server_pack/" + iconFile), REPLACE_EXISTING);
        } catch (IOException ex) {
            errorLogger.error("An error occurred trying to copy the server icon.", ex);
        }
    }

    // If true, copy server.properties to serverpack.
    public static void copyProperties(String modpackDir) {
        appLogger.info("Copying server.properties...");
        try {
            Files.copy(Paths.get("server_files/" + propertiesFile), Paths.get(modpackDir + "/server_pack/" + propertiesFile), REPLACE_EXISTING);
        } catch (IOException ex) {
            errorLogger.error("An error occurred trying to copy the server.properties-file.", ex);
        }
    }
}
