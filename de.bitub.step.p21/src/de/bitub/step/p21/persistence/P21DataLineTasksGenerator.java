package de.bitub.step.p21.persistence;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EPackage;

import com.google.inject.Inject;

import de.bitub.step.p21.concurrrent.P21DataLineTask;
import de.bitub.step.p21.di.P21ParserFactory;
import de.bitub.step.p21.parser.P21EntityListener;

public class P21DataLineTasksGenerator
{
  EPackage ePackage = null;

  @Inject
  P21ParserFactory parserFactory;

  /**
   * Split input stream into tasks. One task is to read and parse one entity
   * instance line in P21 instance file. For every entity
   * instance line a tasks is queued into a list for execution.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param p21InstanceFileStream
   * @return
   * @throws IOException
   */
  public List<P21DataLineTask> generateWorkTasksFrom(InputStream p21InstanceFileStream) throws IOException
  {
    List<P21DataLineTask> taskList = new ArrayList<>();

    long start = System.currentTimeMillis();
    try (BufferedReader br = new BufferedReader(new InputStreamReader(p21InstanceFileStream))) {

      String line = "";
      boolean isDataSection = false;

      while ((line = br.readLine()) != null) {

        if (line.equalsIgnoreCase("ENDSEC;")) {
          isDataSection = false;
        }

        if (isDataSection) {

          P21EntityListener listener = parserFactory.createWith(ePackage);
          taskList.add(new P21DataLineTask(listener, line));
        }

        if (line.equalsIgnoreCase("DATA;")) {
          isDataSection = true;
        }
      }
    }
    System.out.println((System.currentTimeMillis() - start) + " ms to read lines of DATA section.");

    return taskList;
  }

  public void setEPackage(EPackage ePackage)
  {
    this.ePackage = ePackage;
  }
}
