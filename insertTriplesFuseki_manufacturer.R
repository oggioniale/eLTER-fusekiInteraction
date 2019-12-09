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
  titlePanel("Add manufacturer information in SPARQL Fuseki endpoint"),
  
  fluidRow(
    column(12,
           sidebarPanel(
             # Input: procedure URL
             textInput('manName', 'Manufacturer name*'),
             textInput('manTel', 'Phone number*'),
             textInput('manAdd', 'Address*'),
             textInput('manNumber', 'Address number*'),
             textInput('manCity', 'City*'),
             textInput('manAdm', 'Administrative area*'),
             textInput('manPostCode', 'Postal code*'),
             textInput('manCountry', 'Country*'),
             textInput('manEMail', 'e-mail address*'),
             textInput('manWebSite', 'Web site*'),
             actionButton("sendQ", "Add new manufacturer")
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
             '', '<http://rdfdata.get-it.it/sensors/manufacturers/>',
             'foaf',  '<http://xmlns.com/foaf/0.1/>',
             'addr',  '<http://wymiwyg.org/ontologies/foaf/postaddress#>',
             'vcard', '<http://www.w3.org/2006/vcard/ns#>'
           ),
           curl_args=list(
             'userpwd'=paste('admin',':','sos432015',sep=''),
             style = "post"
           )
    )
  })
  
  queryContentSPARQL <- reactive(paste0(
      "prefix : <http://rdfdata.get-it.it/sensors/manufacturers/> prefix foaf:  <http://xmlns.com/foaf/0.1/> prefix addr:  <http://wymiwyg.org/ontologies/foaf/postaddress#> prefix vcard: <http://www.w3.org/2006/vcard/ns#> INSERT DATA {<http://rdfdata.get-it.it/sensors/manufacturers/", gsub(" ", "", input$manName), "> a foaf:Organization; vcard:email <mailto:", input$manEMail, ">; addr:address [addr:deliveryPoint  [addr:location [addr:building '' ; addr:country '", input$manCountry, "'; addr:postcode '", input$manPostCode, "'; addr:region '' ; addr:streetNr '", input$manNumber, "'; addr:thoroughfareName '", input$manAdd, "'; addr:town '", input$manCity, "'] ] ]; addr:address [addr:deliveryPoint [addr:location [addr:building '' ; addr:country '", input$manCountry, "'; addr:postcode '", input$manPostCode, "'; addr:region ''; addr:streetNr '", input$manNumber, "'; addr:thoroughfareName '", input$manAdd, "'; addr:town '", input$manCity, "'] ] ] ; foaf:homepage  <", input$manWebSite, ">; foaf:name '", input$manName, "'; foaf:phone <tel:", input$manTel, ">}",
      sep = ""
    ))
  
  queryContentUI <- reactive(paste0(
    "
    prefix : <http://rdfdata.get-it.it/sensors/manufacturers/>
    prefix foaf:  <http://xmlns.com/foaf/0.1/>
    prefix addr:  <http://wymiwyg.org/ontologies/foaf/postaddress#>
    prefix vcard: <http://www.w3.org/2006/vcard/ns#>

    INSERT DATA
    {
    <http://rdfdata.get-it.it/sensors/manufacturers/",
    gsub(" ", "", input$manName),
    "> a foaf:Organization ;
    vcard:email <mailto:",
    input$manEMail,
    "> ;
    addr:address   [ addr:deliveryPoint  [ addr:location
    [ addr:building          '' ;
    addr:country           '",
    input$manCountry,
    "' ;
    addr:postcode          '",
    input$manPostCode,
    "' ;
    addr:region            '' ;
    addr:streetNr          '",
    input$manNumber,
    "' ;
    addr:thoroughfareName  '",
    input$manAdd,
    "' ;
    addr:town              '",
    input$manCity,
    "'
    ] ] ] ;
    addr:address   [ addr:deliveryPoint  [ addr:location
    [ addr:building          '' ;
    addr:country           '",
    input$manCountry,
    "' ;
    addr:postcode          '",
    input$manPostCode,
    "' ;
    addr:region            '' ;
    addr:streetNr          '",
    input$manNumber,
    "' ;
    addr:thoroughfareName  '",
    input$manAdd,
    "' ;
    addr:town              '",
    input$manCity,
    "'
    ] ] ] ;
    foaf:homepage  <",
    input$manWebSite,
    "> ;
    foaf:name      '",
    input$manName,
    "' ;
    foaf:phone     <tel:",
    input$manTel,
    ">  }",
    sep = ""
  ))
  
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
      condition = (input$manName != "" & input$manTel != "" & input$manAdd != "" & input$manNumber != "" & input$manCity != "" & input$manAdm != "" & input$manPostCode != "" & input$manCountry != "" & input$manWebSite != "")
    )
  })
  
}
# Run the app ----
shinyApp(ui, server)