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
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.Schema
import de.bitub.step.express.Type
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

class EXPRESSCollector {
	
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
	
	val conceptMap = <ExpressConcept, EClassifier>newHashMap();
	
	/**
	 * Transforms an EXPRESS schema into EPackage.
	 */
	def EPackage transform(Schema schema, String eURI) {
		
		val ePackage = EcoreFactory.eINSTANCE.createEPackage;

		ePackage.name = schema.name;
		ePackage.nsPrefix = schema.name;
		ePackage.nsURI = eURI;
		
		for(Type type : schema.types) {
			
			// Check whether type has a built in mapping
			if(builtinTypeMapping.containsKey(type.datatype)) {
				
				val eDatatype = builtinTypeMapping.get(type.datatype)
				conceptMap.put(type, eDatatype )
				myLog.info("Adapted type \""+type.name+"\" to builtin EDataType \""+ eDatatype.name +"\" concept.")				
			} else {		
				
				// Otherwise generate explicit class descriptor for composite data types				
				val newType = EcoreFactory.eINSTANCE.createEClass;
				newType.name = type.name;
				conceptMap.put(type, newType)
				ePackage.EClassifiers += newType
				
				myLog.info("Adapted type \""+newType.name+"\" to EClass concept.")				
			}
		}
		
		for(Entity entity: schema.entities) {
			
			val newClass = eClassOf(entity)
			
			for(Attribute attribute : entity.attribute) {
				
				val eAttr = EcoreFactory.eINSTANCE.createEAttribute
				eAttr.name = attribute.name
				
				// TODO Distinction between attribute and reference
				newClass.EAttributes += eAttr
				
				eAttr.derived = attribute.expression != null
				eAttr.changeable = attribute.expression == null
				eAttr.transient = attribute.expression != null			
			}
		}

		ePackage;	
	}
	
	def EClass eClassOf(Entity e) {
		
		if(conceptMap.containsKey(e)) {
			
			conceptMap.get(e) as EClass
		} else {
			
			val newClass = EcoreFactory.eINSTANCE.createEClass;
			newClass.name = e.name			
			conceptMap.put(e, newClass)
			myLog.info("Adapted entity \""+e.name+"\" to EClass \""+newClass.name+"\".")
			
			if(e.abstract) {
				newClass.abstract = true
				newClass.interface = true;
			}
					
			newClass
		}
	} 
}