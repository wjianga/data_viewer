library(shiny)
library(maftools)
library(tidyverse)
library(shinyFeedback)
library(data.table)
# library(DT)

options(shiny.maxRequestSize=10*1024^2)

source("./circos_plot.R")
source("./plot_cnv.R")

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # read in files reactively
  snv_file <- reactive({
    if (input$snv_input_type == ".csv") {
      read.csv(input$snv_data_input$datapath)
    } else {
      read.csv(input$snv_data_input$datapath, sep = "\t")
    }
    })
  
  mafObj <- reactive({
    maftools::read.maf(snv_file())
    })
  
  sv_file <- reactive({
    if (input$sv_input_type == ".csv") {
      read.csv(input$sv_data_input$datapath)
    } else {
      read.csv(input$sv_data_input$datapath, sep = "\t")
    }
    })
  
  cnv_file <- reactive({
    if (input$cnv_input_type == ".csv") {
      read.csv(input$cnv_data_input$datapath)
    } else {
      read.csv(input$cnv_data_input$datapath, sep = "\t")
    }
    })
  
  output$test = renderText({
    paste(str_interp("We are on ${input$tabs}!"))
  })
  
  # observe event that tabs have been switched
  observeEvent(input$tabs, { 
    updateTabsetPanel(inputId = "dynamic_sidebar",
                      selected = input$tabs)
  })
  
  ## SNV
  observeEvent(input$snv_plot_checkboxInput, {
    print(input$snv_plot_checkboxInput)
    if ("Lollipop plot" %in% input$snv_plot_checkboxInput) {
      updateTabsetPanel(inputId = "sideBarOptions",
                        selected = "lollipop")
    } else {
      updateTabsetPanel(inputId = "sideBarOptions",
                        selected = "default")
    }
  })
  
  output$oncoPlot <- renderPlot({
    req(input$snv_data_input$datapath)
  
    maftools::oncoplot(mafObj())
  })
  
  output$snv_summaryPlot <- renderPlot({
    req(input$snv_data_input$datapath)

    maftools::plotmafSummary(mafObj())
  })
  
  output$snv_lollipopPlot <- renderPlot({
    maftools::lollipopPlot(mafObj(),
                           gene = toupper(input$lollipop_gene),
                           AACol = "Protein_Change",
                           labelPos = "all")
    })
  
  ## SV
  output$sv_table <- renderDataTable({
    req(input$sv_data_input$datapath)
    
    datatable(
      sv_file(),
      options = list(scrollX = TRUE,
                     scrollY = TRUE)
    )
  })
  
  ## CNV
  output$cnv_plot <- renderPlot({
    req(input$cnv_data_input$datapath)
    
    plot_cnv(cnv_file(), 
             input$cnv_plot_start, 
             input$cnv_plot_end,
             input$cnv_plot_chr)
    })
  
  
  ## Circos plot
  output$circos_plot <- renderUI({
    req(input$snv_data_input$datapath,
        input$cnv_data_input$datapath,
        input$sv_data_input$datapath)
    
    draw_circosplot(input$reference_genome, snv_file(), cnv_file(), sv_file())
  })
}