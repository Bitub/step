package de.bitub.step.p21.mapper;

import org.eclipse.emf.ecore.EClassifier;

public interface NameToClassifierMap
{
  /**
   * Get classifier by name from current STEP schema package.
   * The name will be transformed to upper case inside without respect to
   * locale.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @param name The name of the classifier to search for.
   * @return The EClassifier if found or null.
   */
  EClassifier getEClassifier(String name);
}
