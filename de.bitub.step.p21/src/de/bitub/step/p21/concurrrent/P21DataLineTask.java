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
