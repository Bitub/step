/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.generator

import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.Schema
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import de.bitub.step.express.Type

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class OclInEcoreGenerator implements IGenerator {
	
	val static Logger myLog = Logger.getLogger(EXPRESSCollector);
	
	static val builtinTypeMapping =  <EClass, EDataType>newHashMap(
		new Pair(ExpressPackage.Literals.INTEGER_TYPE, EcorePackage.Literals.EINT),
		new Pair(ExpressPackage.Literals.NUMBER_TYPE, EcorePackage.Literals.EDOUBLE),
		new Pair(ExpressPackage.Literals.LOGICAL_TYPE, EcorePackage.Literals.EBOOLEAN_OBJECT),
		new Pair(ExpressPackage.Literals.BOOLEAN_TYPE, EcorePackage.Literals.EBOOLEAN),
		new Pair(ExpressPackage.Literals.BINARY_TYPE, EcorePackage.Literals.EBOOLEAN),
		new Pair(ExpressPackage.Literals.REAL_TYPE, EcorePackage.Literals.EDOUBLE),
		new Pair(ExpressPackage.Literals.STRING_TYPE, EcorePackage.Literals.ESTRING)
	);
	
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
							
		myLog.info("Generating oclinecore representation of "+schema.name)
		fsa.generateFile(schema.name+".oclinecore", schema.compile)
	}
	
	def compile(Resource resource) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		schema.compile
	}
	
	def compile(Schema s) {
		
		'''import ecore : 'http://www.eclipse.org/emf/2002/Ecore';
		
package «s.name.toFirstLower» : «s.name» = 'http://www.bitub.de/express/«s.name»' {
			
  -- Enumerations of «s.name»
			
  «s.types.filter[t | t.datatype instanceof EnumType].forEach[en | compile(en.name, en.datatype as EnumType)]»
			
  -- Select types of «s.name»
			
  «FOR e : s.entities»«e.compile»«ENDFOR»	
}'''
	}
	
	def compile(Entity e) {
		
		'''«IF e.abstract»abstract«ENDIF» class «e.name.toFirstUpper»
		«IF !e.supertype.empty» extends «e.supertype.map[name].join(', ')» «ENDIF»
		{
			
		}'''
	}
	
	def compile(String name, EnumType t) {
		
		'''
		enum «name.toFirstUpper»  {			
			«FOR literal : t.literal» 
			«literal.name» ; 
			«ENDFOR»
		}'''
	}
	
	def compile(Attribute a) {
		
	}
}
