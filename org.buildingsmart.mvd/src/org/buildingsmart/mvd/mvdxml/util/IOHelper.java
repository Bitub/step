package org.buildingsmart.mvd.mvdxml.util;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.buildingsmart.mvd.mvdxml.MvdXmlPackage;
import org.buildingsmart.mvd.mvdxml.resource.MvdXmlResourceHandler;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.impl.XMLResourceFactoryImpl;

public class IOHelper {

	public static EObject loadMvdXML(String fileName) {

		// Obtain a new resource set
		//
		ResourceSetImpl resSet = new ResourceSetImpl();

		EPackage.Registry.INSTANCE.put(MvdXmlPackage.eNS_URI, MvdXmlPackage.eINSTANCE);

		// Register the XML resource factory for the .ifc extension
		//
		resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("mvdxml", new XMLResourceFactoryImpl());

		resSet.getLoadOptions().put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_LEXICAL_HANDLER, Boolean.TRUE);

		Map<String, Object> options = new HashMap<String, Object>();

		options.put(XMLResource.OPTION_ENCODING, "UTF8");

		// use extended meta data in ecore model for parsing
		options.put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		options.put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.FALSE);

		// do not fail on unknown elements
		options.put(XMLResource.OPTION_RECORD_UNKNOWN_FEATURE, Boolean.TRUE);

		// register hooks for pre and post laod events
		options.put(XMLResource.OPTION_RESOURCE_HANDLER, new MvdXmlResourceHandler());

		// Get the resource
		//
		Resource resource = resSet.createResource(URI.createFileURI(fileName));

		try {
			resource.load(options);
			if (resource.getContents().size() > 0) {
				return resource.getContents().get(0);
			}
		} catch (IOException exception) {
			System.out.println(resource.getErrors().toString());
			if (resource.getContents().size() > 0) {
				return resource.getContents().get(0);
			}
		}
		return resource.getContents().get(0);
	}
}
