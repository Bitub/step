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
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.EMap;
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
import de.bitub.step.p21.mapper.StepToModel;
import de.bitub.step.p21.mapper.StepToModelImpl;
import de.bitub.step.p21.util.StepUntypedToEcore;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 08.02.2015
 */
public class P21ParserListener extends StepParserBaseListener implements StepParserListener
{
  private static final Logger LOGGER = Logger.getLogger(P21ParserListener.class.getName());

  // dependencies graph
  //
  Map<Integer, List<Integer>> refs = new HashMap<>();

  // store entities with forward references
  //
  private Map<String, EObject> forwards = new HashMap<>();

  // map entity instance names (IDs #12) to entities for later reuse
  //
  private Map<String, EObject> idToEntity = new HashMap<String, EObject>();

  private StepToModel util = new StepToModelImpl();

  //
  // save different variables for current entity subtree walk
  //

  private EObject curObject = null;
  private String curKeyword = null;
  private Integer curID = -1;

  // save the index for the current parameter in parameterList, stack value if goiing deeper
  //
  private int curParameterIndex = -1;
  Deque<Integer> parameterIndexStack = new ArrayDeque<Integer>();

  private Mode mode = Mode.HEADER;

  public Header header = null;

  private boolean isInList;
  private List<Object> eList = null;

  private String curIdAsString;

  public enum Mode
  {
    HEADER, DATA, FOOTER, DONE
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   */
  public P21ParserListener()
  {
    LOGGER.setLevel(Level.CONFIG);
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
    if (mode != Mode.HEADER) {
      mode = Mode.HEADER;
    }

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
    StepUntypedToEcore.eInteger(curParameterIndex, curObject, ctx.getText(), util);
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
      StepUntypedToEcore.eString(curParameterIndex, curObject, ctx.getText(), util);
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

        try {
          this.eList.add(Double.parseDouble(ctx.getText()));
        }
        catch (ArrayStoreException exception) { // FIXME how to handle that
          exception.printStackTrace();
        }
      }
    }
  }

  private void resolveReference(String referenceId)
  {
    // this is a backwards reference, which already holds the right object
    //
    if (this.idToEntity.containsKey(referenceId)) {

      EObject referencedObject = this.idToEntity.get(referenceId);

      try {
        StepUntypedToEcore.setEStructuralFeature(curParameterIndex, curObject, referencedObject, util);
        LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + referencedObject);
      }
      catch (ClassCastException exception) {
        LOGGER.warning("ClassCastException: Un-resolvable REFERENCE: " + referenceId + ": " + exception.getMessage());
      }
      catch (Exception e) {
        LOGGER.warning("Exception Un-resolvable REFERENCE: " + referenceId + ": " + e.getMessage());
      }

    } else {

      // this is a forward reference
      //
      LOGGER.warning("Forward REFERENCE: " + referenceId);

      // first time create an placeholder object
      //
      if (!forwards.containsKey(referenceId)) {

        // calculate index of parameter
        //
        EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();
        int structuralIndex = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);
        EStructuralFeature eStructuralFeature = eStructuralFeatures.get(structuralIndex);

        // create empty object if not already there
        //
        EObject preCreated = this.util.addElementByKeyword(eStructuralFeature.getEType().getName());

        // save forward created object as reference
        //
        if (preCreated != null) {
          LOGGER.warning("Forward PRECREATEd: " + preCreated);
          this.forwards.put(referenceId, preCreated);

          try {
            StepUntypedToEcore.setEStructuralFeature(curParameterIndex, curObject, preCreated, util);
            LOGGER.info("Set resolvable REFERENCE: " + referenceId + " -> " + preCreated);
          }
          catch (Exception e) {
            LOGGER.warning("Exception Un-resolvable REFERENCE: " + referenceId + ": " + e.getMessage());
          }
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
      }
    }
  }

  // TODO calc index the right way
  private void resolveEnumeration(String literal)
  {
    // calculate index of parameter
    //
    EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();
    int structuralIndex = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);
    EStructuralFeature eStructuralFeature = eStructuralFeatures.get(structuralIndex);

