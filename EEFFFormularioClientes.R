## Se crea formulario estándar para desarrollar posteriormente una herramienta 
## que permita leer la información directamente del PDF.
## Será requisito que cliente complete el PDF creado para posterior desarrollo.


# Instalar paquetes necesarios 
if (!requireNamespace("xfun", quietly = TRUE)) install.packages("xfun")
if (!requireNamespace("tinytex", quietly = TRUE)) install.packages("tinytex")

# Instalar TinyTeX (versión portable, sin admin) - 
if (!tinytex::is_tinytex()) tinytex::install_tinytex()

# carpeta destino
carpeta_destino <- "C:/Users/VILCHFE/Documents"

# Crear el código LaTeX
tex_code <- "
\\documentclass{article}
\\usepackage{hyperref}
\\begin{document}

\\noindent Empresa: \\TextField[name=empresa,width=10cm]{}\\\\[10pt]

\\noindent Año 1: \\TextField[name=anio1,width=3cm]{} \\quad Año 2: \\TextField[name=anio2,width=3cm]{}\\\\[10pt]

\\section*{Balance General}

\\begin{tabular}{lcc}
Concepto & Año 1 & Año 2 \\\\
Activos corrientes & \\TextField[name=ac1,width=3cm]{} & \\TextField[name=ac2,width=3cm]{} \\\\
Activos no corrientes & \\TextField[name=an1,width=3cm]{} & \\TextField[name=an2,width=3cm]{} \\\\
Total activos & \\TextField[name=ta1,width=3cm]{} & \\TextField[name=ta2,width=3cm]{} \\\\
Pasivos corrientes & \\TextField[name=pc1,width=3cm]{} & \\TextField[name=pc2,width=3cm]{} \\\\
Pasivos no corrientes & \\TextField[name=pn1,width=3cm]{} & \\TextField[name=pn2,width=3cm]{} \\\\
Total pasivos & \\TextField[name=tp1,width=3cm]{} & \\TextField[name=tp2,width=3cm]{} \\\\
Patrimonio & \\TextField[name=pat1,width=3cm]{} & \\TextField[name=pat2,width=3cm]{} \\\\
\\end{tabular}

\\section*{Estado de Resultados}

\\begin{tabular}{lcc}
Concepto & Año 1 & Año 2 \\\\
Ventas & \\TextField[name=ventas1,width=3cm]{} & \\TextField[name=ventas2,width=3cm]{} \\\\
Costo de ventas & \\TextField[name=costo1,width=3cm]{} & \\TextField[name=costo2,width=3cm]{} \\\\
Margen (Ventas - Costo) & \\TextField[name=margen1,width=3cm]{} & \\TextField[name=margen2,width=3cm]{} \\\\
Utilidad / Pérdida & \\TextField[name=utilidad1,width=3cm]{} & \\TextField[name=utilidad2,width=3cm]{} \\\\
\\end{tabular}

\\vspace{1cm}

\\noindent Nombre: \\TextField[name=nombre,width=6cm]{} \\quad Cargo: \\TextField[name=cargo,width=6cm]{}\\\\[20pt]

\\noindent Firma: \\TextField[name=firma,width=6cm]{} \\quad Fecha: \\TextField[name=fecha,width=4cm]{}

\\end{document}
"

# Guardar archivo .tex en carpeta destino
ruta_tex <- file.path(carpeta_destino, "formulario_financiero.tex")
writeLines(tex_code, ruta_tex)

# Compilar a PDF usando TinyTeX (en la misma carpeta)
tinytex::pdflatex(ruta_tex)

# Definir ruta completa del PDF generado
ruta_pdf <- file.path(carpeta_destino, "formulario_financiero.pdf")

# Abrir el PDF generado
shell.exec(ruta_pdf)

cat("✅ PDF creado y abierto correctamente en: ", ruta_pdf, "\n")
