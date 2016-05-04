package de.bitub.step.p21.concurrrent;

import java.util.concurrent.Callable;

import org.eclipse.emf.ecore.EObject;

import com.google.inject.Inject;

import de.bitub.step.p21.parser.P21EntityListener;
import de.bitub.step.p21.persistence.SingleLineEntityParser;

public class P21DataLineRunnable implements Callable<EObject>
{
  P21EntityListener listener;
  String line = "";

  @Inject
  public P21DataLineRunnable(P21EntityListener listener, String line)
  {
    this.listener = listener;
    this.line = line;
  }

  @Override
  public EObject call() throws Exception
  {
    return parse(line, listener);
  }

  private EObject parse(String line, P21EntityListener listener)
  {
    SingleLineEntityParser parser = new SingleLineEntityParser();
    return parser.parse(line, listener);
  }

}
