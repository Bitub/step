package de.bitub.step.p21.parser;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.inject.Inject;

import de.bitub.step.p21.IndexUtil;
import de.bitub.step.p21.P21Index;
import de.bitub.step.p21.StepParser.IntegerContext;
import de.bitub.step.p21.StepParser.ListContext;
import de.bitub.step.p21.StepParser.RealContext;
import de.bitub.step.p21.StepParser.SimpleEntityInstanceContext;
import de.bitub.step.p21.StepParser.StringContext;
import de.bitub.step.p21.StepParser.TypedContext;
import de.bitub.step.p21.StepParser.UntypedContext;
import de.bitub.step.p21.StepUntypedToEcore;
import de.bitub.step.p21.XPressModel;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.util.Antlr4Util;

public class P21EntityListener extends P21LevelListener
{
  P21Index entities;
  EPackage ePackage;
  NameToClassifierMap classifierMap;

  // save different variables for current entity subtree walk
  //
  private EObject curObject = null;
  private String curKeyword = null;
  private String curId = null;

  // helper to storing current list
  //
  private EObject listWrapper = null;
  private String typedName;

  @Inject
  public P21EntityListener(P21Index entities, IndexUtil index)
  {
    super(index);
    this.entities = entities;
  }

  @Override
  public void exitUntyped(UntypedContext ctx)
  {
    if (null != ctx.ENTITY_INSTANCE_NAME()) {

      String reference = ctx.ENTITY_INSTANCE_NAME().getText();
      handleUntyped(Antlr4Util.partOfList(ctx), reference);
    }

    if (null != ctx.ENUMERATION()) {

      String literal = ctx.ENUMERATION().getText().replace(".", "");
      handleEnumeration(literal);
    }
  }

  private void handleEnumeration(String literal)
  {
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.current());

    // from T -> TRUE
    //
    literal = XPressModel.toLongLogicalEnum(literal);

