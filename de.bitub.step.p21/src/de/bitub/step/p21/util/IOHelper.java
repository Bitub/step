/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 14.04.2015.
 */
package de.bitub.step.p21.util;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMIResource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

import de.bitub.step.p21.persistence.P21Resource;
import de.bitub.step.p21.persistence.P21ResourceFactoryImpl;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.04.2015
 */
public class IOHelper
{

  private static final Logger LOGGER = LoggerHelper.init(Level.WARNING, IOHelper.class);

  /**
   * Store the resource as XMI file.
   * Needed EcorePackacke must be initialzed first.
   *
   * @param eObject
   * @param uri
   */
  public static void storeAsXMI(EObject eObject, URI uri)
  {
    // Obtain a new resource set
    //
    ResourceSet resSet = new ResourceSetImpl();

    // Register the P21 resource factory for the .xmi extension
    //
    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());

    // Get the resource
    //
    XMIResource resource = (XMIResource) resSet.createResource(uri, null);
    resource.getDefaultSaveOptions().put(XMIResource.OPTION_KEEP_DEFAULT_CONTENT, Boolean.TRUE);
    resource.getContents().add(eObject);

    try {
      resource.save(null);

      IOHelper.LOGGER.info(String.format("%s saved.", eObject));
    }
    catch (IOException exception) {
      exception.printStackTrace();
      IOHelper.LOGGER.warning(String.format("Failed to save %s to resource %s. See reason %s", eObject, uri, exception));
    }
    catch (Exception exception) {
      exception.printStackTrace();
      IOHelper.LOGGER
          .severe(String.format("Something unexpected happened while saving resource %s. See reason %s", uri, exception));
    }
  }

  /**
   * Load the resource from a given STEP instnace file (.ifc).
   * 
   * @param uri
   * @return
   */
  public static EObject load(URI uri, EPackage ePackage)
  {
    // Obtain a new resource set
    //
    ResourceSet resSet = new ResourceSetImpl();

    // Register the P21 resource factory for the .ifc extension
    //
    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("ifc", new P21ResourceFactoryImpl());

    // Get the resource
    //
    P21Resource resource = (P21Resource) resSet.createResource(uri);

    EObject eObject = null;

    try {
      Map<Object, Object> options = new HashMap<Object, Object>();
      options.put("ePackage", ePackage);

      resource.load(options);

      if (resource.getContents().size() > 0) {
        eObject = resource.getContents().get(0);
      }
      IOHelper.LOGGER.info(String.format("%s loaded.", eObject));
    }
    catch (IOException exception) {

      IOHelper.LOGGER.warning(String.format("Failed to load resource %s. See reason %s", uri, exception.getMessage()));
    }

    // Get the first model element and cast it to the right type, in my
    // example everything is hierarchical included in this first node
    //
    return eObject;
  }
}
