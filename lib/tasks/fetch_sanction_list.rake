# require 'csv'

namespace :fetch_sanction_list do
  desc "Fetch the latest SDN list from the US Department of the Treasury"
  task us_treasury_sdn: :environment do
    # This always fetches the real list in all environments. If a fake list is desirable in some
    # environments then we can always add the link to the config or envvars
    resp = HTTP.get("https://www.treasury.gov/ofac/downloads/sdn.xml")
    raise("Error when downloading latest SDN list") unless resp.status.success?

    sdn_model_objects = []

    # The unparsed list is only a few MB in size, so we can just load the entire response into memory. Then
    # we parse the XML entry by entry to prevent having to build up a giant DOM tree for the entire document. 
    Nokogiri::XML::Reader(resp.body.to_s).each do |node|
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
        if aliases
          # todo: add all the aliases too
        end

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

    # Atomically replace all the rows in the table that were generated from the US treasury list.
    SanctionedEntity.transaction do
      SanctionedEntity.where(authority: "us_treasury_sdn").delete_all
      SanctionedEntity.insert_all(sdn_model_objects)
    end
  end

  desc "Fetch the latest Sanctioned Individuals list from the UN Security Council"
  task un_sc_consolidated_list: :environment do
    # resp = HTTP.get("https://scsanctions.un.org/resources/xml/en/consolidated.xml")
    # raise("Error when downloading latest UN sanctions list") unless resp.status.success?

    unsc_model_objects = []

    Nokogiri::XML::Reader(File.open('/home/wjw/Downloads/consolidated.xml')).each do |node|
      if node.name == 'INDIVIDUAL' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        n = Nokogiri::XML(node.outer_xml).at('./INDIVIDUAL')
        
        list_type = n.at('./UN_LIST_TYPE').content
        uid = n.at('./DATAID').content
        first_name = n.at('./FIRST_NAME').content

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
        uid = n.at('./DATAID').content
        first_name = n.at('./FIRST_NAME').content

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

    # Atomically replace all the rows in the table that were generated from the UN list.
    SanctionedEntity.transaction do
      SanctionedEntity.where(authority: "un_sc_consolidated").delete_all
      SanctionedEntity.insert_all(unsc_model_objects)
    end
  end

end
