package de.bitub.step.p21.util;

import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

public class LoggerHelper
{
  public static Logger init(Level level, Class<?> forClass)
  {
    FileHandler fh;
    Logger logger = Logger.getLogger(forClass.getName());

    try {
      // This block configure the logger with handler and formatter
      //
      fh = new FileHandler("logs/" + forClass.getSimpleName() + ".log");
      SimpleFormatter formatter = new SimpleFormatter();
      fh.setFormatter(formatter);

      logger.addHandler(fh);
      logger.setLevel(level);
      logger.setUseParentHandlers(false);
    }
    catch (SecurityException e) {
      e.printStackTrace();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    return logger;
  }
}
