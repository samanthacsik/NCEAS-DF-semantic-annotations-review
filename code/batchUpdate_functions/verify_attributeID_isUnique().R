##############################
# verify that attribute ID created is unique
##############################

verify_attributeID_isUnique <- function(current_attribute_id){
  
  # search hash table for an id (key) match; if no match, add to table (value = TRUE)
  if (is.null(validate_attributeID_hash[[current_attribute_id]])) {
    validate_attributeID_hash[[current_attribute_id]] <- TRUE
    # message("'", current_attribute_id, "' is unique and has been added to the hash")
    
    # if duplicate, add to vector (value = NULL)
  } else {
    # warning("the following id is a duplicate: ", current_attribute_id)
    duplicate_ids <- current_attribute_id
  }
}