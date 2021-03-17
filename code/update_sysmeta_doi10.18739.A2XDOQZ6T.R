# old_metadataPID: doi:10.18739/A2M32NB0W
# new_metadataPID: doi:10.18739/A2XD0QZ6T
# old_rm: resource_map_urn:uuid:2011fd52-a5e8-45f1-97da-43c9780d440e
# new_rm: resource_map_doi:10.18739/A2XD0QZ6T

# didn't update the formatId so doing that now -- added formatId update into replaceMember now so it should do so for packages moving forward

d1c_prod <- dataone::D1Client("PROD", "urn:node:ARCTIC")

sysmeta <- getSystemMetadata(d1c_prod@mn, "doi:10.18739/A2XD0QZ6T")

sysmeta@formatId <- "https://eml.ecoinformatics.org/eml-2.2.0"

updateSystemMetadata(d1c_prod@mn, "doi:10.18739/A2XD0QZ6T", sysmeta)


double_check_sysmeta <- getSystemMetadata(d1c_prod@mn, "doi:10.18739/A2XD0QZ6T")
