
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
####################
# Tab One: File Upload
###################
uploadPanel <- tabPanel("File Upload",
                        sidebarLayout(
                          sidebarPanel(
                            fileInput('file1', 'Choose file to upload',
                                      accept = c(
                                     'text/csv',
                                     'text/comma-separated-values',
                                     'text/tab-separated-values',
                                     'text/plain',
                                     '.csv',
                                     '.tsv'
                         ), multiple=TRUE),
               radioButtons("uploadTypeRadio", label = "Upload type",
                            choices = list("zip file" = 1, ".txt files" = 2, "corpus object"), 
                            selected = 1)
             ),
             # Show a plot of the generated distribution
             mainPanel(
               dataTableOutput("fileTable")
             )
           )
)

###################
# Tab Two: Dfm
###################
dfmPanel <- tabPanel("DFM",
         sidebarLayout(
           sidebarPanel(
             "Trim features by word and doc frequency",
             textInput("minFreq", label = "Min. frequency", value = 1),
             textInput("minDoc", label = "Min. document frequency", value = 1),
             hr(),
             tmpLabel <- "Number of features to display (displaying all can be slow).",
             textInput("showN", label = tmpLabel, value = 100),
             hr(),
             "Feature weighting",
             radioButtons("weightingRadio", label = "Type of feature weighting",
                          choices = list("Count" = "count", "tf-idf" = "tfidf", "Relative frequency" = "relFreq"), 
                          selected = "count"),hr(),
             actionButton("dfm_button", "Process")
           ),
           # Show a plot of the generated distribution
           mainPanel(
             dataTableOutput("dfmTable")
           )
         ))

###################
# Tab Three: Kwic
###################
kwicPanel <- tabPanel("Keyword-in-context",
         sidebarLayout(
           sidebarPanel(
             p("Keyword in context search"),
             textInput("keyword", label = "Search string"),
             hr(),
             sliderInput("contextSize", "Context size", min=3, max=50, value=5, step=1),
             radioButtons("kwicValueType", label = "Type of search string",
                          choices = list("glob" = "glob", "regex" = "regex", "fixed" = "fixed"), 
                          selected = "glob"),
             checkboxInput("caseSensitive", "Case Sensitive")
           ),
           mainPanel(
             dataTableOutput("kwicTable")
           )
         )
)


###################
# Tab Four: Scaling
###################
scale_plot <- tabPanel("Scale Plot",
                      sidebarLayout(
                          sidebarPanel(
                              actionButton("scale_button", "go")
                          ),
                          mainPanel(
                              dataTableOutput("scale_table")
                          )
                      )
)

shinyUI(fluidPage(
  # Application title
  titlePanel(h4("Quanteda")),
  "A prototype of a graphical interface for the quanteda package.",
  a(href="https://github.com/pnulty/quantedaGui", "Shiny app code."),
  a(href="https://github.com/kbenoit/quanteda", "Quanteda code and introduction. "),

  # Sidebar with a slider input for number of bins
  tabsetPanel(
    uploadPanel,
    dfmPanel,
    kwicPanel,
    scale_plot
    )
  )
)
