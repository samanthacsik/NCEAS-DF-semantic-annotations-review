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


# from 10c_identify_chilk_pkgs.R
####################################### saving just in case ########################################

# # doi:10.18739/A2RJ48V9W (know we have a lot of its child pkgs in 'attributes' df)
# parent_pkg_test <- get_package(d1c_prod@mn,
#                                "doi:10.18739/A2RJ48V9W", # metadata pid
#                                file_names = TRUE)
# 
# # child packages stored here
# children_of_doi.10.18739.A2RJ48V9W <- parent_pkg_test$child_packages
# 
# # create empty vector to store child resource maps in
# child_rm <- c()
# 
# # extract rm for each child package
# for(i in 1:length(children_of_doi.10.18739.A2RJ48V9W)){
#   child_rm[i] <- children_of_doi.10.18739.A2RJ48V9W[[i]]
# }
# 
# # create empty vector to store child metadata pids in
# child_metadata_pids <- c()
# 
# # use resource maps in `children` to download packages and extract metadata pics
# for(i in 1:length(child_rm)){
#   
#   message("downloading child package ", i, "...")
#   
#   # download package
#   pkg <- get_package(d1c_prod@mn, 
#                      child_rm[i], 
#                      file_names = TRUE)
#   
#   # extract metadata pic from child pkg
#   child_metadata_pids[i] <-  pkg$metadata
#   
# }
# 
# # match metadata pids with those in 'attributes' df to label them as child packages
# identifier <- child_metadata_pids
# pkg_type <- rep(c("child"), times = 104)
# parent_pkg_rm <- rep(c("doi:10.18739/A2RJ48V9W"), times = 104)
# 
# MP_children_of_doi.10.18739.A2RJ48V9W <- data.frame(identifier, type, parent_pkg_rm)
# 
# attributes_new <- full_join(attributes, MP_children_of_doi.10.18739.A2RJ48V9W)