    if (XPressModel.isSelect(feature)) {

      setSelect(feature, literal);
    } else {

      StepUntypedToEcore.eEnum(index.current(), curObject, literal);
    }
  }

  @Override
  public void enterSimpleEntityInstance(SimpleEntityInstanceContext ctx)
  {
    curId = ctx.id.getText();
    curKeyword = ctx.simpleRecord().keyword().getText();
    curObject = EcoreUtil.create((EClass) classifierMap.getEClassifier(curKeyword));
    entities.store(curId, curObject);
  }

  @Override
  public void enterTyped(TypedContext ctx)
  {
    setTypedName(ctx.keyword().getText());
  }

  @Override
  public void exitTyped(TypedContext ctx)
  {
    setTypedName(null);
  }

  @Override
  public void exitInteger(IntegerContext ctx)
  {
    handlePrimitive(Antlr4Util.partOfList(ctx), Integer.parseInt(ctx.getText()));
  }

  private void handleSingleValue(Object value)
  {
    boolean isTyped = Objects.isNull(typedName);
    if (isTyped) {
      EStructuralFeature eStructuralFeature = XPressModel.p21FeatureBy(curObject, index.current());
      curObject.eSet(eStructuralFeature, value);
    }

    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.current());
    if (XPressModel.isSelect(feature)) {
      setSelect(feature, value);
    }
  }

  private void handleUntyped(boolean isPartOfList, String reference)
  {
    if (isPartOfList) {

      handleReferences(reference);
    } else {

      handleReference(reference);
    }
  }

  private void handleReferences(String reference)
  {
    if (index.isListLevel()) {
      handleReferenceList(reference);
    }

    if (index.isNestedListLevel()) {
      handleNestedReferenceList(reference);
    }
  }

  private void handleList(Object value)
  {
    if (index.isListLevel()) {
      handlePrimitiveList(value);
    }

    if (index.isNestedListLevel()) {
      handleNestedPrimitiveList(value);
    }
  }

  private void handlePrimitive(boolean isPartOfList, Object value)
  {
    if (isPartOfList) {

      handleList(value);
    } else {

      handleSingleValue(value);
    }
  }

  @Override
  public void exitString(StringContext ctx)
  {
    handlePrimitive(Antlr4Util.partOfList(ctx), ctx.getText());
  }

  @Override
  public void exitReal(RealContext ctx)
  {
    handlePrimitive(Antlr4Util.partOfList(ctx), Double.parseDouble(ctx.getText()));
  }

  @SuppressWarnings("unchecked")
  private <T> void handleNestedPrimitiveList(T value)
  {
    EStructuralFeature listFeature = XPressModel.p21FeatureBy(curObject, index.entityLevelIndex());
    EList<EObject> list = (EList<EObject>) curObject.eGet(listFeature);

    // multidimensional list with delegates, non-schema helpers
    //
    if (XPressModel.isDelegate(listFeature)) {

      if (listFeature.getEType() instanceof EClass) {
        EClass eClass = (EClass) listFeature.getEType();

        boolean isListIndexAlreadySet = list.size() > index.upper();
        if (!isListIndexAlreadySet) {

          // create and set the primitive list wrapper
          //
          EObject primitiveListWrapper = EcoreUtil.create(eClass);
          list.add(index.upper(), primitiveListWrapper);
          setValueToList(primitiveListWrapper, value);

        } else {

          EObject primitiveListWrapper = list.get(index.upper());
          setValueToList(primitiveListWrapper, value);
        }
      }
    }
  }

  private void setSelect(EStructuralFeature selectFeature, Object value)
  {
    StepUntypedToEcore.eSelect(selectFeature, curObject, typedName, value);
  }

  private <T> void setValueToList(EObject listWrapper, T value)
  {
    EStructuralFeature listFeature = listWrapper.eClass().getEStructuralFeatures().get(0);

    @SuppressWarnings("unchecked")
    EList<T> valueList = (EList<T>) listWrapper.eGet(listFeature);
    valueList.add(value);
  }

  private void handlePrimitiveList(Object value)
  {
    listWrapper = null;
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.upper());

    if (feature.isMany()) {

      @SuppressWarnings("unchecked")
      EList<Object> list = (EList<Object>) curObject.eGet(feature);

      if (XPressModel.isSelect(feature)) {

        // handle primitive wrapping SELECT type
        //
        EObject select = StepUntypedToEcore.prepareSelect(feature, value, typedName);
        list.add(select);
      } else {

        // handle primitives inside list
        //
        list.add(value);
      }
    }
  }

  @SuppressWarnings("unchecked")
  private void handleNestedReferenceList(String ref)
  {
    EStructuralFeature listFeature = XPressModel.p21FeatureBy(curObject, index.entityLevelIndex());
    EList<EObject> list = (EList<EObject>) curObject.eGet(listFeature);

    // multidimensional list with delegates, non-schema helpers
    //
    if (XPressModel.isDelegate(listFeature)) {
      if (listFeature.getEType() instanceof EClass) {
        EClass eClass = (EClass) listFeature.getEType();

        boolean isListIndexAlreadySet = list.size() > index.upper();
        if (!isListIndexAlreadySet) {

          // create and set the primitive list wrapper
          //
          EObject entityListWrapper = EcoreUtil.create(eClass);
          list.add(index.upper(), entityListWrapper);
          listWrapper = entityListWrapper;

        } else {

          EObject entityListWrapper = list.get(index.upper());
          listWrapper = entityListWrapper;
        }
      }
    }
  }

  private void handleReferenceList(String ref)
  {
    listWrapper = curObject;
  }

  private void handleReference(String ref)
  {
    // store information about references
    //
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.current());
    entities.store(ref, curId, feature);
  }

  @Override
  public void exitList(ListContext ctx)
  {
    // handle non-empty list with references
    //
    if (!ctx.parameters.isEmpty() && Antlr4Util.isDirectParentOf(ctx, UntypedContext.class)) {
      List<String> refs = ctx.parameters.stream().map(p -> p.getText()).collect(Collectors.toList());

      boolean isNested = index.level() > 1;
      if (isNested) {
        entities.store(refs, listWrapper, listWrapper.eClass().getEStructuralFeatures().get(0));
        listWrapper = null;
      }

      if (index.level() == 1 && Objects.nonNull(listWrapper)) {
        entities.store(refs, listWrapper, XPressModel.p21FeatureBy(curObject, index.upper()));
      }
    }
    super.exitList(ctx);
  }

  private void setTypedName(String typedName)
  {
    this.typedName = typedName;
  }

  public EObject entity()
  {
    return curObject;
  }

  public void setPackage(EPackage ePackage)
  {
    this.ePackage = ePackage;
  }

  public void setNameToClassifierMap(NameToClassifierMap nameToClassifierMap)
  {
    this.classifierMap = nameToClassifierMap;
  }

}
