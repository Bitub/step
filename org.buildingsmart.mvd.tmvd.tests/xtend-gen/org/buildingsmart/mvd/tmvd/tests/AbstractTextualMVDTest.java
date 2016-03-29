package org.buildingsmart.mvd.tmvd.tests;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.buildingsmart.mvd.mvdxml.MvdXML;
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.eclipse.xtext.junit4.util.ParseHelper;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.junit.runner.RunWith;

@RunWith(XtextRunner.class)
@InjectWith(TextualMVDInjectorProvider.class)
@SuppressWarnings("all")
public class AbstractTextualMVDTest {
  @Inject
  @Extension
  private ParseHelper<MvdXML> _parseHelper;
  
  protected final ResourceSet resourceSet = new ResourceSetImpl();
  
  public InputStream readMvdXml(final String path) {
    Class<? extends AbstractTextualMVDTest> _class = this.getClass();
    ClassLoader _classLoader = _class.getClassLoader();
    return _classLoader.getResourceAsStream(path);
  }
  
  public CharSequence readModel(final InputStream in) {
    try {
      InputStreamReader _inputStreamReader = new InputStreamReader(in);
      final BufferedReader reader = new BufferedReader(_inputStreamReader);
      String line = null;
      StringBuilder buffer = new StringBuilder();
      while ((!Objects.equal((line = reader.readLine()), null))) {
        StringBuilder _append = buffer.append(line);
        _append.append("\n");
      }
      return buffer;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public MvdXML generateTextualMVD(final CharSequence tmvd) {
    try {
      return this._parseHelper.parse(tmvd, this.resourceSet);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
