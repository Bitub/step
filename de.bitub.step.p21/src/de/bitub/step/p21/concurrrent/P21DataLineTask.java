package de.bitub.step.p21.concurrrent;

import java.util.concurrent.Callable;

import org.eclipse.emf.ecore.EObject;

import com.google.inject.Inject;

import de.bitub.step.p21.parser.P21EntityListener;
import de.bitub.step.p21.persistence.SingleLineEntityParser;

public class P21DataLineTask implements Callable<EObject>
{
  P21EntityListener listener;
  String line = "";

  @Inject
  public P21DataLineTask(P21EntityListener listener, String line)
  {
    this.listener = listener;
    this.line = line;
  }

  @Override
  public EObject call() throws Exception
  {
//    System.out.printf("Start parsing line: %s\n", this.line);
    return parse(line, listener);
  }

  private EObject parse(String line, P21EntityListener listener)
  {
    SingleLineEntityParser parser = new SingleLineEntityParser();
    EObject result = null;
    try {
      result = parser.parse(line, listener);
    }
    catch (Exception e) {
      e.printStackTrace();
    }
    return result;
  }

}
