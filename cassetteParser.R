cassetteParser <- function(file.path){
  if (!require("tidyverse", quietly = TRUE))
    install.packages("tidyverse")
  library(tidyverse)
  data <- read.table(file = file.path, header = T)
  data$ID_replicon <- paste0(data$ID_replicon, '__', data$ID_integron)
  data$element <- ifelse(!str_detect(data$element,'attc'), 
                         paste0(
                           data$ID_replicon, '_',
                           str_extract(data$element, '_[:digit:]{1,3}$')),
                         data$element)
  seq.ids.start <- unique(data$ID_replicon)
  seq.ids <- data %>% 
    dplyr::filter(!str_detect(annotation, 'intI')) %>% 
    group_by(ID_replicon, type_elt) %>% 
    tally() %>% 
    pivot_wider(id_cols = ID_replicon,
                names_from = type_elt,
                values_from = n) %>% 
    dplyr::filter(attC >= 1 & protein >= 1) %>% 
    pull(ID_replicon)
  cat('Input integrons: ', length(seq.ids.start), '\n')
  cat('Excluding ', length(seq.ids.start)-length(seq.ids), 'sequences (n.attC and/or nCDS < 1', '\n')
  cat('Analyzing ', length(seq.ids), 'integrons', '\n')
  data.intermediate <- data[data$type_elt == 'protein' | data$type_elt == 'attC', ]
  data.intermediate$element <- ifelse(grepl('^intI', data.intermediate$annotation),
                                      paste0(data.intermediate$element, '[', 
                                             data.intermediate$annotation, ']'),
                                      data.intermediate$element)
  data.intermediate$element <- ifelse(grepl('^attc_', data.intermediate$element),
                                      paste0(data.intermediate$ID_replicon, '_', 
                                             data.intermediate$element),
                                      data.intermediate$element)
  
  table.output <- data.frame()
  for(alfa in 1:length(seq.ids)){
    cat('..Processing sequence: ', seq.ids[alfa], '\n')
    data.intermediate2 <- data.intermediate[data.intermediate$ID_replicon == seq.ids[alfa], ] 
    data.intermediate3 <- data.intermediate2[grepl('^intI', data.intermediate2$annotation), ]
    n.integrases <- nrow(data.intermediate3)
    strand <- data.intermediate3[,'strand']
    
    
    if (n.integrases == 0){
      array_pos <- paste0((data.intermediate2[!(grepl('attc',data.intermediate2$element) & 
                                                  data.intermediate2$strand == -1), ])$element, 
                          collapse = '|')
      array_pos_sep <- unlist( strsplit(array_pos, "(?<=attc_[[:digit:]]{3}+\\|)", perl = TRUE) )
      table <- tibble(cds.id = str_remove(string = array_pos_sep, pattern = '\\|$')) %>% 
        tidyr::separate(col = cds.id, 
                        sep = paste0('\\|',seq.ids[2], '_attc'), 
                        into = c('cds.id', 'attC.id'), 
                        remove = F, convert = T) %>% 
        mutate(attC.id = paste0(seq.ids[2], attC.id)) 
      table.output <- rbind(table.output, table) 
    } else if (n.integrases == 1 & strand == -1){
      
      array_pos <- paste0((data.intermediate2[!(grepl('attc',data.intermediate2$element) & 
                                                  data.intermediate2$strand == -1), ])$element, 
                          collapse = '|')
      array_pos_sep <- unlist( strsplit(array_pos, "(?<=attc_[[:digit:]]{3}+\\|)", perl = TRUE) )
      table <- tibble(cds.id = str_remove(string = array_pos_sep, pattern = '\\|$')) %>% 
        tidyr::separate(col = cds.id, 
                        sep = paste0('\\|',seq.ids[alfa], '_attc'), 
                        into = c('cds.id', 'attC.id'), 
                        remove = F, convert = T) %>% 
        mutate(attC.id = paste0(seq.ids[alfa], attC.id)) 
      table.output <- rbind(table.output, table)
    } else if (n.integrases == 1 & strand == 1) {
      data.intermediate2 <- data.intermediate2[nrow(data.intermediate2):1, ]
      array_neg <- paste0((data.intermediate2[!(grepl('attc',data.intermediate2$element) & 
                                                  data.intermediate2$strand == -1), ])$element, 
                          collapse = '|')
      array_pos_sep <- unlist( strsplit(array_pos, "(?<=attc_[[:digit:]]{3}+\\|)", perl = TRUE) )
      table <- tibble(cds.id = str_remove(string = array_pos_sep, pattern = '\\|$')) %>% 
        tidyr::separate(col = cds.id, 
                        sep = paste0('\\|',seq.ids[alfa], '_attc'), 
                        into = c('cds.id', 'attC.id'), 
                        remove = F, convert = T) %>% 
        mutate(attC.id = paste0(seq.ids[alfa], attC.id)) 
      table.output <- rbind(table.output, table)
    } else {
      table <- data.frame()
    }
  }
  table.output <- 
  table.output %>% 
    dplyr::filter(!str_detect(attC.id, 'NA$') )
  
  return(table.output)
}


