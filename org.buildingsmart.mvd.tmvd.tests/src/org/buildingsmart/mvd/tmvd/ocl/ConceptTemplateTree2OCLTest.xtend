package org.buildingsmart.mvd.tmvd.ocl

import com.google.inject.Inject
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.analyzing.MVDModelInfo
import org.buildingsmart.mvd.tmvd.generator.ConceptTemplateTree2OCL
import org.buildingsmart.mvd.tmvd.util.IOHelper
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(TextualMVDInjectorProvider)
class ConceptTemplateTree2OCLTest {

	@Inject
	extension IOHelper io

	var example1 = "mvd-files/mvdXML_V1-1-Final_Validation.mvdxml"
	var example2 = "mvd-files/DoorHasSelfClosing.mvdxml"

	@Test
	def void testExample1() {
		val mvd = io.loadMvdXML(example1) as MvdXML
		val info = new MVDModelInfo(mvd)
		val tree2ocl = new ConceptTemplateTree2OCL(info)

		val expected = #[
			"predefinedType",
			"name",
			"nominalValue",
			"name"
		]

		val actuals = info.ruleIds.map [
			tree2ocl.compile(it, '''''').toString
		]

		assertArrayEquals(expected, actuals)
	}

	@Test
	def void testRealtionshipForAll() {
		val mvd = io.loadMvdXML(example1) as MvdXML
		val info = new MVDModelInfo(mvd)
		val tree2ocl = new ConceptTemplateTree2OCL(info)

		tree2ocl.relationships() // test
		var expected = newHashMap(
			"T_PsetName" ->
				"isTypedBy-> selectByType(IfcRelDefinesByType).relatingType-> selectByType(IfcTypeObject).hasPropertySets-> selectByType(IfcPropertySet)isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)name",
			"T_PName" ->
				"isTypedBy-> selectByType(IfcRelDefinesByType).relatingType-> selectByType(IfcTypeObject).hasPropertySets-> selectByType(IfcPropertySet)isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)hasProperties-> selectByType(IfcPropertySingleValue).name",
			"PSingleValue" -> "hasProperties-> selectByType(IfcPropertySingleValue).nominalValue",
			"PsetName" ->
				"isTypedBy-> selectByType(IfcRelDefinesByType).relatingType-> selectByType(IfcTypeObject).hasPropertySets-> selectByType(IfcPropertySet)isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)name",
			"PName" -> "hasProperties-> selectByType(IfcPropertySingleValue).name",
			"O_PSingleValue" ->
				"isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)hasProperties-> selectByType(IfcPropertySingleValue).nominalValue",
			"T_PSingleValue" ->
				"isTypedBy-> selectByType(IfcRelDefinesByType).relatingType-> selectByType(IfcTypeObject).hasPropertySets-> selectByType(IfcPropertySet)isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)hasProperties-> selectByType(IfcPropertySingleValue).nominalValue",
			"O_PsetName" ->
				"isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)name",
			"PredefinedType" -> "predefinedType",
			"O_PName" ->
				"isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet)hasProperties-> selectByType(IfcPropertySingleValue).name"
		)

		var actual = tree2ocl.exprMap

		assertEquals(expected, actual)
	}

	@Test
	def void testExample2() {
		val mvd = io.loadMvdXML(example2) as MvdXML
		val info = new MVDModelInfo(mvd)
		val tree2ocl = new ConceptTemplateTree2OCL(
			info)

		val expected = #[
			'''isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition-> selectByType(IfcPropertySet).hasProperties-> selectByType(IfcPropertySingleValue).name'''
		]

		val actuals = info.ruleIds.map [
			tree2ocl.compile(it, '''''').toString
		]

		assertArrayEquals(expected, actuals)
	}
}
