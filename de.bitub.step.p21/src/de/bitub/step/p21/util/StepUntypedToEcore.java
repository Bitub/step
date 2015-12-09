/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 16.04.2015.
 */
package de.bitub.step.p21.util;

import java.io.IOException;
import java.util.List;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import de.bitub.step.p21.mapper.StepToModel;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.04.2015
 */
public class StepUntypedToEcore
{

  public static final Logger LOGGER = Logger.getLogger(StepUntypedToEcore.class.getName());

  static {
    try {

      // This block configure the logger with handler and formatter
      //
      FileHandler fh = new FileHandler("logs/" + StepUntypedToEcore.class.getSimpleName() + ".log");
      SimpleFormatter formatter = new SimpleFormatter();
      fh.setFormatter(formatter);

      StepUntypedToEcore.LOGGER.setLevel(Level.WARNING);
      StepUntypedToEcore.LOGGER.addHandler(fh);
      StepUntypedToEcore.LOGGER.setUseParentHandlers(false);
    }
    catch (SecurityException e) {
      e.printStackTrace();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  public static void eString(int index, EObject eObject, String value, StepToModel util)
  {
    StepUntypedToEcore.setEStructuralFeature(index, eObject, value, util);
  }

  public static void setEStructuralFeature(int parameterIndex, EObject eObject, Object value, StepToModel util)
  {
    EList<EStructuralFeature> eStructuralFeatures = eObject.eClass().getEAllStructuralFeatures();

    int structuralIndex = StepUntypedToEcore.calcIndex(parameterIndex, eStructuralFeatures);

    LOGGER.info("INDEX: text: " + parameterIndex + "  struc: " + structuralIndex + " all: " + eStructuralFeatures.size());

    if (structuralIndex == -1) {
      LOGGER.warning("" + structuralIndex);
      return;
    }

    EStructuralFeature eStructuralFeature = eStructuralFeatures.get(structuralIndex);

    // is it an attribute
    //
    if (eStructuralFeature instanceof EAttribute) {

      EAttribute eAttribute = (EAttribute) eStructuralFeature;
//      LOGGER.info("It's an EAttribute: " + eAttribute);

      StepUntypedToEcore.setEAttribute(eAttribute, eObject, value);
    }

    // is it an reference
    //
    if (eStructuralFeature instanceof EReference) {

      EReference eReference = (EReference) eStructuralFeature;
      LOGGER.info(eReference.getName() + " references " + eReference.getEType().getName());

      if (value instanceof EObject) {
        EObject eValue = (EObject) value;
        boolean isNotMatched = !eValue.eClass().getName().equals(eReference.getEType().getName());

        LOGGER.info("New Value " + value + " != " + eReference.getEType().getName() + " ? " + isNotMatched);
        if (isNotMatched) {

          EClass eSelectClass = (EClass) eReference.getEType();

          // only when not abstract
          //
          if (!eSelectClass.isAbstract()) {
            EObject eSelectInstance = EcoreUtil.create(eSelectClass); // BOOM

            EStructuralFeature refersToEntity = null;

            for (EStructuralFeature curEStructuralFeature : eSelectClass.getEStructuralFeatures()) {

              boolean isReferingTypeSameAsOriginalValue =
                  curEStructuralFeature.getEType().getName().equals(eValue.eClass().getName());
              if (isReferingTypeSameAsOriginalValue) {
                LOGGER.warning("FOUND ERef: " + curEStructuralFeature);
                refersToEntity = curEStructuralFeature;
              }
            }

            if (refersToEntity != null) {

              StepUntypedToEcore.setEReference((EReference) refersToEntity, eSelectInstance, value);
              StepUntypedToEcore.setEReference(eReference, eObject, eSelectInstance);
              return;
            }
          }
        }
      }

      // TODO handle SELECT
      StepUntypedToEcore.setEReference(eReference, eObject, value);
    }
  }

  public static int calcIndex(int parameterIndex, EList<EStructuralFeature> eStructuralFeatures)
  {

    P21ParameterIterator<EStructuralFeature> iterator = new P21ParameterIterator<>(eStructuralFeatures);

    int i = 0;
    while (iterator.hasNext() && i <= parameterIndex) {
      i++;
      iterator.next();
    }
    return iterator.index();
  }

  private static void setEAttribute(EAttribute eAttribute, EObject eObject, Object value)
  {
    StepUntypedToEcore.set(eAttribute, eObject, value);
  }

  private static void set(EStructuralFeature eFeature, EObject eObject, Object value)
  {
    try {
      LOGGER.info(String.format("SET %s as %s of %s", value, eFeature.getName(), eObject.eClass().getName()));
      eObject.eSet(eFeature, value);
    }
    catch (ClassCastException exception) {
      LOGGER.severe(value + " : " + eFeature.getName() + " " + exception.getMessage());
    }

  }

  private static void setEReference(EReference eReference, EObject eObject, Object value)
  {
    StepUntypedToEcore.set(eReference, eObject, value);
  }

  public static void eInteger(int index, EObject eObject, String value, StepToModel util)
  {
    try {
      LOGGER.info(String.format("SET %s to %s", value, eObject.eClass().getName()));

      int newValue = Integer.parseInt(value, 10);
      StepUntypedToEcore.setEStructuralFeature(index, eObject, newValue, util);
    }
    catch (NumberFormatException exception) {
      LOGGER.warning(exception.getMessage());
    }
  }

  public static void eReal(int index, EObject eObject, String value, StepToModel util)
  {
    try {
      LOGGER.info(String.format("SET %s to %s", value, eObject.eClass().getName()));

      double newValue = Double.parseDouble(value);
      StepUntypedToEcore.setEStructuralFeature(index, eObject, newValue, util);
    }
    catch (NumberFormatException exception) {
      LOGGER.warning(exception.getMessage());
    }
  }

  public static void eBoolean(int index, EObject eObject, String value, StepToModel util)
  {
    try {

      switch (value) {
        case "T":
          StepUntypedToEcore.setEStructuralFeature(index, eObject, new Boolean(true), util);
          break;

        case "F":
          StepUntypedToEcore.setEStructuralFeature(index, eObject, new Boolean(false), util);
          break;

        default:
          break;
      }
    }
    catch (NumberFormatException exception) {
      LOGGER.warning(exception.getMessage());
    }
  }

  public static String eBinary(String text)
  {
    throw new UnsupportedOperationException("Not implemented yet!");
  }

  public static List<?> eList(String text)
  {
    throw new UnsupportedOperationException("Not implemented yet!");
  }
}
