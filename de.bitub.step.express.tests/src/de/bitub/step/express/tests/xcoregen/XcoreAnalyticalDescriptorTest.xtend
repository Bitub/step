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
import de.bitub.step.xcore.XcoreAnalyticalPackageDescriptor
import de.bitub.step.xcore.XcoreAnalyticalPackageDescriptor.ProceduralDescriptor
import de.bitub.step.xcore.XcorePackageDescriptor
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.naming.QualifiedName
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreAnalyticalDescriptorTest extends AbstractXcoreGeneratorTest {
	
   	val scheme = 
    		'''
			SCHEMA XcoreSuperTypeTest;
			
			ENTITY EntityA
			  SUPERTYPE OF (ONEOF (EntityB));
			END_ENTITY;
			
			ENTITY EntityBA
			  SUBTYPE OF (EntityA);
			END_ENTITY;
			
			ENTITY EntityCBA
			  SUBTYPE OF (EntityB);
			END_ENTITY;
			
			ENTITY SpecialEntityC;
			END_ENTITY;
			
			TYPE EnumType = ENUMERATION OF
			(BRACE
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
    	val apd = new XcoreAnalyticalPackageDescriptor(root)
    	
    	apd.append( ProceduralDescriptor.isKindOf(root, typeof(EnumType), "enums") )
    	apd.append( ProceduralDescriptor.isLeastInheritanceLevel(root, 2, "level2") )
    	apd.append( ProceduralDescriptor.isNamedLike(root, "^Special", "specials") )
    	
    	val result = 
    	'''«FOR c : model.entity»
    		«c.name» => «apd.apply(c).get.basePackage
    	   »«ENDFOR»
    	   «FOR e : model.type»
    	    «e.name» => «apd.apply(e).get.basePackage»
    	   «ENDFOR»
    	'''
    	
    	println(result)
    } 
}