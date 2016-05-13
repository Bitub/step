package org.buildingsmart.mvd.tmvd.tests;

import org.buildingsmart.mvd.mvdxml.MvdXML;
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider;
import org.buildingsmart.mvd.tmvd.util.IOHelper;

/* @RunWith(XtextRunner.class)
@InjectWith(TextualMVDInjectorProvider.class)
 */@SuppressWarnings("all")
public class AbstractTextualMVDTest {
  /* @Inject
   */private IOHelper io;
  
  public MvdXML loadTextualMVD(final String pathToFile) {
    return this.io.loadTextualMVD(pathToFile);
  }
  
  public Object loadMvdXML(final String pathToFile) {
    return this.io.loadMvdXML(pathToFile);
  }
  
  public Object saveMvdXML(final /* EObject */Object root, final String pathToFile) {
    return this.io.storeAsMVDXML(root, pathToFile);
  }
  
  public Object saveTextualMVD(final /* EObject */Object root, final String pathToFile) {
    return this.io.storeAsTMVD(root, pathToFile);
  }
}
