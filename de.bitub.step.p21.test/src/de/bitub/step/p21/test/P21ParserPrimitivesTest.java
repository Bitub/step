package de.bitub.step.p21.test;

import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsCollectionContaining.hasItems;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.hamcrest.core.IsInstanceOf.instanceOf;
import static org.junit.Assert.assertThat;

import org.buildingsmart.ifc4.EnumIfcValue;
import org.buildingsmart.ifc4.Ifc4Package;
import org.buildingsmart.ifc4.IfcApplication;
import org.buildingsmart.ifc4.IfcBSplineCurveWithKnots;
import org.buildingsmart.ifc4.IfcBuildingStorey;
import org.buildingsmart.ifc4.IfcCartesianPoint;
import org.buildingsmart.ifc4.IfcMeasureWithUnit;
import org.buildingsmart.ifc4.IfcOrientedEdge;
import org.buildingsmart.ifc4.IfcOwnerHistory;
import org.buildingsmart.ifc4.IfcPostalAddress;
import org.buildingsmart.ifc4.IfcPropertySingleValue;
import org.buildingsmart.ifc4.IfcSIUnit;
import org.buildingsmart.ifc4.IfcSIUnitName;
import org.buildingsmart.ifc4.IfcUnitEnum;
import org.buildingsmart.ifc4.IfcValue;
import org.eclipse.emf.ecore.EObject;
import org.junit.Before;
import org.junit.Test;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.AllP21Entities;
import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.di.P21ParserFactory;
import de.bitub.step.p21.parser.P21EntityListener;
import de.bitub.step.p21.parser.SingleLineEntityParser;

public class P21ParserPrimitivesTest
{
  SingleLineEntityParser parser = null;
  P21EntityListener listener = null;
  AllP21Entities entites = null;

  @Before
  public void before()
  {
    Injector injector = Guice.createInjector(new P21Module());

    P21ParserFactory factory = injector.getInstance(P21ParserFactory.class);
    listener = factory.createWith(Ifc4Package.eINSTANCE);

    entites = injector.getInstance(AllP21Entities.class);
    parser = new SingleLineEntityParser();
  }

  @Test
  public void shouldParseInteger()
  {
    String line = "#42= IFCOWNERHISTORY(#39,#5,$,.NOCHANGE.,$,$,$,1402272198);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcOwnerHistory.class)));
    IfcOwnerHistory curveWithKnots = (IfcOwnerHistory) entity;

    assertThat(curveWithKnots.getCreationDate(), is(1402272198));
  }

  @Test
  public void shouldParseEnumerationLiteral()
  {
    String line = "#48= IFCSIUNIT(*,.AREAUNIT.,$,.SQUARE_METRE.);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcSIUnit.class)));
    IfcSIUnit curveWithKnots = (IfcSIUnit) entity;

    assertThat(curveWithKnots.getName(), is(IfcSIUnitName.SQUARE_METRE));
    assertThat(curveWithKnots.getUnitType(), is(IfcUnitEnum.AREAUNIT));
  }

  @Test
  public void shouldParseReal()
  {
    String line =
        "#146= IFCBUILDINGSTOREY('0_3TRpN6PEYA2pg4E8Zt4j',#42,'Ground Floor',$,$,#145,$,'Ground Floor',.ELEMENT.,543.5);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcBuildingStorey.class)));
    IfcBuildingStorey buildingStorey = (IfcBuildingStorey) entity;

    assertThat(buildingStorey.getElevation(), is(543.5));
  }

