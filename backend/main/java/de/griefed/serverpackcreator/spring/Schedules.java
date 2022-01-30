package de.griefed.serverpackcreator.spring;

import de.griefed.serverpackcreator.ApplicationProperties;
import de.griefed.serverpackcreator.DefaultFiles;
import de.griefed.serverpackcreator.VersionLister;
import de.griefed.serverpackcreator.spring.models.ServerPack;
import de.griefed.serverpackcreator.spring.services.ServerPackService;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.File;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Schedules to cover all kinds of aspects of ServerPackCreator.
 * @author Griefed
 */
@Service
public class Schedules {

    private static final Logger LOG = LogManager.getLogger(Schedules.class);

    private final ApplicationProperties APPLICATIONPROPERTIES;
    private final ServerPackService SERVERPACKSERVICE;
    private final DefaultFiles DEFAULTFILES;
    private final VersionLister VERSIONLISTER;

    /**
     * Constructor for DI.
     * @author Griefed
     * @param injectedApplicationProperties Instance of {@link ApplicationProperties}.
     * @param injectedServerPackService Instance of {@link ServerPackService}.
     * @param injectedDefaultFiles Instance of {@link DefaultFiles}.
     * @param injectedVersionLister Instance of {@link VersionLister}.
     */
    @Autowired
    public Schedules(ApplicationProperties injectedApplicationProperties, ServerPackService injectedServerPackService,
                     DefaultFiles injectedDefaultFiles, VersionLister injectedVersionLister) {

        this.APPLICATIONPROPERTIES = injectedApplicationProperties;
        this.SERVERPACKSERVICE = injectedServerPackService;
        this.DEFAULTFILES = injectedDefaultFiles;
        this.VERSIONLISTER = injectedVersionLister;
    }

    private void deletePack(ServerPack pack) {
        LOG.info("Deleting archive " + pack.getPath().replace("\\","/"));
        FileUtils.deleteQuietly(new File(pack.getPath().replace("\\","/")));

        LOG.info("Deleting folder " + pack.getPath().replace("\\","/").replace("_server_pack-zip",""));
        FileUtils.deleteQuietly(new File(pack.getPath().replace("\\","/").replace("_server_pack-zip","")));

        LOG.info("Deleting modpack " + "./work/" + pack.getProjectID() + "/" + pack.getFileID());
        FileUtils.deleteQuietly(new File("./work/" + pack.getProjectID() + "/" + pack.getFileID()));

        LOG.info("Cleaned server pack " + pack.getId() + " from database.");
        SERVERPACKSERVICE.deleteServerPack(pack.getId());
    }

    /**
     * Check the database every <code>de.griefed.serverpackcreator.spring.schedules.database.cleanup</code> for validity.
     * <br>Deletes entries from the database which are older than 1 week and have 0 downloads.
     * <br>Deletes entries whose status is <code>Available</code> but no server pack ZIP-archive can be found.
     * <br>
     * @author Griefed
     */
    @Scheduled(cron = "${de.griefed.serverpackcreator.spring.schedules.database.cleanup}")
    private void cleanDatabase() {
        if (!SERVERPACKSERVICE.getServerPacks().isEmpty()) {

            LOG.info("Cleaning database...");

            for (ServerPack pack : SERVERPACKSERVICE.getServerPacks()) {

                if ((new Timestamp(new Date().getTime()).getTime() - pack.getLastModified().getTime()) >= 604800000 && pack.getDownloads() == 0) {

                    deletePack(pack);

                } else if (pack.getStatus().equals("Available") && !new File(pack.getPath()).isFile()) {

                    deletePack(pack);

                } else if (pack.getStatus().equals("Generating") && (new Timestamp(new Date().getTime()).getTime() - pack.getLastModified().getTime()) >= 86400000) {

                    deletePack(pack);

                } else {
                    LOG.info("No database entries to clean up.");
                }

            }

            LOG.info("Database cleanup completed.");

        }
    }

    @Scheduled(cron = "${de.griefed.serverpackcreator.spring.schedules.files.cleanup}")
    private void cleanFiles() {
        if (!SERVERPACKSERVICE.getServerPacks().isEmpty()) {

            LOG.info("Cleaning files...");

            for (ServerPack pack : SERVERPACKSERVICE.getServerPacks()) {

                if (new File(pack.getPath()).isFile() && new File(pack.getPath().replace("_server_pack-zip","")).isDirectory()) {

                    LOG.info("Deleting folder " + pack.getPath().replace("_server_pack-zip","").replace("\\","/"));
                    FileUtils.deleteQuietly(new File(pack.getPath().replace("_server_pack-zip","").replace("\\","/")));

                } else if (pack.getProjectID() >= 10 && pack.getFileID() >= 60018 && new File(pack.getPath()).isFile()) {

                    LOG.info("Deleting modpack " + "./work/" + pack.getProjectID() + "/" + pack.getFileID());
                    FileUtils.deleteQuietly(new File("./work/" + pack.getProjectID() + "/" + pack.getFileID()));

                } else {
                    LOG.info("No files to clean up.");
                }

            }

            LOG.info("File cleanup completed.");

        }
    }

    @Scheduled(cron = "${de.griefed.serverpackcreator.spring.schedules.versions.refresh}")
    private void refreshVersionLister() {
        DEFAULTFILES.refreshManifestFile(DEFAULTFILES.getMinecraftManifestUrl(), APPLICATIONPROPERTIES.FILE_MANIFEST_MINECRAFT);
        DEFAULTFILES.refreshManifestFile(DEFAULTFILES.getForgeManifestUrl(), APPLICATIONPROPERTIES.FILE_MANIFEST_FORGE);
        DEFAULTFILES.refreshManifestFile(DEFAULTFILES.getFabricManifestUrl(), APPLICATIONPROPERTIES.FILE_MANIFEST_FABRIC);
        DEFAULTFILES.refreshManifestFile(DEFAULTFILES.getFabricInstallerManifestUrl(), APPLICATIONPROPERTIES.FILE_MANIFEST_FABRIC_INSTALLER);

        VERSIONLISTER.refreshVersions();
    }
}
