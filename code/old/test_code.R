# for later: https://cran.r-project.org/web/packages/tryCatchLog/vignettes/tryCatchLog-intro.html
# hashes: https://riptutorial.com/r/example/18339/environments-as-hash-maps
# datapack: https://cran.r-project.org/web/packages/datapack/vignettes/datapack-overview.html 




for(i in 1:5){
  print("Start First Loop")
  for(j in 11:15){
    if(j %% 2 == 1){
      next
    }
    print(j)
  }
  print(i)
  print("End First Loop")
  print("---------------")
}









# ----------------------- 3) annotate attributes in current dataTable -----------------------

for(att_num in 1:length(current_dataTable_subset$attributeName)){
  
  # 3.1) get attribute from dataTable in eml
  current_attribute_name_from_eml <- doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$attributeName
  message("--> Found attribute #", att_num, " : '", current_attribute_name_from_eml, "'")
  
  # 3.2) subset df using current_attribute_name_from_eml 
  current_attribute_subset <- current_dataTable_subset %>% 
    filter(attributeName == current_attribute_name_from_eml)
  
  # # 3.3) if eml attribute exists in df, continue, if not move to next attribute in eml
  # if(length(current_attribute_subset$attributeName < 1)) {
  #   message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")
  #   next
  # }
  # 
  # message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
  
  if(isTRUE(length(current_attribute_subset$attributeName > 0))) {
    message("The corresponding attribute to #", att_num, " in the df is: '", current_attribute_subset$attributeName, "'")
  } else {
    message("No match was found in the df for the attribute: '", current_attribute_name_from_eml, "'")
    next
  }
  
  # 3.3) create attribute id 
  current_attribute_id <- build_attributeID(dataTable_number = dt_num, attribute_number = att_num)
  
  # 3.4) verify that the attribute id is unique across datapackage
  verify_attributeID_isUnique(current_attribute_id = current_attribute_id)
  
  # 3.5) add attribute id to metadata
  doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$id <- current_attribute_id
  message("Added attributeID, '", current_attribute_id, "' to metadata")
  
  # 3.6) create/add property URI to metadata (same for all attributes)
  doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$propertyURI <- list(label = "contains meausurements of",
                                                                                                    propertyURI = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
  
  # 3.7) add value URI to metadata
  current_valueURI <- current_attribute_subset$assigned_valueURI
  current_label <- current_attribute_subset$prefName
  doc$dataset$dataTable[[dt_num]]$attributeList$attribute[[att_num]]$annotation$valueURI <- list(label = current_label,
                                                                                                 valueURI = current_valueURI)
  message("Added semantic annotation URI, '", current_valueURI, "' to metadata for attribute, '", current_attribute_name_from_eml, "'")
}

}



