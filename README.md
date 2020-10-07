# NCEAS-DF-semantic-annotations-review
Overview of currently annotated data packages within the Arctic Data Center in preparation for the 2020 NSF site visit

* **Contributors:** Samantha Csik
* **Contact:** scsik@nceas.ucsb.edu

### Overview

...

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

* `0_libraries.R`: packages required in subsequent scripts
* `0_functions.R`: custom functions for data wrangling & plotting; information regarding function purpose and arguments is included in the script 
* `1_query_download_metadata.R`: uses solr query to extract package identifiers; use `eatocsv` package to parse associated xml files to tidy attribute information (including semantic annotations, if applicable)
* `2_exploration_and_webscraping`: super basic annotation exploration (number of ADC data packages with/without annotations, etc); webscrape for annotation preferred names to add to dataframes from script 1
* `3_unnest_tokens.R`: unnest attribute information into individual words, bigrams, and trigrams; currently only done for non-annotated attributes
* `4_filterStopWords_count_tokens.R`: filter out stop words and count number of occurrances of unnested terms; currently only done for non-annotated attributes

### Data

*The most important data files (i.e. original unaltered data, or those data files used in subsequent analyses that are saved as .csv files to eliminated time-intensive processing in scripts) are detailed below.*

#### `data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_solr.csv`
* `identifier`: unique persistent identifier assigned to each ADC data package (in most cases, this is a DOI)
* `abstract`: data package abstract
* `title`: data package title
* `keywords`: data package keywords
* `attributes`: data package attribute(s) and their corresponding attribute definitions (if available)
* `semAnnotation`: valueURI(s) for any semantically annotated attributes

#### `data/queries/query2020-10-01/fullQuery_semAnnotations2020-10-01_webscraping.csv`
* `identifier`: unique persistent identifier assigned to each ADC data package (in most cases, this is a DOI)
* `entityName`:
* `attributeName`: The name of an attribute, as listed in a .csv file
* `attributeLabel`: A descriptive label that can be used to display the name of an attribute
* `attributeDefinition`: Longer description of the attribute, including the required context for interpreting the `attributeName`
* `attributeUnit`: Unit string for affiliated attribute
* `propertyURI`: predicate URI
* `valueURI`: object URI
* `viewURL`: URL of ADC data package
* `query_datetime_utc`: date/time of query
* `prefName`: the preferred name of a semantic annotation; scraped from the web
* `ontoName`: the ontology that an semantic annotation comes from; scraped from the web

### Software

These analyses were performed in R (version 3.6.3). See [SessionInfo](https://github.com/samanthacsik/NCEAS-DF-semantic-annotations-review/blob/main/SessionInfo) for dependencies.

### Acknowledgements

Work on this project was supported by: ...
