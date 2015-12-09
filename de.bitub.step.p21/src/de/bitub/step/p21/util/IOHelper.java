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
import java.util.Collections;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
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

  private static final Logger LOGGER = Logger.getLogger(IOHelper.class.getName());

  static {
    try {

      // This block configure the logger with handler and formatter
      //
      FileHandler fh = new FileHandler("logs/" + IOHelper.class.getSimpleName() + ".log");
      SimpleFormatter formatter = new SimpleFormatter();
      fh.setFormatter(formatter);

      IOHelper.LOGGER.setLevel(Level.WARNING);
      IOHelper.LOGGER.addHandler(fh);
      IOHelper.LOGGER.setUseParentHandlers(true);
    }
    catch (SecurityException e) {
      e.printStackTrace();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  // TODO (Riemschüssel 09.12.2015) Change serialisation from xmi to STEP instance file (.p21, .ifc, .stp)

  /**
   * Store the resource as XMI file.
   * Needed EcorePackacke must be initialzed first.
   *
   * @param eObject
   * @param uri
   */
  public static void storeAsXMI(EObject eObject, URI uri)
  {
    // Initialize the model
    //
//    Ifc4Package ifc4Package = Ifc4Package.eINSTANCE;

    // Obtain a new resource set
    //
    ResourceSet resSet = new ResourceSetImpl();

    // Register the P21 resource factory for the .ifc extension
    //
    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("ifc", new XMIResourceFactoryImpl());

    // Get the resource
    //
    XMIResource resource = (XMIResource) resSet.createResource(uri, null);
    resource.getContents().add(eObject);

    try {
      resource.save(Collections.EMPTY_MAP);
      IOHelper.LOGGER.info(String.format("%s saved.", eObject));
    }
    catch (IOException exception) {

      IOHelper.LOGGER.warning(String.format("Failed to save resource %s. See reason %s", uri, exception.getMessage()));
    }
    catch (Exception exception) {
      IOHelper.LOGGER.severe(
          String.format("Something unexpected happened while saving resource %s. See reason %s", uri, exception.getMessage()));
    }
  }

  /**
   * Load the resource from a given STEP instnace file (.ifc).
   * 
   * @param uri
   * @return
   */
  public static EObject load(URI uri)
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
      resource.load(null);

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
