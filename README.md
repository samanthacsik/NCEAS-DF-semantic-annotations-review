# NCEAS-DF-semantic-annotations-review
Overview of currently annotated data packages within the Arctic Data Center in preparation for the 2020 NSF site visit

* **Contributors:** Samantha Csik
* **Contact:** scsik@nceas.ucsb.edu

### Overview

### Getting Started

Scripts are numbered in the order they are to be run.

### Repository Structure

```
NCEAS-DF-semantic-annotations-review
  |_code
    |_old
  |_data
    |_filtered_term_counts
      |_nonannotated_attributes
    |_queries
      |_query2020-10-01
        |_xml
    |_unnested_tokens
      |_nonannotated_attributes
```

### Code

### Data

*The most important (i.e. original unaltered data, or those data files used in subsequent analyses that are saved as .csv files to eliminated time-intensive processing in scripts) data files are detailed below.*

#### `data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_solr.csv`
* `identifier`:
* `abstract`:
* `title`:
* `keywords`:
* `attributes`:
* `semAnnotation`:

#### `data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_webscraping.csv`
* `identifier`:
* `entityName`:
* `attributeName`: 
* `attributeLabel`:  
* `attributeDefinition`: 
* `attributeUnit`:
* `propertyURI`: 
* `valueURI`: 
* `viewURL`: 
* `query_datetime_utc`: 
* `prefName`: 
* `ontoName`: 

### Software

These analyses were performed in R (version 3.6.3). See [SessionInfo](https://github.com/samanthacsik/NCEAS-DF-semantic-annotations-review/blob/main/SessionInfo) for dependencies.

### Acknowledgements

Work on this project was supported by: ...
