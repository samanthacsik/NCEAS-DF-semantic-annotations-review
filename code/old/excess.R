x <- nonannotated_attributes %>% 
  filter(attributeName %in% c("-2", "-4", "-5", "-6", "-8", "-10", "-12", "-15", "-16", "-18", 
                              "-20", "-22", "-24", "-25", "-26", "-27", 
                              "-30", "-32", "-34", "-35", "-36", "-38", 
                              "-40", "-42", "-44", "-45", "-46", "-48", 
                              "-50", "-52", "-54", "-55", "-56", "-58", 
                              "-60", "-62", "-64", "-65", "-66", "-68", 
                              "-70", "-72", "-74", "-75", "-76", "-78", 
                              "-80", "-82", "-84", "-485", "-86", "-88", 
                              "-90", "-92", "-94", "-95", "-96", "-98",
                              "-100", "-110", "-114", "-115", "-116", 
                              "-120", "-122", "-124", "-125", "-126", "-128", "-130", 
                              "-140", "-145", "-150", "-160", "-170", "-175", "-180", "-185",
                              "-190", "-195", "-200", "-205", "-210", "-215", "-220", "-230", 
                              "-235", "-240", "-245", "-250", "-255", "-260", "-265", "-270", 
                              "-275", "-280", "-285", "-290", "-295", "-300", "-305", "-310", 
                              "-315", "-320", "-325", "-330", "-340", "-350", "-360", "-370", 
                              "-380", "-390", "-400", "-410"))










# from automating semantic annotation creation (attribute IDs)
# iterate through all entities in the datapackage
for(i in 1:numberOf_dataTables){
  
  message("Processing dataTable ", i, " of ", numberOf_dataTables)
  
  # see all attribute names in current dataTable
  current_attribute_list <- eml_get_simple(doc$dataset$dataTable[[i]]$attributeList, "attributeName")
  
  # iterate through attributes to build id and add to hash table
  for(j in 1:length(current_attribute_list)){
    
    # build attribute_id
    entity_name <- tolower(paste("entity", i, sep = "")) 
    attribute_name <- tolower(doc$dataset$dataTable[[i]]$attributeList$attribute[[j]]$attributeName)
    attribute_name_combo <- (paste("attribute", attribute_name, sep = "_")) 
    current_attribute_id <- paste(entity_name, attribute_name, sep = "_")
    
    # search hash table for an id (key) match; if no match, add to table (value = TRUE); if duplicate, add to vector (value = NULL)
    if (is.null(my_hash[[current_attribute_id]])) {
      my_hash[[current_attribute_id]] <- TRUE
      message(current_attribute_id, " has been added")
    } else {
      warning("the following id is a duplicate: ", current_attribute_id)
      duplicate_ids <- current_attribute_id
    }
  }
}
