package de.bitub.step.p21.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EPackage;

/**
 * Implements the getEClassifier functionality of EPackage for upper case
 * naming of all classifiers. Entity names in P21 data exchange are all in upper
 * case notation. This way it is easier to get access to the correct classifier.
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 * 
 * @generated NOT
 * @author Riemi - 08.05.2016
 */
public class NameToClassifierMapImpl implements NameToClassifierMap
{
  private Map<String, EClassifier> eNameToEClassifierMap = null;

  private EPackage ePackage = null;

  public NameToClassifierMapImpl(EPackage ePackage)
  {
    this.ePackage = ePackage;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @see de.bitub.step.p21.mapper.NameToClassifierMap#getEClassifier(java.lang.String)
   */
  @Override
  public EClassifier getEClassifier(String name)
  {
    if (eNameToEClassifierMap == null) {

      List<EClassifier> eClassifiers = ePackage.getEClassifiers();
      Map<String, EClassifier> result = new HashMap<String, EClassifier>(eClassifiers.size());

      for (EClassifier eClassifier : eClassifiers) {

        String key = eClassifier.getName().toUpperCase(); // store all upper-case name
        EClassifier duplicate = result.put(key, eClassifier);

        // TODO log or maintain name duplicates
        //
        if (duplicate != null) {
          result.put(key, duplicate); // restore first value
        }
      }
      eNameToEClassifierMap = result;
    }

    return eNameToEClassifierMap.get(name.toUpperCase());
  }
}
