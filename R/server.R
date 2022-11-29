library(shiny)
library(maftools)
library(tidyverse)
library(shinyFeedback)
library(data.table)
library(DT) # datatable() function

options(shiny.maxRequestSize=10*1024^2)

hg38_genes <- read.csv("../data/genes_hg38.bed", sep = "\t")

# source("./circos_plot.R")
source("./plot_cnv.R")
source("./plot_sv.R")

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
    
    # every time you switch out a tab, clear options tab
    updateTabsetPanel(inputId = "sideBarOptions",
                      selected = "default")
  })
  
  ## SNV
  observeEvent(input$snv_plot_checkboxInput, {
    output$firstPlot = renderPlot({
    })
    
    output$secondPlot = renderPlot({
    })

    
    numOfPlot = length(input$snv_plot_checkboxInput)
    
    if (numOfPlot > 2) {
      updateCheckboxGroupInput(inputId = "snv_plot_checkboxInput",
                               selected = c("Oncoplot", "Summary plot"))
      numOfPlot == 2
    }
    
    if (numOfPlot == 1) {
      
      if (input$snv_plot_checkboxInput == "Lollipop plot") {
        updateTabsetPanel(inputId = "sideBarOptions",
                          selected = "lollipop")
        
        req(input$lollipop_gene)
        req(input$snv_data_input$datapath)
        
        output$firstPlot = renderPlot({
          maftools::lollipopPlot(mafObj(),
                                 gene = toupper(input$lollipop_gene),
                                 AACol = "Protein_Change",
                                 labelPos = "all")
        })
      } else if (input$snv_plot_checkboxInput == "Rainfall plot") {
        updateTabsetPanel(inputId = "sideBarOptions",
                          selected = "rainfall")

        req(input$snv_data_input$datapath)
        
        output$firstPlot = renderPlot({
          maftools::rainfallPlot(mafObj(),
                                 tsb = toupper(input$rainfall_sample))
      })
      } else {
        req(input$snv_data_input$datapath)
        
        if (input$snv_plot_checkboxInput == "Oncoplot") {
          output$firstPlot = renderPlot({
            maftools::oncoplot(mafObj())
          })
        } else if (input$snv_plot_checkboxInput == "Summary plot") {
          output$firstPlot = renderPlot({
            maftools::plotmafSummary(mafObj())
          })
        }
      }
    } else if (numOfPlot == 2) {
      if ("Lollipop plot" %in% input$snv_plot_checkboxInput && "Rainfall plot" %in% input$snv_plot_checkboxInput) {
        updateTabsetPanel(inputId = "sideBarOptions",
                          selected = "lollipopANDrainfall")
        
        output$firstPlot = renderPlot({
          maftools::lollipopPlot(mafObj(),
                                 gene = toupper(input$snv_gene),
                                 AACol = "Protein_Change",
                                 labelPos = "all")
        })
        
        output$secondPlot = renderPlot({
          maftools::rainfallPlot(mafObj(),
                                 tsb = toupper(input$snv_sample))
        })
        
      } else if ("Lollipop plot" %in% input$snv_plot_checkboxInput) {
        updateTabsetPanel(inputId = "sideBarOptions",
                          selected = "lollipop")
        
        if (input$snv_plot_checkboxInput[1] == "Oncoplot"){
          output$firstPlot = renderPlot({
            maftools::oncoplot(mafObj())
          })
          output$secondPlot = renderPlot({
            maftools::lollipopPlot(mafObj(),
                                   gene = toupper(input$lollipop_gene),
                                   AACol = "Protein_Change",
                                   labelPos = "all")
          })
        } else {
          output$firstPlot = renderPlot({
            maftools::plotmafSummary(mafObj())
          })
          
          output$secondPlot = renderPlot({
            maftools::lollipopPlot(mafObj(),
                                   gene = toupper(input$lollipop_gene),
                                   AACol = "Protein_Change",
                                   labelPos = "all")
          })
        }
        
      } else if ("Rainfall plot" %in% input$snv_plot_checkboxInput) {
        updateTabsetPanel(inputId = "sideBarOptions",
                          selected = "rainfall")
        
        if (input$snv_plot_checkboxInput[1] == "Oncoplot"){
          output$firstPlot = renderPlot({
            maftools::oncoplot(mafObj())
            })
          output$secondPlot = renderPlot({
            maftools::rainfallPlot(mafObj(),
                                   tsb = toupper(input$rainfall_sample))
          })
        } else {
          output$firstPlot = renderPlot({
            maftools::plotmafSummary(mafObj())
          })
          
          output$secondPlot = renderPlot({
            maftools::rainfallPlot(mafObj(),
                                   tsb = toupper(input$rainfall_sample))
          })
        }
      } else {
            output$firstPlot = renderPlot({
              maftools::oncoplot(mafObj())
            })

            output$secondPlot = renderPlot({
              maftools::plotmafSummary(mafObj())
          })
      }
    }
})
  
  observeEvent(input$cnv_plot_mode, {
    if (input$cnv_plot_mode == "By Hugo_Symbol") {
      updateTabsetPanel(inputId = "sideBarOptions",
                        selected = "CNV_by_gene")
      
    } else {
      updateTabsetPanel(inputId = "sideBarOptions",
                        selected = "CNV_by_coor")
      
      ## CNV
      output$cnv_plot <- renderPlot({
        req(input$cnv_data_input$datapath)
        
        plot_cnv(cnv_file(), 
                 input$cnv_plot_start, 
                 input$cnv_plot_end,
                 input$cnv_plot_chr,
                 input$cnv_plot_sample)
      })
    }
    
    })
  
  observeEvent(input$cnv_plot_gene, {
    gene_loc <- hg38_genes %>% 
      filter(str_remove(chromosome, "chr") == input$cnv_plot_chr) %>% 
      filter(name == toupper(input$cnv_plot_gene))
    
    ## CNV
    output$cnv_plot <- renderPlot({
      req(input$cnv_data_input$datapath)
      
      plot_cnv(cnv_file(), 
               min(gene_loc$start) - 100000, 
               max(gene_loc$end) + 100000,
               input$cnv_plot_chr,
               input$cnv_plot_sample)
      })
    })
  
  output$firstPlot <- renderPlot({
    req(input$snv_data_input$datapath)
  
    maftools::oncoplot(mafObj())
  })
  
  ## SV
  output$sv_circos = renderUI({
    req(input$sv_data_input$datapath)
    req(input$sv_plot_sample)
    
    plot_sv(sv_file(), input$reference_genome, input$sv_plot_sample)
    })
  
  
  ## Circos plot
  output$circos_plot <- renderUI({
    req(input$snv_data_input$datapath,
        input$cnv_data_input$datapath,
        input$sv_data_input$datapath)
    
    draw_circosplot(input$reference_genome, snv_file(), cnv_file(), sv_file())
  })
  
  observeEvent(input$table_to_render, {
    numOfselected = length(input$table_to_render)
    
    if (numOfselected > 1) {
      updateCheckboxGroupInput(inputId = "table_to_render",
                               selected = "SNV")

      numOfselected = 1
    }
    
    if (input$table_to_render == "SNV") {
      output$table = renderDataTable({
        req(input$snv_data_input$datapath)
        
        datatable(
          snv_file(),
          options = list(scrollX = TRUE,
                         scrollY = TRUE)
        )
      })
    } else if (input$table_to_render == "SV") {
      output$table = renderDataTable({
        req(input$sv_data_input$datapath)
        
        datatable(
          sv_file(),
          options = list(scrollX = TRUE,
                         scrollY = TRUE)
        )
      })
    } else {
      output$table = renderDataTable({
        req(input$cnv_data_input$datapath)
        
        datatable(
          cnv_file(),
          options = list(scrollX = TRUE,
                         scrollY = TRUE)
        )
      })
    }
  })
}