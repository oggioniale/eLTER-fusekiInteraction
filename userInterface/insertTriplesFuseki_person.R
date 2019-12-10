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

orgs <- SPARQL::SPARQL(url = endpointQuery,
                       query = queryOrg)

proj <- SPARQL::SPARQL(url = endpointQueryProj,
                       query = queryProj)

tabItem(
  tabName = 'person',
  fluidRow(
    column(
      width = 4,
      boxPlus(
        width = 12,
        # title = "Selezione dati colturali e areale di produzione",
        closable = FALSE,
        status = "danger",
        solidHeader = FALSE,
        collapsible = TRUE,
        enable_sidebar = TRUE,
        sidebar_width = 25,
        sidebar_start_open = FALSE,
        sidebar_content = tagList(
          tags$p(
            "Fill all fileds in order to create new new record of yourself."
          )
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('perFamName', 'Person family name*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('perGName', 'Person given name*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          selectInput('perOrg', choices = orgs$results[2], label = 'Organizations*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px; padding-bottom: 10px;",
          actionButton(
              "toNewOrg", 
              HTML("add your organization"),
              style = "color: #fff; background-color: #337ab7; border-color: #2e6da4",
              onclick = "openTab('organization')",
              href="#"
          )
        ),
        # these bsTooltip and bsModal doesn't work
        # bsTooltip("toNewOrg", "If don't find your Organization please <br/>click here and create new element.<br/>", placement = "right", trigger = "hover",
        #                    options = NULL),
        # shinyBS::bsModal(id = "rdfOrg",
        #                  title = "RDF input box",
        #                  trigger = "toNewOrg",
        #                  tags$div(
        #                    tags$iframe(
        #                      src = "http://processing.get-it.it/shiny/private/insertRDFOrg/",
        #                      height="500px",
        #                      width="100%",
        #                      scrolling = T
        #                    )
        #                  ),
        #                  size = "large"
        # ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          # TODO: più di un progetto???
          selectizeInput('perProj',
                         label = 'Projects acronym*', 
                         choices = setNames(
                           as.list(proj$results$project), proj$results$acronym
                         ),
                         multiple=TRUE)
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('perOrcid', 'ORCID*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('perEMail', 'e-mail address*')
        ),
        tags$div(
          style = "padding-right: 5px; padding-left: 5px; padding-bottom: 10px;",
          disabled(
            actionButton(
              "sendQPerson",
              "Add new person",
              style = "color: #fff; background-color: #6D9538; border-color: #435926"
            ) 
          )
        )
      )
    ),
    column(
      width = 8,
      boxPlus(
        width = 12,
        # title = "Selezione dati colturali e areale di produzione",
        closable = FALSE,
        status = "success",
        solidHeader = FALSE,
        collapsible = TRUE,
        enable_sidebar = TRUE,
        sidebar_width = 25,
        height = '400px',
        sidebar_start_open = FALSE,
        sidebar_content = tagList(
          tags$p(
            ""
          )
        ),
        tags$head(HTML(
          "<link rel='stylesheet' href='../css/codemirror.css'>"
        )),
        tags$head(HTML(
          "<script src='../js/codemirror.js'></script>"
        )),
        tags$head(HTML(
          "<script src='../js/matchbrackets.js'></script>"
        )),
        tags$head(HTML(
          "<script src='../js/sparql.js'></script>"
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
        tags$div(
          class = "CodeMirror cm-s-default",
          style = "top: 10px;",
          uiOutput("selectedVarPerson")
        )
      )
    )
  )
)