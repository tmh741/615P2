library(shiny)
library(ggmap)
library(maptools)
library(maps)

projections <- c("mercator","cylindrical","sinusoidal","gnomonic")

mapWorld <- map_data("world")

mp1 <- ggplot(mapWorld, aes(x=long, y=lat, group=group))+
  geom_polygon(fill="white", color="black") +
  coord_map(xlim=c(-180,180), ylim=c(-60, 90))

ui <- fluidPage(
  selectInput("projection","Choose a Projection", projections),
  plotOutput(outputId="map")
  )

server <- function(input, output, session) {
  output$map <- renderPlot({
    mp1 + coord_map(projection= input$projection, xlim=c(-180,180), ylim=c(-60, 90))
  }) 
}

shinyApp(ui, server)
