package de.bitub.step.p21.test;

import java.util.Arrays;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.IfcAxis2Placement2D;
import org.buildingsmart.ifc4.IfcAxis2Placement3D;
import org.buildingsmart.ifc4.IfcBuilding;
import org.buildingsmart.ifc4.IfcDirection;
import org.buildingsmart.ifc4.IfcExtrudedAreaSolid;
import org.buildingsmart.ifc4.IfcGeometricRepresentationContext;
import org.buildingsmart.ifc4.IfcGeometricRepresentationSubContext;
import org.buildingsmart.ifc4.IfcLocalPlacement;
import org.buildingsmart.ifc4.IfcPolyline;
import org.buildingsmart.ifc4.IfcPostalAddress;
import org.buildingsmart.ifc4.IfcProductDefinitionShape;
import org.buildingsmart.ifc4.IfcProject;
import org.buildingsmart.ifc4.IfcRectangleProfileDef;
import org.buildingsmart.ifc4.IfcRelContainedInSpatialStructure;
import org.buildingsmart.ifc4.IfcRepresentationContext;
import org.buildingsmart.ifc4.IfcShapeRepresentation;
import org.buildingsmart.ifc4.IfcUnitAssignment;
import org.buildingsmart.ifc4.IfcWallStandardCase;
import org.junit.Assert;
import org.junit.Test;

/**
 * Example files from @link{https://github.com/BuildingSMART/IfcScript}
 * 
 * @author Riemi
 */
public class Ifc4WallTest extends AbstractP21TestHelper
{
  private IFC4 ifc4 = load("Wall.ifc");

  @Test
  public void testWall()
  {
    Assert.assertEquals(1, ifc4.getIfcGeometricRepresentationContext().size());
    Assert.assertEquals(4, ifc4.getIfcCartesianPoint().size());
    Assert.assertEquals(3, ifc4.getIfcAxis2Placement3D().size());
    Assert.assertEquals(2, ifc4.getIfcDirection().size());
    Assert.assertEquals(2, ifc4.getIfcGeometricRepresentationSubContext().size());
    Assert.assertEquals(1, ifc4.getIfcBuilding().size());
    Assert.assertEquals(2, ifc4.getIfcLocalPlacement().size());
    Assert.assertEquals(1, ifc4.getIfcRelContainedInSpatialStructure().size());
    Assert.assertEquals(1, ifc4.getIfcPostalAddress().size());
    Assert.assertEquals(1, ifc4.getIfcProject().size());
    Assert.assertEquals(1, ifc4.getIfcUnitAssignment().size());
    Assert.assertEquals(3, ifc4.getIfcSIUnit().size());
    Assert.assertEquals(1, ifc4.getIfcRelAggregates().size());
    Assert.assertEquals(2, ifc4.getIfcMaterial().size());
    Assert.assertEquals(3, ifc4.getIfcMaterialLayer().size());
    Assert.assertEquals(1, ifc4.getIfcMaterialLayerSet().size());
    Assert.assertEquals(2, ifc4.getIfcRelAssociatesMaterial().size());
    Assert.assertEquals(1, ifc4.getIfcWallType().size());
    Assert.assertEquals(1, ifc4.getIfcRelDefinesByType().size());
    Assert.assertEquals(1, ifc4.getIfcWallStandardCase().size());
    Assert.assertEquals(1, ifc4.getIfcMaterialLayerSetUsage().size());
    Assert.assertEquals(1, ifc4.getIfcPolyline().size());
    Assert.assertEquals(2, ifc4.getIfcShapeRepresentation().size());
    Assert.assertEquals(1, ifc4.getIfcAxis2Placement2D().size());
    Assert.assertEquals(1, ifc4.getIfcRectangleProfileDef().size());
    Assert.assertEquals(1, ifc4.getIfcExtrudedAreaSolid().size());
    Assert.assertEquals(1, ifc4.getIfcProductDefinitionShape().size());
  }

