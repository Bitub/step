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

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
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
import org.eclipse.emf.ecore.util.EcoreUtil;

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
import de.bitub.step.p21.mapper.P21ToModel;
import de.bitub.step.p21.mapper.StepToModel;
import de.bitub.step.p21.mapper.StepToModelImpl;
import de.bitub.step.p21.util.Antlr4Util;
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
  private Map<String, EObject> idToEntity = new HashMap<String, EObject>();

  // helper class to create and save model elements
  //
  private StepToModel util = new StepToModelImpl();

  // save information when forward referenced type is abstract and can't be guessed at this point in time
  //
  Map<String, List<Pair<EObject, EStructuralFeature>>> abstractReferences = new HashMap<>();

  //
  // save different variables for current entity subtree walk
  //

  private EObject curObject = null;
  private String curKeyword = null;

  // save the index for the current parameter in parameterList, stack value if goiing deeper
  //
  private int curParameterIndex = -1;
  private int upperIndex = -1;

  Deque<Integer> parameterIndexStack = new ArrayDeque<Integer>();

  private Mode mode = Mode.HEADER;

  public Header header = null;

  private boolean isInList;
  private List<Object> eList = null;

  private String curIdAsString;

  public enum Context
  {
    LIST, ATTRIBUTES, NESTED_LIST
  }

  public enum Mode
  {
    HEADER, DATA, FOOTER, DONE
  }

  public EObject getContainer()
  {
    return this.util.getIfc4();
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

      StepUntypedToEcore.eInteger(curParameterIndex, curObject, ctx.getText(), util);
    } else {

      if (eList != null) {
        try {
          this.eList.add(Integer.parseInt(ctx.getText()));
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
   * @see de.bitub.step.p21.StepParserBaseListener#exitString(de.bitub.step.p21.StepParser.StringContext)
   */
  @Override
  public void exitString(StringContext ctx)
  {
    if (mode == Mode.DATA && this.curObject != null) {
      if (!isInList) {

        StepUntypedToEcore.eString(curParameterIndex, curObject, ctx.getText(), util);
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

        StepUntypedToEcore.eReal(curParameterIndex, curObject, ctx.getText(), util);
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
    if (this.idToEntity.containsKey(referenceId)) {

      EObject referencedObject = this.idToEntity.get(referenceId);

      return referencedObject;

    } else {

      // this is a forward reference
      //
      LOGGER.info("Forward REFERENCE: " + referenceId);

      // first time create an placeholder object
      //
      if (!forwards.containsKey(referenceId)) {

        // calculate index of parameter
        //
        EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();
        int structuralIndex = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);

        // FIXME use upper index to get correct structural feature when forward reference in list
        //
        if (isInList) {
          structuralIndex = StepUntypedToEcore.calcIndex(upperIndex, eStructuralFeatures);
        }

        if (structuralIndex != -1) {
          // FIXME handle forward referenced proxy (IFCAXIS2PLACEMENT)
          // FIXME handle forward referenced non-abstract supertype, but implemented subtype (IfcFaceBound -> IfcLoop / IfcPolyloop)
          // FIXME forward refernce in LIST 
          EStructuralFeature eStructuralFeature = eStructuralFeatures.get(structuralIndex);

          if (eStructuralFeature.getEType() instanceof EClass) {
            EClass eClass = (EClass) eStructuralFeature.getEType();

            if (eClass.isAbstract()) {
              if (abstractReferences.containsKey(referenceId)) {

                abstractReferences.get(referenceId).add(new Pair<EObject, EStructuralFeature>(curObject, eStructuralFeature));
              } else {

                List<Pair<EObject, EStructuralFeature>> pairs = new ArrayList<>();
                pairs.add(new Pair<EObject, EStructuralFeature>(curObject, eStructuralFeature));
                abstractReferences.put(referenceId, pairs);
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
            LOGGER.info("Forward PRECREATEd: " + preCreated);
            this.forwards.put(referenceId, preCreated);

            try {
              StepUntypedToEcore.setEStructuralFeature(curParameterIndex, curObject, preCreated, util);
              LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + preCreated);
            }
            catch (Exception e) {
              LOGGER.warning("Exception Un-resolvable REFERENCE: " + referenceId + ": " + e.getMessage());
            }
          }
          return preCreated;
        } else {

          LOGGER.severe(String.format("BAD INDEX", referenceId, curObject.eClass().getName()));
          return null;
        }
      } else {

        EObject placeholder = forwards.get(referenceId);

        // this time the placeholder already exists, use it
        //
        try {
          StepUntypedToEcore.setEStructuralFeature(curParameterIndex, curObject, placeholder, util);
          LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + placeholder);
        }
        catch (Exception exception) {
          LOGGER.warning("Un-resolvable REFERENCE: " + referenceId + ": " + exception.getMessage());
        }
        return placeholder;
      }
    }
  }

  private void resolveEnumeration(String literal)
  {
    // calculate index of parameter
    //
    EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();
    EStructuralFeature eStructuralFeature =
        eStructuralFeatures.get(StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures));

    if (eStructuralFeature instanceof EAttribute) {

      EDataType eDataType = ((EAttribute) eStructuralFeature).getEAttributeType();
      String enumNameUppercase = eDataType.getName().toUpperCase();

      // create the enumeration
      //
      Object created = this.util.createEnumBy(enumNameUppercase, literal);

      // set enumeration to object
      //
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
            StepUntypedToEcore.setEStructuralFeature(curParameterIndex, curObject, referencedObject, util);
            LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + referencedObject.eClass().getName());
          }
          catch (ClassCastException exception) {
            LOGGER.severe("ClassCastException: Un-resolvable REFERENCE: " + referenceId + ": " + exception.getMessage());
          }
          catch (Exception e) {
            LOGGER.severe("Exception Un-resolvable REFERENCE: " + referenceId + ": " + e.getMessage());
          }

        } else {

          EObject eObject = this.resolveReference(referenceId); // FIXME issues with list 

          // FIXME handle abstract forward reference !!! IFcObject -> IfcWallStandardType in IfcRelDefinesByType
          // FIXME handle forward references in lists e.g. #34102=IFCPRESENTATIONSTYLEASSIGNMENT((#35061));
          // FIXME handle forward supertypes (IfcUnit forward now IfcSIUnit)
          //
          try {
            LOGGER.severe(String.format("BEFORE ADD %s", this.eList));

            this.eList.add(this.idToEntity.get(referenceId));

            LOGGER.severe(String.format("ADD %s TO %s", this.idToEntity.get(referenceId), this.eList));
          }
          catch (ArrayStoreException | IllegalArgumentException | NullPointerException exception) {

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
          StepUntypedToEcore.eBoolean(curParameterIndex, curObject, literal, util);
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

    System.out.println(curObject);

    if (this.curObject != null) { // IfcMeasureWithUnit

      //FIXME check before if it is proxy
      

      // calculate index where to put current typed value
      //
      EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();

      int index = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);

      if (index != -1) {
        EStructuralFeature eStructuralFeature = eStructuralFeatures.get(index);

        LOGGER.info(String.format("TYPED with name %s as parameter into %s", innerKeyword, eStructuralFeature.getName()));

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
          String namedElement = null;
          for (EStructuralFeature selectedType : eReferencedTypeStructuralFeatures) {

            if (selectedType.getName().equalsIgnoreCase(innerKeyword)) {
              namedElement = selectedType.getName();
            }
          }

          // this is the structural feature from the select which is needed
          //
          EStructuralFeature eReferenedInstanceFeature = eReferencedType.getEStructuralFeature(namedElement);
          // FIX handle null better

          if (eReferenedInstanceFeature == null) {
            return;
          }
          String kind = EcoreUtil.getAnnotation(eReferenedInstanceFeature, "http://www.bitub.de/express/XpressModel", "kind");

          if (kind.equals("mapped")) {

            String datatype =
                EcoreUtil.getAnnotation(eReferenedInstanceFeature, "http://www.bitub.de/express/XpressModel", "datatypeRef");

            // what type is it mapped to
            //
            switch (datatype) {
              case "double":
                LOGGER.config(String.format("Mapped SELECT with type double -> %s", datatype));

                eReferenedInstance.eSet(eReferenedInstanceFeature,
                    Double.parseDouble(ctx.parameter().untyped().real().getText()));
                break;

              case "int":
                LOGGER.config(String.format("Mapped SELECT with type int: %s", datatype));

                eReferenedInstance.eSet(eReferenedInstanceFeature,
                    Integer.parseInt(ctx.parameter().untyped().integer().getText()));
                break;

              case "boolean": // IFC_BOOLEAN
                LOGGER.config(String.format("Mapped SELECT with type boolean: %s", datatype));

                String booleanValue = ctx.parameter().getText();
                if (booleanValue.equalsIgnoreCase(".T.")) {

                  eReferenedInstance.eSet(eReferenedInstanceFeature, true);
                } else {

                  eReferenedInstance.eSet(eReferenedInstanceFeature, false);
                }
                break;

              case "Boolean": // IFC_LOGICAL
                LOGGER.config(String.format("Mapped SELECT with type Boolean: %s", datatype));

                String logicalValue = ctx.parameter().getText();
                if (logicalValue.equalsIgnoreCase(".U.")) {

                  eReferenedInstance.eSet(eReferenedInstanceFeature, null);
                }
                break;

              case "String":
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

          LOGGER.warning(String.format("TYPED feature as attribute %s", eAttribute));
        }
      } else {
        System.out.println(String.format("SEVERE %s %s %s", curObject, curParameterIndex, ctx.getText()));
        System.out.println(curParameterIndex + " " + XPressModel.p21FeatureBy(curObject, curParameterIndex));
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

      // get the correct structural feature to access the list
      //
      EList<EStructuralFeature> eStructuralFeatures = this.curObject.eClass().getEAllStructuralFeatures();
      int index = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);

      if (index != -1) {
        EStructuralFeature eStructuralFeature = eStructuralFeatures.get(index);

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
        LOGGER.severe(String.format("Index (%s) mapping not resolved for %s.", curParameterIndex, this.curObject));
      }
    }

    this.startNestedParametersList();
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
    this.endNestedParametersList();
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
  @Override
  public void enterSimpleEntityInstance(SimpleEntityInstanceContext ctx)
  {
    if (mode == Mode.DATA) {

      // save ID (#12) of current row
      //
      setCurrentId(ctx.id.getText());

      // save current keyword (IFCRELAGGREGATES) of current row
      //
      this.curKeyword = ctx.simpleRecord().keyword().getText();

      if (forwards.containsKey(curIdAsString)) {

        // take forward created object
        //
        this.curObject = forwards.get(ctx.id.getText());

        // must be a select which needs a type to be set
        //
        if (!this.curKeyword.equalsIgnoreCase(this.curObject.eClass().getName())) {

          try {
            EObject selectedObject = util.addElementByKeyword(this.curKeyword);
            EStructuralFeature feature = findNestedPlaceToPut(this.curObject, this.curKeyword, selectedObject);

            this.curObject.eSet(feature, selectedObject);
            this.curObject = selectedObject;
          }
          catch (Exception e) {
            LOGGER.severe(String.format("UNFOUND %s", e));
          }
        }
      } else {

        // save created object which maps to keyword
        //
        this.curObject = util.addElementByKeyword(this.curKeyword);

        // handle abstract entity references
        //
        if (abstractReferences.containsKey(curIdAsString)) {
          for (Pair<EObject, EStructuralFeature> pair : abstractReferences.get(curIdAsString)) {
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
      EObject eObjectOrNull = this.idToEntity.put(this.curIdAsString, this.curObject);
      LOGGER.info("Save reference with id " + this.curIdAsString + " of type " + this.curObject);

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
    for (EStructuralFeature eCurFeature : searchIn.eClass().getEAllStructuralFeatures()) {

      // found in first level by name
      //
      if (eCurFeature.getName().equalsIgnoreCase(searchFor)) {

        return eCurFeature;
      } else {

        // see if it is a spezilized value
        //
        for (EClass supertype : selectedObject.eClass().getEAllSuperTypes()) {

          if (supertype.getName().equalsIgnoreCase(eCurFeature.getName())) {
            return eCurFeature;
          }

        }
      }
    }
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
    this.startNestedParametersList();
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

    // count parameters only if there in lists
    //
    if (parentCtx instanceof StepParser.ParameterListContext || parentCtx instanceof StepParser.ListContext) {

      this.curParameterIndex++;
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
    this.endNestedParametersList();
  }

  /**
   * Set the current id of the row. #12 will be 12.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param text
   */
  private void setCurrentId(String text)
  {
    this.curIdAsString = text;
  }

  private void startNestedParametersList()
  {
    // if parameter list is nested recursively 
    //
    if (this.curParameterIndex != -1) {
      this.parameterIndexStack.push(this.curParameterIndex); // save current pointer
      this.upperIndex = this.curParameterIndex;
    }

    // start index by 0
    //
    this.curParameterIndex = 0;
  }

  private void endNestedParametersList()
  {
    // restore old index from parent parameter list
    //
    if (!this.parameterIndexStack.isEmpty()) {
      this.curParameterIndex = this.parameterIndexStack.pop();
    } else {
      this.curParameterIndex = -1;
    }
  }
}
