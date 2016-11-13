package de.bitub.step.p21.test;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.common.util.URI;

import de.bitub.step.p21.util.IOHelper;

public class AbstractP21TestHelper
{

  protected final Ifc4Package ifc4Package = Ifc4Package.eINSTANCE;

  // base path to ifc4 test files
  //
  protected static final String BASE_PATH = "ifc-files/ifc4/";

  /**
   * Helper method for laoding IFC4 container from given file in test folder.
   * 
   * @param fileName
   * @return
   */
  protected IFC4 load(String fileName)
  {
    return (IFC4) IOHelper.load(URI.createFileURI(BASE_PATH + fileName), Ifc4Package.eINSTANCE);
  }
}
