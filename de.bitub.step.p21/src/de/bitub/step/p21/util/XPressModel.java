/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 16.06.2015.
 */
package de.bitub.step.p21.util;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EModelElement;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 16.06.2015
 */
public class XPressModel
{
  private static final String XPRESS_MODEL_ANNOTATION_SRC = "http://www.bitub.de/express/XpressModel";
  private static final String P21_MODEL_ANNOTATION_SRC = "http://www.bitub.de/express/P21";

  private static final String NEW = "new";
  private static final String GENERATED = "generated";
  private static final String MAPPED = "mapped";
  private static final String DELEGATE = "delegate";

  private static final String KIND = "kind";
  private static final String NAME = "name";
  private static final String PATTERN = "pattern";
  private static final String DATATYPE_REF = "datatypeRef";
  private static final String SELECT = "select";

  public enum Kind
  {
    NEW, GENERATED, MAPPED, PROXY
  }

  public interface DatatypeRefStrings
  {
    String DOUBLE = "double";
    String INT = "int";
    String STRING = "string";
    String BOOLEAN = "boolean";
    String LOGICAL = "Boolean";
    String DOUBLE_ARRAY = "double[]";
  }

  public enum DatatypeRef
  {
    DOUBLE, INT, STRING, BOOLEAN, DOUBLE_ARRAY
  }

  /**
   * Get type of model object. Can be GENERATED, NEW.
   * 
   * @param entityName
   * @return
   */
  public Kind getKindOf(String entityName) // name of class
  {
    throw new UnsupportedOperationException();
  }

  public static String getDataTypeOf(EStructuralFeature eStructuralFeature)
  {
    return EcoreUtil.getAnnotation(eStructuralFeature, XPRESS_MODEL_ANNOTATION_SRC, DATATYPE_REF);
  }

  public static boolean isGenerated(EClassifier eClassifier)
  {
    String kind = getKindOf(eClassifier);
    return null != kind && kind.equalsIgnoreCase(GENERATED);
  }

  public static boolean isNew(EClassifier eClassifier)
  {
    String kind = getKindOf(eClassifier);
    return null != kind && kind.equalsIgnoreCase(NEW);
  }

  public static boolean isMapped(EStructuralFeature eStructuralFeature)
  {
    String kind = getKindOf(eStructuralFeature);
    return null != kind && kind.equalsIgnoreCase(MAPPED);
  }

  public static boolean isDelegate(EModelElement eModelElement)
  {
    String kind = getPatternOf(eModelElement);
    return null != kind && kind.equalsIgnoreCase(DELEGATE);
  }

  public static boolean isDelegate(EStructuralFeature eStructuralFeature)
  {
    String kind = getPatternOf(eStructuralFeature);
    return null != kind && kind.equalsIgnoreCase(DELEGATE);
  }

  public static boolean isSelectProxy(EStructuralFeature eStructuralFeature)
  {
    String select = getSelectOf(eStructuralFeature);
    return isDelegate(eStructuralFeature) && null != select;
  }

  public static boolean isSelect(EModelElement eModelElement)
  {
    return null != getSelectOf(eModelElement);
  }

  public static boolean isSelect(EStructuralFeature eStructuralFeature)
  {
    return null != getSelectOf(eStructuralFeature);
  }

  private static String getSelectOf(EModelElement eModelElement)
  {
    return EcoreUtil.getAnnotation(eModelElement, XPRESS_MODEL_ANNOTATION_SRC, SELECT);
  }

  private static String getKindOf(EModelElement eModelElement)
  {
    return XPressModel.geKeyOf(eModelElement, KIND);
  }

  private static String getPatternOf(EModelElement eModelElement)
  {
    return XPressModel.geKeyOf(eModelElement, PATTERN);
  }

  private static String geKeyOf(EModelElement eModelElement, String key)
  {
    if (null == eModelElement) {
      return null;
    }
    return EcoreUtil.getAnnotation(eModelElement, XPRESS_MODEL_ANNOTATION_SRC, key);
  }

  public static EStructuralFeature p21FeatureBy(EObject eObject, int p21Index)
  {
    // filter only @P21 annotated features
    //
    List<EStructuralFeature> annotatedFeatures = eObject.eClass().getEAllStructuralFeatures().parallelStream()
        .filter((feature) -> Objects.nonNull(feature.getEAnnotation(P21_MODEL_ANNOTATION_SRC))).collect(Collectors.toList());

    if (annotatedFeatures.isEmpty() || annotatedFeatures.size() <= p21Index) {
      return null;
    }
    return annotatedFeatures.get(p21Index);
  }

  public void setAttribute(EObject ifcEntity, int index, Object parsedValue)
  {
    EStructuralFeature eStructuralFeature = ifcEntity.eClass().getEStructuralFeatures().get(index);
    this.getKindOf(eStructuralFeature.getName());
    ifcEntity.eSet(eStructuralFeature, parsedValue);
  }

  public static String getName(EStructuralFeature eStructuralFeature)
  {
    return EcoreUtil.getAnnotation(eStructuralFeature, XPRESS_MODEL_ANNOTATION_SRC, NAME);
  }
}
