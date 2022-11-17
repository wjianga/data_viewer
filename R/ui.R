library(shiny)
library(shinyFeedback)

# dynamically change side bar layout based on which tab the user selected
sidebar_panel <- tabsetPanel(
  id = "dynamic_sidebar",
  type = "hidden",
  selectInput(
    inputId = "reference_genome",
    label = "Please select reference genome",
    choices = c("GRCh38/hg38", "GRCh37/hg19", "GRCh36/hg18"),
    selected = "GRCh38/hg38"
  ),
  tabPanel(
    title = "Introduction",
    selectInput(
      inputId = "snv_input_type",
      label = "File extension",
      choices = c(".csv", ".tsv", ".txt")
    ),
    fileInput(
      inputId = "snv_data_input",
      label = "Upload Point Mutation files",
      buttonLabel = "Upload",
      multiple = T,
      accept = c(".csv", ".tsv", ".txt")
    ),
    selectInput(
      inputId = "sv_input_type",
      label = "File extension",
      choices = c(".csv", ".tsv", ".txt")
    ),
    fileInput(
      inputId = "sv_data_input",
      label = "Upload Structural Variant files",
      buttonLabel = "Upload",
      multiple = T,
      accept = c(".csv", ".tsv", ".txt")
    ),
    selectInput(
      inputId = "cnv_input_type",
      label = "File extension",
      choices = c(".csv", ".tsv", ".txt")
    ),
    fileInput(
      inputId = "cnv_data_input",
      label = "Upload Copy Number Variant files",
      buttonLabel = "Upload",
      multiple = T,
      accept = c(".csv", ".tsv", ".txt")
    )
  ),
  tabPanel(
    title = "Point Mutations",
    checkboxGroupInput(
      inputId = "snv_plot_checkboxInput",
      choices = c("Oncoplot", "Summary plots", "Lollipop plot", "Rainfall plot"),
      label = "Plots to render"
    )
  ),
  tabPanel(
    title = "Structural Variants"
  ),
  tabPanel(
    title = "Copy Number Variants",
    fluidRow(
      column(6,
             numericInput('cnv_plot_start', 'Start Coordinate', value = 0,
                          min = 0)),
      column(6,
             numericInput('cnv_plot_end', 'End Coordinate', value = 15000000))
    ),
    selectInput("cnv_plot_chr", "Chrmosome", choices = c(1:22))
  ),
  tabPanel(
    title = "Circos Plot",
    # checkboxGroupInput(
    #   inputId = "variant",
    #   label = "Select variant types",
    #   choices = c("Single Nucleotide Variants",
    #               "Structural Variants",
    #               "Copy Number Variants"),
    #   selected = c("Single Nucleotide Variants",
    #                "Structural Variants",
    #                "Copy Number Variants")
    # )
  )
)

# dynamically change the options based on plots chosen
option_panel <- tabsetPanel(
  id = "sideBarOptions",
  type = "hidden",
  tabPanel(
    title = "default"
  ),
  tabPanel(
    title = "lollipop",
    textInput(
      inputId = "lollipop_gene",
      label = "Gene for lollipop plot"
    ),
    selectInput(
      inputId = "snv_plot_sample",
      label = "Sample",
      choices = c()
    )
  )
)

# # dynamically change the main panel based on sidebar input
# # Main Panel
# main_panel <- 

# Define UI for application that draws a histogram
ui <- fluidPage(
  shinyFeedback::useShinyFeedback(),
  
  # Application title
  titlePanel(title = "Mutations data analysis and visualizations"),
  
  sidebarLayout(
    # Siderbar Panel
    sidebarPanel(
      sidebar_panel,
      option_panel,
      textOutput("test"),
      width = 3
    ),
    
    mainPanel(
      title = "dynamic_main",
      tabsetPanel(id = "tabs",
                  tabPanel(
                    title = "Introduction",
                    includeMarkdown("../help/help.Rmd")
                  ),
                  tabPanel(
                    title = "Point Mutations",
                    plotOutput(outputId = "oncoPlot"),
                    plotOutput(outputId = "snv_summaryPlot"),
                    plotOutput(outputId = "snv_lollipopPlot")
                  ),
                  tabPanel(
                    title = "Structural Variants",
                    # plotOutput(outputId = "sv_summaryPlot"),
                    dataTableOutput(outputId = "sv_table")
                  ),
                  tabPanel(
                    title = "Copy Number Variants",
                    plotOutput("cnv_plot")
                  ),
                  tabPanel(
                    title = "Circos Plot",
                    column(12, align = "center",
                           uiOutput(
                             outputId = "circos_plot"
                           )
                    )
                  )
      )
    )
  )
)
