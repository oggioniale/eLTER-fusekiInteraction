tabItem(
  tabName = 'organization',
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
            "Fill all fileds in order to create new new record of your organization."
          )
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgName', 'Organization name*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgAddr', 'Organization address*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgCap', 'Organization CAP*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgLoc', 'Organization locality*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgCountry', 'Organization country*')
        ),
        tags$div(
          style = "padding-right: 5px;padding-left: 5px",
          textInput('orgWebSite', 'Web site*')
        ),
        tags$div(
          style = "padding-right: 5px; padding-left: 5px; padding-bottom: 10px;",
          disabled(
            actionButton(
              "sendQOrganization", 
              "Add new organization",
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
          uiOutput("selectedVarOrganization")
        )
      )
    )
  )
)