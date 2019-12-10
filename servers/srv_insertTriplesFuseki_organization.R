# Set up preliminaries and define query
# Define the fuseki GET-IT endpoint
endpointUpdate <- "http://fuseki1.get-it.it/directory/update"

# SPARQL package to submit query and save results
observeEvent(input$sendQOrganization, {
  SPARQL(url = endpointUpdate, 
         query = queryContentSPARQLOrganization(),
         ns = c(
           '', '<http://rdfdata.get-it.it/directory/people/>',
           'foaf',  '<http://xmlns.com/foaf/0.1/>',
           'vcard', '<http://www.w3.org/2006/vcard/ns#>'
         ),
         curl_args=list(
           'userpwd'=paste('xxx',':','xxx',sep=''),
           style = "post"
         )
  )
})

queryContentSPARQLOrganization <- reactive(paste0(
  "prefix : <http://rdfdata.get-it.it/directory/people/> prefix vcard: <http://www.w3.org/2006/vcard/ns#> prefix foaf: <http://xmlns.com/foaf/0.1/> INSERT DATA { <http://rdfdata.get-it.it/directory/organizations/", gsub(" ", "_", input$orgName), ">  a  foaf:Organization; vcard:hasAddress  [ vcard:country-name  \"", input$orgCountry, "\"; vcard:locality \"", input$orgLoc, "\"; vcard:postal-code \"", input$orgCap, "\"; vcard:street-address  \"", input$orgAddr, "\" ] ; foaf:homepage <", input$orgWebSite, ">; foaf:name \"", input$orgName, "\"@zxx }",
  sep = ""
))

queryContentUIOrganization <- reactive(
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

output$selectedVarOrganization <- renderUI({
  tags$form(
    tags$textarea(
      id = "code",
      name = "code",
      queryContentUIOrganization()
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
  toggleState("sendQOrganization",
              condition = (
                input$orgName != "" &&
                input$orgAddrl != "" &&
                input$orgCap != "" &&
                input$orgLoc != "" &&
                input$orgCountry != "" &&
                input$orgWebSite != ""
              )
  )
})

observeEvent(input$sendQOrganization, {
  # Show a modal when the button sendQPerson is pressed
  shinyalert::shinyalert(
    title = "Well done!",
    type = "info",
    confirmButtonText = "Ok",
    timer = 3000
  )
})


