package org.buildingsmart.mvd.tmvd.analyzing

import java.util.List
import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.ifc4.IfcDoor
import org.buildingsmart.ifc4.IfcObject
import org.buildingsmart.ifc4.IfcProject
import org.buildingsmart.ifc4.IfcPropertySet
import org.buildingsmart.ifc4.IfcPropertySingleValue
import org.buildingsmart.ifc4.IfcRelDefinesByProperties
import org.buildingsmart.ifc4.IfcTypeObject
import org.buildingsmart.ifc4.IfcWall
import org.buildingsmart.ifc4.IfcWallStandardCase
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.EcoreUtil2

class IfcModelChecker {

	private IFC4 model
	private MvdXML mvd

	protected MVDModelInfo info

	new(IFC4 model, MvdXML mvd) { // TODO: make schema independant
		this.model = model
		this.mvd = mvd

		init(mvd)
	}

	def private void init(MvdXML mvd) {
		info = new MVDModelInfo(mvd)
	}

	def check() {

		info.MVDConstraints.forall[]
	}

	def check(Concept concept) {

		new MVDConstraint(concept)
		true
	}

	def filterByType(List<IfcRelDefinesByProperties> relDefinesByPropertiesList) {

		return relDefinesByPropertiesList.map [
			var realtingPropertyDefinition = it.relatingPropertyDefinition.relatingPropertyDefinition

			if (relDefinesByPropertiesList instanceof IfcPropertySet) {
				return realtingPropertyDefinition as IfcPropertySet
			}
			null
		].filterNull
	}

	def relatingPropertyDefinition2(IfcRelDefinesByProperties relation) {
		var relatingpropertyDefiniton = relation.relatingPropertyDefinition.relatingPropertyDefinition

		if (relatingpropertyDefiniton instanceof IfcPropertySet) {
			return relatingpropertyDefiniton as IfcPropertySet
		}
	}

	def hasPropertySets(IfcTypeObject typeObject) {

		typeObject.hasPropertySets.map [
			if (it instanceof IfcPropertySet) {
				return it as IfcPropertySet
			}
		].filterNull
	}

	def hasProperties(IfcPropertySet propertySet) {
		propertySet.hasProperties.filter(IfcPropertySingleValue)
	}

	def extractApplicableEntities(Concept concept) {
		val triple = new MVDConstraint(concept)
		triple.conceptRoot.applicableRootEntity
		val entityName = triple.conceptRoot.applicableRootEntity
		val typeName = getClassFromName(entityName)

		

		// all entities of applicable type
		val allApplicableEntities = EcoreUtil2::getAllContentsOfType(mvd.views, typeName);
		val allDoors = model.ifcDoor

		// search for entities to check from here
		allDoors.forall [
			it.PropertyName.forall [
				var propertyName = it.name;
				propertyName.equals("SelfClosing")
			]
		]
	}
	
	def ProjectHaveTerrainObject(IfcProject project) {
		newArrayList(project).map [
			isDecomposedBy
		].flatten.map [
			relatedObjects
		].flatten.filter(IfcObject).toList
	}

	def PropertyName(IfcDoor door) {
		newArrayList(door).map [
			isDefinedBy
		].flatten.map [
			it.ifcRelDefinesByProperties
		].map [
			relatingPropertyDefinition.relatingPropertyDefinition
		].filter(IfcPropertySet).map [
			hasProperties
		].flatten.filter(IfcPropertySingleValue).toList
	}

	def O_(List<IfcWallStandardCase> allWalls) {
		allWalls.map [
			isDefinedBy
		].flatten.map [
			it.ifcRelDefinesByProperties
		].map [
			relatingPropertyDefinition.relatingPropertyDefinition
		].filter(IfcPropertySet)
	}

	def singleWall(IfcWallStandardCase wall) {
		newArrayList(wall).map [
			isDefinedBy
		].flatten.map [
			it.ifcRelDefinesByProperties
		].map [
			relatingPropertyDefinition.relatingPropertyDefinition
		].filter(IfcPropertySet)
	}

	def reusableTemplate(Iterable<IfcPropertySet> allWalls) {
		allWalls.map [
			hasProperties
		].flatten.filter(IfcPropertySingleValue)
	}

	def T_(List<IfcWallStandardCase> allWalls) {
		allWalls.map [
			isTypedBy
		].flatten.map [
			relatingType
		].map [
			hasPropertySets
		].flatten.filter(IfcPropertySet)
	}

	def O_PsetName(List<IfcWallStandardCase> allWalls) {
		var propertysets = O_(allWalls)

		propertysets.forall [
			name.equals("Pset_WallCommon")
		]
	}

	def T_PsetName(List<IfcWallStandardCase> allWalls) {
		var propertysets = T_(allWalls)

		propertysets.forall [
			name.equals("Pset_WallCommon")
		]
	}

	def O_PSingleValue(List<IfcWallStandardCase> allWalls) {
		var nominalvlaues = O_(allWalls).reusableTemplate.map [
			nominalValue
		]

		nominalvlaues.forall [
			booleanValue.equals(true)
		]
	}

	def T_PSingleValue(List<IfcWallStandardCase> allWalls) {
		var nominalvlaues = T_(allWalls).reusableTemplate.map [
			nominalValue
		]

		nominalvlaues.forall [
			booleanValue.equals(true)
		]
	}

	def O_PName(List<IfcWallStandardCase> allWalls) {
		var propertysinglevalues = O_(allWalls).reusableTemplate

		propertysinglevalues.forall [
			name.equals("FireRating")
		]
	}

	def T_PName(List<IfcWallStandardCase> allWalls) {
		var propertysinglevalues = T_(allWalls).reusableTemplate

		propertysinglevalues.forall [
			name.equals("FireRating")
		]
	}

	def getClassFromName(String name) {
		var eClass = Ifc4Package::eINSTANCE.getEClassifier(name) as EClass;
		var tmpObject = EcoreUtil.create(eClass)
		tmpObject.class
	}

	// only get walls which have the PropertSet 'Pset_WallCommon' assigned
	// only get walls which have a SingleValueProperty of 'IsExternal' & 'LoadBearing' assigned
	def applicableWalls() {
		val allWalls = model.ifcWallStandardCase

		var propertysets = O_(allWalls)

		propertysets.filter [
			name.equals("Pset_WallCommon")
		].reusableTemplate.filter [
			name.equals("IsExternal")
		].map [
			nominalValue
		].filter [
			booleanValue.equals(true)
		]
	}

	def isApplicable(IfcWall wall) {
		
		

		var result = newArrayList(wall).map [
			isDefinedBy
		].flatten.map [
			it.ifcRelDefinesByProperties
		].map [
			relatingPropertyDefinition.relatingPropertyDefinition
		].filter(IfcPropertySet).filter [
			name.equals("Pset_WallCommon") // check
		].reusableTemplate.filter [
			name.equals("IsExternal") // check
		].map [
			nominalValue
		].filter [
			booleanValue.equals(true)
		]

		!result.nullOrEmpty
	}

}
