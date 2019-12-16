#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plotly)
library(DT)
library(here)
library(iAdapt)

#################################################
# Define server logic 
shinyServer(function(input, output, session) {
  
  ## Unacceptable minimum ##
  
  output$Udlt = renderUI({
    p_no_min = input$p_yes
    
    sliderInput("p_no", h4("Unacceptable DLT:"),
                min = p_no_min, max = 1, value = 0.40,
                step = diff(0:1/20, 1) #animate=TRUE
    )
  })
  
  
  ##Creating toxicity and efficacy vectors##
  m <- eventReactive(input$update, {
    as.numeric(c(input$eff1, input$eff2, input$eff3, input$eff4, input$eff5, 
                 input$eff6, input$eff7, input$eff8, input$eff9, input$eff10)[1:input$dose])
  })
  
  output$eff_range <- renderPrint({ 
    m()
  })
  
  dose.tox <- eventReactive(input$update, {
    as.numeric(c(input$tox1, input$tox2, input$tox3, input$tox4, input$tox5, 
                 input$tox6, input$tox7, input$tox8, input$tox9, input$tox10)[1:input$dose])
  })
  
  output$tox_range <- renderPrint({ 
    dose.tox()
  })
  
  dose <- eventReactive(input$update, {
    input$dose
  })
  
  ##Creating datatables##
    #generate seed for reproducibility
  seed <- eventReactive(input$update,{
    rpois(1, 100000)
  })
   #tox.profile: show which doses are considered safe in phase 1
  dt_tox <- eventReactive(input$update, {
    set.seed(seed())
        tox.profile(dose = input$dose, 
                dose.tox = dose.tox(),
                p1 = input$p_no, p2 = input$p_yes, K = input$K, coh.size = input$coh.size) %>% 
      as_tibble() %>% 
      dplyr::select(V1, V2, V4) %>% 
      mutate(logical = ifelse(V4 > (1/input$K), TRUE, FALSE)) %>% #create logical for color coding
      rename("Dose" = V1, "# DLTs" = V2, "Likelihood of Safety (1/k)" = V4)
  }, ignoreNULL = FALSE)
  
  #rand.stg2: show how the assignments, and efficacies, will go in stage 2
 rand <- eventReactive(input$update, {
    set.seed(seed())
    rand <- rand.stg2(dose = input$dose, 
                dose.tox = dose.tox(),
                p1 = input$p_no, p2 = input$p_yes, 
                K = input$K, coh.size = input$coh.size,
                m = m(), v = rep(input$v, input$dose), 
                N = input$N, stop.rule = input$stop.rule, cohort = 1, samedose = TRUE, nbb = 100) 
    rand
  }, ignoreNULL = FALSE)
  
 sim <- eventReactive(input$repeated, {
    simulations <- sim.trials(numsims = input$sims, 
               dose = input$dose, 
               dose.tox = dose.tox(),
               p1 = input$p_no, p2 = input$p_yes, K = input$K, coh.size = input$coh.size,
               m = m(), v = rep(input$v, input$dose), N = input$N) 
    simulations
      }, ignoreNULL = FALSE)
  
  eff <- eventReactive(input$update, {
    set.seed(seed())
    eff.stg1(dose = input$dose, 
             dose.tox = dose.tox(),
             p1 = input$p_no, p2 = input$p_yes, K = input$K, coh.size = input$coh.size, 
             m = m(),
             v = rep(input$v, input$dose), nbb = 100)
  }, ignoreNULL = FALSE)
  
  
  ##Table outputs##
  
  output$dt_tox <- DT::renderDataTable({
    dt_tox <- dt_tox() 
    DT::datatable(dt_tox, rownames = FALSE, 
                  options = list(paging = FALSE, searching = FALSE, rownames = FALSE,
                                 columnDefs = list(list(visible=FALSE, targets = 3))))  %>% 
      formatStyle("logical",
                  target = 'row',
                  backgroundColor = styleEqual(c(1, 0), c('#98fb98', '#ffcccb'))
      )
  })
  
  output$dt_rand <- DT::renderDataTable({
    rand <- rand() 
    
    dt_rand_2 <- rand %>% 
      as_tibble() %>%
      select(Y.final, d.final) %>% 
      mutate(n = row_number()) %>% 
      top_n((input$N - rand$n1), wt = n) %>% 
      select(n, d.final, Y.final) %>% 
      rename("Subject number" = n, "Dose Assignment" = d.final, "Efficacy Outcome" = Y.final)
    
    DT::datatable(dt_rand_2, rownames = FALSE, 
                  options = list(paging = TRUE, searching = FALSE))
  })
  
  output$sim_treated <- DT::renderDataTable({
    sim_tables <- sim.summary(sim())
    sim_treated <- sim_tables$pct.treated %>% 
      as_tibble() %>% 
      rename("Dose" = V1, "25th percentile" = V2, "Median" = V3, "75th percentile" = V4)
    DT::datatable(sim_treated, rownames = FALSE, 
                  options = list(paging = FALSE, searching = FALSE))
  })
  
  output$sim_eff <- DT::renderDataTable({
    sim_tables <- sim.summary(sim())
    sim_eff <- sim_tables$efficacy %>% 
      as_tibble() %>% 
      rename("Dose" = V1, "25th percentile" = V2, "Median" = V3, "75th percentile" = V4)
    DT::datatable(sim_eff, rownames = FALSE, 
                  options = list(paging = FALSE, searching = FALSE))
  })
  
  ##Plot output##
  
  output$plot_tox <- renderPlotly({
    tox <- tibble(toxicity = dose.tox(),
                 dose = seq(from = 1, to = dose(), by = 1)
    ) %>% 
      ggplot() +
      geom_line(aes(y = toxicity, x = dose), color = "dark red") +
      geom_point(aes(y = toxicity, x = dose), color = "dark red") +
      geom_hline(aes(yintercept = input$p_no), color = "red") +
      geom_hline(aes(yintercept = input$p_yes), color = "dark green") +
      annotate("text", x = 3, label = "Unacceptable DLT", y = input$p_no - 0.02, color = "red") +
      annotate("text", x = 3, label = "Acceptable DLT", y = input$p_yes - 0.02, color = "dark green") +
      labs(y = "Toxicity",
                    x = "Dose Level",
                    colour = " ") + theme_bw() 
    plotly::ggplotly(tox)
    
    
  })
  
  output$plot_eff <- renderPlotly({
    eff <- tibble(efficacy = m(),
                  dose = seq(from = 1, to = dose(), by = 1)
    ) %>%
      ggplot() +
      geom_line(aes(y = efficacy, x = dose), color = "dark blue") +
      geom_point(aes(y = efficacy, x = dose), color = "dark blue") +
      labs(y = "Efficacy",
           x = "Dose Level",
           colour = " ") + theme_bw()
    plotly::ggplotly(eff)


  })
  
  
  # output$plot_stg1 <- renderPlotly({
  #    rand <- rand() 
  #   
  #   dt_rand_1 <- rand %>% 
  #     as_tibble() %>%
  #     select(Y.final, d.final) %>% 
  #     mutate(n = row_number()) %>% 
  #     top_n(-rand$n1, wt = n) 
  #   p1 <- dt_rand_1 %>% 
  #     ggplot(aes(y = Y.final, x =  factor(d.final), fill = factor(d.final))) + 
  #     geom_point() +
  #     geom_boxplot(alpha = 0.3) +
  #     labs(y = "Efficacy Outcomes in Stage 1", x = "Dose") +
  #     theme_bw() + viridis::scale_fill_viridis(discrete = TRUE) + theme(legend.position = "none")
  #   
  #   plotly::ggplotly(p1)
  # })

output$plot_stg2 <- renderPlotly({
  rand <- rand() 
  
    dt_rand_2 <- rand %>% 
      as_tibble() %>%
      select(Y.final, d.final) %>% 
      mutate(n = row_number()) %>% 
     # top_n((input$N - rand$n1), wt = n) %>% 
      select(n, d.final, Y.final)
    
    p1 <- dt_rand_2 %>% 
      ggplot(aes(y = Y.final, x = d.final, fill = factor(d.final))) + 
      geom_point() +
      geom_boxplot(alpha = 0.3) +
      labs(y = "Efficacy Outcomes in Stage 2", x = "Dose") + theme_bw() +
      viridis::scale_fill_viridis(discrete = TRUE) + theme(legend.position = "none")
    
    plotly::ggplotly(p1)
  })
  
  
  # output$plot_safe <- renderPlotly({
  #   p1 <- tibble(eff_safe = eff()$Y.safe, 
  #                dose_safe = eff()$d.safe) %>% 
  #     ggplot(aes(y = eff_safe, x = factor(as.character(eff()$d.safe)))) + 
  #     geom_boxplot() +
  #     labs(y = "Efficacy Outcomes", x = "Safe Doses")
  #   
  #   plotly::ggplotly(p1)
  # })
  
})
