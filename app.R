library(shiny)
library(querychat)
library(reactable)
library(highcharter)
library(bslib)
library(tidyverse)

ca_data <- readRDS("ca_data.rds")

querychat_config <- querychat_init(
  ca_data,
  greeting = readLines("greeting.md"),
  data_description = "data-description.md",
  extra_instructions = "extra-instructions.md",
  create_chat_func = purrr::partial(ellmer::chat_anthropic)
)


create_interactive_crime_chart <- function(data, n_agencies = 6) {
  # Get top n largest agencies
  top_agencies <- data |> 
    filter(year == max(year)) |> 
    distinct(agency_name, pop_jurisdiction) |> 
    slice_max(pop_jurisdiction, n = n_agencies) |> 
    pull(agency_name)
  
  # Prepare data for all offense types for the top agencies
  chart_data <- data |> 
    filter(agency_name %in% top_agencies) |>
    select(year, agency_name, offense, reported_per100k, n_reported) |>
    arrange(offense, agency_name, year)
  
  # Get all offense types for the dropdown
  offense_types <- chart_data |> 
    distinct(offense) |> 
    pull(offense) |> 
    sort()
  
  hc_with_dropdown <- highchart() |>
    hc_chart(type = "line") |>
    hc_title(text = "Crime Rates by Agency") |>
    hc_subtitle(text = "Select offense type from dropdown above") |>
    hc_xAxis(title = list(text = "")) |>
    hc_yAxis(title = list(text = "Reported crime per 100k")) |>
    hc_legend(title = list(text = "")) |>
    hc_tooltip(
      useHTML = TRUE,
      pointFormatter = JS("
        function() {
          return '<b>' + this.series.name + '</b><br/>' +
                 'Offense: ' + this.offense + '<br/>' +
                 'Total Reported: ' + this.n_reported.toLocaleString() + '<br/>' +
                 'Rate: ' + this.y.toFixed(1) + ' per 100k';
        }
      ")
    ) |>
    hc_plotOptions(
      line = list(
        marker = list(enabled = TRUE, radius = 4)
      )
    ) |>
    # Add the dropdown and data using JavaScript
    hc_add_dependency("modules/exporting.js") |>
    htmlwidgets::onRender(
      paste0("
      function(el, x) {
        // All data for different offenses
        var allData = ", jsonlite::toJSON(chart_data, dataframe = "rows"), ";
        
        // Get unique offense types
        var offenseTypes = ", jsonlite::toJSON(offense_types), ";
        
        // Remove any existing dropdown to prevent duplicates
        $('#offense-select').parent().remove();
        
        // Create dropdown HTML
        var dropdownHtml = '<div style=\"margin: 10px 0;\"><label for=\"offense-select\">Select Offense: </label><select id=\"offense-select\" style=\"padding: 5px; margin-left: 10px;\">';
        offenseTypes.forEach(function(offense) {
          dropdownHtml += '<option value=\"' + offense + '\"' + (offense === 'Aggravated assault' ? ' selected' : '') + '>' + offense + '</option>';
        });
        dropdownHtml += '</select></div>';
        
        // Insert dropdown before the chart
        $(el).before(dropdownHtml);
        
        // Function to update chart based on selected offense
        function updateChart(selectedOffense) {
          // Filter data for selected offense
          var filteredData = allData.filter(function(d) {
            return d.offense === selectedOffense;
          });
          
          // Group by agency
          var agencies = [...new Set(filteredData.map(d => d.agency_name))];
          var series = [];
          
          agencies.forEach(function(agency) {
            var agencyData = filteredData
              .filter(d => d.agency_name === agency)
              .map(function(d) {
                return {
                  x: d.year,
                  y: d.reported_per100k,
                  offense: d.offense,
                  n_reported: d.n_reported
                };
              })
              .sort((a, b) => a.x - b.x);
            
            series.push({
              name: agency,
              data: agencyData
            });
          });
          
          // Update chart
          var chart = $('#' + el.id).highcharts();
          
          // Remove all existing series
          while(chart.series.length > 0) {
            chart.series[0].remove(false);
          }
          
          // Add new series
          series.forEach(function(s) {
            chart.addSeries(s, false);
          });
          
          // Update title and redraw
          chart.setTitle({text: selectedOffense + ' Rates by Agency'});
          chart.redraw();
        }
        
        // Initialize with default offense
        setTimeout(function() {
          updateChart('Aggravated assault');
        }, 100);
        
        // Add event listener for dropdown change
        $('#offense-select').on('change', function() {
          updateChart(this.value);
        });
      }
      ")
    )
    
  return(hc_with_dropdown)
}



ui <- page_sidebar(
  sidebar = querychat_sidebar("chat", width = 600),
  card(
    full_screen = TRUE,
    height = "400px",
    reactableOutput("tbl")
  ),
  card(
    full_screen = TRUE, 
    height = "400px",
    highchartOutput("crime_chart")
  )
)

server <- function(input, output, session) {

  querychat <- querychat_server("chat", querychat_config)

  output$tbl <- renderReactable({
    reactable(
      data = querychat$df(),
      searchable = TRUE,
      style = list(fontSize = "0.8rem"),
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

  output$crime_chart <- renderHighchart({
    create_interactive_crime_chart(querychat$df(), n_agencies = 6)
  })


}

shinyApp(ui, server)