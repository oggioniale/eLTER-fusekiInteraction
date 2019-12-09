#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###
# libraries
###

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyjs)

###
# UI
###
shinyUI(fluidPage(
  dashboardPagePlus(
    skin = "green-light",
    collapse_sidebar = TRUE,
    dashboardHeaderPlus(
      title = tagList(
        tags$span(class = "logo-lg", "Add information of"),
        tags$img(src = "http://www.get-it.it/assets/img/loghi/lter_leaf.jpg")
      ),
      # fixed = FALSE,
      # enable_rightsidebar = TRUE,
      # rightSidebarIcon = "gears",
      tags$li(
        class = "dropdown",
        tags$a(
          href = "http://www.lter-europe.net",
          tags$img(src = "http://www.get-it.it/assets/img/loghi/eLTERH2020.png"),
          style = "margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
          target = "_blank"
        )
      ),
      tags$li(
        class = "dropdown",
        tags$a(
          href = "http://www.lteritalia.it",
          tags$img(src = "http://www.get-it.it/assets/img/loghi/LogoLTERIta.png"),
          style = "margin:0;padding-top:2px;padding-bottom:2px;padding-left:10px;padding-right:10px;",
          target = "_blank"
        )
      )
    ),
    dashboardSidebar(collapsed = TRUE,
                     sidebarMenu(
                       menuItem(
                         "Person",
                         tabName = "person",
                         icon = icon("user-tag", lib = "font-awesome")
                       ),
                       menuItem(
                         "Organization",
                         tabName = "organization",
                         icon = icon("building", lib = "font-awesome")
                       ),
                       menuItem(
                         "Manufacturer",
                         tabName = "manufacturer",
                         icon = icon("briefcase", lib = "font-awesome")
                       )
                     )),
    dashboardBody(
      useShinyjs(),
      tags$script(
        HTML(
          "
      var openTab = function(tabName){
        $('a', $('.sidebar')).each(function() {
          if(this.getAttribute('data-value') == tabName) {
            this.click()
          };
        });
      }
    "
        )
      ),
      tabItems(
        source("userInterface/insertTriplesFuseki_person.R", local = TRUE)$value,
        source("userInterface/insertTriplesFuseki_organization.R", local = TRUE)$value,
        source("userInterface/insertTriplesFuseki_manufacturer.R", local = TRUE)$value
      )
    )
  )
))