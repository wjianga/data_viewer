library(shiny)

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
    fileInput(
      inputId = "snv_data_input",
      label = "Upload Point Mutation files",
      buttonLabel = "Upload",
      multiple = T,
      accept = c(".csv", ".tsv", ".txt")
    ),
    fileInput(
      inputId = "sv_data_input",
      label = "Upload Structural Variant files",
      buttonLabel = "Upload",
      multiple = T,
      accept = c(".csv", ".tsv", ".txt")
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
      choices = c("Summary plots", "Lollipop plot"),
      label = "Plots to render"
    )
  ),
  tabPanel(
    title = "Structural Variants"
  ),
  tabPanel(
    title = "Copy Number Variants"
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
  id = "options",
  type = "hidden",
  tabPanel(
    title = "default"
  ),
  tabPanel(
    title = "lollipop",
    selectInput(
      inputId = "lollipop_gene",
      label = "Gene for lollipop plot",
      choices = c()
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
                    uiOutput(outputId = "oncoPlot")
                    # plotOutput(outputId = "oncoPlot"),
                    # plotOutput(outputId = "summaryPlot")
                  ),
                  tabPanel(
                    title = "Structural Variants"
                  ),
                  tabPanel(
                    title = "Copy Number Variants"
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
