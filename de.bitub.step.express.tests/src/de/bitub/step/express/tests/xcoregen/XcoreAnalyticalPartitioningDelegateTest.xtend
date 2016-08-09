/* 
 * Copyright (c) 2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.EnumType
import de.bitub.step.xcore.XcoreAnalyticalPartitioningDelegate
import de.bitub.step.xcore.XcoreAnalyticalPartitioningDelegate.ProceduralDescriptor
import de.bitub.step.xcore.XcorePackageDescriptor
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.naming.QualifiedName
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreAnalyticalPartitioningDelegateTest extends AbstractXcoreGeneratorTest {
	
   	val scheme = 
    		'''
			SCHEMA XcoreSuperTypeTest;
			
			TYPE EnumExample = ENUMERATION OF (
			    BRACE
				,CHORD
				,COLLAR
				,MEMBER
				,MULLION
				,PLATE
				,POST
				,PURLIN
				,RAFTER
				,STRINGER
				,STRUT
				,STUD
				,USERDEFINED
				,NOTDEFINED);
			END_TYPE;
			
			ENTITY EntityA
			  SUPERTYPE OF (ONEOF (EntityBA));
			END_ENTITY;
			
			ENTITY EntityBA
			  SUPERTYPE OF (ONEOF (EntityCBA))
			  SUBTYPE OF (EntityA);
			END_ENTITY;
			
			ENTITY EntityCBA
			  SUBTYPE OF (EntityBA);
			END_ENTITY;
			
			ENTITY SpecialEntityC;
			END_ENTITY;

			END_SCHEMA;
    		'''
	    
    @Test
    def void testXcoreSuperTypeTest() {
    	
    	val model = generateEXPRESS(scheme)	 
    	val root = new ProceduralDescriptor(new XcorePackageDescriptor() {
						
						override getNsURI() {
							"http://test.org"
						}
						
						override getName() {
							"test"
						}
						
						override getBasePackage() {
							QualifiedName.create("base","testpackage");
						}						
		})   	
    	val apd = new XcoreAnalyticalPartitioningDelegate(root)
    	
    	apd.append( ProceduralDescriptor.isDataKindOf(root, typeof(EnumType), "enums") )
    	apd.append( ProceduralDescriptor.isAtInheritanceLevel(root, "at%d") )
    	apd.append( ProceduralDescriptor.isLeastInheritanceLevel(root, 2, "level2") )
    	apd.append( ProceduralDescriptor.isNamedLike(root, "^Special", "specials") )
    	
    	val map = newHashMap
		for(c : model.entity) {
			
			map.put(c.name, apd.apply(c).get.basePackage.toString)
		}    	

		for(c : model.type) {
			
			map.put(c.name, apd.apply(c).get.basePackage.toString)
		}    	
		
		assertEquals("base.testpackage.at0", map.get("EntityA"))
		assertEquals("base.testpackage.at1", map.get("EntityBA"))
		assertEquals("base.testpackage.level2.at2", map.get("EntityCBA"))
		assertEquals("base.testpackage.specials.at0", map.get("SpecialEntityC"))
		assertEquals("base.testpackage.at0.enums", map.get("EnumExample"))
    } 
}