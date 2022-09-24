# UNAL_2022

## ejemplo 1. "river lake" calibración de coeficientes de difusión
Requiere MATLAB (corre también en Octave)
+ River and Stratified lake problem.pdf [PDF]
+ run_river_lake.m, calculadora de ajuste de calibración. Un par de valores a la vez. 
+ run_river_lake_loop.m, fuerza bruta o muestreo aleatorio.
+ three_tanks.m, ecuaciones diferenciales.
+ riverlake_measurements.dat, datos de la campaña de monitoreo.

## ejemplo 2. calibración de un atractor de Lorenz using GA (Borg MOEA)
Requiere MATLAB (para obtener la última versión de Borg http://borgmoea.org/#contact )
+ Borg-Lorenz.zip, descomprimir y renombrar archivo .dllxxx to .dll
+ test_lorenzcomp.m, ubicar este arvhivo en la misma carpeta que se descomprimió Borg-Lorenz.zip. Este archivo sirve para visualizar dos atractores con parámetros similares y ver como divergen las trayectorias rápidamente

## ejemplo 3. calibración de regla de operación estándar de embalses (SOR) y regla de cobertura óptima Tipo I y Tipo II (RCO) 
Requiere python, se necesita instalar PRIM, Platypus y Rhodium
+ SOR.zip, descomprimir. Archivo de python contiene el código de las SOR (Regla de operación estándar) y la RCO (Regla de Cobertura Optima)
Para entender SOR y RCO favor leer  Castro-Gama et al. (2019) https://doi.org/10.1080/23863781.2019.1707132

## ejemplo 4*. Programación de cascadas de embalses de hidrogeneración con precio variable (24 hr y 168 hr) 
Requiere MATLAB, YALMIP y GUROBI instalado. YALMIP se consigue en GitHub de forma gratuita. GUROBI ofrece licencia gratuita para academia por 1 año.

