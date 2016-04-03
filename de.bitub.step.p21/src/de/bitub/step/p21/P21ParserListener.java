/*
 * Copyright (c) 2014 Bernold Kraft, Sebastian Riemschüssel, Torsten Krämer (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Initial commit by Riemi @ 08.02.2015.
 */
package de.bitub.step.p21;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.misc.Pair;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.bitub.step.p21.StepParser.DataSectionContext;
import de.bitub.step.p21.StepParser.HeaderSectionContext;
import de.bitub.step.p21.StepParser.IntegerContext;
import de.bitub.step.p21.StepParser.ListContext;
import de.bitub.step.p21.StepParser.ParameterContext;
import de.bitub.step.p21.StepParser.ParameterListContext;
import de.bitub.step.p21.StepParser.RealContext;
import de.bitub.step.p21.StepParser.SimpleEntityInstanceContext;
import de.bitub.step.p21.StepParser.StringContext;
import de.bitub.step.p21.StepParser.TypedContext;
import de.bitub.step.p21.StepParser.UntypedContext;
import de.bitub.step.p21.header.Header;
import de.bitub.step.p21.mapper.StepToModel;
import de.bitub.step.p21.util.IndexUtilImpl;
import de.bitub.step.p21.util.LoggerHelper;
import de.bitub.step.p21.util.StepUntypedToEcore;
import de.bitub.step.p21.util.XPressModel;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 08.02.2015
 */
public class P21ParserListener extends StepParserBaseListener implements StepParserListener
{
  private static final Logger LOGGER = LoggerHelper.init(Level.WARNING, P21ParserListener.class);

  // store entities with forward references
  //
  private Map<String, EObject> forwards = new HashMap<>();

  // map entity instance names (IDs #12) to entities for later reuse
  //
  private Map<String, EObject> entities = new HashMap<String, EObject>();

  // helper class to create and save model elements
  //
  private StepToModel util = null;

  // save information when forward referenced type is abstract and can't be guessed at this point in time
  //
  Map<String, List<Pair<EObject, EStructuralFeature>>> abstractRefs = new HashMap<>();

  // save different variables for current entity subtree walk
  //
  private EObject curObject = null;
  private String curKeyword = null;
  private String curId = null;

  // save the index for the current parameter in parameterList, stack value if goiing deeper
  //
  private IndexUtilImpl index = new IndexUtilImpl();

  private Mode mode = Mode.DATA;
  public Header header = null;

  private boolean isInList = false;
  private List<Object> eList = null;

  public enum Mode
  {
    HEADER, DATA, FOOTER, DONE
  }

  public P21ParserListener(StepToModel stepToModel)
  {
    this.util = stepToModel;
  }

  @Override
  public void enterHeaderSection(HeaderSectionContext ctx)
  {
    // set header mode if not already set
    //
    mode = Mode.HEADER;

    // create header class to collect all information
    //
    header = new Header();
  }

