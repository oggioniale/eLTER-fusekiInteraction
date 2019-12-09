#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(shinycssloaders)
library(leaflet.extras)
library(shinyjs)
library(SPARQL)

###
# UI
###
ui <- fluidPage(
  useShinyjs(),
  # App title ----
  titlePanel("Add organization information in SPARQL Fuseki endpoint"),
  
  fluidRow(
    column(12,
           sidebarPanel(
             # Input: procedure URL
             textInput('orgName', 'Organization name*'),
             textInput('orgAddr', 'Organization address*'),
             textInput('orgCap', 'Organization CAP*'),
             textInput('orgLoc', 'Organization locality*'),
             textInput('orgCountry', 'Organization country*'),
             textInput('orgWebSite', 'Web site*'),
             actionButton("sendQ", "Add new organization")
           ),
           mainPanel(
             tags$head(HTML(
               "<link rel='stylesheet' href='css/codemirror.css'>"
             )),
             tags$head(HTML(
               "<script src='js/codemirror.js'></script>"
             )),
             tags$head(HTML(
               "<script src='js/matchbrackets.js'></script>"
             )),
             tags$head(HTML(
               "<script src='js/sparql.js'></script>"
             )),
             uiOutput("selected_var")
           )
    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output, session) {
  
  # Set up preliminaries and define query
  # Define the fuseki GET-IT endpoint
  endpointUpdate <- "http://fuseki1.get-it.it/directory/update"
  
  # SPARQL package to submit query and save results
  observeEvent(input$sendQ, {
    SPARQL(url = endpointUpdate, 
           query = queryContentSPARQL(),
           ns = c(
             '', '<http://rdfdata.get-it.it/directory/people/>',
             'foaf',  '<http://xmlns.com/foaf/0.1/>',
             'vcard', '<http://www.w3.org/2006/vcard/ns#>'
           ),
           curl_args=list(
             'userpwd'=paste('admin',':','sos432015',sep=''),
             style = "post"
           )
    )
  })
  
  queryContentSPARQL <- reactive(paste0(
    "prefix : <http://rdfdata.get-it.it/directory/people/> prefix vcard: <http://www.w3.org/2006/vcard/ns#> prefix foaf: <http://xmlns.com/foaf/0.1/> INSERT DATA { <http://rdfdata.get-it.it/directory/organizations/", gsub(" ", "_", input$orgName), ">  a  foaf:Organization; vcard:hasAddress  [ vcard:country-name  \"", input$orgCountry, "\"; vcard:locality \"", input$orgLoc, "\"; vcard:postal-code \"", input$orgCap, "\"; vcard:street-address  \"", input$orgAddr, "\" ] ; foaf:homepage <", input$orgWebSite, ">; foaf:name \"", input$orgName, "\"@zxx }",
    sep = ""
  ))
  
  queryContentUI <- reactive(
    paste0(
      "
      prefix :      <http://rdfdata.get-it.it/directory/organizations/>
      prefix vcard: <http://www.w3.org/2006/vcard/ns#>
      prefix foaf:  <http://xmlns.com/foaf/0.1/>
      INSERT DATA
      {
      <http://rdfdata.get-it.it/directory/organizations/",
      gsub(" ", "_", input$orgName),
      ">  a  foaf:Organization ;
      vcard:hasAddress  [ vcard:country-name  \"",
      input$orgCountry,
      "\" ;
      vcard:locality        \"",
      input$orgLoc,
      "\" ;
      vcard:postal-code     \"",
      input$orgCap,
      "\" ;
      vcard:street-address  \"",
      input$orgAddr,
      "\"
      ] ;
      foaf:homepage     <",
      input$orgWebSite,
      "> ;
      foaf:name         \"",
      input$orgName,
      "\"@zxx }",
      sep = ""
    )
  )
  
  output$selected_var <- renderUI({
    tags$form(
      tags$textarea(
        id = "code",
        name = "code",
        queryContentUI()
      ),
      tags$script(HTML(
        "var editorXML = CodeMirror.fromTextArea(document.getElementById(\"code\"), {
          mode: \"application/sparql-query\",
          matchBrackets: true,
          lineNumbers: true,
          smartindent: true,
          extraKeys: {\"Ctrl-Space\": \"autocomplete\"}
        });
        editorXML.setSize(\"100%\",\"100%\");"
        ))
    )
  })
  
  observe({
    toggleState("sendQ",
                condition = (input$orgName != "" & input$orgAddrl != "" & input$orgCap != "" & input$orgLoc != "" & input$orgCountry != "" & input$orgWebSite != "")
    )
  })
  
}
# Run the app ----
shinyApp(ui, server)