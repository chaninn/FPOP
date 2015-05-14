library(shiny)
library(seqinr)
library(protr)
library(caret)
library(randomForest)
library(shinyjs)

Train_DPC_PCP <- read.csv("Train_DPC_PCP.csv", header=TRUE)
Train <- Train_DPC_PCP[,1:401]
fit <- randomForest(Oligomerization~., data = Train, importance=TRUE, ntree=2000)

shinyServer(function(input, output, session) {
  
  
  observe({
    FASTADATA <- ''
    fastaexample <- '>mCitrine-Monomer
DPMVSKGEELFTGVVPILVELDGDVNGHKFSVSGEGEGDATYGKLTLKF
ILTTGKLPVPWPTLVTTFGYGLMVFARYPDHMKRHDFFKSAMPEGYVQER
TIFFKDDGNYKTRAEVKFEGDTLVNRIELKGIDFKEDGNILGHKLEYNYN
SHNVYIMADKQKNGIKVNFKIRHNIEDGSVQLADHYQQNTPIGDGPVLLP
DNHYLSYQSKLSKDPNEKRDHMVLLEFVTAAGITHGMDELYK
>amFP486(E150Q)-Tetramer
MRGSHHHHHHGSALSNKFIGDDMKMTYHMDGCVNGHYFTVKGEGNGKPY
EGTQTSTFKVTMANGGPLAFSFDILSTVFKYGNRCFTAYPTSMPDYFKQA
FPDGMSYERTFTYEDGGVATASWEISLKGNCFEHKSTFHGVNFPADGPVM
AKKTTGWDPSFQKMTVCDGILKGDVTAFLMLQGGGNYRCQFHTSYKTKKP
VTMPPNHVVEHRIARTDLDKGGNSVQLTEHAVAHITSVVPF
'
    if(input$addlink>0) {
      isolate({
        FASTADATA <- fastaexample
        updateTextInput(session, inputId = "Sequence", value = FASTADATA)
      })
    }
  })
  
  observe({
    emptyDATA <- ""
    if(input$clearbutton>0) {
      isolate({
        updateTextInput(session, inputId = "Sequence", value = emptyDATA) 
        is.null(datasetInput())
        
      })
    }
  })
  

  datasetInput <- reactive({
    
    inFile <- input$file1 
    inTextbox <- input$Sequence
    
    
    if (is.null(inTextbox)) {
      return("Please insert/upload sequence in FASTA format")
    } else {
      if (is.null(inFile)) {
        x <- inTextbox
        write.fasta(sequence = x, names = names(x),
                    nbchar = 80, , file.out = "text.fasta")
        x <- readFASTA("text.fasta")
        x <- x[(sapply(x, protcheck))]
        DPC <- t(sapply(x, extractDC))
        test <- data.frame(DPC)
        Prediction <- predict(fit, test)
        Prediction <- as.data.frame(Prediction)
        Protein <- cbind(Name = rownames(Prediction, Prediction))
        results <- cbind(Protein, Prediction)
        results <- data.frame(results, row.names=NULL)
        print(results)
      } 
      else {     
        x <- readFASTA(inFile$datapath)
        x <- x[(sapply(x, protcheck))]
        DPC <- t(sapply(x, extractDC))
        test <- data.frame(DPC)
        Prediction <- predict(fit, test)
        Prediction <- as.data.frame(Prediction)
        Protein <- cbind(Protein = rownames(Prediction, Prediction))
        results <- cbind(Protein, Prediction)
        results <- data.frame(results, row.names=NULL)
        print(results)
        
      }
    }
    
    
  })
  
  
  
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
    isolate(datasetInput()) 
    } else {
      if (input$clearbutton>0) {
      isolate(is.null(datasetInput()))
    } else {
      return("Please insert/upload sequence in FASTA format")
    }
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { paste('Predicted_Results', '.csv', sep='') },
    content = function(file) {
      write.csv(datasetInput(), file, row.names=FALSE)
    })
  
  

  })

