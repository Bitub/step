package de.bitub.step.p21.util;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

public class LoggerHelper {
	public static Logger init(Level level, Class<?> forClass) {
		FileHandler fh;
		Logger logger = Logger.getLogger(forClass.getName());

		try {
			// This block configure the logger with handler and formatter
			//
			Path logFolderPath = FileSystems.getDefault().getPath("logs");
			String logFileName = forClass.getSimpleName() + ".log";

			if (Files.exists(logFolderPath)) {
				fh = new FileHandler("logs/" + logFileName);
				SimpleFormatter formatter = new SimpleFormatter();
				fh.setFormatter(formatter);

				logger.addHandler(fh);
				logger.setLevel(level);
				logger.setUseParentHandlers(false);
			}

		} catch (SecurityException | IOException e) {
			e.printStackTrace();
		}
		return logger;
	}
}
