/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 14.07.2015.
 */
package de.bitub.step.p21;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.Ifc4Package;
import org.buildingsmart.ifc4.impl.IFC4Impl;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EReference;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.07.2015
 */
public class Registry
{
  private static final Registry INSTANCE = new Registry();

  // container for all entities
  //
  private IFC4 container = null;

  // mappings betweeen names and ...
  //
  private Map<String, EList<?>> lists = null;

  private Map<String, EClassifier> list = Collections.synchronizedMap(new TreeMap<>());

  private Map<String, EClassifier> stepToEcoreNames = null;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  private Registry()
  {
    this.init();
  }

  public static Registry INSTANCE()
  {
    return INSTANCE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  private void init()
  {
    container = Ifc4Package.eINSTANCE.getIfc4Factory().createIFC4();

    // init maps
    //
    lists = LoadHelper.initKeywordToContainmentListsMap(container);
    stepToEcoreNames = LoadHelper.initNameToClassifierMap();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @return the container
   */
  public IFC4 getContainer()
  {
    return container;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @return the lists
   */
  public Map<String, EList<?>> getLists()
  {
    return lists;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @return the stepToEcoreNames
   */
  public Map<String, EClassifier> getNameMapping()
  {
    return stepToEcoreNames;
  }

  private static class LoadHelper
  {
    public static Map<String, EList<?>> initKeywordToContainmentListsMap(IFC4 ifc4)
    {
      Map<String, EList<?>> containerLists = new HashMap<>();

      // all containment references in IFC4
      //
      for (EReference eReference : ifc4.eClass().getEAllContainments()) {

        String upperCaseKey = eReference.getName().toUpperCase();
        int containmentListFeatureId = eReference.getFeatureID();

        Object containmentList = ((IFC4Impl) ifc4).eGet(containmentListFeatureId, true, true);

        if (containmentList instanceof EList) {

          // save references to containment lists of overall ifc4 container
          //
          containerLists.put(upperCaseKey, (EList<?>) containmentList);
        }
      }
      return containerLists;
    }

    public static Map<String, EClassifier> initNameToClassifierMap()
    {
      Map<String, EClassifier> stepToEcoreNames = new HashMap<String, EClassifier>();

      for (EClassifier eClassifier : Ifc4Package.eINSTANCE.getEClassifiers()) {

        String upperCaseEntityName = eClassifier.getName().toUpperCase();
        stepToEcoreNames.put(upperCaseEntityName, eClassifier);
      }
      return stepToEcoreNames;
    }
  }

}
