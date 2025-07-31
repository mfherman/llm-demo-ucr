library(shiny)
library(querychat)
library(reactable)

ca_data <- readRDS("ca_data.rds")

querychat_config <- querychat_init(
  ca_data,
  greeting = readLines("greeting.md"),
  data_description = "data-description.md",
  extra_instructions = "extra-instructions.md",
  create_chat_func = purrr::partial(ellmer::chat_anthropic)
)

ui <- bslib::page_sidebar(
  sidebar = querychat_sidebar("chat"),
  reactable::reactableOutput("tbl")
)

server <- function(input, output, session) {

  querychat <- querychat_server("chat", querychat_config)

  output$tbl <- reactable::renderReactable({
    reactable::reactable(
      data = querychat$df(),
      searchable = TRUE,
      columns = list(
        year = colDef(name = "Year"),
        agency_name = colDef(name = "Agency name"),
        agency_type = colDef(name = "Agency type"),
        pop_group = colDef(name = "Population group"),
        pop_jurisdiction = colDef(
          name = "Population",
          format = colFormat(separators = TRUE)
          ),
        offense = colDef(name = "Offense"),
        n_reported = colDef(
          name = "Reported crimes",
          format = colFormat(separators = TRUE)
          ),
        reported_per100k = colDef(
          name = "Reported crime per 100k",
          format = colFormat(separators = TRUE, digits = 0)
          ),
        n_solved = colDef(
          name = "Solved crimes",
          format = colFormat(separators = TRUE)
          ),
        n_unsolved = colDef(
          name = "Unsolved crimes",
          format = colFormat(separators = TRUE)
          ),
        solve_rate = colDef(
          name = "Solve rate",
          format = colFormat(percent = TRUE, digits = 0)
          )
      )
      )
  })
}

shinyApp(ui, server)