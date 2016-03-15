package de.bitub.step.p21.test;

import java.util.Arrays;

import org.buildingsmart.ifc4.IFC4;
import org.buildingsmart.ifc4.IfcAdvancedBrep;
import org.buildingsmart.ifc4.IfcAdvancedFace;
import org.buildingsmart.ifc4.IfcBSplineCurveWithKnots;
import org.buildingsmart.ifc4.IfcBSplineSurfaceWithKnots;
import org.buildingsmart.ifc4.IfcCartesianPoint;
import org.buildingsmart.ifc4.IfcClosedShell;
import org.buildingsmart.ifc4.IfcEdgeCurve;
import org.buildingsmart.ifc4.IfcEdgeLoop;
import org.buildingsmart.ifc4.IfcFace;
import org.buildingsmart.ifc4.IfcFaceBound;
import org.buildingsmart.ifc4.IfcFaceOuterBound;
import org.buildingsmart.ifc4.IfcLoop;
import org.buildingsmart.ifc4.IfcOrientedEdge;
import org.buildingsmart.ifc4.IfcPolyline;
import org.buildingsmart.ifc4.IfcSurface;
import org.buildingsmart.ifc4.IfcVertexPoint;
import org.junit.Assert;
import org.junit.Test;

public class Ifc4BasinAdvancedBrepTest extends AbstractP21TestHelper
{
  private IFC4 ifc4 = load("BasinAdvancedBrep.ifc");

  @Test
  public void testBasinAdvancedBrep()
  {
    Assert.assertEquals(1, ifc4.getIfcAdvancedBrep().size());
    Assert.assertEquals(1, ifc4.getIfcGeometricRepresentationContext().size());
    Assert.assertEquals(60, ifc4.getIfcCartesianPoint().size());
    Assert.assertEquals(6, ifc4.getIfcAxis2Placement3D().size());
    Assert.assertEquals(4, ifc4.getIfcDirection().size());
    Assert.assertEquals(2, ifc4.getIfcGeometricRepresentationSubContext().size());
    Assert.assertEquals(1, ifc4.getIfcBuilding().size());
    Assert.assertEquals(2, ifc4.getIfcLocalPlacement().size());
    Assert.assertEquals(1, ifc4.getIfcPostalAddress().size());
    Assert.assertEquals(1, ifc4.getIfcProject().size());
    Assert.assertEquals(1, ifc4.getIfcUnitAssignment().size());
    Assert.assertEquals(3, ifc4.getIfcSIUnit().size());
    Assert.assertEquals(1, ifc4.getIfcRelAggregates().size());
    Assert.assertEquals(1, ifc4.getIfcMaterial().size());
    Assert.assertEquals(1, ifc4.getIfcRelAssociatesMaterial().size());
    Assert.assertEquals(1, ifc4.getIfcSanitaryTerminalType().size());
    Assert.assertEquals(1, ifc4.getIfcRelDefinesByType().size());
    Assert.assertEquals(1, ifc4.getIfcCartesianTransformationOperator3D().size());
    Assert.assertEquals(1, ifc4.getIfcMappedItem().size());
    Assert.assertEquals(1, ifc4.getIfcSanitaryTerminal().size());
    Assert.assertEquals(1, ifc4.getIfcProductDefinitionShape().size());
    Assert.assertEquals(2, ifc4.getIfcShapeRepresentation().size());
    Assert.assertEquals(4, ifc4.getIfcVertexPoint().size());
    Assert.assertEquals(2, ifc4.getIfcPolyline().size());
    Assert.assertEquals(6, ifc4.getIfcEdgeCurve().size());
    Assert.assertEquals(4, ifc4.getIfcBSplineCurveWithKnots().size());
    Assert.assertEquals(2, ifc4.getIfcBSplineSurfaceWithKnots().size());
    Assert.assertEquals(12, ifc4.getIfcOrientedEdge().size());
    Assert.assertEquals(6, ifc4.getIfcEdgeLoop().size());
    Assert.assertEquals(5, ifc4.getIfcFaceOuterBound().size());
    Assert.assertEquals(5, ifc4.getIfcAdvancedFace().size());
    Assert.assertEquals(3, ifc4.getIfcPlane().size());
    Assert.assertEquals(1, ifc4.getIfcClosedShell().size());
    Assert.assertEquals(1, ifc4.getIfcAdvancedBrep().size());
    Assert.assertEquals(1, ifc4.getIfcRepresentationMap().size());
  }

