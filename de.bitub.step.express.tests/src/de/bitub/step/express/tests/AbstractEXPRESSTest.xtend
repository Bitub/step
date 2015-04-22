package de.bitub.step.express.tests

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Schema
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
abstract class AbstractEXPRESSTest {

	@Inject protected ParseHelper<Schema> parseHelper
	
	protected def parse(CharSequence schema) {
		
		parseHelper.parse(schema)
	} 

}