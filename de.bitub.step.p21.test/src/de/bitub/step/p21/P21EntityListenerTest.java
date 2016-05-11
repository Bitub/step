package de.bitub.step.p21;

import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsCollectionContaining.hasItems;
import static org.hamcrest.core.IsInstanceOf.instanceOf;
import static org.hamcrest.core.IsNull.nullValue;
import static org.junit.Assert.assertThat;

import org.buildingsmart.ifc4.DoubleInList;
import org.buildingsmart.ifc4.Ifc4Package;
import org.buildingsmart.ifc4.IfcBSplineSurfaceWithKnots;
import org.buildingsmart.ifc4.IfcBuilding;
import org.buildingsmart.ifc4.IfcCartesianPoint;
import org.buildingsmart.ifc4.IfcCartesianPointInList;
import org.buildingsmart.ifc4.IfcElementCompositionEnum;
import org.buildingsmart.ifc4.IfcMaterialLayerSetUsage;
import org.buildingsmart.ifc4.IfcRationalBSplineSurfaceWithKnots;
import org.eclipse.emf.ecore.EObject;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.inject.Guice;
import com.google.inject.Injector;

import de.bitub.step.p21.di.P21Module;
import de.bitub.step.p21.di.P21ParserFactory;
import de.bitub.step.p21.parser.P21EntityListener;
import de.bitub.step.p21.parser.SingleLineEntityParser;

public class P21EntityListenerTest
{
  static Injector injector;

  SingleLineEntityParser parser = null;
  P21EntityListener listener = null;
  AllP21Entities entites = null;

  @BeforeClass
  public static void beforeEach()
  {
    injector = Guice.createInjector(new P21Module());
  }

  @Before
  public void before()
  {
    P21ParserFactory factory = injector.getInstance(P21ParserFactory.class);
    listener = factory.createWith(Ifc4Package.eINSTANCE);

    entites = injector.getInstance(AllP21Entities.class);
    parser = new SingleLineEntityParser();
  }

  @Test
  public void parseWithoutError2()
  {
    String line = "#195472= IFCRECTANGLEPROFILEDEF(.AREA.,'Garage Security Grille 8''-4\" High',#195471,0.0625,0.0625);";
    try {
      EObject object = parser.parse(line, listener);
      assertThat(object, nullValue());
    }
    catch (Exception e) {

      System.out.println("FAIL" + e);
    }
  }

  @Test
  public void parseWithoutError()
  {
    String line = "#50= IFCBUILDING('39t4Pu3nTC4ekXYRIHJB9W',$,'IfcBuilding',$,$,#51,$,$,.ELEMENT.,$,$,#56);";
    EObject object = parser.parse(line, listener);

    assertThat(object, is(instanceOf(IfcBuilding.class)));

    IfcBuilding building = (IfcBuilding) object;
    assertThat(building.getGlobalId(), is("39t4Pu3nTC4ekXYRIHJB9W"));
    assertThat(building.getName(), is("IfcBuilding"));
    assertThat(building.getCompositionType(), is(IfcElementCompositionEnum.ELEMENT));
  }

  @Test
  public void containsTwoUnresolvedEntities()
  {
    String line = "#50= IFCBUILDING('39t4Pu3nTC4ekXYRIHJB9W',$,'IfcBuilding',$,$,#51,$,$,.ELEMENT.,$,$,#56);";
    parser.parse(line, listener);

    assertThat(entites.retrieveUnresolved().entrySet().size(), is(2));
  }

  @Test
  public void parseListOfDoublesInCartesianPoint()
  {
    String line = "#24 = IFCCARTESIANPOINT((0., -1., 0.));";
    EObject object = parser.parse(line, listener);

    assertThat(object, is(instanceOf(IfcCartesianPoint.class)));
    IfcCartesianPoint point = (IfcCartesianPoint) object;

    assertThat(point.getCoordinates().size(), is(3));
    assertThat(point.getCoordinates(), hasItems(0., -1., 0.));
  }

  @Test
  public void parseDoubleInIFCMATERIALLAYERSETUSAGE()
  {
    String line = "#61 = IFCMATERIALLAYERSETUSAGE(#62, .AXIS2., .POSITIVE., -150., $);";
    EObject object = parser.parse(line, listener);

    assertThat(object, instanceOf(IfcMaterialLayerSetUsage.class));
    IfcMaterialLayerSetUsage point = (IfcMaterialLayerSetUsage) object;

    assertThat(point.getOffsetFromReferenceLine(), is(-150.));
  }

  @Test
  public void parseRealInMultiDimensionalLists()
  {
    String line = "#548= " + "IfcRationalBSplineSurfaceWithKnots".toUpperCase() + "(3,3,"
        + "((#549,#550,#551,#552,#549,#550,#551),(#553,#554,#555,#556,#553,#554,#555),(#557,#558,#559,#560,#557,#558,#559),(#561,#562,#563,#564,#561,#562,#563))"
        + ",.UNSPECIFIED.,.F.,.T.,.F.,(4,4),(1,1,1,1,1,1,1,1,1,1,1),(0.0,14.7110308353668),(-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0),.UNSPECIFIED., ((0.,1.),(2.,3.)));";
    EObject object = parser.parse(line, listener);

    assertThat(object, instanceOf(IfcRationalBSplineSurfaceWithKnots.class));
    IfcRationalBSplineSurfaceWithKnots surface = (IfcRationalBSplineSurfaceWithKnots) object;

    assertThat(surface.getWeightsData().size(), is(2));
    assertThat(surface.getWeightsData().get(0), instanceOf(DoubleInList.class));

    if (surface.getWeightsData().get(0) instanceof DoubleInList) {
      DoubleInList doubleList = (DoubleInList) surface.getWeightsData().get(0);
      assertThat(doubleList.getAList().size(), is(2));
    }
  }

  @Test
  public void parseReferencesInMultiDimensionalLists()
  {
    String line = "#548= IFCBSPLINESURFACEWITHKNOTS(3,3,"
        + "((#549,#550,#551,#552,#549,#550,#551),(#553,#554,#555,#556,#553,#554,#555),(#557,#558,#559,#560,#557,#558,#559),(#561,#562,#563,#564,#561,#562,#563))"
        + ",.UNSPECIFIED.,.F.,.T.,.F.,(4,4),(1,1,1,1,1,1,1,1,1,1,1),(0.0,14.7110308353668),(-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0),.UNSPECIFIED.);";
    EObject object = parser.parse(line, listener);

    assertThat(object, instanceOf(IfcBSplineSurfaceWithKnots.class));
    IfcBSplineSurfaceWithKnots surface = (IfcBSplineSurfaceWithKnots) object;

    assertThat(surface.getControlPointsList().size(), is(4));
    assertThat(surface.getControlPointsList().get(0), instanceOf(IfcCartesianPointInList.class));

//    Map<String, Collection<ListPair>> unresolved = entites.retrieveUnresolvedLists();
//
//    assertThat(unresolved.keySet(), hasItems("#549", "#550", "#551", "#552", "#549", "#550", "#551"));
//    assertThat(unresolved.get("#549").size(), is(2));
//    assertThat(unresolved.get("#550").size(), is(2));
//    assertThat(unresolved.get("#551").size(), is(2));
//    assertThat(unresolved.get("#552").size(), is(1));
  }

}
