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
library(shinydashboardPlus)
library(shinyjs)

# SPARQL query for select organizations stored in a fuseki directory dataset
endpointQuery <- "http://fuseki1.get-it.it/directory/query"
endpointQueryProj <- "http://lod.openaire.eu/sparql"

queryOrg <- "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
             PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
             SELECT DISTINCT ?c (SAMPLE(?name) AS ?nome)
             WHERE {
                ?c rdf:type foaf:Organization ;
                foaf:name ?name .
                FILTER(lang(?name)='zxx')
             }
             GROUP BY ?c
             ORDER BY DESC(lang(?name)) ASC(?name)"

queryProj <- "PREFIX oav: <http://lod.openaire.eu/vocab/>
              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              SELECT DISTINCT ?acronym ?project ?label ?founder
              WHERE {
	              ?project a oav:ProjectEntity.
                ?project oav:acronym ?acronym.
 	              ?project oav:projectTitle ?label.
                ?project oav:funder ?founder.
                ?project oav:projectCode ?code.
                FILTER (CONTAINS(LCASE(STR(?founder)), LCASE('European Commission')))
                FILTER (CONTAINS(STR(?acronym), 'e'))
                FILTER (CONTAINS(LCASE(STR(?code)), '65'))
              }
              ORDER BY ASC(?acronym)"

orgs <- SPARQL::SPARQL(
  url = endpointQuery,
  query = queryOrg
  )

proj <- SPARQL::SPARQL(
  url = endpointQueryProj,
  query = queryProj
)

###
# UI
###
ui <- fluidPage(
  # useShinyjs(),
  # App title ----
  titlePanel("Add person information in SPARQL Fuseki endpoint"),
  
  fluidRow(
    column(12,
           sidebarPanel(
             # Input: procedure URL
             textInput('perFamName', 'Person family name*'),
             textInput('perGName', 'Person given name*'),
             selectInput('perOrg', choices = orgs$results[2], label = 'Organizations*'),
             actionButton(
               "toNewOrg", 
               HTML("add your organization"),
               style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
             ),
             shinyBS::bsTooltip("toNewOrg", "If don't find your Organization please <br/>click here and create new element.<br/>", placement = "right", trigger = "hover",
                       options = NULL),
             shinyBS::bsModal(id = "rdfOrg", 
                              title = "RDF input box", 
                              trigger = "toNewOrg", 
                              tags$iframe(
                                src = "http://processing.get-it.it/shiny/private/insertRDFOrg/",
                                height="500px",
                                width="100%",
                                scrolling = T
                              ), 
                              size = "large"
             ),
             # TODO: più di un progetto???
             selectizeInput('perProj',
                            label = 'Projects acronym*', 
                            choices = setNames(
                            as.list(proj$results$project), proj$results$acronym
                          ),
                         multiple=TRUE),
             textInput('perOrcid', 'ORCID*'),
             textInput('perEMail', 'e-mail address*'),
             actionButton("sendQ", "Add new person")
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
             # tags$head(HTML(
             #   ".CodeMirror {
             #    border-top: 1px solid black;
             #    border-bottom: 1px solid black;
             #   }"
             # )),
             # tags$head(HTML(
             #   "<link rel='stylesheet' href='css/show-hint.css'>"
             # )),
             # tags$head(HTML(
             #   "<script src='js/jquery.js'></script>"
             # )),
             # tags$head(HTML(
             #   "<script src='js/show-hint.js'></script>"
             # )),
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
           update = queryContentSPARQL(),
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
    "prefix : <http://rdfdata.get-it.it/directory/people/> prefix vcard: <http://www.w3.org/2006/vcard/ns#> prefix foaf: <http://xmlns.com/foaf/0.1/> INSERT DATA {<http://rdfdata.get-it.it/directory/people/", paste0(input$perFamName, "_", input$perGName, sep=""), "> a foaf:Person; vcard:org ", subset(orgs$results[1], orgs$results[2] == input$perOrg), "; foaf:account [ a foaf:OnlineAccount; foaf:accountName \"", paste0(input$perFamName, " ", input$perGName), "\"; foaf:accountProfilePage <", paste0("https://orcid.org/", input$perOrcid, sep=""), ">; foaf:accountServiceHomepage  <https://orcid.org>]; foaf:currentProject ", paste(input$perProj, sep = '', collapse = ','),"; foaf:familyName \"", input$perFamName, "\"; foaf:fullName \"", paste0(input$perFamName, "", input$perGName), "\"; foaf:givenName \"", input$perGName, "\"; foaf:mbox <mailto:", input$perEMail, ">  }", 
    sep = "" )
    )
  
  queryContentUI <- reactive(
    
    paste0(
      "
      prefix :      <http://rdfdata.get-it.it/directory/people/>
      prefix vcard: <http://www.w3.org/2006/vcard/ns#>
      prefix foaf:  <http://xmlns.com/foaf/0.1/>
      
      INSERT DATA
      {
      <http://rdfdata.get-it.it/directory/people/",
      paste0(input$perFamName, "_", input$perGName, sep=""),
      "> a foaf:Person ;
      vcard:org ",
      subset(orgs$results[1], orgs$results[2] == input$perOrg),
      ";
      foaf:account [ a foaf:OnlineAccount ;
      foaf:accountName \"",
      paste0(input$perFamName, " ", input$perGName),
      "\" ;
      foaf:accountProfilePage      <",
      paste0("https://orcid.org/", input$perOrcid, sep=""),
      "> ;
      foaf:accountServiceHomepage  <https://orcid.org>] ;
      foaf:currentProject ",
      paste(input$perProj, sep = '', collapse = ','),
      ";
      foaf:familyName  \"",
      input$perFamName,
      "\" ;
      foaf:fullName    \"",
      paste0(input$perFamName, " ", input$perGName),
      "\" ;
      foaf:givenName   \"",
      input$perGName,
      "\" ;
      foaf:mbox        <mailto:",
      input$perEMail,
      ">  }" ,
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
                condition = (input$perFamName != "" & input$perGName != "" & input$perOrg != ""  & input$perOrcid != "" & input$perEMail != "")
    )
  })
  

}
# Run the app ----
shinyApp(ui, server)