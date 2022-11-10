library(shiny)
library(maftools)
library(tidyverse)
options(shiny.maxRequestSize=10*1024^2)

source("./circos_plot.R")

# Define server logic required to draw a histogram
server <- function(input, output) {
  # snv_file <- reactive(read.csv(input$snv_data_input$datapath) %>%
  #                        dplyr::rename("Hugo_Symbol" = "GENE_NAME",
  #                                      "Tumor_Sample_Barcode" = "SAMPLE_NAME") %>%
  #                        separate(
  #                          col = "MUTATION_GENOME_POSITION",
  #                          into = c("Chromosome", "Start_Position", "End_Position"),
  #                          sep = "[:-]"
  #                        ) %>%
  #                        mutate(
  #                          MUTATION_CDS = sapply(
  #                            MUTATION_CDS,
  #                            FUN = str_replace,
  #                            "[^A-Z>]",
  #                            ""
  #                          )) %>%
  #                        separate(
  #                          col = "MUTATION_CDS",
  #                          into = c("Reference_Allele", "Tumor_Seq_Allele2"),
  #                          sep = ">"
  #                        ) %>%
  #                        separate(
  #                          col = "MUTATION_DESCRIPTION",
  #                          into = c("Variant_Type", "Variant_Classification"),
  #                          sep = " - "
  #                        ) %>%
  #                        mutate(
  #                          Variant_Classification =
  #                            ifelse(Variant_Classification == "Substitution", "SNP", Variant_Classification)
  #                        ))
  
  snv_file <- reactive(read.csv(input$snv_data_input$datapath))
  sv_file <- reactive(read.csv(input$sv_data_input$datapath))
  cnv_file <- reactive(read.csv(input$cnv_data_input$datapath, sep = "\t"))
  
  output$test = renderText({
    paste(str_interp("We are on ${input$tabs}!"))
  })
  
  # observe event that tabs have been switched
  observeEvent(input$tabs, { 
    updateTabsetPanel(inputId = "dynamic_sidebar",
                      selected = input$tabs)
  })
  
  ## SNV
  output$oncoPlot <- renderPlot({
    mafObj <- maftools::read.maf(snv_file())
    maftools::oncoplot(mafObj)
  })
  
  output$summaryPlot <- renderPlot({
    mafObj <- maftools::read.maf(snv_file())
    maftools::plotmafSummary(mafObj)
  })
  
  ## Circos plot
  output$circos_plot <- renderUI({
    draw_circosplot(input$reference_genome, snv_file(), cnv_file(), sv_file())
  })
}