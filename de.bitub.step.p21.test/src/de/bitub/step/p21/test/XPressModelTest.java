package de.bitub.step.p21.test;

import org.buildingsmart.ifc4.Ifc4Package;
import org.eclipse.emf.ecore.EClass;
import org.junit.Assert;
import org.junit.Test;

import de.bitub.step.p21.XPressModel;

public class XPressModelTest extends AbstractP21TestHelper
{
  @Test
  public void testIsProxy()
  {
    EClass proxy = Ifc4Package.eINSTANCE.getIfcClassificationReference();

    Assert.assertEquals(true, XPressModel.isDelegate(proxy.getEStructuralFeature("classificationRefForObjects")));
    Assert.assertEquals(false, XPressModel.isDelegate(proxy.getEStructuralFeature("description")));
  }

  @Test
  public void testIsSelectProxy()
  {
    EClass selectProxy = Ifc4Package.eINSTANCE.getIfcMetric();
    Assert.assertEquals(true, XPressModel.isSelectProxy(selectProxy.getEStructuralFeature("hasExternalReferences")));
    Assert.assertEquals(false, XPressModel.isSelectProxy(selectProxy.getEStructuralFeature("propertiesForConstraint")));
  }
}
