package de.bitub.step.p21;

import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.inject.Inject;

import de.bitub.step.p21.StepParser.IntegerContext;
import de.bitub.step.p21.StepParser.ListContext;
import de.bitub.step.p21.StepParser.RealContext;
import de.bitub.step.p21.StepParser.SimpleEntityInstanceContext;
import de.bitub.step.p21.StepParser.StringContext;
import de.bitub.step.p21.StepParser.UntypedContext;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.util.Antlr4Util;
import de.bitub.step.p21.util.XPressModel;

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

      if (!Antlr4Util.partOfList(ctx)) {

        handleEntityInstanceName(reference);
      } else {

        if (index.level() == 1) {
          handleEntityInstanceNameList(reference);
        }

        if (index.level() > 1) {
          handleEntityInstanceNameNestedList(reference);
        }
      }
    }

    if (null != ctx.ENUMERATION()) {

      String literal = ctx.ENUMERATION().getText().replace(".", "");
      handleEnumeration(literal);
    }
  }

  private void handleEnumeration(String literal)
  {
    switch (literal) {
      case "T":
      case "F":
        StepUntypedToEcore.eBoolean(index.current(), curObject, literal);
        break;
      default:
        StepUntypedToEcore.eEnum(index.current(), curObject, literal);
        break;
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
  public void exitInteger(IntegerContext ctx)
  {
    if (!Antlr4Util.partOfList(ctx)) {
      StepUntypedToEcore.eInteger(index.current(), curObject, ctx.getText());
    } else {

      handlePrimitiveList(Integer.parseInt(ctx.getText()));
    }
  }

  @Override
  public void exitString(StringContext ctx)
  {
    if (!Antlr4Util.partOfList(ctx)) {
      StepUntypedToEcore.eString(index.current(), curObject, ctx.getText());
    } else {

      handlePrimitiveList(ctx.getText());
    }
  }

  @Override
  public void exitReal(RealContext ctx)
  {
    if (!Antlr4Util.partOfList(ctx)) {

      StepUntypedToEcore.eReal(index.current(), curObject, ctx.getText());
    } else {

      double value = Double.parseDouble(ctx.getText());

      if (index.level() == 1) {
        handlePrimitiveList(value);
      }

      if (index.level() > 1) {
        handleNestedPrimitiveList(value);
      }
    }
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
          setValueToList(eClass, primitiveListWrapper, value);

        } else {

          EObject primitiveListWrapper = list.get(index.upper());
          setValueToList(eClass, primitiveListWrapper, value);
        }
      }
    }
  }

  @SuppressWarnings("unchecked")
  private <T> void setValueToList(EClass eClass, EObject primitiveListWrapper, T value)
  {
    EStructuralFeature innerListFeature = eClass.getEStructuralFeatures().get(0);
    EList<T> valueList = (EList<T>) primitiveListWrapper.eGet(innerListFeature);
    valueList.add(value);
  }

  @SuppressWarnings("unchecked")
  private <T> void handlePrimitiveList(T value)
  {
    listWrapper = null;

    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.upper());
    if (feature.isMany()) {
      EList<T> oldList = (EList<T>) curObject.eGet(feature);
      oldList.add(value);
    }
  }

  @SuppressWarnings("unchecked")
  private void handleEntityInstanceNameNestedList(String ref)
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

  private void handleEntityInstanceNameList(String ref)
  {
    listWrapper = curObject;
  }

  private void handleEntityInstanceName(String ref)
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

      boolean isNested = index.level() > 1;
      if (isNested) {

        List<String> refs = ctx.parameters.stream().map(p -> p.getText()).collect(Collectors.toList());
//        System.out.println(refs + " -> " + listWrapper.eClass().getName() + "@"
//            + listWrapper.eClass().getEStructuralFeatures().get(0).getName());
        entities.store(refs, listWrapper, listWrapper.eClass().getEStructuralFeatures().get(0));
        listWrapper = null;
      }

      if (index.level() == 1 && listWrapper != null) {

        List<String> refs = ctx.parameters.stream().map(p -> p.getText()).collect(Collectors.toList());
//        System.out.println(
//            refs + " -> " + listWrapper.eClass().getName() + "@" + XPressModel.p21FeatureBy(curObject, index.upper()).getName());
        entities.store(refs, listWrapper, XPressModel.p21FeatureBy(curObject, index.upper()));
      }
    }
    super.exitList(ctx);
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
