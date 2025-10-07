Greetings, integron enthusiasts!!

The function cassetteParser uses the [IntegronFinder](https://doi.org/10.3390/microorganisms10040700) output to identify the cassettes, i.e., coding sequences (CDS) and associated *attC* site.

Given that the bounderies of a cassette are context-driven, this function uses the integrase gene as a reference point and interprets cassettes by separation of the array string by *attC* sites position in the strand complementar to the *intI* (based on classical integron structure in which the integrase is inversely orientated to the gene array), like so:

<img src="image.png" alt="My Diagram" width="600">





# Cassette parser function

## Arguments required for usage
- **file.path:** path to the annotation file (mandatory).


## Input
If the annotation is provided by another software, the input requires the following columns:
- ID_replicon: the sequence ID;
- ID_integron: different integron structures numbering in the same replicon. Particularly important when having composite integron structures containing several integrases. IntegronFinder will separate this structure into different arrays (having in consideration the integrase and *attC* sites orientation) each associated at maximum with 1 integrase;
- element: features identified and numbered by IntegronFinder (essential are the CDS and the *attC* sites);
- pos_beg: sequence position where a feature begins;
- pos_end: sequence position where a feature ends;
- strand: in which strand is encoded a feature.
- annotation: the integrase sequences must be identified with a string containing 'intI' (the annotation of other CDS can be later added to the output).

## Output
The output will be a table with two columns:
- cds.id: It contains the identifiers of a single or multiple CDS that are contain a given cassette. This can be easily formatted to a CDS-by-row table using the function [separate_rows](https://tidyr.tidyverse.org/reference/separate_rows.html) from tidyverse. When available, the CDS encoding integrases are retained in the first 'cassette' (identified as a merge of the CDS code with '[intI]') to enable the identification of the relative position of the cassettes in the array.
- attC.id: Contains a unique attC identifier based on the ID_replicon, ID_integron and *attC* numbering (replicon01__integron_1_001, replicon01__integron_1_002, replicon01__integron_2_001, ...).

## Required packages

- [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)

## Warning
In the case of CALIN elements, because there is no integrase detected, this function assumes the integron structures is in the 'correct orientation' (i.e., |----GC1-->|-------GC2------>|----GC3--->).

