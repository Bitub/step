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

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.ecore.EAnnotation;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
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

  Ifc4Package ifc4Package = null;

  private static final String XPRESS_MODEL_ANNOTATION_SRC = "http://www.bitub.de/express/XpressModel";

  private Map<String, Kind> kindByName = Collections.emptyMap();
  private Map<String, String> datatypeRefByName = Collections.emptyMap();
  private Map<String, String> selectByName = Collections.emptyMap();

  public enum Kind
  {
    NEW, GENERATED, MAPPED, PROXY
  }

  public enum DatatypeRef
  {
    DOUBLE, INT, STRING, BOOLEAN, DOUBLE_ARRAY
  }

  public XPressModel()
  {
    this(Ifc4Package.eINSTANCE);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public XPressModel(Ifc4Package ifc4Package)
  {
    this.ifc4Package = ifc4Package;
    init();
  }

  private void init()
  {
    List<EClassifier> eClassifiers = this.ifc4Package.getEClassifiers();

    // iterate about model classes, enums, etc.
    //
    for (EClassifier eClassifier : eClassifiers) {
      addAnnotatedEntity(eClassifier);
    }
  }

  private void addAnnotatedEntity(EClassifier eClassifier)
  {
    String name = EcoreUtil.getAnnotation(eClassifier, XPRESS_MODEL_ANNOTATION_SRC, "name");
    if (null != name) {
      name = name.toUpperCase();

      String kind = EcoreUtil.getAnnotation(eClassifier, XPRESS_MODEL_ANNOTATION_SRC, "kind");
      if (null != kind) {
        switch (kind) {
          case "new":
            this.kindByName.put(name, Kind.NEW);
            break;
          case "generated":
            this.kindByName.put(name, Kind.GENERATED);
            break;
          case "mapped":
            this.kindByName.put(name, Kind.MAPPED);
            break;
          case "proxy":
            this.kindByName.put(name, Kind.PROXY);
            break;
        }
      }

      String datatypeRef = EcoreUtil.getAnnotation(eClassifier, XPRESS_MODEL_ANNOTATION_SRC, "kidatatypeRefnd");
      if (null != datatypeRef) {
        this.datatypeRefByName.put(name, datatypeRef);
      }

      String select = EcoreUtil.getAnnotation(eClassifier, XPRESS_MODEL_ANNOTATION_SRC, "select");
      if (null != select) {
        this.selectByName.put(name, select);
      }
    }

  }

  /**
   * Get type of model object. Can be GENERATED, NEW, MAPPED or PROXY.
   * 
   * @param entityName
   * @return
   */
  public Kind getKindOf(String entityName) // name of class
  {
    System.out.println(entityName + " kind = " + this.kindByName.get(entityName.toUpperCase()));
    return this.kindByName.get(entityName.toUpperCase());
  }

  /**
   * Get data type reference. Can be DOUBLE, INT, STRING, BOOLEAN or
   * DOUBLE_ARRAY.
   * 
   * @param entityName
   * @return
   */
  public String getDatatypeRefOf(String entityName) // name of class
  {
    System.out.println(entityName + " datatypeRef = " + this.datatypeRefByName.get(entityName.toUpperCase()));
    return this.datatypeRefByName.get(entityName.toUpperCase());
  }

  /**
   * @param entityName
   * @return
   */
  public String getSelectOf(String entityName) // name of class
  {
    System.out.println(entityName + " select = " + this.selectByName.get(entityName.toUpperCase()));
    return this.selectByName.get(entityName.toUpperCase());
  }

  public static void main(String[] args)
  {
    XPressModel model = new XPressModel();
    model.getKindOf("IfcDerivedMeasureValue");
    EObject ifcEntity = model.getEObjectFor("IfcDerivedMeasureValue");
    System.out.println(ifcEntity);
    model.setAttribute(ifcEntity, 0, 3.0);
  }

  public void setAttribute(EObject ifcEntity, int index, Object parsedValue)
  {
    EStructuralFeature eStructuralFeature = ifcEntity.eClass().getEStructuralFeatures().get(index);
    this.getKindOf(eStructuralFeature.getName());
//    this.toString(eStructuralFeature.getEType());
    ifcEntity.eSet(eStructuralFeature, parsedValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param string
   */
  private EObject getEObjectFor(String string)
  {
    EClassifier eClassifier = Ifc4Package.eINSTANCE.getEClassifier(string);
    EObject eObject = null;

    if (eClassifier instanceof EClass) {
      eObject = EcoreUtil.create((EClass) eClassifier);
    }

//    this.toString(eClassifier);

    return eObject;
  }

  public void toString(EClassifier classifier)
  {
    System.out.println(classifier.getName());
    System.out.print("  ");

    if (classifier instanceof EClass) {
      EClass eClass = (EClass) classifier;

      for (EAnnotation annotation : eClass.getEAnnotations()) {
        System.out.println(this.printAnnotation(annotation));
      }

      System.out.println("ATTR: ");
      for (EAttribute attribute : eClass.getEAttributes()) {
        System.out.print("     " + attribute.getName() + " / ");
        for (EAnnotation annotation : attribute.getEAnnotations()) {
          System.out.println(this.printAnnotation(annotation));
        }
      }

      if (!eClass.getEAttributes().isEmpty() && !eClass.getEReferences().isEmpty()) {
        System.out.println();
        System.out.print("  ");
      }

      System.out.print("REF: ");
      for (EReference reference : eClass.getEReferences()) {
        System.out.print(reference.getName() + " ");
        for (EAnnotation annotation : reference.getEAnnotations()) {
          System.out.println(this.printAnnotation(annotation));
        }
      }
    } else
      if (classifier instanceof EEnum) {

        EEnum eEnum = (EEnum) classifier;
        System.out.print("ENUM: ");
        for (EEnumLiteral literal : eEnum.getELiterals()) {
          System.out.print(literal.getName() + " ");
          for (EAnnotation annotation : literal.getEAnnotations()) {
            System.out.println(this.printAnnotation(annotation));
          }
        }
      } else {
        System.out.print("DT: ");
        if (classifier instanceof EDataType) {
          EDataType eDataType = (EDataType) classifier;
          System.out.print(eDataType.getInstanceClassName());
          for (EAnnotation annotation : eDataType.getEAnnotations()) {
            System.out.println(this.printAnnotation(annotation));
          }
        }
      }
    System.out.println();
  }

  private String printAnnotation(EAnnotation annotation)
  {
    String result = "";

    for (Entry<String, String> entry : annotation.getDetails().entrySet()) {

      result += entry.getKey() + " - " + entry.getValue() + " | ";
    }

    return result;

  }
}