//    EList<EStructuralFeature> eStructuralFeatures = this.curObject.eClass().getEAllStructuralFeatures();
//    EStructuralFeature eStructuralFeature = eStructuralFeatures.get(curParameterIndex);

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

      if (ctx.ENTITY_INSTANCE_NAME() != null && !isInList) {

        String referenceId = ctx.ENTITY_INSTANCE_NAME().getText();
        this.addDependantId(referenceId);
        this.resolveReference(referenceId);
      }

      if (ctx.ENUMERATION() != null) {

        String literal = ctx.ENUMERATION().getText().replace(".", "");

        // it is a simple boolean
        //
        if (literal.equals("T") || literal.equals("F")) {
          StepUntypedToEcore.eBoolean(curParameterIndex, curObject, literal, util);
        }

        try {
          this.resolveEnumeration(literal);
        }
        catch (Exception e) {
          // TODO ONLY SHORT TOIME
          e.printStackTrace();
        }
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param referenceId
   */
  private void addDependantId(String referenceId)
  {
    // add dependent IDs
    //
    if (this.refs.containsKey(curID)) {
      try {
        this.refs.get(this.curID).add(Integer.valueOf(referenceId.substring(1)));
      }
      catch (NumberFormatException exception) {
        LOGGER.warning(exception.getMessage());
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
      EList<EStructuralFeature> eStructuralFeatures = curObject.eClass().getEAllStructuralFeatures();
      int structuralIndex = StepUntypedToEcore.calcIndex(curParameterIndex, eStructuralFeatures);
      EStructuralFeature eStructuralFeature = eStructuralFeatures.get(structuralIndex);

      LOGGER.warning(String.format("TYPED with name %s as parameter into %s", innerKeyword, eStructuralFeature.getName()));

      // hold the reference to the SELECT type
      //
      if (eStructuralFeature instanceof EReference) {
        EReference eReference = (EReference) eStructuralFeature;

        // the SELECT class which is referenced
        //
        EClass eReferencedType = eReference.getEReferenceType(); // IfcValue
        EObject eReferenedInstance = EcoreUtil.create(eReferencedType); // create referenced object

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
        EMap<String, String> details =
            eReferenedInstanceFeature.getEAnnotation("http://www.bitub.de/express/XpressModel").getDetails();

        if (details.get("kind").equals("mapped")) { // this is a mapped value

          // what type is it mapped to
          //
          switch (details.get("datatypeRef")) {
            case "double":

              eReferenedInstance.eSet(eReferenedInstanceFeature, 15.0); // TODO set real value

              LOGGER.warning("Container is " + eStructuralFeature.eContainer());
              LOGGER.warning(String.format("SET %s as %s of referenced %s", eReferenedInstance.eGet(eReferenedInstanceFeature),
                  eReferenedInstanceFeature.getName(), eReferenedInstance.eClass().getName()));

              LOGGER.warning(String.format("PUT object of type %s as %s into %s", eReferenedInstance.eClass().getName(),
                  eStructuralFeature.getName(), this.curObject.eClass().getName()));

              // set reference to current object
              //
              this.curObject.eSet(eStructuralFeature, eReferenedInstance);
              break;

            default:

              LOGGER.warning(String.format("NO MATCH %s", details.get("datatypeRef")));
              break;
          }
        }
      }
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.StepParserBaseListener#enterList(de.bitub.step.p21.StepParser.ListContext)
   */
  @Override
  public void enterList(ListContext ctx)
  {
    if (this.curObject != null) {

      EList<EStructuralFeature> eStructuralFeatures = this.curObject.eClass().getEAllStructuralFeatures();
      EStructuralFeature eStructuralFeature = eStructuralFeatures.get(this.curParameterIndex);

      if (eStructuralFeature instanceof EReference) {

        EReference eReference = (EReference) eStructuralFeature;
        LOGGER.warning(String.format("%s[] as %s in %s", eReference.getEReferenceType().getName(), eReference.getName(),
            this.curObject.eClass().getName()));

        boolean isSet = eReference.isMany() && eReference.isUnique() && !eReference.isOrdered();
        Object curRef = this.curObject.eGet(eReference);

        if (isSet && curRef instanceof List<?>) {

          this.eList = (List) curRef;
        }
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

      // take forward created object
      //
      if (forwards.containsKey(curIdAsString)) {

        boolean isForwardASelect = !forwards.get(curIdAsString).eClass().getName().equalsIgnoreCase(this.curKeyword);
        if (isForwardASelect) {

//          LOGGER
//              .info(curIdAsString + " " + forwards.get(curIdAsString).eClass().getName() + " IS SELECT WITH " + this.curKeyword);
          this.curObject = util.addElementByKeyword(this.curKeyword);
        } else {

          this.curObject = forwards.get(ctx.id.getText());
        }
      } else {

        // save created object which maps to keyword
        //
        this.curObject = util.addElementByKeyword(this.curKeyword);
      }

      EObject eObject = this.idToEntity.put(this.curIdAsString, this.curObject);
      LOGGER.info("Put REFERENCE: " + this.curIdAsString + " - " + this.curKeyword + " -> " + this.curObject);

      if (eObject != null) {
        this.curObject = forwards.remove(ctx.id.getText());
      }

      // add new entity id to references map
      //
      try {
        this.refs.put(Integer.valueOf(ctx.id.getText().substring(1)), new ArrayList<>());
      }
      catch (NumberFormatException exception) {
        LOGGER.warning(exception.getMessage());
      }
    }
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
    super.enterParameterList(ctx);
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
    super.exitParameter(ctx);

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
    super.exitParameterList(ctx);
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
    this.curID = Integer.parseInt(text.substring(1));
  }

//  private void add(EList<EAttribute> eAttributes)
//  {
//    for (EAttribute eAttribute : eAttributes) {
//      System.out.println(eAttribute.getName());
//
//      EStructuralFeature feature = this.curObject.eClass().getEStructuralFeature(eAttribute.getName());
//      if (feature != null) {
//
//        Object newValue = "";
//        LOGGER.config(feature.toString());
//        this.curObject.eSet(feature, newValue);
//      }
//    }
//  }

  private void startNestedParametersList()
  {
    // if parameter list is nested recursively 
    //
    if (this.curParameterIndex != -1) {
      this.parameterIndexStack.push(this.curParameterIndex); // save current pointer
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