  @Test
  public void shouldParseString()
  {
    String line = "#5= IFCAPPLICATION(#1,'2015','Autodesk Revit 2015 (ENU)','Revit');";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcApplication.class)));
    IfcApplication orientedEdge = (IfcApplication) entity;

    assertThat(orientedEdge.getApplicationFullName(), equalTo("Autodesk Revit 2015 (ENU)"));
    assertThat(orientedEdge.getApplicationIdentifier(), equalTo("Revit"));
    assertThat(orientedEdge.getVersion(), equalTo("2015"));
  }

  @Test
  public void shouldParseBooleanEnum()
  {
    String line = "#566= IFCORIENTEDEDGE(*,*,#526,.T.);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcOrientedEdge.class)));
    IfcOrientedEdge orientedEdge = (IfcOrientedEdge) entity;

    assertThat(orientedEdge.isOrientation(), equalTo(true));
  }

  @Test
  public void shouldParseIntegerList()
  {
    String line = "#510= IFCBSPLINECURVEWITHKNOTS(3,(#511,#512,#513,#514,#511,#512,#513),.UNSPECIFIED.,.T.,.T.,"
        + "(1,1,1,1,1,1,1,1,1,1,1)" + "," + "(-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0)" + ",.UNSPECIFIED.);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcBSplineCurveWithKnots.class)));
    IfcBSplineCurveWithKnots curveWithKnots = (IfcBSplineCurveWithKnots) entity;

    assertThat(curveWithKnots.getKnotMultiplicities(), hasItems(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1));
  }

  @Test
  public void shouldParseNamedTypeString()
  {
    String line = "#317= IFCPROPERTYSINGLEVALUE('Reference',$,IFCIDENTIFIER('FUEL VAULT 03'),$);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcPropertySingleValue.class)));
    IfcPropertySingleValue propertySingleValue = (IfcPropertySingleValue) entity;

    assertThat(propertySingleValue.getNominalValue(), is(instanceOf(IfcValue.class)));
    IfcValue value = (IfcValue) propertySingleValue.getNominalValue();

    assertThat(value.getValue(), is(instanceOf(String.class)));
    assertThat(value.getValue(), equalTo("FUEL VAULT 03"));
    assertThat(value.getIfcValue(), equalTo(EnumIfcValue.IFCIDENTIFIER));
  }

  @Test
  public void shouldParseNamedTypeBooleanEnum()
  {
    String line = "#7106= IFCPROPERTYSINGLEVALUE('LoadBearing',$,IFCBOOLEAN(.F.),$);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcPropertySingleValue.class)));
    IfcPropertySingleValue propertySingleValue = (IfcPropertySingleValue) entity;

    assertThat(propertySingleValue.getNominalValue(), is(instanceOf(IfcValue.class)));
    IfcValue value = (IfcValue) propertySingleValue.getNominalValue();

    assertThat(value.getValue(), is(instanceOf(Boolean.class)));
    assertThat(value.getValue(), equalTo(false));
    assertThat(value.getIfcValue(), equalTo(EnumIfcValue.IFCBOOLEAN));
  }

  @Test
  public void shouldParseNamedTypeReal()
  {
    String line = "#58= IFCMEASUREWITHUNIT(IFCRATIOMEASURE(0.0174532925199433),#56);";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcMeasureWithUnit.class)));
    IfcMeasureWithUnit measureWithUnit = (IfcMeasureWithUnit) entity;

    assertThat(measureWithUnit.getValueComponent(), is(instanceOf(IfcValue.class)));
    IfcValue value = (IfcValue) measureWithUnit.getValueComponent();

    assertThat(value.getValue(), is(instanceOf(double.class)));
    assertThat(value.getValue(), equalTo(0.0174532925199433));
    assertThat(value.getIfcValue(), equalTo(EnumIfcValue.IFCRATIOMEASURE));
  }

  @Test
  public void shouldParseRealList()
  {
    String line = "#2= IFCCARTESIANPOINT((0.0,0.0,0.0));";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcCartesianPoint.class)));
    IfcCartesianPoint cartesianPoint = (IfcCartesianPoint) entity;

    assertThat(cartesianPoint.getCoordinates(), hasItems(0.0, 0.0, 0.0));
  }

  @Test
  public void shouldParseStringList()
  {
    String line = "#121= IFCPOSTALADDRESS($,$,$,$,('Enter address here'),$,'','Rochester','','NY');";
    EObject entity = parser.parse(line, listener);

    assertThat(entity, is(instanceOf(IfcPostalAddress.class)));
    IfcPostalAddress cartesianPoint = (IfcPostalAddress) entity;

    assertThat(cartesianPoint.getAddressLines(), hasItems("Enter address here"));
  }
}
