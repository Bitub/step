package org.buildingsmart.mvd.tmvd.converter

import com.google.inject.Inject
import java.util.Arrays
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.eclipse.xtext.junit4.AbstractXtextTests
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.buildingsmart.mvd.tmvd.converter.ApplicableEntitiesValueConverter

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class ApplicableEntitiesValueConverterTest extends AbstractXtextTests {

	@Inject ApplicableEntitiesValueConverter valueConverter;

	@Test def testOneValue() throws Exception {
		val s = "IfcObject"
		val value = valueConverter.toValue(s, null)
		assertArrayEquals(Arrays.asList("IfcObject"), value)
		assertEquals(s, valueConverter.toString(value))
	}

	@Test def testMultiValue() throws Exception {
		val s = "IfcObject,IfcElement"
		val value = valueConverter.toValue(s, null)
		assertArrayEquals(Arrays.asList("IfcObject", "IfcElement"), value)
		assertEquals(s, valueConverter.toString(value))
	}

	@Test def testMultiValueWithSpace() throws Exception {
		val s = "IfcObject, IfcElement"
		val value = valueConverter.toValue(s, null)
		assertArrayEquals(Arrays.asList("IfcObject", "IfcElement"), value)
		assertEquals("IfcObject,IfcElement", valueConverter.toString(value))
	}
}
