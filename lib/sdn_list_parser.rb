module SdnListParser
  def self.parse_from_XML(xml_string)
    sdn_model_objects = []
    Nokogiri::XML::Reader(xml_string).each do |node|
      if node.name == 'sdnEntry' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        n = Nokogiri::XML(node.outer_xml).at('sdnEntry')
        entity_type = n.at('sdnType').content
        
        # We only care about individuals and organizations for now
        next unless ["Entity", "Individual"].include? entity_type

        sdn_id = n.at('uid').content.to_i
        last_name = n.at('lastName').content
        sanction_program = n.at('programList/program').content
        
        # These are optional and not all entities have them
        first_names = n.at('firstName')&.content
        remarks = n.at('remarks')&.content
        title = n.at('title')&.content
        aliases = n.at('akaList')

        full_name = first_names ? "#{last_name}, #{first_names}" : last_name

        sdn_model_objects << {
          list_id: sdn_id,
          full_name: full_name,
          entity_type: entity_type,
          sanction_program: sanction_program,
          remarks: remarks,
          title: title,
          authority: "us_treasury_sdn"
        }
      end
    end
    sdn_model_objects
  end
end
