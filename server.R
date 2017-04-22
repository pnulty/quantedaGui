# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(quanteda)
library(dplyr)
library(DT)

getCorpus <- function(path){
  if(is.null(path)){
    return(NULL)
  }
  tmpPath <- tempdir
  fs <- path$datapath
  textsvec = c()
  for (i in 1:length(fs)){
    textsvec[i] <- paste(readLines(fs[i]), collapse = " ")
  }
  names(textsvec) <- basename(path$name)
  qc <- corpus(textsvec)
  return(qc)
}


getCorpusFromZip <- function(path, fixedZip = FALSE){
  if(is.null(path)){
    return(NULL)
  }
  if(fixedZip){
    qc <- (textfile(path))
  }
  else{
    td <- tempdir()
    fs <- unzip(path$datapath, exdir = td)
    textsvec = c()
    for (i in 1:length(fs)){
      textsvec[i] <- paste(readLines(fs[i]), collapse = " ")
    }
    names(textsvec) <- basename(fs)
    qc <- corpus(textsvec)
  }
  return(qc)
}


shinyServer(function(input, output) {
  myCorpus <- reactive({
    inFile <- input$file1
    print('reading in corpus')
    if (is.null(inFile))
      return(NULL)

    if(input$uploadTypeRadio == 1){
      mc <- getCorpusFromZip(inFile)
    }
    else{
      mc <- getCorpus(inFile)
    }
    return(mc)
  })
  
  
  make_dfm <- eventReactive(input$dfm_button,{
      curCorpus <- myCorpus()
      curDf <- dfm(curCorpus) %>% dfm_trim(as.numeric(input$minFreq), as.numeric(input$minDoc))
      if(input$weightingRadio != "count"){
          curDf <- weight(curDf, input$weightingRadio)
      }
    curDf  
     # toRender <- cbind(filenames = row.names(curDf[,1:showN]), curDf[,1:showN])
  } )
  
  make_scale <- eventReactive(input$scale_button,{
      print('scale button called')
      curCorpus <- myCorpus()
      curDf <- make_dfm()
      ca_fitted <- textmodel_ca(curDf, nd=2)
      coldf <- as.data.frame(ca_fitted$colcoord)
      rownames(coldf) <- ca_fitted$colnames
      coldf
      
      
  })
  
  
    output$fileTable <- DT::renderDataTable({

        
        curCorpus <- myCorpus()
        validate(
            need(curCorpus != "", "Please select a data set")
        )
        summary(curCorpus, n=ndoc(curCorpus))
        }, options = list(searching = FALSE))
    
    
    output$dfmTable <-  DT::renderDataTable({
    disp <- as.data.frame(make_dfm())
    disp[,1:input$showN]
    })
    
    output$scale_table <- DT::renderDataTable({make_scale()})


  
    output$kwicTable <- renderDataTable({
    curCorpus <- myCorpus()
    kwic(curCorpus, input$keyword, window = input$contextSize,
         valuetype = input$kwicValueType,
         case_insensitive = !(input$caseSensitive))
    }, options = list(searching = FALSE))

})