  @Test
  public void testWallAdditionalTypes()
  {
    Assert.assertEquals(3, ifc4.getIfcUnit().size());
  }

  @Test
  public void testRelations()
  {
    // #100= IFCPROJECT('0$WU4A9R19$vKWO$AdOnKA',$,'IfcProject',$,$,'IfcProject',$,(#1),#101);
    //
    IfcProject project = (IfcProject) ifc4.getIfcProject().get(0);

    Assert.assertEquals("0$WU4A9R19$vKWO$AdOnKA", project.getGlobalId());
    Assert.assertEquals("IfcProject", project.getName());
    Assert.assertEquals("IfcProject", project.getLongName());

    IfcUnitAssignment unitAssignment = project.getUnitsInContext();
    Assert.assertNotNull(unitAssignment);
    Assert.assertNotNull(unitAssignment.getUnits());

    // #1= IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,0.0001,#3,#4);
    //
    IfcRepresentationContext representationContext = (IfcRepresentationContext) project.getRepresentationContexts().get(0);
    IfcGeometricRepresentationContext geometricRepresentationContext = (IfcGeometricRepresentationContext) representationContext;

    Assert.assertNotNull(representationContext);
    Assert.assertEquals("Model", geometricRepresentationContext.getContextType());
    Assert.assertEquals(3, geometricRepresentationContext.getCoordinateSpaceDimension());
    Assert.assertEquals(0.0001, geometricRepresentationContext.getPrecision(), 0.000001);
    Assert.assertNotNull(geometricRepresentationContext.getWorldCoordinateSystem());
    Assert.assertNotNull(geometricRepresentationContext.getWorldCoordinateSystem().getIfcAxis2Placement3D());
    Assert.assertNotNull(geometricRepresentationContext.getHasSubContexts());
    Assert.assertNotNull(geometricRepresentationContext.getTrueNorth());
    Assert.assertEquals(2, geometricRepresentationContext.getHasSubContexts().size());

    // #3= IFCAXIS2PLACEMENT3D(#2,$,$);
    // 
    IfcAxis2Placement3D axis2Placement3D = geometricRepresentationContext.getWorldCoordinateSystem().getIfcAxis2Placement3D();

    Assert.assertNotNull(axis2Placement3D.getLocation());
    Assert.assertEquals(Arrays.asList(new Double[] { 0.0, 0.0, 0.0 }), axis2Placement3D.getLocation().getCoordinates());

    // #4= IFCDIRECTION((0.0,1.0));
    //
    IfcDirection trueNorthDirection = geometricRepresentationContext.getTrueNorth();

    Assert.assertEquals(2, trueNorthDirection.getDirectionRatios().size());
    Assert.assertEquals(Arrays.asList(new Double[] { 0.0, 1.0 }), trueNorthDirection.getDirectionRatios());

    // #5= IFCGEOMETRICREPRESENTATIONSUBCONTEXT('Axis','Model',*,*,*,*,#1,$,.MODEL_VIEW.,$);
    //
    IfcGeometricRepresentationSubContext geometricRepresentationSubContext1 =
        (IfcGeometricRepresentationSubContext) geometricRepresentationContext.getHasSubContexts().get(0);
    Assert.assertEquals("Model", geometricRepresentationSubContext1.getContextType());
    Assert.assertEquals("Axis", geometricRepresentationSubContext1.getContextIdentifier());
    Assert.assertEquals("MODEL_VIEW", geometricRepresentationSubContext1.getTargetView().getLiteral());
    Assert.assertEquals(geometricRepresentationContext, geometricRepresentationSubContext1.getParentContext());
    Assert.assertNotNull(geometricRepresentationSubContext1.getRepresentationsInContext());
    Assert.assertEquals(1, geometricRepresentationSubContext1.getRepresentationsInContext().size());

    // #6= IFCGEOMETRICREPRESENTATIONSUBCONTEXT('Body','Model',*,*,*,*,#1,$,.MODEL_VIEW.,$);
    //
    IfcGeometricRepresentationSubContext geometricRepresentationSubContext2 =
        (IfcGeometricRepresentationSubContext) geometricRepresentationContext.getHasSubContexts().get(1);
    Assert.assertEquals("Model", geometricRepresentationSubContext2.getContextType());
    Assert.assertEquals("Body", geometricRepresentationSubContext2.getContextIdentifier());
    Assert.assertEquals("MODEL_VIEW", geometricRepresentationSubContext2.getTargetView().getLiteral());
    Assert.assertNotNull(geometricRepresentationSubContext2.getRepresentationsInContext());
    Assert.assertEquals(1, geometricRepresentationSubContext2.getRepresentationsInContext().size());

    // #310= IFCSHAPEREPRESENTATION(#5,'Axis','Curve2D',(#309));
    //
    Assert.assertTrue(geometricRepresentationSubContext1.getRepresentationsInContext().get(0) instanceof IfcShapeRepresentation);
    IfcShapeRepresentation shapeRepresentation1 =
        (IfcShapeRepresentation) geometricRepresentationSubContext1.getRepresentationsInContext().get(0);
    Assert.assertEquals("Axis", shapeRepresentation1.getRepresentationIdentifier());
    Assert.assertEquals("Curve2D", shapeRepresentation1.getRepresentationType());
    Assert.assertEquals(geometricRepresentationSubContext1, shapeRepresentation1.getContextOfItems());
    Assert.assertNotNull(shapeRepresentation1.getItems());
    Assert.assertEquals(1, shapeRepresentation1.getItems().size());
    Assert.assertTrue(shapeRepresentation1.getItems().get(0) instanceof IfcPolyline);

    // #316= IFCSHAPEREPRESENTATION(#6,'Body','SweptSolid',(#315));
    //
    Assert.assertTrue(geometricRepresentationSubContext2.getRepresentationsInContext().get(0) instanceof IfcShapeRepresentation);
    IfcShapeRepresentation shapeRepresentation2 =
        (IfcShapeRepresentation) geometricRepresentationSubContext2.getRepresentationsInContext().get(0);
    Assert.assertEquals("Body", shapeRepresentation2.getRepresentationIdentifier());
    Assert.assertEquals("SweptSolid", shapeRepresentation2.getRepresentationType());
    Assert.assertEquals(geometricRepresentationSubContext2, shapeRepresentation2.getContextOfItems());
    Assert.assertNotNull(shapeRepresentation2.getItems());
    Assert.assertEquals(1, shapeRepresentation2.getItems().size());
    Assert.assertTrue(shapeRepresentation2.getItems().get(0) instanceof IfcExtrudedAreaSolid);

    // #315= IFCEXTRUDEDAREASOLID(#313,$,#314,2000.0);
    //
    IfcExtrudedAreaSolid extrudedAreaSolid = (IfcExtrudedAreaSolid) shapeRepresentation2.getItems().get(0);
    Assert.assertEquals(2000.0, extrudedAreaSolid.getDepth(), 0);
    Assert.assertNotNull(extrudedAreaSolid.getExtrudedDirection());
    Assert.assertNotNull(extrudedAreaSolid.getSweptArea());
    Assert.assertTrue(extrudedAreaSolid.getSweptArea() instanceof IfcRectangleProfileDef);

    // #314= IFCDIRECTION((0.0,0.0,1.0));
    //
    IfcDirection direction = extrudedAreaSolid.getExtrudedDirection();
    Assert.assertEquals(3, direction.getDirectionRatios().size());
    Assert.assertEquals(Arrays.asList(new Double[] { 0.0, 0.0, 1.0 }), direction.getDirectionRatios());

    // #313= IFCRECTANGLEPROFILEDEF(.AREA.,'Wall Perim',#311,5000.0,270.0);
    //
    IfcRectangleProfileDef rectangleProfileDef = (IfcRectangleProfileDef) extrudedAreaSolid.getSweptArea();
    Assert.assertEquals("AREA", rectangleProfileDef.getProfileType().getLiteral());
    Assert.assertEquals("Wall Perim", rectangleProfileDef.getProfileName());
    Assert.assertEquals(5000.0, rectangleProfileDef.getXDim(), 0);
    Assert.assertEquals(270.0, rectangleProfileDef.getYDim(), 0);
    Assert.assertNotNull(rectangleProfileDef.getPosition());

    // #311= IFCAXIS2PLACEMENT2D(#312,$);
    //
    IfcAxis2Placement2D axis2Placement2D = rectangleProfileDef.getPosition();
    Assert.assertNotNull(axis2Placement2D.getLocation());
    Assert.assertEquals(Arrays.asList(new Double[] { 2500.0, 135.0 }), axis2Placement2D.getLocation().getCoordinates());

    // #302= IFCWALLSTANDARDCASE('0DWgwt6o1FOx7466fPk$jl',$,$,$,$,#305,#317,$,$);
    //
    IfcWallStandardCase wallStandardCase = (IfcWallStandardCase) ifc4.getIfcWallStandardCase().get(0);
    Assert.assertEquals("0DWgwt6o1FOx7466fPk$jl", wallStandardCase.getGlobalId());
    Assert.assertEquals("MOVABLE", wallStandardCase.getPredefinedType().getLiteral());
    Assert.assertNotNull(wallStandardCase.getRepresentation());
    Assert.assertTrue(wallStandardCase.getRepresentation() instanceof IfcProductDefinitionShape);
    Assert.assertNotNull(wallStandardCase.getObjectPlacement());
    Assert.assertTrue(wallStandardCase.getObjectPlacement() instanceof IfcLocalPlacement);

    // IfcRelContainedInSpatialStructure
    Assert.assertEquals(1, ifc4.getIfcRelContainedInSpatialStructure().size());
    IfcRelContainedInSpatialStructure relContainedInSpatialStructure =
        (IfcRelContainedInSpatialStructure) ifc4.getIfcRelContainedInSpatialStructure().get(0);
    Assert.assertEquals("3Sa3dTJGn0H8TQIGiuGQd5", relContainedInSpatialStructure.getGlobalId());
    Assert.assertEquals(null, relContainedInSpatialStructure.getOwnerHistory());
    Assert.assertEquals("Building", relContainedInSpatialStructure.getName());
    Assert.assertEquals("Building Container for Elements", relContainedInSpatialStructure.getDescription());
    Assert.assertTrue(relContainedInSpatialStructure.getRelatingStructure() instanceof IfcBuilding);

    IfcBuilding building = (IfcBuilding) relContainedInSpatialStructure.getRelatingStructure();

    // IfcBuilding
    Assert.assertEquals("39t4Pu3nTC4ekXYRIHJB9W", building.getGlobalId());
    Assert.assertEquals("IfcBuilding", building.getName());
    Assert.assertTrue(building.getObjectPlacement() instanceof IfcLocalPlacement);
    Assert.assertTrue(building.getBuildingAddress() instanceof IfcPostalAddress);
    Assert.assertEquals("Unknown", building.getBuildingAddress().getRegion());
    Assert.assertEquals("ELEMENT", building.getCompositionType().getLiteral());
  }

  @Test
  public void test_ShapeOf_ProductDefinitionShape()
  {
//    IfcWallStandardCase wallStandardCase = (IfcWallStandardCase) ifc4.getIfcWallStandardCase().get(0);
//
//    // #317= IFCPRODUCTDEFINITIONSHAPE($,$,(#310,#316));
//    //
//    IfcProductDefinitionShape productDefinitionShape = (IfcProductDefinitionShape) wallStandardCase.getRepresentation();
//    Assert.assertEquals(2, productDefinitionShape.getShapeOfProduct());
  }
}
