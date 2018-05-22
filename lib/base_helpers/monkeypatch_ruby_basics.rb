# credit to no one. hoping i got it right
class NilClass
  # watir
  def exists?
    nil
  end
  
  # watir
  def present?
    nil
  end
  
  # watir
  def visible?
    nil
  end
  
  # own aggregator for watir
  def exist_pres?
    nil
  end
  
  # own aggregator for watir
  def exist_pres_vis?
    nil
  end
end

class FalseClass
  # watir
  def exists?
    false
  end
  
  # watir
  def present?
    false
  end
  
  # watir
  def visible?
    false
  end
  
  # own aggregator for watir
  def exist_pres?
    false
  end
  
  # own aggregator for watir
  def exist_pres_vis?
    false
  end
end
