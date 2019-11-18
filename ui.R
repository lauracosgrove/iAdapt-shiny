#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plotly)
library(DT)
library(shinydashboard)
library(shinybusy)

# example: data management
#load("x")
#players = x %>% distinct(y) %>% pull()
#made = x %>% distinct(t ) %>% pull()


# Define UI 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("iAdapt Dose-Finding for Early-Phase Clinical Trials"),
    tabsetPanel(type = "pills",
     tabPanel("Introduction", fluidPage(    
                         includeMarkdown("introduction.md"))
                ),      
     tabPanel("Simulation",
          fluidPage(
             fluidRow(
             column(width = 4,
              wellPanel(
                h3("Setup"),
                helpText(h4("First, specify true parameters for simulation. One trial will be simulated.")),
                numericInput("dose",
                             h4("Number of doses:"),
                             min = 2,
                             max = 10,
                             value = 5),
                #next: Vector of true toxicities associated with each dose (select range and "by")
                #e.g. dose.tox <- c(0.05, 0.10, 0.15, 0.20, 0.30)       
                fluidRow(
                  box(width = 11, h4("True Toxicities:"), 
                      splitLayout(
                        textInput("tox1", "1", value = 0.05),
                        conditionalPanel(
                          condition = "input.dose >= 2",
                          textInput("tox2", "2", value = 0.08)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 3",
                          textInput("tox3", "3", value = 0.1)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 4",
                          textInput("tox4", "4", value = 0.2)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 5",
                          textInput("tox5", "5", value = 0.3)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 6",
                          textInput("tox6", "6", value = 0.4)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 7",
                          textInput("tox7", "7", value = 0.5)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 8",
                          textInput("tox8", "8", value = 0.6)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 9",
                          textInput("tox9", "9", value = 0.7)
                        ),
                        conditionalPanel(
                          condition = "input.dose == 10",
                          textInput("tox10", "10", value = 0.8)
                        )
                        
                      )
                  )
                ),
                #Vector of true mean efficacies per dose (select range and "by")
                fluidRow(
                  box(width = 11, h4("True Mean Efficacies:"), 
                      splitLayout(
                        textInput("eff1", "1", value = 5),
                        conditionalPanel(
                          condition = "input.dose >= 2",
                          textInput("eff2", "2", value = 10)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 3",
                          textInput("eff3", "3", value = 15)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 4",
                          textInput("eff4", "4", value = 20)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 5",
                          textInput("eff5", "5", value = 25)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 6",
                          textInput("eff6", "6", value = 30)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 7",
                          textInput("eff7", "7", value = 35)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 8",
                          textInput("eff8", "8", value = 40)
                        ),
                        conditionalPanel(
                          condition = "input.dose >= 9",
                          textInput("eff9", "9", value = 45)
                        ),
                        conditionalPanel(
                          condition = "input.dose == 10",
                          textInput("eff10", "10", value = 50)
                        )
                        
                      )
                  )
                ),
                
                numericInput("v", h4("True Variance of Efficacies:"),
                             min = 0, max = 1, value = 0.01,
                             step = 0.01),
                helpText("Note: Variance is assumed uniform")
                ) #end of selector panel
              ), #end of col
    #show what you selected
    column(width = 4, h4("True Dose-Toxicity Relationship"), plotlyOutput("plot_tox")),
    column(width = 4, h4("True Dose-Efficacy Relationship"), plotlyOutput("plot_eff"))
    ),
      fluidRow(
        column(width = 4,
        wellPanel(
          h3("Stage 1"),
          helpText(h4("For stage 1, specify acceptable and unacceptable toxicity rates, likelihood ratio threshold, and cohort size.")),
          
          #Acceptable (p_yes) and unacceptable (p_no) DLT rates used for establishing safety (select range between 0 and 1)
          fluidRow(
            box(width = 11, title = "Dose Limiting Toxicity (DLT) Rates",
                splitLayout(
                  sliderInput("p_yes", h4("Acceptable DLT:"),
                              min = 0, max = 1, value = 0.15,
                              step = diff(0:1/20, 1) #animate=TRUE
                  ),
                  uiOutput("Udlt")
                )
            )
          ),
          
          #Likelihood-ratio (LR) threshold (2, 4, 8?  check paper)
          numericInput("K",
                       h4("Likelihood Ratio Threshold (k):"),
                       min = 1,
                       max = 32,
                       step = 1,
                       value = 2),
          helpText("Recommended values are 2, 4, or 8 for small sample sizes (Blume, 2002)."),
          
          #Cohort size used in stage 1: 
          numericInput("coh.size",
                       h4("Stage 1 cohort size:"),
                       min = 1,
                       max = 10,
                       step = 1,
                       value = 3)
        )
        ), #end of column
      column(width = 4,
        h4("Simulated Toxicity Profile"), 
        DT::dataTableOutput("dt_tox"),
        h6("Doses are considered safe if the likelihood ratio is greater than 1/k (colored green).")
      ) #end of column
      ), #end of row
    fluidRow(
      column(width = 4,
        wellPanel(
          h3("Stage 2"),
          helpText(h4("Stage 2 is conducted with only safe doses. Safety and efficacy are monitored, and participants will have a higher likelihood of being assigned safe and efficacious doses.")),
          #Total Sample Size
          numericInput("N",
                       h4("Total Sample Size:"),
                       min = 3,
                       max = 100,
                       step = 1,
                       value = 30),
          numericInput("stoprule",
                       h4("Stop Rule:"),
                       min = 1,
                       max = 10,
                       step = 1,
                       value = 9),
          helpText("This stop rule determines after how many patients the stage 1 trial should be stopped, if dose 1 is shown to be toxic."),
          #Update Button
          actionButton("update", "Simulate!")
        )
        ), #end of col
        #plot and table from rand stg 2 and table will go here in fluid row
      column(width = 4,
        h4("Adaptive Randomization in Stage 2"),
        DT::dataTableOutput("dt_rand")
        ),
      column(width = 4,
        h4("Estimated Efficacy of Safe Doses (Stages 1 & 2)"),
        plotlyOutput("plot_stg2")
        ) #end of col
    ) #end of row
   ) #end fluidPage
        ), #end tab panel
        tabPanel("Repeated simulation",
    wellPanel(
      add_busy_spinner(spin = "fading-circle"),
      numericInput("sims",
                   h4("Number of repeated simulations:"),
                   min = 1,
                   max = 1000,
                   step = 50,
                   value = 100),
      helpText("Before conducting repeated simulations, specify a design in the Simulation tab."),
      #Simulate n times
      actionButton("repeated", "Simulate n times")
    ),
    column(width = 8, h4("Summary Statistics of Simulated Trials"),
      h6("Percent allocation per dose"),
      DT::dataTableOutput("sim_treated"),
      h6("Estimated efficacy outcomes by dose"),
      DT::dataTableOutput("sim_eff"))
    ),
   tabPanel("Implementation"
            ,fluidPage(    
   includeMarkdown("Implementation_example.md"))
    )
  )
)
)