  @Test
  public void testRelations()
  {
    // IfcAdvancedBrep
    IfcAdvancedBrep advancedBrep = (IfcAdvancedBrep) ifc4.getIfcAdvancedBrep().get(0);
    Assert.assertNotNull(advancedBrep.getOuter());

    // IfcClosedShell
    IfcClosedShell closedShell = advancedBrep.getOuter();
    Assert.assertEquals(5, closedShell.getCfsFaces().size());

    IfcFace face = (IfcFace) closedShell.getCfsFaces().get(0);
    Assert.assertTrue(face instanceof IfcAdvancedFace);
    IfcAdvancedFace advancedFace = (IfcAdvancedFace) face;
    Assert.assertEquals(1, advancedFace.getBounds().size());

    IfcFaceBound faceBound1 = (IfcFaceBound) advancedFace.getBounds().get(0);
    Assert.assertTrue(faceBound1 instanceof IfcFaceOuterBound);
    IfcFaceOuterBound faceOuterBound = (IfcFaceOuterBound) faceBound1;
    Assert.assertNotNull(faceOuterBound.getBound());

//    IfcFaceBound faceBound2 = advancedFace.getBounds().get(1);
//    Assert.assertTrue(faceBound2 instanceof IfcFaceBound);
//    Assert.assertNotNull(faceBound2.getBound());
//    Assert.assertNotNull(advancedFace.getFaceSurface()); // IFCBSPLINESURFACEWITHKNOTS
//    Assert.assertFalse(advancedFace.isSameSense());

    IfcLoop loop = faceOuterBound.getBound();
    Assert.assertTrue(loop instanceof IfcEdgeLoop);
    IfcEdgeLoop edgeLoop = (IfcEdgeLoop) loop;
    Assert.assertEquals(4, edgeLoop.getEdgeList().size());

    IfcOrientedEdge orientedEdge = (IfcOrientedEdge) edgeLoop.getEdgeList().get(0);
    Assert.assertTrue(orientedEdge.isOrientation());
    Assert.assertNull(orientedEdge.getEdgeEnd());
    Assert.assertNull(orientedEdge.getEdgeEnd());
    Assert.assertNotNull(orientedEdge.getEdgeElement());
    Assert.assertTrue(orientedEdge.getEdgeElement() instanceof IfcEdgeCurve);

    IfcEdgeCurve edgeCurve = (IfcEdgeCurve) orientedEdge.getEdgeElement();
    Assert.assertTrue(edgeCurve.isSameSense());
    Assert.assertNotNull(edgeCurve.getEdgeStart());
    Assert.assertTrue(edgeCurve.getEdgeStart() instanceof IfcVertexPoint);
    Assert.assertNotNull(edgeCurve.getEdgeEnd());
    Assert.assertTrue(edgeCurve.getEdgeEnd() instanceof IfcVertexPoint);
    Assert.assertTrue(((IfcVertexPoint) edgeCurve.getEdgeStart()).getVertexGeometry() instanceof IfcCartesianPoint);
    IfcCartesianPoint cartesianPoint = (IfcCartesianPoint) ((IfcVertexPoint) edgeCurve.getEdgeStart()).getVertexGeometry();
    Assert.assertEquals(Arrays.asList(new Double[] { 0.0, 253.099263998677, 0.0 }), cartesianPoint.getCoordinates());

    Assert.assertNotNull(edgeCurve.getEdgeGeometry());
    Assert.assertTrue(edgeCurve.getEdgeGeometry() instanceof IfcPolyline);
    IfcPolyline polyline = (IfcPolyline) edgeCurve.getEdgeGeometry();
    Assert.assertEquals(2, polyline.getPoints().size());

    IfcBSplineCurveWithKnots bSplineCurveWithKnots = ifc4.getIfcBSplineCurveWithKnots().get(0);
    Assert.assertEquals("UNSPECIFIED", bSplineCurveWithKnots.getKnotSpec().getLiteral());
    Assert.assertEquals(3, bSplineCurveWithKnots.getDegree());
    Assert.assertEquals(Arrays.asList(new Integer[] { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }),
        bSplineCurveWithKnots.getKnotMultiplicities());
    Assert.assertEquals(11, bSplineCurveWithKnots.getKnots().size());
    Assert.assertEquals(Arrays.asList(new Double[] { -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0 }),
        bSplineCurveWithKnots.getKnots());
    Assert.assertTrue(bSplineCurveWithKnots.getClosedCurve());
    Assert.assertTrue(bSplineCurveWithKnots.getSelfIntersect());
//    Assert.assertEquals(7, bSplineCurveWithKnots.getControlPointsList().size()); // FIXME one point missing

    IfcSurface surface = advancedFace.getFaceSurface();
    Assert.assertTrue(surface instanceof IfcBSplineSurfaceWithKnots);
  }
}
