library(shiny)
library(shinythemes)
library(protr)
library(markdown)


shinyUI(fluidPage(title="FPOP: Fluorescent Protein Oligomerization Predictor", theme=shinytheme("cerulean"),
                  navbarPage(strong("FPOP"),
                             tabPanel("Submit Job", titlePanel("FPOP: Fluorescent Protein Oligomerization Predictor"),
                                      sidebarLayout(
                                        wellPanel(
                                          tags$label("Enter your input sequence(s) in FASTA format",style="float: none; width: 100%;"),
                                          actionLink("addlink", "Insert example data"),
                                          tags$textarea(id="Sequence", rows=5, cols=100, style="float: none; width:100%;", ""),
                                          #actionLink("addlink", "Insert example data"),
                                          #tags$label("or",style="float: none; width: 100%;"),
                                          fileInput('file1', 'or upload file',accept=c('text/FASTA','FASTA','.fasta','.txt')),
                                          # tags$label("Step 2 - Submit your job",style="float: none; width: 100%;"),
                                          actionButton("submitbutton", "Submit", class = "btn btn-primary"),
                                          HTML("<a class='btn btn-default' href='/fpop'>Clear</a>")
                                        ), #wellPanel
                                        
                                        mainPanel(
                                          verbatimTextOutput('contents'),
                                          downloadButton('downloadData', 'Download CSV')
                                        )  
                                      ) #sidebarLayout
                             ), #tabPanel Submit Job
                             
                             tabPanel("About", titlePanel("Fluorescent protein oligomerization"), div(includeMarkdown("about.md"), align="justify")),
                             tabPanel("Citing Us", titlePanel("Citing Us"), includeMarkdown("citingus.md")),
                             tabPanel("Contact", titlePanel("Contact"), includeMarkdown("contact.md")),	
                  ) #navbarPage
                  copyright <- div(HTML("<p align='center'>Copyright © 2015 codes.bio. All rights reserved.</p>")),
                  cat(as.character(copyright))
) #fluidPage	
) #shinyUI
