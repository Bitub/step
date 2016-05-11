package de.bitub.step.p21.test;

import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.ecore.EClass;
import org.junit.Assert;
import org.junit.Test;

import de.bitub.step.p21.util.XPressModel;

public class XPressModelTest extends AbstractP21TestHelper
{

  @Test
  public void testIsNew()
  {
    EClass select = Ifc4Package.eINSTANCE.getIfcFillStyleSelect();
    EClass proxy = Ifc4Package.eINSTANCE.getDelegateIfcConstraintIfcExternalReferenceRelationship();

    Assert.assertEquals(true, XPressModel.isNew(proxy));
    Assert.assertEquals(false, XPressModel.isNew(select.eClass()));
  }

  @Test
  public void testIsGenerated()
  {
    EClass select = Ifc4Package.eINSTANCE.getIfcFillStyleSelect();
    EClass proxy = Ifc4Package.eINSTANCE.getDelegateIfcConstraintIfcExternalReferenceRelationship();

    Assert.assertEquals(false, XPressModel.isGenerated(proxy));
    Assert.assertEquals(true, XPressModel.isGenerated(select));
  }

  @Test
  public void testIsMapped()
  {
    EClass select = Ifc4Package.eINSTANCE.getIfcAppliedValueSelect();

    Assert.assertEquals(true, XPressModel.isMapped(select.getEStructuralFeature("ifcBoolean")));
    Assert.assertEquals(false, XPressModel.isMapped(select.getEStructuralFeature("ifcMeasureWithUnit")));
  }

  @Test
  public void testIsProxy()
  {
    EClass proxy = Ifc4Package.eINSTANCE.getIfcClassificationReference();

    Assert.assertEquals(true, XPressModel.isProxy(proxy.getEStructuralFeature("classificationRefForObjects")));
    Assert.assertEquals(false, XPressModel.isProxy(proxy.getEStructuralFeature("description")));
  }

  @Test
  public void testIsSelectProxy()
  {
    EClass selectProxy = Ifc4Package.eINSTANCE.getIfcMetric();
    Assert.assertEquals(true, XPressModel.isSelectProxy(selectProxy.getEStructuralFeature("hasExternalReferences")));
    Assert.assertEquals(false, XPressModel.isSelectProxy(selectProxy.getEStructuralFeature("propertiesForConstraint")));
  }
}
