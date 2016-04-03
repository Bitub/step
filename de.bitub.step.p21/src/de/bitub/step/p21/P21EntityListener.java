package de.bitub.step.p21;

import java.util.Arrays;

import org.eclipse.emf.common.util.ECollections;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;

import com.google.inject.Inject;

import de.bitub.step.p21.StepParser.IntegerContext;
import de.bitub.step.p21.StepParser.RealContext;
import de.bitub.step.p21.StepParser.SimpleEntityInstanceContext;
import de.bitub.step.p21.StepParser.StringContext;
import de.bitub.step.p21.StepParser.UntypedContext;
import de.bitub.step.p21.mapper.NameToClassifierMap;
import de.bitub.step.p21.util.Antlr4Util;
import de.bitub.step.p21.util.IndexUtil;
import de.bitub.step.p21.util.P21Index;
import de.bitub.step.p21.util.StepUntypedToEcore;
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
        handleEntityInstanceNameList(reference);
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

      handlePrimitiveList(Double.parseDouble(ctx.getText()));
    }
  }

  @SuppressWarnings("unchecked")
  private <T> void handlePrimitiveList(T value)
  {
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.upper());

    if (feature.isMany()) {
      EList<T> list = ECollections.asEList(Arrays.asList(value));
      ECollections.setEList((EList<T>) curObject.eGet(feature), list);
    }
  }

  private void handleEntityInstanceNameList(String ref)
  {
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.upper());

    if (feature.isMany()) {

      // multidimensional list with delegates, non-schema helpers
      //
      if (XPressModel.isNew(feature.getEType())) {
//        System.out.println(feature.getEType() + " " + feature.getName());

      }
    }
  }

  private void handleEntityInstanceName(String ref)
  {
    // store information about references
    //
    EStructuralFeature feature = XPressModel.p21FeatureBy(curObject, index.current());
    entities.store(ref, curId, feature);
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
