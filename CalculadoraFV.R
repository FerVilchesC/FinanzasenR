install.packages(c("shiny", "writexl"))
library(shiny)
library(writexl)

ui <- fluidPage(
  # CSS para disminuir tamaño de letra y ajustar margen/padding
  tags$style(HTML("
    body, label, input, button, select, table, h3, h4 {
      font-size: 12px !important;
    }
    .shiny-text-output, .shiny-table-output {
      font-size: 12px !important;
    }
    .sidebar {
      max-height: 100vh;
      overflow-y: auto;
    }
  ")),
  
  # Autor arriba del título
  div("Autor: Fernanda Vilches - Hapag Lloyd", 
      style = "text-align: center; color: gray; font-size: 11px; margin-bottom: 5px;"),
  
  titlePanel("Calculadora de Ratios Financieros para 2 Años"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("empresa", "Nombre de la empresa:", ""),
      
      fluidRow(
        column(6,
               h4("Datos Año 1"),
               numericInput("anio1", "Año:", value = as.numeric(format(Sys.Date(), "%Y")), min = 1900, max = 2100),
               numericInput("act_corr1", "Activos Corrientes:", 0, min = 0, step = 1000),
               numericInput("pas_corr1", "Pasivos Corrientes:", 0, min = 0, step = 1000),
               numericInput("pas_tot1", "Pasivos Totales:", 0, min = 0, step = 1000),
               numericInput("act_tot1", "Activos Totales:", 0, min = 0, step = 1000),
               numericInput("util_neta1", "Utilidad Neta:", 0, step = 1000),
               numericInput("ventas1", "Ventas:", 0, min = 0, step = 1000)
        ),
        column(6,
               h4("Datos Año 2"),
               numericInput("anio2", "Año:", value = as.numeric(format(Sys.Date(), "%Y")) - 1, min = 1900, max = 2100),
               numericInput("act_corr2", "Activos Corrientes:", 0, min = 0, step = 1000),
               numericInput("pas_corr2", "Pasivos Corrientes:", 0, min = 0, step = 1000),
               numericInput("pas_tot2", "Pasivos Totales:", 0, min = 0, step = 1000),
               numericInput("act_tot2", "Activos Totales:", 0, min = 0, step = 1000),
               numericInput("util_neta2", "Utilidad Neta:", 0, step = 1000),
               numericInput("ventas2", "Ventas:", 0, min = 0, step = 1000)
        )
      ),
      
      fluidRow(
        column(6, actionButton("calcular", "Calcular")),
        column(6, actionButton("limpiar", "Limpiar"))
      ),
      br(),
      downloadButton("guardar_excel", "Guardar en Excel")
    ),
    
    mainPanel(
      h3("Resultados"),
      tableOutput("tabla_resultados"),
      br(),
      h4("Análisis de los resultados"),
      uiOutput("analisis_resultados")
    )
  )
)

server <- function(input, output, session) {
  
  datos_calculados <- reactiveVal(NULL)
  
  observeEvent(input$calcular, {
    req(input$empresa)
    
    calc_ratios <- function(act_corr, pas_corr, pas_tot, act_tot, util_neta, ventas) {
      liquidez <- if (pas_corr != 0) round(act_corr / pas_corr, 2) else NA
      endeudamiento <- if (act_tot != 0) round(pas_tot / act_tot, 2) else NA
      rentabilidad <- if (ventas != 0) round(util_neta / ventas, 2) else NA
      list(liquidez=liquidez, endeudamiento=endeudamiento, rentabilidad=rentabilidad)
    }
    
    res1 <- calc_ratios(input$act_corr1, input$pas_corr1, input$pas_tot1, input$act_tot1, input$util_neta1, input$ventas1)
    res2 <- calc_ratios(input$act_corr2, input$pas_corr2, input$pas_tot2, input$act_tot2, input$util_neta2, input$ventas2)
    
    df <- data.frame(
      Empresa = input$empresa,
      Año = c(input$anio1, input$anio2),
      Liquidez_Corriente = c(res1$liquidez, res2$liquidez),
      Endeudamiento = c(res1$endeudamiento, res2$endeudamiento),
      Rentabilidad = c(res1$rentabilidad, res2$rentabilidad)
    )
    
    datos_calculados(df)
  })
  
  observeEvent(input$limpiar, {
    updateTextInput(session, "empresa", value = "")
    updateNumericInput(session, "anio1", value = as.numeric(format(Sys.Date(), "%Y")))
    updateNumericInput(session, "anio2", value = as.numeric(format(Sys.Date(), "%Y")) - 1)
    
    inputs <- c("act_corr1", "pas_corr1", "pas_tot1", "act_tot1", "util_neta1", "ventas1",
                "act_corr2", "pas_corr2", "pas_tot2", "act_tot2", "util_neta2", "ventas2")
    for (i in inputs) updateNumericInput(session, i, value = 0)
    
    datos_calculados(NULL)
  })
  
  output$tabla_resultados <- renderTable({
    req(datos_calculados())
    datos_calculados()
  })
  
  output$analisis_resultados <- renderUI({
    req(datos_calculados())
    df <- datos_calculados()
    
    analisis_texto <- function(ratio, valor) {
      if (is.na(valor)) return("No se pudo calcular.")
      if (ratio == "Liquidez_Corriente") {
        if (valor < 1) "Riesgo de iliquidez: podría no cubrir sus obligaciones a corto plazo."
        else if (valor <= 2) "Nivel saludable."
        else "Liquidez muy alta: posible exceso de activos ociosos."
      } else if (ratio == "Endeudamiento") {
        if (valor > 0.6) "Alto endeudamiento: mucha dependencia de deuda."
        else if (valor >= 0.4) "Nivel moderado de deuda."
        else "Bajo endeudamiento."
      } else if (ratio == "Rentabilidad") {
        if (valor < 0) "Pérdida neta."
        else if (valor < 0.1) "Rentabilidad baja."
        else if (valor <= 0.2) "Rentabilidad aceptable."
        else "Alta rentabilidad."
      } else {
        ""
      }
    }
    
    tagList(
      lapply(1:nrow(df), function(i) {
        fluidRow(
          column(12,
                 tags$h4(paste0("Análisis para ", df$Empresa[i], " - Año ", df$Año[i])),
                 tags$ul(
                   tags$li(strong("Liquidez Corriente: "), paste0(df$Liquidez_Corriente[i], " - ", analisis_texto("Liquidez_Corriente", df$Liquidez_Corriente[i]))),
                   tags$li(strong("Endeudamiento: "), paste0(df$Endeudamiento[i], " - ", analisis_texto("Endeudamiento", df$Endeudamiento[i]))),
                   tags$li(strong("Rentabilidad: "), paste0(df$Rentabilidad[i], " - ", analisis_texto("Rentabilidad", df$Rentabilidad[i])))
                 )
          )
        )
      })
    )
  })
  
  output$guardar_excel <- downloadHandler(
    filename = function() {
      paste0("Ratios_Financieros_", gsub(" ", "_", input$empresa), "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      req(datos_calculados())
      writexl::write_xlsx(datos_calculados(), path = file)
    }
  )
  
}

shinyApp(ui, server)


