package de.bitub.step.p21;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.SetMultimap;

public class P21IndexImpl implements P21Index
{

  // (key => value) <-> (#21 => EObject [Entity])
  //
  private final ConcurrentMap<String, EObject> index = new ConcurrentHashMap<>();

  // (key => values) <-> (#5 => (#2, Attribute/Refernce), (#1, Attribute/Refernce))
  //
  private final SetMultimap<String, IdStructuralFeaturePair> unresolved = HashMultimap.create();

  public final List<ListTriple> triples = new ArrayList<P21IndexImpl.ListTriple>();

  private P21IndexImpl()
  {
  }

  static P21IndexImpl init()
  {
    return new P21IndexImpl();
  }

  @Override
  public EObject retrieve(String id)
  {
    return index.get(id);
  }

  @Override
  public EObject store(String id, EObject object)
  {
    return index.put(id, object);
  }

  @Override
  public void store(String ref, String id, EStructuralFeature feature)
  {
    unresolved.put(ref, new IdStructuralFeaturePair(id, feature));
  }

  @Override
  public Map<String, Collection<IdStructuralFeaturePair>> retrieveUnresolved()
  {
    return unresolved.asMap();
  }

  @Override
  public List<ListTriple> retrieveUnresolvedLists()
  {
    return triples;
  }

  /**
   * Store a string list with unresolved references (e.g. #12).
   * And an list wrapper object which will be filled with the
   * resolved entity instances.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * 
   * @generated NOT
   * @author Riemi - 03.05.2016
   */
  public class ListTriple
  {
    public List<String> references;

    public EObject wrapper;

    public EStructuralFeature feature;

    public ListTriple(List<String> references, EObject wrapper, EStructuralFeature listFeature)
    {
      this.references = references;
      this.wrapper = wrapper;
      this.feature = listFeature;
    }

    @Override
    public String toString()
    {
      StringBuilder sb = new StringBuilder();
      sb.append("(" + references + " -> " + wrapper.eClass().getName() + "@" + feature.getName() + ")");
      return sb.toString();
    }
  }

  public class IdStructuralFeaturePair
  {
    public String id = null;

    public EStructuralFeature feature = null;

    public String featureName = null;

    public IdStructuralFeaturePair(String id, EStructuralFeature feature)
    {
      this.id = id;
      this.feature = feature;
      this.featureName = feature.getName();
    }

    @Override
    public String toString()
    {
      StringBuilder sb = new StringBuilder();
      sb.append("(" + id + " -> " + featureName + ")");
      return sb.toString();
    }
  }

  @Override
  public void store(List<String> references, EObject listWrapper, EStructuralFeature listFeature)
  {
    triples.add(new ListTriple(references, listWrapper, listFeature));
  }

  @Override
  public List<EObject> retrieveAll(List<String> references)
  {
    List<EObject> entities = new ArrayList<EObject>();

    for (String ref : references) {
      entities.add(retrieve(ref));
    }

    return entities;
  }

}