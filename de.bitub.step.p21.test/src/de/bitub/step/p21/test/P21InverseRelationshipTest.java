package de.bitub.step.p21.test;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.IfcProjectionElement;
import org.buildingsmart.ifc4.IfcRelProjectsElement;
import org.buildingsmart.ifc4.IfcWallStandardCase;
import org.junit.Assert;
import org.junit.Test;

public class P21InverseRelationshipTest extends AbstractP21TestHelper
{
  private IFC4 ifc4 = load("P21InverseRelationshipTest.ifc");

  @Test
  public void p21InverseRelationshipTest()
  {
    Assert.assertEquals(1, ifc4.getIfcWallStandardCase().size());
    Assert.assertEquals(1, ifc4.getIfcRelProjectsElement().size());
    Assert.assertEquals(1, ifc4.getIfcProjectionElement().size());

    IfcWallStandardCase wall = ifc4.getIfcWallStandardCase().get(0);
    IfcProjectionElement projectionElement = ifc4.getIfcProjectionElement().get(0);
    IfcRelProjectsElement relProjectsElement = ifc4.getIfcRelProjectsElement().get(0);

    Assert.assertEquals("0DWgwt6o1FOx7466fPk$jl", wall.getGlobalId());
    Assert.assertEquals("39t4Pu3nTC4ekXYRIHJB9W$jl", projectionElement.getGlobalId());
    Assert.assertEquals("36U74BIPDD89cYkx9bkV$Y", relProjectsElement.getGlobalId());
    Assert.assertEquals("Project Element Name", relProjectsElement.getName());
    Assert.assertEquals("Project Element Desc", relProjectsElement.getDescription());

    Assert.assertEquals(relProjectsElement.getRelatedFeatureElement(), projectionElement);
    Assert.assertEquals(projectionElement.getProjectsElements(), relProjectsElement);

    Assert.assertEquals(relProjectsElement.getRelatingElement(), wall);
    Assert.assertEquals(1, wall.getHasProjections().size());
    Assert.assertEquals(wall.getHasProjections().get(0), relProjectsElement);
  }
}
