# Set up preliminaries and define query
# Define the fuseki GET-IT endpoint
endpointUpdate <- "http://fuseki1.get-it.it/directory/update"

# SPARQL package to submit query and save results
observeEvent(input$sendQManufacturer, {
  SPARQL(url = endpointUpdate, 
         query = queryContentSPARQManufacturerL(),
         ns = c(
           '', '<http://rdfdata.get-it.it/sensors/manufacturers/>',
           'foaf',  '<http://xmlns.com/foaf/0.1/>',
           'addr',  '<http://wymiwyg.org/ontologies/foaf/postaddress#>',
           'vcard', '<http://www.w3.org/2006/vcard/ns#>'
         ),
         curl_args=list(
           'userpwd'=paste('xxx',':','xxx',sep=''),
           style = "post"
         )
  )
})

queryContentSPARQLManufacturer <- reactive(paste0(
  "prefix : <http://rdfdata.get-it.it/sensors/manufacturers/> prefix foaf:  <http://xmlns.com/foaf/0.1/> prefix addr:  <http://wymiwyg.org/ontologies/foaf/postaddress#> prefix vcard: <http://www.w3.org/2006/vcard/ns#> INSERT DATA {<http://rdfdata.get-it.it/sensors/manufacturers/", gsub(" ", "", input$manName), "> a foaf:Organization; vcard:email <mailto:", input$manEMail, ">; addr:address [addr:deliveryPoint  [addr:location [addr:building '' ; addr:country '", input$manCountry, "'; addr:postcode '", input$manPostCode, "'; addr:region '' ; addr:streetNr '", input$manNumber, "'; addr:thoroughfareName '", input$manAdd, "'; addr:town '", input$manCity, "'] ] ]; addr:address [addr:deliveryPoint [addr:location [addr:building '' ; addr:country '", input$manCountry, "'; addr:postcode '", input$manPostCode, "'; addr:region ''; addr:streetNr '", input$manNumber, "'; addr:thoroughfareName '", input$manAdd, "'; addr:town '", input$manCity, "'] ] ] ; foaf:homepage  <", input$manWebSite, ">; foaf:name '", input$manName, "'; foaf:phone <tel:", input$manTel, ">}",
  sep = ""
))

queryContentUIManufacturer <- reactive(paste0(
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

output$selectedVarManufacturer <- renderUI({
  tags$form(
    tags$textarea(
      id = "code",
      name = "code",
      queryContentUIManufacturer()
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
  toggleState("sendQManufacturer",
              condition = (
                input$manName != "" &&
                input$manTel != "" &&
                input$manAdd != "" &&
                input$manNumber != "" &&
                input$manCity != "" &&
                input$manAdm != "" &&
                input$manPostCode != "" &&
                input$manCountry != "" &&
                input$manWebSite != ""
              )
  )
})

observeEvent(input$sendQManufacturer, {
  # Show a modal when the button sendQPerson is pressed
  shinyalert::shinyalert(
    title = "Well done!",
    type = "info",
    confirmButtonText = "Ok",
    timer = 3000
  )
})


