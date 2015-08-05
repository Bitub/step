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

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
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
public class SaveLoad
{
  private EObject container;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public SaveLoad()
  {
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public SaveLoad(EObject container)
  {
    this.container = container;
  }

  public void save(URI uri)
  {

    // Initialize the model
    //
    Ifc4Package ifc4Package = Ifc4Package.eINSTANCE;

    // Obtain a new resource set
    //
    ResourceSet resSet = new ResourceSetImpl();

    // Register the P21 resource factory for the .ifc extension
    //
//    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("ifc", new P21ResourceFactoryImpl());
    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("ifc", new XMIResourceFactoryImpl());

    // Get the resource
    //
    XMIResource resource = (XMIResource) resSet.createResource(uri, null);
    System.out.println(uri + " " + resource);
    resource.getContents().add(this.container);

    try {
      resource.save(Collections.EMPTY_MAP);
      System.out.println(this.container + " saved!");
    }
    catch (IOException exception) {

      System.out.println("Failed to save " + uri);
    }
    catch (Exception exception) {

      System.out.println("Something gone wrong! " + exception);
    }
  }

  public IFC4 load(String path)
  {
    URI uri = URI.createURI(path);

    // Obtain a new resource set
    //
    ResourceSet resSet = new ResourceSetImpl();

    // Register the P21 resource factory for the .ifc extension
    //
    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("ifc", new P21ResourceFactoryImpl());

    // Get the resource
    //
    P21Resource resource = (P21Resource) resSet.createResource(uri);

    try {
      resource.load(null);

      if (resource.getContents().size() != 0) {

        this.container = resource.getContents().get(0);
      }
      System.out.println(this.container + " loaded!");
    }
    catch (IOException exception) {

      System.out.println("Failed to load " + uri);
    }

    // Get the first model element and cast it to the right type, in my
    // example everything is hierarchical included in this first node
    //
    return (IFC4) this.container;
  }

  public void print()
  {
    EPackage ePackage = Ifc4Package.eINSTANCE;

    for (EClassifier classifier : ePackage.getEClassifiers()) {
      System.out.println(classifier.getName());
      System.out.print("  ");

      if (classifier instanceof EClass) {
        EClass eClass = (EClass) classifier;

        System.out.print("ATTR: ");
        for (EAttribute attribute : eClass.getEAttributes()) {
          System.out.print(attribute.getName() + " ");
        }

        if (!eClass.getEAttributes().isEmpty() && !eClass.getEReferences().isEmpty()) {
          System.out.println();
          System.out.print("  ");
        }

        System.out.print("REF: ");
        for (EReference reference : eClass.getEReferences()) {
          System.out.print(reference.getName() + " ");
        }
      } else
        if (classifier instanceof EEnum) {

          EEnum eEnum = (EEnum) classifier;
          System.out.print("ENUM: ");
          for (EEnumLiteral literal : eEnum.getELiterals()) {
            System.out.print(literal.getName() + " ");
          }
        } else {
          System.out.print("DT: ");
          if (classifier instanceof EDataType) {
            EDataType eDataType = (EDataType) classifier;
            System.out.print(eDataType.getInstanceClassName());
          }
        }
      System.out.println();
    }
  }
}
