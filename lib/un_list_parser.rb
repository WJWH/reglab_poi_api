module UnListParser
  def self.parse_from_XML(xml_string)
    unsc_model_objects = []
    Nokogiri::XML::Reader(xml_string).each do |node|
      if node.name == 'INDIVIDUAL' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        n = Nokogiri::XML(node.outer_xml).at('./INDIVIDUAL')
        
        list_type = n.at('./UN_LIST_TYPE').content
        uid = n.at('./DATAID').content.to_i
        first_name = n.at('./FIRST_NAME').content.strip

        second_name = n.at('./SECOND_NAME')&.content
        third_name = n.at('./THIRD_NAME')&.content
        comments = n.at('./COMMENTS1')&.content
        note = n.at('./NOTE')&.content

        full_name = second_name ? "#{first_name}, #{second_name} #{third_name}" : first_name

        unsc_model_objects << {
          list_id: uid,
          full_name: full_name,
          entity_type: "Individual",
          sanction_program: list_type,
          remarks: "#{comments} #{note}",
          authority: "un_sc_consolidated"
        }
      elsif node.name == 'ENTITY' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        n = Nokogiri::XML(node.outer_xml).at('./ENTITY')
        
        list_type = n.at('./UN_LIST_TYPE').content
        uid = n.at('./DATAID').content.to_i
        full_name = n.at('./FIRST_NAME').content.strip

        comments = n.at('./COMMENTS1')&.content
        note = n.at('./NOTE')&.content

        unsc_model_objects << {
          list_id: uid,
          full_name: full_name,
          entity_type: "Entity",
          sanction_program: list_type,
          remarks: "#{comments} #{note}",
          authority: "un_sc_consolidated"
        }
      end
    end
    unsc_model_objects
  end
end
