namespace :fetch_sanction_list do
  desc "Fetch the latest SDN list from the US Department of the Treasury"
  task us_treasury_sdn: :environment do
    # This always fetches the real list in all environments. If a fake list is desirable in some
    # environments then we can always add the link to the config or envvars
    resp = HTTP.get("https://www.treasury.gov/ofac/downloads/sdn.xml")
    raise("Error when downloading latest SDN list") unless resp.status.success?

    # The unparsed list is only a few MB in size, so we can just load the entire response into memory. Then
    # we parse the XML entry by entry to prevent having to build up a giant DOM tree for the entire document. 
    sdn_model_objects = SdnListParser.parse_from_XML(resp.body.to_s)

    # Atomically replace all the rows in the table that were generated from the US treasury list.
    SanctionedEntity.transaction do
      SanctionedEntity.where(authority: "us_treasury_sdn").delete_all
      SanctionedEntity.insert_all(sdn_model_objects)
    end
  end

  desc "Fetch the latest Sanctioned Individuals list from the UN Security Council"
  task un_sc_consolidated_list: :environment do
    resp = HTTP.get("https://scsanctions.un.org/resources/xml/en/consolidated.xml")
    raise("Error when downloading latest UN sanctions list") unless resp.status.success?

    unsc_model_objects = UnListParser.parse_from_XML(resp.body.to_s)

    SanctionedEntity.transaction do
      SanctionedEntity.where(authority: "un_sc_consolidated").delete_all
      SanctionedEntity.insert_all(unsc_model_objects)
    end
  end
end
