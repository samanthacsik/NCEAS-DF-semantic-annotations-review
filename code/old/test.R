# practice with datapack

# set node
d1c_test <- dataone::D1Client("STAGING", "urn:node:mnTestARCTIC") # d1c_test@mn

# get pre-existing package
packageId <- "resource_map_urn:uuid:c84fec1f-33c6-4042-8605-33ab76e20a0f"
dp <- getDataPackage(d1c_test, identifier=packageId, lazyLoad=TRUE, quiet=FALSE)

# get metadata identifier
metadataId <- selectMember(dp, name="sysmeta@formatId", value="eml://ecoinformatics.org/eml-2.1.1")

# update metadata file to include new member
eml_path <- "path/to/your/saved/eml.xml"
write_eml(doc, eml_path)

dp <- replaceMember(dp, metadataId, replacement=eml_path)

# updating datapackage with a pre-issued DOI
dp <- replaceMember(dp, metadataId, replacement=eml_path, newId = "your pre-issued doi previously generated")

newPackageId <- uploadDataPackage(d1c_test, dp, public = TRUE, quiet = FALSE)

# will need to issue a new doi for metadata!!
