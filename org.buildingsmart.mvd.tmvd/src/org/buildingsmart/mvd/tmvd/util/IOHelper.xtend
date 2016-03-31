package org.buildingsmart.mvd.tmvd.util

import com.google.inject.Guice
import java.io.IOException
import java.util.HashMap
import org.buildingsmart.mvd.tmvd.TextualMVDRuntimeModule
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.xmi.impl.XMLResourceFactoryImpl
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.serializer.ISerializer

class IOHelper {

	def storeAsMVDXML(EObject eObject, String fileName) {

		// Obtain a new resource set
		//
		val resSet = new ResourceSetImpl

		// Register the XML resource factory for the .mvdxml extension
		//
		resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("mvdxml", new XMLResourceFactoryImpl());

		// Get the resource
		//
		val resource = resSet.createResource(URI.createPlatformResourceURI(fileName, true));
		resource.getContents().add(eObject);

		// Save the contents of the resource to the file system.
		val options = new HashMap<String, Object>();
		options.put(XMLResource.OPTION_ENCODING, "UTF8");
		options.put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		options.put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.FALSE);
		options.put(XMLResource.OPTION_SCHEMA_LOCATION, Boolean.TRUE);

		try {
			resource.save(options);
		} catch (IOException exception) {
			exception.printStackTrace
		}
	}

	/**
	 * FIXME Because of EFeatureMapEntry usage in Ecore model (TemplateRules#group) the xtext model can not be serialized.
	 */
	def storeAsTMVD(EObject eObject, String fileName) {

		// Obtain a new resource set
		//
		val resSet = new XtextResourceSet

		System::out.println(eObject.eResource)

		// Get the resource
		//
		val resource = resSet.createResource(URI.createPlatformResourceURI(fileName, true));
		resource.contents += eObject;

		// Save the contents of the resource to the file system.
		//
		val options = SaveOptions.defaultOptions
		options.addTo(newHashMap(XtextResource.OPTION_ENCODING -> "UTF8"))

		try {

			//			resource.save(options);
			val injector = Guice.createInjector(new TextualMVDRuntimeModule())
			val serializer = injector.getInstance(ISerializer)
			val serialized = serializer.serialize(eObject, options)
			System::out.println(serialized)

		} catch (IOException exception) {
			exception.printStackTrace
		}
	}

	def EObject load(String fileName) {

		// Obtain a new resource set
		//
		val resSet = new ResourceSetImpl;

		// Register the P21 resource factory for the .ifc extension
		//
		resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("mvdxml", new XMLResourceFactoryImpl());

		resSet.getLoadOptions().put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_LEXICAL_HANDLER, Boolean.TRUE);

		// Get the resource
		//
		val resource = resSet.createResource((URI.createPlatformResourceURI(fileName, true)))

		return try {
			resource.load(emptyMap)
			if (resource.contents.size > 0) {
				return resource.contents.get(0)
			}
		} catch (IOException exception) {
			null
		}
	}
}
