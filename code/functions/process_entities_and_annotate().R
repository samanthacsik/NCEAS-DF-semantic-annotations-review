##############################
# process & annotate (works for dataTables only or otherEntities only)
##############################

process_entities_and_annotate <- function(all_entities){
  
  # FIRST OPTION: if muliple entities (of the same type i.e. multiple dataTables or multiple otherEntities) present
  if(isTRUE(is.list(all_entities_path[[1]]))){
    
    for(entity_num in 1:length(all_entities[[1]])){ 
      
      # 2.1) get current dataTable name from metadata
      current_entityName_from_eml <- all_entities[[1]][[entity_num]]$entityName
      num_attributes_in_eml_entity <- length(all_entities[[1]][[entity_num]]$attributeList$attribute)
      
      # 2.2) subset 'current_datapackage_subset' accordingly
      current_entity_subset <- current_datapackage_subset %>%
        filter(entityName == current_entityName_from_eml)
      
      # ----------------------- 3) annotate attributes in current dataTable -----------------------
      
      doc <- annotate_attributes(doc, entity_num, 
                                 current_entityName_from_eml,
                                 num_attributes_in_eml_entity, 
                                 current_entity_subset,
                                 entity_path) 
    }
    
    return(doc)
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    # SECOND OPTION: if a single, unpacked entity present 
    } else if(isTRUE(is.character(all_entities_path[[1]]))){
      
      # 2.1) get current dataTable name from metadata
      current_entityName_from_eml <- all_entities_path$entityName
      num_attributes_in_eml_entity <- length(all_entities_path$attributeList$attribute)
      
      # 2.2) subset 'current_datapackage_subset' accordingly
      current_entity_subset <- current_datapackage_subset %>%
        filter(entityName == current_entityName_from_eml)
      
      # ----------------------- 3) annotate attributes in current dataTable -----------------------
      
      doc <- annotate_attributes_unpacked(doc,
                                          current_entityName_from_eml,
                                          num_attributes_in_eml_entity, 
                                          current_entity_subset,
                                          entity_path) 
    }
  
  return(doc)
  
}
  

  
  




# for(dt_num in 1:length(all_entities)){ # dataTables_from_metadata
#   
#   # 2.1) get current dataTable name from metadata
#   current_dataTable_name_from_eml <- dataTables_from_metadata[[dt_num]]$entityName
#   num_attributes_in_eml_dataTable <- length(dataTables_from_metadata[[dt_num]]$attributeList$attribute)
#   
#   # 2.2) subset 'current_datapackage_subset' accordingly
#   current_dataTable_subset <- current_datapackage_subset %>%
#     filter(entityName == current_dataTable_name_from_eml)
#   
#   # ----------------------- 3) annotate attributes in current dataTable -----------------------
#   
#   doc <- annotate_attributes(num_attributes_in_eml_dataTable, 
#                              doc, dt_num,
#                              current_dataTable_subset)
# }