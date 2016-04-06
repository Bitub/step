package org.buildingsmart.mvd.tmvd.tests;

import com.google.inject.Inject;
import org.buildingsmart.mvd.mvdxml.MvdXML;
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider;
import org.buildingsmart.mvd.tmvd.util.IOHelper;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.xbase.lib.Extension;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(TextualMVDInjectorProvider.class)
@SuppressWarnings("all")
public class AbstractTextualMVDTest {
  @Inject
  @Extension
  private IOHelper io;
  
  public MvdXML loadTextualMVD(final String pathToFile) {
    return this.io.loadTextualMVD(pathToFile);
  }
  
  public EObject loadMvdXML(final String pathToFile) {
    return this.io.loadMvdXML(pathToFile);
  }
  
  public void saveMvdXML(final EObject root, final String pathToFile) {
    this.io.storeAsMVDXML(root, pathToFile);
  }
  
  public void saveTextualMVD(final EObject root, final String pathToFile) {
    this.io.storeAsTMVD(root, pathToFile);
  }
}
