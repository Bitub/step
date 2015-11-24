package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreMultiInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {
	
    @Test
    def void testMultiInverseLeftNonUniqueRelationship() {
    	
    	val model = 
    		'''
			SCHEMA XCoreMultiInverseLeftNonUniqueRelationshipTest;
			
			TYPE RightHandMultiBranch = SELECT
				(EntityMultiA
				,EntityMultiB);
			END_TYPE;


			ENTITY EntityMultiA;
			INVERSE
			  RelationA : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiB;
			INVERSE
			  RelationB : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiC;
			  RelationC : LIST [0:?] OF RightHandMultiBranch;
			END_ENTITY;
			
			END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}