  /**
   * Set all header entities from processed header section.
   * (Could by improved.)
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitHeaderSection(de.bitub.step.p21.StepParser.HeaderSectionContext)
   */
  @Override
  public void exitHeaderSection(HeaderSectionContext ctx)
  {
    // get all parameters for the header
    //
    List<ParameterContext> fileDescriptionParameters = ctx.fileDesciption.parameterList().parameters;
    List<ParameterContext> fileNameParameters = ctx.fileName.parameterList().parameters;
    List<ParameterContext> fileSchemaParameters = ctx.fileSchema.parameterList().parameters;

    // needed header entities
    //
    Header.FileDescription fileDescription = header.fileDescription;
    Header.FileName fileName = header.fileName;
    Header.FileSchema fileSchema = header.fileSchema;

    // set file description header
    //
    if (!ctx.fileDesciption.parameterList().isEmpty()) {

      if (fileDescriptionParameters.get(0).untyped().list() != null) {
        for (ParameterContext parameterContext : fileDescriptionParameters.get(0).untyped().list().parameters) {
          fileDescription.description.add(parameterContext.untyped().string().getText());
        }
      }

      if (fileDescriptionParameters.get(1).untyped().string() != null) {
        fileDescription.implementationLevel = fileDescriptionParameters.get(1).untyped().string().getText();
      }
    }

    // set file name header
    //
    if (!ctx.fileName.parameterList().isEmpty()) {

      if (fileNameParameters.get(0).untyped().string() != null) {
        fileName.name = fileNameParameters.get(0).untyped().string().getText();
      }

      if (fileNameParameters.get(1).untyped().string() != null) {
        fileName.setTimeStamp(fileNameParameters.get(1).untyped().string().getText());
      }

      if (fileNameParameters.get(2).untyped().list() != null) {
        for (ParameterContext parameterContext : fileNameParameters.get(2).untyped().list().parameters) {
          fileName.author.add(parameterContext.untyped().string().getText());
        }
      }

      if (fileNameParameters.get(3).untyped().list() != null) {
        for (ParameterContext parameterContext : fileNameParameters.get(3).untyped().list().parameters) {
          fileName.organization.add(parameterContext.untyped().string().getText());
        }
      }

      if (fileNameParameters.get(4).untyped().string() != null) {
        fileName.preprocessorVersion = fileNameParameters.get(4).untyped().string().getText();
      }

      if (fileNameParameters.get(5).untyped().string() != null) {
        fileName.originatingSystem = fileNameParameters.get(5).untyped().string().getText();
      }

      if (fileNameParameters.get(6).untyped().string() != null) {
        fileName.authorization = fileNameParameters.get(6).untyped().string().getText();
      }
    }

    // set file schema header
    //
    if (!ctx.fileSchema.parameterList().isEmpty()) {

      if (fileSchemaParameters.get(0).untyped().list() != null) {
        for (ParameterContext parameterContext : fileSchemaParameters.get(0).untyped().list().parameters) {
          fileSchema.schemaIdentifiers.add(parameterContext.untyped().string().getText());
        }
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#enterDataSection(de.bitub.step.p21.StepParser.DataSectionContext)
   */
  @Override
  public void enterDataSection(DataSectionContext ctx)
  {
    mode = Mode.DATA;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitInteger(de.bitub.step.p21.StepParser.IntegerContext)
   */
  @Override
  public void exitInteger(IntegerContext ctx)
  {
    if (!isInList) {

      if (null == curObject) {
        return;
      }
      StepUntypedToEcore.eInteger(index.current(), curObject, ctx.getText());
    } else {

      if (eList != null) {
        this.eList.add(Integer.parseInt(ctx.getText()));
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitString(de.bitub.step.p21.StepParser.StringContext)
   */
  @Override
  public void exitString(StringContext ctx)
  {
    if (mode == Mode.DATA && this.curObject != null) {
      if (!isInList) {

        StepUntypedToEcore.eString(index.current(), curObject, ctx.getText());
      } else
        if (eList != null) {
          try {
            this.eList.add(ctx.getText());
          }
          catch (ArrayStoreException exception) {
            LOGGER.severe(exception.getMessage());
          }
        }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitReal(de.bitub.step.p21.StepParser.RealContext)
   */
  @Override
  public void exitReal(RealContext ctx)
  {
    if (mode == Mode.DATA && this.curObject != null) {
      if (!isInList) {

        StepUntypedToEcore.eReal(index.current(), curObject, ctx.getText());
      } else {

        if (eList != null) {
          try {
            this.eList.add(Double.parseDouble(ctx.getText()));
          }
          catch (ArrayStoreException exception) {
            LOGGER.severe(exception.getMessage());
          }
        }
      }
    }
  }

  private EObject resolveReference(String referenceId)
  {
    // this is a backwards reference, which already holds the right object
    //
    if (this.entities.containsKey(referenceId)) {
      return this.entities.get(referenceId);
    }

    // this is a forward reference   

    // first time create an placeholder object
    //
    if (!forwards.containsKey(referenceId)) {
      EStructuralFeature eStructuralFeature =
          isInList ? XPressModel.p21FeatureBy(curObject, index.upper()) : XPressModel.p21FeatureBy(curObject, index.current());

      if (eStructuralFeature.getEType() instanceof EClass) {
        EClass eClass = (EClass) eStructuralFeature.getEType();

        if (eClass.isAbstract()) {
          if (abstractRefs.containsKey(referenceId)) {

            abstractRefs.get(referenceId).add(new Pair<EObject, EStructuralFeature>(curObject, eStructuralFeature));
          } else {

            List<Pair<EObject, EStructuralFeature>> pairs = new ArrayList<>();
            pairs.add(new Pair<EObject, EStructuralFeature>(curObject, eStructuralFeature));
            abstractRefs.put(referenceId, pairs);
          }
        }
      }

      LOGGER.info(String.format("Forward reference %s in %s of type %s", referenceId, curObject.eClass().getName(),
          eStructuralFeature.getEType().getName()));

      // create empty object if not already there
      //
      EObject preCreated = this.util.addElementByKeyword(eStructuralFeature.getEType().getName());

      // save forward created object as reference
      //
      if (preCreated != null) {
        this.forwards.put(referenceId, preCreated);

        if (isInList) {

        } else {

          StepUntypedToEcore.setEStructuralFeature(index.current(), curObject, preCreated);
          LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + preCreated);
        }
      }
      return preCreated;

    } else {

      EObject placeholder = forwards.get(referenceId);

      // this time the placeholder already exists, use it
      //
      StepUntypedToEcore.setEStructuralFeature(index.current(), curObject, placeholder);
      LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + placeholder);

      return placeholder;
    }

  }

  private void resolveEnumeration(String literal)
  {
    EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(curObject, index.current());

    if (eStructuralFeature instanceof EAttribute) {
      EDataType eDataType = ((EAttribute) eStructuralFeature).getEAttributeType();
      String enumNameUppercase = eDataType.getName().toUpperCase();

      Object created = this.util.createEnumBy(enumNameUppercase, literal);

      if (created != null) {

        this.curObject.eSet(eStructuralFeature, created);
        LOGGER.info(String.format("%s -> %s = %s", enumNameUppercase, literal, created));
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitUntyped(de.bitub.step.p21.StepParser.UntypedContext)
   */
  @Override
  public void exitUntyped(UntypedContext ctx)
  {
    if (mode == Mode.DATA && this.curObject != null) {

      if (ctx.ENTITY_INSTANCE_NAME() != null) {
        String referenceId = ctx.ENTITY_INSTANCE_NAME().getText();

        if (!isInList) {

          EObject referencedObject = this.resolveReference(referenceId);

          try {
            StepUntypedToEcore.setEStructuralFeature(index.current(), curObject, referencedObject);
            LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + referencedObject.eClass().getName());
          }
          catch (ClassCastException exception) {
            LOGGER.severe("ClassCastException: Un-resolvable REFERENCE: " + referenceId + ": " + exception.getMessage());
          }
          catch (Exception e) {
            LOGGER.severe("Exception Un-resolvable REFERENCE: " + referenceId + ": " + e.getMessage());
          }

        } else {

          try {
            this.eList.add(this.entities.get(referenceId));
          }
          catch (ArrayStoreException | IllegalArgumentException | NullPointerException exception) {

            EObject eObject = this.resolveReference(referenceId);

            try {
              this.eList.add(eObject);
              LOGGER.severe("Fallback added " + referenceId + " | " + eObject + " | " + exception.getStackTrace());
            }
            catch (ArrayStoreException | IllegalArgumentException | NullPointerException e) {
              LOGGER.severe(this.eList + " - " + referenceId + " | " + eObject + " | " + exception);
            }
          }
        }
      }

      if (ctx.ENUMERATION() != null) {

        // .ILLUMINANCEUNIT. -> ILLUMINANCEUNIT
        //
        String literal = ctx.ENUMERATION().getText().replace(".", "");

        // it is a simple built in Boolean
        //
        if (literal.equals("T") || literal.equals("F")) {
          StepUntypedToEcore.eBoolean(index.current(), curObject, literal);
        }

        try {
          this.resolveEnumeration(literal);
        }
        catch (Exception e) {
          LOGGER.severe("Could not resolve enumeration literal.");
        }
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitTyped(de.bitub.step.p21.StepParser.TypedContext)
   */
  @Override
  public void enterTyped(TypedContext ctx)
  {
    String innerKeyword = ctx.keyword().STANDARD_KEYWORD().getText();

    if (this.curObject != null) { // IfcMeasureWithUnit

      // calculate index where to put current typed value
      //     
      EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(curObject, this.index.current());

      // hold the reference to the SELECT type
      //
      if (eStructuralFeature instanceof EReference) {
        EReference eReference = (EReference) eStructuralFeature;

        // the SELECT class which is referenced
        //
        EClass eReferencedType = eReference.getEReferenceType(); // IfcValue        
        EObject eReferenedInstance = util.addElementByKeyword(eReferencedType.getName());

        // find mapped attribute
        //
        EList<EStructuralFeature> eReferencedTypeStructuralFeatures = eReferencedType.getEAllStructuralFeatures();
        EStructuralFeature eReferenedInstanceFeature = null;
        for (EStructuralFeature selectedType : eReferencedTypeStructuralFeatures) {

          if (selectedType.getName().equalsIgnoreCase(innerKeyword)) {
            // this is the structural feature from the select which is needed
            //
            eReferenedInstanceFeature = eReferencedType.getEStructuralFeature(selectedType.getName());
          }
        }

        if (XPressModel.isMapped(eReferenedInstanceFeature)) {

          String datatype = XPressModel.getDataTypeOf(eReferenedInstanceFeature);
          switch (datatype) {
            case XPressModel.DatatypeRefStrings.DOUBLE:
              LOGGER.config(String.format("Mapped SELECT with type double -> %s", datatype));

              eReferenedInstance.eSet(eReferenedInstanceFeature, Double.parseDouble(ctx.parameter().untyped().real().getText()));
              break;

            case XPressModel.DatatypeRefStrings.INT:
              LOGGER.config(String.format("Mapped SELECT with type int: %s", datatype));

              eReferenedInstance.eSet(eReferenedInstanceFeature, Integer.parseInt(ctx.parameter().untyped().integer().getText()));
              break;

            case XPressModel.DatatypeRefStrings.BOOLEAN: // IFC_BOOLEAN
              LOGGER.config(String.format("Mapped SELECT with type boolean: %s", datatype));

              String booleanValue = ctx.parameter().getText();
              eReferenedInstance.eSet(eReferenedInstanceFeature, booleanValue.equalsIgnoreCase(".T."));
              break;

            case XPressModel.DatatypeRefStrings.LOGICAL: // IFC_LOGICAL
              LOGGER.config(String.format("Mapped SELECT with type Boolean: %s", datatype));

              String logicalValue = ctx.parameter().getText();
              if (logicalValue.equalsIgnoreCase(".U.")) {

                eReferenedInstance.eSet(eReferenedInstanceFeature, null);
              } else {

                eReferenedInstance.eSet(eReferenedInstanceFeature, logicalValue.equalsIgnoreCase(".T."));
              }
              break;

            case XPressModel.DatatypeRefStrings.STRING:
              LOGGER.config(String.format("Mapped SELECT with type String: %s", datatype));

              eReferenedInstance.eSet(eReferenedInstanceFeature, ctx.parameter().untyped().string().getText());
              break;

            default:
              LOGGER.warning(String.format("Mapped SELECT which stayed UNRESOLVED: %s", eReferenedInstance));
          }

          // set reference to current object
          //
          this.curObject.eSet(eStructuralFeature, eReferenedInstance);
        }
      }

      if (eStructuralFeature instanceof EAttribute) {
        EAttribute eAttribute = (EAttribute) eStructuralFeature;
        LOGGER.severe(String.format("Unhandled TYPED feature as attribute %s", eAttribute));
      }
    }
  }

  /**
   * Accesed when the currently parsed entities attribute is a collection type.
   * We save a pointer to the list reference of this particular instance of the
   * entity.
   * </br>
   * The Parser goes to list mode and all subsequent methods react specific to
   * that.
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#enterList(de.bitub.step.p21.StepParser.ListContext)
   */
  @SuppressWarnings("unchecked")
  @Override
  public void enterList(ListContext ctx)
  {
    if (this.curObject != null) {

      EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(this.curObject, this.index.current());

      Object curRef = this.curObject.eGet(eStructuralFeature);

      if (eStructuralFeature.isMany() && curRef instanceof List<?>) {

        this.eList = (List<Object>) curRef;
        LOGGER.config(String.format("Found list %s", eStructuralFeature.getName()));
      } else {

        // TODO should not happen (index maps to correct structural feature)
        // FIXME remove if IfcSite in Xcore is fixed
        //
        LOGGER.severe(String.format("NO list %s", curRef));
      }
    } else {
      LOGGER.severe(String.format("Index (%s) mapping not resolved for %s.", this.index.current(), this.curObject));
    }

    index.levelDown();
    this.isInList = true;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitList(de.bitub.step.p21.StepParser.ListContext)
   */
  @Override
  public void exitList(ListContext ctx)
  {
    index.levelUp();
    this.isInList = false;
    this.eList = null;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#enterSimpleEntityInstance(de.bitub.step.p21.StepParser.SimpleEntityInstanceContext)
   */
  @SuppressWarnings({ "unchecked", "rawtypes" })
  @Override
  public void enterSimpleEntityInstance(SimpleEntityInstanceContext ctx)
  {
    if (mode == Mode.DATA) {

      curId = ctx.id.getText();
      curKeyword = ctx.simpleRecord().keyword().getText();

      if (forwards.containsKey(curId)) {
        curObject = forwards.get(curId);

        boolean isTypeMismatch = !curKeyword.equalsIgnoreCase(curObject.eClass().getName());
        if (isTypeMismatch) { // could be a super class or a select or a proxy
          EObject selectedObject = util.addElementByKeyword(curKeyword);
          EStructuralFeature feature = findNestedPlaceToPut(curObject, curKeyword, selectedObject);

          if (null != feature) {
            curObject.eSet(feature, selectedObject);
          }

          if (null == feature) { // it is a proxy

            for (EStructuralFeature searchType : selectedObject.eClass().getEAllStructuralFeatures()) {
              if (searchType.getEType().equals(curObject.eClass())) {
                if (searchType.isMany()) {
                  ((EList) selectedObject.eGet(searchType)).add(curObject);
                } else {
                  selectedObject.eSet(searchType, curObject);
                }
              }
            }
          }
          curObject = selectedObject;
        }
      } else {

        // save created object which maps to keyword
        //
        this.curObject = util.addElementByKeyword(this.curKeyword);

        // handle abstract entity references
        //
        if (abstractRefs.containsKey(curId)) {
          for (Pair<EObject, EStructuralFeature> pair : abstractRefs.get(curId)) {
            try {
              pair.a.eSet(pair.b, curObject);
            }
            catch (ClassCastException exception) {
              LOGGER.severe("Some abstract problems." + exception.toString());
            }
          }
        }
      }

      // cache the new object and make it accesible by its id
      //
      EObject eObjectOrNull = this.entities.put(this.curId, this.curObject);
      LOGGER.info("Save reference with id " + this.curId + " of type " + this.curObject);

      // clean up forward reference
      //
      boolean hasPreviousReference = null != eObjectOrNull;
      if (hasPreviousReference) { // there was a value before

        this.curObject = forwards.remove(ctx.id.getText());
        LOGGER.severe(String.format("Overwrite existing object %s with %s", eObjectOrNull, this.curObject));
      } else {

        LOGGER.info(String.format("Add new object %s", this.curObject));
      }
    }
  }

  private EStructuralFeature findNestedPlaceToPut(EObject searchIn, String searchFor, EObject selectedObject)
  {
    for (EStructuralFeature curFeature : searchIn.eClass().getEAllStructuralFeatures()) {

      // found in first level by name
      //
      if (curFeature.getName().equalsIgnoreCase(searchFor)) {

        return curFeature;
      } else {

        // see if it is a specialized value
        //
        for (EClass supertype : selectedObject.eClass().getEAllSuperTypes()) {

          if (supertype.getName().equalsIgnoreCase(curFeature.getName())) {
            return curFeature;
          }
        } // eo for
      }
    } // eo for
    return null;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#enterParameterList(de.bitub.step.p21.StepParser.ParameterListContext)
   */
  @Override
  public void enterParameterList(ParameterListContext ctx)
  {
    index.levelDown();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitParameter(de.bitub.step.p21.StepParser.ParameterContext)
   */
  @Override
  public void exitParameter(ParameterContext ctx)
  {
    ParserRuleContext parentCtx = ctx.getParent();

    if (parentCtx instanceof StepParser.ParameterListContext || parentCtx instanceof StepParser.ListContext) {
      index.up();
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#exitParameterList(de.bitub.step.p21.StepParser.ParameterListContext)
   */
  @Override
  public void exitParameterList(ParameterListContext ctx)
  {
    index.levelUp();
  }

  // public API /////////////////////////////////////////////////////////////////////////////

  public EObject data()
  {
    return util.getSchemaContainer();
  }

  public Header header()
  {
    return header;
  }
}
