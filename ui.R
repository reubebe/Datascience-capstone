

library(shiny)

shinyUI(fluidPage(
  navbarPage("SuggestApp",
             tabPanel("Home",
                      sidebarLayout(
                        sidebarPanel(
                          h4('Type word here:'), 
                          tags$textarea(id="text_in", rows=2, cols=30),
                          sliderInput("word.suggestions", "Number of word predictions:",
                                      value = 1.0, min = 1.0, max = 5.0, step = 1.0),
                          HTML("<br><br>"),
                                                     h4("Instructions"),
                                                     HTML("<p>This App predicts the next word(s) based on your text input."),
                                                     HTML("<br><br>Text fields"),
                                                     HTML("<li><b>Type word here</b>: This is where the word is to be entered"),
                                                     HTML("<li><b>Number of word predictions </b>: Number of words to be predicted."),
                                                     HTML("<li><b>Next Word</b>: The next word(s)"),
                                                     HTML("<li><b>Previous word input </b>: Suggestions based on previous use or word(s) shown when the app detects a partial text."),
                                                    HTML("<br><br>Please allow a few seconds for word to process.")
                                                   ),
                        mainPanel(
                          h3("Next Word"),
                          verbatimTextOutput('next_word'),
                          HTML("<br>"),
                          h4("Previous word input"),
                          verbatimTextOutput('current.text')
                        )
                      )
             ),
             tabPanel("About",
                      mainPanel(
                        column(12,
                               includeHTML("about.html"))
                      )
             )
  )
))