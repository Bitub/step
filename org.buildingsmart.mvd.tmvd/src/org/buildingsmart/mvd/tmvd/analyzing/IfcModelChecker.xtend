package org.buildingsmart.mvd.tmvd.analyzing

import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.IfcDoor
import org.buildingsmart.ifc4.IfcObject
import org.buildingsmart.ifc4.IfcProject
import org.buildingsmart.ifc4.IfcPropertySet
import org.buildingsmart.ifc4.IfcPropertySingleValue
import org.buildingsmart.ifc4.IfcWall
import org.buildingsmart.mvd.mvdxml.MvdXML

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

	def checkAll() {

		info.MVDConstraints.forEach [
			it.check
		]
	}

	def check(MVDConstraint constraint) {
		var allEntities = constraint.getAllCheckableEntitiesFrom(model)
		allEntities.removeIf(constraint.isNotApplicable)

		var allApplicableEntities = allEntities
		allApplicableEntities.forEach [
			println(it)
		]
	}

	// TODO remove hard-coded example
	def ProjectHaveTerrainObject(IfcProject project) {

		newArrayList(project).map [
			isDecomposedBy
		].flatten.map [
			relatedObjects
		].flatten.filter(IfcObject).toList
	}
	
	// TODO remove hard-coded example
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
	
	// TODO remove hard-coded example
	def isApplicable(IfcWall wall) {

		var result = newArrayList(wall).map [
			isDefinedBy
		].flatten.map [
			it.ifcRelDefinesByProperties
		].map [
			relatingPropertyDefinition.relatingPropertyDefinition
		].filter(IfcPropertySet).filter [
			name.equals("Pset_WallCommon") // check
		].map [
			hasProperties
		].flatten.filter(IfcPropertySingleValue).filter [
			name.equals("IsExternal") // check
		].map [
			nominalValue
		].filter [
			booleanValue.equals(true)
		]

		!result.nullOrEmpty
	}

}
