shinyServer(function(input, output, session) {

  # Server manufacturer
  source("servers/srv_insertTriplesFuseki_manufacturer.R", local = TRUE)$value
  
  # Server person 
  source("servers/srv_insertTriplesFuseki_person.R", local = TRUE)$value
  
  # Server organization 
  source("servers/srv_insertTriplesFuseki_organization.R", local = TRUE)$value
  
})