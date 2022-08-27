package de.griefed.serverpackcreator;

import de.griefed.serverpackcreator.ServerPackCreator.CommandlineParser.Mode;
import java.io.File;
import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;
import org.xml.sax.SAXException;

@SpringBootTest(classes = WebServiceTest.class)
@PropertySources({@PropertySource("classpath:serverpackcreator.properties")})
public class WebServiceTest {

  private static final Logger LOG = LogManager.getLogger(WebServiceTest.class);

  WebServiceTest() throws IOException, ParserConfigurationException, SAXException {
    try {
      FileUtils.copyDirectory(
          new File("backend/test/resources/testresources/addons"), new File("plugins"));
    } catch (IOException e) {
      LOG.error("Error copying file.", e);
    }
    try {
      FileUtils.copyFile(
          new File("backend/main/resources/serverpackcreator.properties"),
          new File("serverpackcreator.properties"));
    } catch (IOException e) {
      LOG.error("Error copying file", e);
    }
    try {
      FileUtils.copyFile(
          new File("backend/test/resources/serverpackcreator.db"),
          new File("serverpackcreator.db"));
    } catch (IOException e) {
      LOG.error("Error copying file", e);
    }
    ServerPackCreator.getInstance().run(Mode.SETUP);
    ServerPackCreator.getInstance().checkDatabase();
  }

  @Test
  void contextLoads() {
  }
}
