require 'rexml/document'
module ToXml
  
  def to_xml
    doc = REXML::Document.new
    root = doc.add_element self.class.to_s.downcase
    self.instance_variables.each do |var|
      ele = root.add_element var.reverse.chop.reverse
      ele.add_text self.instance_variable_get(var).to_s
    end
    return doc.to_s
  end
  
  
end
