package org.buildingsmart.mvd.tmvd.formatting2

import com.google.inject.Inject
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.tmvd.AbstractTextualMVDTest
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.formatter.FormatterTester
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class TextualMVDFormatterTest extends AbstractTextualMVDTest {

	@Inject extension FormatterTester

	@Test def void example() {
		var pck = MvdXmlPackage::eINSTANCE

		assertFormatted[
			expectation = '''
				@UUID(00000000-0000-0000-0000-000000000000)
				mvd DoorSelfClosing
				
				author		"Sebastian Riemschüssel"
				status		sample
				version		"1.0"
				
				templates {
					@UUID(ef94ae78-b5f0-468d-b950-46b8a320c45a)
					Name = ConceptTemplate {
						applicableEntity: IfcObject
						applicableSchema: IFC4
						def	rules : [
							attr IsDefinedBy {
								entity IfcRelDefinesByProperties {
									attr RelatingPropertyDefinition {
										entity IfcPropertySet {
											attr HasProperties {
												entity IfcPropertySingleValue {
													@RuleID(PropertyName)
													attr Name with constraints [
														=> "Name[Value]>=X";
														=> "Name[Size]<=10";
													],
													attr NominalValue,
													attr Unit
												}
											}
										}
									}
								}
							}
						]
					}
				}
			'''
			toBeFormatted = '''
				@UUID ( 00000000-0000-0000-0000-000000000000 ) 
				
				mvd DoorSelfClosing
				
				author		"Sebastian Riemschüssel"
				status		sample
				version		"1.0"
				templates {
				@UUID(ef94ae78-b5f0-468d-b950-46b8a320c45a)
				Name = ConceptTemplate {
						applicableEntity: IfcObject
					applicableSchema: IFC4
					def	rules : [
						attr IsDefinedBy 
						{
							entity IfcRelDefinesByProperties {
								attr RelatingPropertyDefinition {
										entity IfcPropertySet {
										attr HasProperties {
										entity IfcPropertySingleValue {
													
													@RuleID(PropertyName)
													attr Name with constraints [
													=> "Name[Value]>=X";
													=> "Name[Size]<=10";
													],
													attr NominalValue,
													attr Unit
												}
											}
										}
									}
								}
							}
						]
					}
				}
			'''
		]
	}

}
