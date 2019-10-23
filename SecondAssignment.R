library(shiny)
library(leaflet)
library(tidyverse)
library(magrittr)
library(leaflet.extras)

crime <- read.csv(url("https://data.boston.gov/dataset/6220d948-eae2-4e4b-8723-2dc8e67722a3/resource/12cb3883-56f5-47de-afa5-3b1cf61b257b/download/tmphbl23vi6.csv"))
crime.clean <- filter(crime, YEAR==2018 & MONTH == 12)
crime.clean <- filter(crime.clean, Lat != -1)
crime.clean$Day <- ifelse(crime.clean$HOUR>=9 & crime.clean$HOUR <=17, "Day","Night")

crime.clean$General <- ifelse(
    crime.clean$OFFENSE_CODE_GROUP=="Motor Vehicle Accident Response", "Accident",
    ifelse(crime.clean$OFFENSE_CODE_GROUP=="Larceny","Larceny",
           ifelse(crime.clean$OFFENSE_CODE_GROUP=="Simple Assault","Simple Assault",
                  ifelse(crime.clean$OFFENSE_CODE_GROUP=="Investigate Person","Investigate Person",
                         ifelse(crime.clean$OFFENSE_CODE_GROUP=="Medical Assistance","Medical Assistance","Other")))))


crime.clean$Shoot <- ifelse(crime.clean$SHOOTING == "Y",1,0)
crime.clean$Homicide <- ifelse(crime.clean$OFFENSE_CODE_GROUP=="Homicide",1,0)
crime.clean$Missing <- ifelse(crime.clean$OFFENSE_CODE_GROUP=="Missing Person Reported",1,0)

crime.shoot <- filter(crime.clean, Shoot == 1)
crime.homicide <- filter(crime.clean, Homicide == 1)
crime.missing <- filter(crime.clean, Missing == 1)




# Define UI for application that draws a histogram
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(checkboxInput("shoot", "Shooting", FALSE),
                     checkboxInput("missing", "Missing Person", FALSE),
                     checkboxInput("murder", "Homicide", FALSE)),
    mainPanel( 
        leafletOutput(outputId = "mymap"),
        
        
        
        p("Hello! This is my shinyapp. I used the crime data. 
          You can hover your mouse over the many points here to see 
          basic info about it. You can click the points to highlight 
          those labeled crimes."),
        p("To interpret this, each point is where a crime was reported. 
          If you click on one of the pointers, circles appear around 
          where selected events happened. The circles are transparent.  
          If they overlap, they become more opaque. You can do this to see
          where more of the crimes were reported."),
        p("I'll also note, some of the crime types were put in as Other. 
          I chose to keep those unlisted as Other.")
        
                      
        )
    ))
# Define server logic required to draw a histogram
server <- function(input, output) {
pal1 <- colorFactor(
    palette = c('brown', 'dark orange', 'blue', 'dark blue', 'purple', 'black'),
    domain=crime.clean$General)

pal2 <- colorFactor(
    palette= c('red'),
    domain=crime.clean$Shoot)

pal3 <- colorFactor(
    palette= c('black'),
    domain=crime.clean$Missing
)

pal4 <- colorFactor(
    palette= c('dark red'),
    domain=crime.clean$Homicide
)



output$mymap <- renderLeaflet({
    leaflet(crime.clean) %>% 
        setView(lng = -71.1, lat = 42.32, zoom = 11.5)  %>% 
        addTiles() %>% 
        addCircles(data = crime.clean, lat = ~ Lat, lng = ~ Long, weight = 1, 
                   radius = 30, popup = ~as.character(OFFENSE_CODE_GROUP), 
        label = ~as.character(paste0("Offense: ", sep = " ", 
        OFFENSE_CODE_GROUP, " at around ", HOUR, ":00 on ", DAY_OF_WEEK )), 
                   color = ~pal1(General), fillOpacity = 1)
})

observe({
    proxy <- leafletProxy("mymap", data = crime.shoot)
    if (input$shoot) {
        proxy %>% 
            addCircleMarkers(stroke = FALSE, 
    color = ~pal2(crime.shoot$Shoot), group="one",
    fillOpacity = 0.3, radius=8,     
    label = ~as.character(paste0("Offense: ", sep = " ", 
OFFENSE_CODE_GROUP, " at around ", HOUR, ":00 on ", DAY_OF_WEEK ))) %>%
addLegend("bottomright", pal = pal2, values = crime.shoot$Shoot,
                      title = "Shooting",
                      opacity = 1)}
    else {
        proxy %>% clearGroup(group="one") %>% clearControls()
    }
})

observe({
    proxy <- leafletProxy("mymap", data = crime.missing)
    if (input$missing) {
        proxy %>% 
            addCircleMarkers(stroke = FALSE, group="three",
                             color = ~pal3(crime.missing$Missing), 
                             fillOpacity = 0.2, radius=8,     
                             label = ~as.character(paste0("Offense: ", sep = " ", OFFENSE_CODE_GROUP, " at around ", HOUR, ":00 on ", DAY_OF_WEEK ))) %>%
            addLegend("bottomright", pal = pal3, values = crime.missing$Missing,
                      title = "Larceny",
                      opacity = 1)}
    else {
        proxy %>% clearGroup(group="three") %>% clearControls()
    }
})


observe({
    proxy <- leafletProxy("mymap", data = crime.homicide)
    if (input$murder) {
        proxy %>% 
            addCircleMarkers(stroke = FALSE, group="two",
                             color = ~pal4(crime.homicide$Homicide), 
                             fillOpacity = 0.3, radius=5,     
                             label = ~as.character(paste0("Offense: ", sep = " ", 
        OFFENSE_CODE_GROUP, " at around ", HOUR, ":00 on ", DAY_OF_WEEK ))) %>%
            addLegend("bottomright", pal = pal4, values = crime.homicide$Homicide,
                      title = "Homicide",
                      opacity = 1)}
    else {
        proxy %>% clearGroup(group="two") %>% clearControls()
    }
})



}
# Run the application 
shinyApp(ui = ui, server = server)
