
library(shiny)
library(tm)
library(RWeka)
library(stringr)

shinyServer(function(input, output) {
  # Load the word prediction algorithm
  source("Source_code.R")
  
  # Load the n-gram frequencies
  load("Capstone.RData")
  
  # Reactively perform word prediction
  observe({
    text.in <- as.character(input$text_in)
    count <- input$word.suggestions
    
    pcw <- NULL
    if (str_sub(text.in, start=-1) != " " && text.in != "") {
    
      pcw <- predictCurrentWord(text.in, nf, count)
      output$current.text=renderPrint(cat(pcw, sep = "\n"))
    } else if(nchar(text.in) > 0) {
     
      output$current.text=renderPrint(cat(""))
    }
    
    if (str_sub(text.in, start=-1) == " ") {
      # Predict next word
      output$next_word=renderPrint(cat(cleanPredictNextWord(text.in, nf, count), sep = "\n"))
    } else if (!is.null(pcw) && lastWords(text.in, 1) %in% pcw) {
      # Full word detected; Predict next word
      output$next_word=renderPrint(cat(cleanPredictNextWord(text.in, nf, count), sep = "\n"))
    } else {
      # Clear prediction output
      output$word.next=renderPrint(cat(""))
    }
  })
})