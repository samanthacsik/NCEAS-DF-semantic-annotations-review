# NCEAS-DF-semantic-annotations-review

Overview of currently annotated data packages within the Arctic Data Center (as of 2020-10-12) in preparation for the 2020 NSF site visit, plus workflows to update datapackages with additional semantic annotations.

* **Contributors:** Samantha Csik
* **Contact:** scsik@nceas.ucsb.edu

### Overview

In order to improve data discoverablity within the [Arctic Data Center](https://arcticdata.io/) (ADC), the datateam is working to implement semantic search within the respository. Here, we explore progress to date (Oct 2020). Data and analyses are detailed below. For a summarized report, see [here](https://samanthacsik.github.io/NCEAS-DF-semantic-annotations-review/) (though this needs updating).

In addition to recent efforts by the ADC data team to add semantic annotations to each incoming dataset (beginning ~Aug 2020, as a part of the data curation workflow), there are legacy data that can be enhanced by retroactively adding semantic annotations to dataset attributes. Here, we also explore non-annotated attributes across the ADC corpus, identify 'cryptically-named' attributes (i.e. attributes whose names/descriptions may not provide sufficient information for understanding the what the attribute is a measurement of), and manually assign appropriate semantic annotation URIs (drawing from ECSO, the [Ecosystem Ontology](http://bioportal.bioontology.org/ontologies/ECSO/?p=summary)). We then develop a workflow for automating this batch-update of legacy ADC datapackages with semantic annotations.

### Getting Started

Scripts are numbered in the order of analyses. 

### Repository Structure

```
NCEAS-DF-semantic-annotations-review
  |_code
  | |_assign_URIs_to_nonannotated_attributes
  | |_batchUpdate_functions
  | |_old
  |_data
  | |_aggregate_scores
  | |_filtered_term_counts
  | | |_nonannotated_attributes2020-10-01
  | | |_nonannotated_attributes2020-10-12
  | |_outputs
  | | |_attributes_to_annotate
  | | | |_script_10a2_attributes_to_annotate
  | |_queries
  | | |_query2020-10-01
  | | | |_query2020-10-12
  | | | |_query2020-10-12_attributes_from_nonannotated_datapackages
  | |_unnested_tokens
  | | |_nonannotated_attributes2020-10-01
  | | |_nonannotated_attributes2020-10-12
  |_docs
  |_dump_files
  |_eml
  |_figures
```

### Code

For a summary of each script and the outputs generated, see [workflow_notes](https://github.com/samanthacsik/NCEAS-DF-semantic-annotations-review/blob/main/workflow_notes).

### Data

*The following dataset contains all attributes (and corresponding infomation) that are to be semantically annotated using the batch-update workflow (scripts 10a.1-10b)*

#### `data/outputs/attributes_to_annotate/script10a2_attributes_to_annotate/attributes_to_annotate_2021Mar12.csv` (Generated in script 10f_organize_pkgs_for_batch_update.R)
* `identifier`: unique persistent identifier assigned to each ADC data package (in most cases, this is a DOI)
* `entityName`: The name of an entity (e.g. dataTable, spatialVector, etc.)
* `attributeName`: The name of an attribute, as listed in a .csv file
* `attributeLabel`: A descriptive label that can be used to display the name of an attribute
* `attributeDefinition`: Longer description of the attribute, including the required context for interpreting the `attributeName`
* `attributeUnit`: Unit string for affiliated attribute
* `viewURL`: URL of ADC data package
* `query_datetime_utc`: date/time of query
* `assigned_valueURI`: term URI from ECSO that has been manually assigned to the corresponding attribute and is to be applied as its semantic annotation
* `prefName`: the preferred name of a semantic annotation; scraped from the web
* `ontoName`: the ontology that an semantic annotation comes from; scraped from the web
* `package_type`: can be one of the following: standalone, child, parent, WEIRD, MULTINESTING, too long to load; see [workflow_notes](https://github.com/samanthacsik/NCEAS-DF-semantic-annotations-review/blob/main/workflow_notes) (under **`Script: 10a.2_batch_update_data_wrangling.R`**) for a description of these package_types
* `child_rm`: only available if package_type == "child"; the resource map of the child package
* `parent_rm`: only present if package_type == "child"; the resource map of the parent package
* `parent_metadata_pid`: only present if package_type == "child"; the metadata pid of the parent package
* `status`: notes whether a datapackage has already has some number semantic annotations, or if it has never been annotated before; (a) "dp has at least one annotation", (b) "dp was never annotated"
* `isPublic`: TRUE, FALSE, or NA; denotes whether or not a datapackage is public
* `num_datasets`: number of data objects (dataTables or otherEntities) that are contained in the datapackage
* `update_cat`: category of datapackage for subsetting batch update runs (standaloneDOI, standaloneUUID, childDOI, childUUID, parentDOI, WEIRDDOI, )

### Software

These analyses were performed in R (version 3.6.3). See [SessionInfo](https://github.com/samanthacsik/NCEAS-DF-semantic-annotations-review/blob/main/SessionInfo) for dependencies.

### Acknowledgements

Work on this project was supported by: ...
