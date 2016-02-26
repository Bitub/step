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
package de.bitub.step.p21.mapper;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.util.EcoreUtil;

import de.bitub.step.p21.util.LoggerHelper;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 14.04.2015
 */
public class StepToModelImpl implements StepToModel
{
  private static final Logger LOGGER = LoggerHelper.init(Level.ALL, StepToModelImpl.class);

  //container for all IFC objects, each stored by class in a separate list
  //
  private EObject schemaContainer = null; //TODO "Schema" as class name for every generated schema.

  // emf + ecore specific references for filling model
  //
  @SuppressWarnings("rawtypes")
  private Map<String, EList> containerLists = null;
  private Map<String, EClassifier> stepToEcoreNames = null;

  public StepToModelImpl(String nsURI, String schemaName)
  {
    this(Ifc4Package.eINSTANCE, Ifc4Package.eINSTANCE.getIfc4Factory().createIFC4().eClass());
  }

  public StepToModelImpl(EPackage ePackage, EClass schemaContainerClass)
  {
    this(ePackage.getEFactoryInstance(), schemaContainerClass);
  }

  public StepToModelImpl(EObject eObject)
  {
    this.schemaContainer = eObject;
    init();
  }

  public StepToModelImpl(EFactory eFactory, EClass eClass)
  {
    this(eFactory.create(eClass));
  }

  /**
   * <!-- begin-user-doc -->
   * Create entity and add it to their container. Returns a reference to the
   * entity object for further processing.
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param keyword Entity instance name from STEP file
   * @return
   */
  @SuppressWarnings("unchecked")
  public EObject addElementByKeyword(String keyword)
  {
    EObject newObject = null;
    keyword = keyword.toUpperCase();

    if (stepToEcoreNames.containsKey(keyword)) {

      newObject = createEObjectFrom(keyword);
      if (newObject != null && this.containerLists.containsKey(keyword)) { // is persistable

        this.containerLists.get(keyword).add(newObject);
      }
    }
    return newObject;
  }

  /**
   * <!-- begin-user-doc -->
   * Create an instance (EObject) of the entity for the keyword, which is the
   * upper case entity name.
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param keyword
   * @return
   */
  private EObject createEObjectFrom(String keyword)
  {
    EObject eObject = null;

    try {
      EClass eClass = (EClass) stepToEcoreNames.get(keyword);
      eObject = EcoreUtil.create(eClass);
    }
    catch (IllegalArgumentException | ClassCastException e) {
      LOGGER.severe(String.format("Could not create object from %s see error %s", keyword, e.getMessage()));
    }

    return eObject;
  }

  /**
   * Create an enumeration by entity keyword (e.g. IfcSlabTypeEnum) and
   * the value it should hold (e.g. BASESLAB).
   * 
   * @generated NOT
   * @see de.bitub.step.p21.mapper.StepToModel#createEnumBy(java.lang.String,
   *      java.lang.String)
   */
  public Object createEnumBy(String keyword, String literalValue)
  {
    EClassifier eClassifier = stepToEcoreNames.get(keyword);

    if (eClassifier instanceof EEnum) {
      EEnum eEnum = (EEnum) eClassifier;

      try {
        LOGGER.info("Create Enum for keyword '" + keyword + "' with Literal " + literalValue);
        return EcoreUtil.createFromString(eEnum, literalValue);
      }
      catch (IllegalArgumentException exception) {
        LOGGER.warning("ERROR! Creating Enum for keyword '" + keyword + "' with Literal " + literalValue);
        LOGGER.warning(exception.getMessage());
      }
    }

    LOGGER.warning("No Enum for keyword '" + keyword + "' with Literal " + literalValue);
    return null;
  }

  private void init()
  {
    containerLists = keywordToContainmentList(schemaContainer.eClass().getEAllContainments());
    stepToEcoreNames = nameToClassifier(Ifc4Package.eINSTANCE.getEClassifiers());
  }

  @SuppressWarnings("rawtypes")
  private Map<String, EList> keywordToContainmentList(EList<EReference> containments)
  {
    Map<String, EList> containerLists = new HashMap<>();

    for (EReference eReference : containments) {
      Object containmentList = schemaContainer.eGet(eReference);

      if (containmentList instanceof EList) {
        containerLists.put(eReference.getName().toUpperCase(), (EList) containmentList);
      }
    }

    return containerLists;
  }

  private Map<String, EClassifier> nameToClassifier(EList<EClassifier> pckgClassifiers)
  {
    Map<String, EClassifier> stepToEcoreNames = new HashMap<>();

    for (EClassifier eClassifier : pckgClassifiers) {
      stepToEcoreNames.put(eClassifier.getName().toUpperCase(), eClassifier);
    }

    return stepToEcoreNames;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @return the ifc4
   */
  public EObject getSchemaContainer()
  {
    return schemaContainer;
  }
}
