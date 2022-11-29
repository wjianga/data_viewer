library(shiny)
library(shinyFeedback)
library(shinythemes)

sidebar_panel <- tabsetPanel(
  id = "dynamic_sidebar",
  type = "hidden",
  selectInput(
    inputId = "reference_genome",
    label = "Please select reference genome",
    choices = c("GRCh38/hg38", "GRCh37/hg19", "GRCh36/hg18"),
    selected = "GRCh38/hg38"
  ),
  # dynamically change side bar layout based on which tab the user selected
  ### Introduction tab
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
  ### User manual
  tabPanel(
    title = "User Manual"
  ),
  ### Point mutation tab
  tabPanel(
    title = "Point Mutations",
    checkboxGroupInput(
      inputId = "snv_plot_checkboxInput",
      choices = c("Oncoplot", "Summary plot", "Lollipop plot", "Rainfall plot"),
      label = "Plots to render (Maximum 2)",
      selected = "Oncoplot"
    )
  ),
  ### Structural Variants tab
  tabPanel(
    title = "Structural Variants",
    textInput("sv_plot_sample", label = "Sample for SV Circos Plot")
  ),
  ### Copy Number Variants tab
  tabPanel(
    title = "Copy Number Variants",
    textInput("cnv_plot_sample", label = "Sample for CNV plot"),
    selectInput("cnv_plot_mode", "Select how would you like to render CNV plot",
                choices = c("By Hugo_Symbol", "By Coordinate"),
                selected = NA)
  ),
  ### Circos Plot tab
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
  ),
  tabPanel(
    title = "Queryable Table",
    checkboxGroupInput(inputId = "table_to_render",
                       label = "Select type to render table (Maximum 1)",
                       choices = c("SNV", "SV", "CNV"),
                       selected = NA)
  )
)

# dynamically change the additional options based on plots chosen
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
    textInput(
      inputId = "lollipop_sample",
      label = "Sample for lollipop plot"
    )
  ),
  tabPanel(
    title = "rainfall",
    textInput(
      inputId = "rainfall_sample",
      label = "Sample for rainfall plot"
    )
  ),
  tabPanel(
    title = "lollipopANDrainfall",
    textInput(
      inputId = "snv_gene",
      label = "Gene"
    ),
    textInput(
      inputId = "snv_sample",
      label = "Sample"
    )
  ),
  tabPanel(
    title = "CNV_by_coor",
    selectInput("cnv_plot_chr", "Chrmosome", choices = c(1:22)),
    fluidRow(
      column(6,
             numericInput('cnv_plot_start', 'Start Coordinate', value = 0,
                          min = 0)),
      column(6,
             numericInput('cnv_plot_end', 'End Coordinate', value = 15000000))
    )
  ),
  tabPanel(
    title = "CNV_by_gene",
    textInput("cnv_plot_gene", label = "Enter Hugo_Symbol for CNV plot")
  )
)

# # dynamically change the main panel based on sidebar input
# # Main Panel
# main_panel <- tabsetPanel(
#   id = "dynamic_main",
#   type = "hidden",
#   tabPanel(
#     title = "Introduction",
#     includeMarkdown("../help/help.Rmd")
#   ),
#   tabPanel(
#     title = "User Manual",
#     includeMarkdown("../help/userManual.Rmd")),
#   tabPanel(
#     title = "Point Mutations",
#     plotOutput(outputId = "oncoPlot"),
#     plotOutput(outputId = "snv_summaryPlot"),
#     plotOutput(outputId = "snv_lollipopPlot")
#   ),
#   tabPanel(
#     title = "Structural Variants",
#     # plotOutput(outputId = "sv_summaryPlot"),
#     dataTableOutput(outputId = "sv_table")
#   ),
#   tabPanel(
#     title = "Copy Number Variants",
#     plotOutput("cnv_plot")
#   ),
#   tabPanel(
#     title = "Circos Plot",
#     column(12, align = "center",
#            uiOutput(
#              outputId = "circos_plot"
#            )
#     )
#   ),
#   tabPanel(
#     title = "Queryable Table",
#     dataTableOutput(outputId = "table")
#   )
# )

# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = shinytheme("flatly"),
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
      tabsetPanel(
        id = "tabs",
        tabPanel(
          title = "Introduction",
          includeMarkdown("../help/help.Rmd")
        ),
        tabPanel(
          title = "User Manual",
          includeMarkdown("../help/userManual.Rmd")),
        tabPanel(
          title = "Point Mutations",
          plotOutput(outputId = "firstPlot"),
          plotOutput(outputId = "secondPlot")
        ),
        tabPanel(
          title = "Structural Variants",
          uiOutput(outputId = "sv_circos")
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
        ),
        tabPanel(
          title = "Queryable Table",
          dataTableOutput(outputId = "table")
        )
      )
      )
  )
)
