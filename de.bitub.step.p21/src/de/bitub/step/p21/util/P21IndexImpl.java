package de.bitub.step.p21.util;

import java.util.Collection;
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

}
