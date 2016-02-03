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

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EFactory;
import org.eclipse.emf.ecore.EObject;
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
  private IFC4 ifc4 = null; //TODO "Schema" as class name for every generated schema.

  // emf + ecore specific references for filling model
  //
  @SuppressWarnings("rawtypes")
  private Map<String, EList> containerLists = null;
  private Map<String, EClassifier> stepToEcoreNames = null;

  public StepToModelImpl()
  {
    this(Ifc4Package.eINSTANCE.getIfc4Factory(), Ifc4Package.eINSTANCE.getIFC4());
  }

  public StepToModelImpl(EFactory eFactory, EClass eClass)
  {
    ifc4 = (IFC4) eFactory.create(eClass);
    init();
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

    if (this.stepToEcoreNames.containsKey(keyword)) { // TODO Is this needed? Check!

      newObject = createBy(keyword);
      if (newObject != null && this.containerLists.containsKey(keyword)) { // is persistable

        this.containerLists.get(keyword).add(newObject);
        LOGGER.info(String.format("Added new %s to containment list reference.", keyword));
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
  private EObject createBy(String keyword)
  {
    EObject eObject = null;

    try {
      EClass eClass = (EClass) this.get(keyword);
      eObject = EcoreUtil.create(eClass);
    }
    catch (IllegalArgumentException | ClassCastException e) {
      LOGGER.severe(String.format("Could not create object from %s see error %s", keyword, e.getMessage()));
    }

    return eObject;
  }

  /**
   * <!-- begin-user-doc -->
   * Return the EClassifier of the given keyword, which is the upper case entity
   * name.
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param keyword
   * @return
   */
  private EClassifier get(String keyword)
  {
    return this.stepToEcoreNames.get(keyword);
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
    EClassifier eClassifier = this.get(keyword);

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
    this.containerLists = this.initKeywordToContainmentListsMap(ifc4.eClass().getEAllContainments());
    this.stepToEcoreNames = this.initNameToClassifierMap();

    if (LOGGER.isLoggable(Level.CONFIG)) {

      for (EClassifier eClassifier : Ifc4Package.eINSTANCE.getEClassifiers()) {

        if (eClassifier instanceof EClass) {

          EClass eClass = (EClass) eClassifier;
          LOGGER.config("CLASS: " + eClass.getName());
        }

        if (eClassifier instanceof EDataType) {

          EDataType eDataType = (EDataType) eClassifier;

          if (eDataType instanceof EEnum) {

            EEnum eEnum = (EEnum) eDataType;
            LOGGER.config("ENUM: " + eEnum.getName() + " " + eEnum.getELiterals());
          } else {

            LOGGER.config("D-TYPE: " + eDataType.getName());
          }
        }
      }
    }
  }

  @SuppressWarnings("rawtypes")
  private Map<String, EList> initKeywordToContainmentListsMap(EList<EReference> containments)
  {
    Map<String, EList> containerLists = new HashMap<>();

    // all containment references in IFC4
    //
    for (EReference eReference : containments) {
      Object containmentList = ifc4.eGet(eReference);

      if (containmentList instanceof EList) {

        // save references to containment lists of overall ifc4 container
        //
        containerLists.put(eReference.getName().toUpperCase(), (EList<?>) containmentList);
      }
    }
    return containerLists;
  }

  private Map<String, EClassifier> initNameToClassifierMap()
  {
    Map<String, EClassifier> stepToEcoreNames = new HashMap<String, EClassifier>();

    for (EClassifier eClassifier : Ifc4Package.eINSTANCE.getEClassifiers()) {

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
  public IFC4 getIfc4()
  {
    return ifc4;
  }
}
