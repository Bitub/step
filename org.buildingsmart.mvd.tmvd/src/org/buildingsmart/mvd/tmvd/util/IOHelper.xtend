package org.buildingsmart.mvd.tmvd.util

import java.io.IOException
import java.util.HashMap
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.tmvd.TextualMVDStandaloneSetup
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.xmi.impl.XMLResourceFactoryImpl
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet

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

		// Get the resource
		//
		val resource = resSet.createResource(URI.createFileURI(fileName));
		resource.contents += eObject;

		// Save the contents of the resource to the file system.
		//
		val options = SaveOptions.defaultOptions
		options.addTo(newHashMap(XtextResource.OPTION_ENCODING -> "UTF8"))

		try {
			resource.save(options.toOptionsMap);

		} catch (IOException exception) {
			exception.printStackTrace
		}
	}

	def loadTextualMVD(String fileName) {

		EPackage.Registry.INSTANCE.put(MvdXmlPackage.eNS_URI, MvdXmlPackage.eINSTANCE);

		val injector = new TextualMVDStandaloneSetup().createInjectorAndDoEMFRegistration()

		val xcoreResourceSet = injector.getInstance(XtextResourceSet);
		xcoreResourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		xcoreResourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("tmvd",
			injector.getInstance(XtextResourceFactory))

		val resource = xcoreResourceSet.getResource(URI.createURI(fileName), Boolean.TRUE);
		resource.contents.get(0) as  MvdXML
	}

	def loadMvdXML(String fileName) {

		// Obtain a new resource set
		//
		val resSet = new ResourceSetImpl;

		EPackage.Registry.INSTANCE.put(MvdXmlPackage.eNS_URI, MvdXmlPackage.eINSTANCE);

		// Register the XML resource factory for the .ifc extension
		//
		resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("mvdxml", new XMLResourceFactoryImpl());

		resSet.getLoadOptions().put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.TRUE);
		resSet.getLoadOptions().put(XMLResource.OPTION_USE_LEXICAL_HANDLER, Boolean.TRUE);

		val options = new HashMap<String, Object>();

		options.put(XMLResource.OPTION_ENCODING, "UTF8");

		// use extended meta data in ecore model for parsing
		options.put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		options.put(XMLResource.OPTION_USE_ENCODED_ATTRIBUTE_STYLE, Boolean.FALSE);

		// do not fail on unknown elements
		options.put(XMLResource.OPTION_RECORD_UNKNOWN_FEATURE, Boolean.TRUE);
		
		// register hooks for pre and post laod events
		options.put(XMLResource.OPTION_RESOURCE_HANDLER, new MvdXmlResourceHandler);

		// Get the resource
		//
		val resource = resSet.createResource(URI.createFileURI(fileName))

		return try {
			resource.load(options)
			if (resource.contents.size > 0) {
				return resource.contents.get(0)
			}
		} catch (IOException exception) {
			System::out.println(resource.errors.toString)
			if (resource.contents.size > 0) {
				return resource.contents.get(0)
			}
		}
	}
}
