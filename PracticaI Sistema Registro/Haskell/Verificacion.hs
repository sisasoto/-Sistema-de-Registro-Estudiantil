module Verificacion where
-- Función para verificar el formato de los datos ingresados (ID, nombre, hora de entrada y hora de salida)
import Data.Char (isDigit, isAlpha, isSpace, toUpper)
--Validación del ID del estudiante
estuIdValido :: String -> Bool          -- Verifica que el ID del estudiante sea un número, sin espacios ni caracteres especiales
estuIdValido "" = False
estuIdValido identificador = all isDigit identificador        -- recorre todo el String identificador y verifica que cada caracter sea un dígito

pedirIdValido :: IO String              -- Función para pedir un ID válido al usuario
pedirIdValido = do
    putStrLn "Ingrese la identificación del estudiante (solo números):"
    identificador <- getLine                       --a identificador le asigna el valor que el usuario ingresa por consola
    if estuIdValido identificador
        then return identificador
        else do
            putStrLn "Identificación inválida. Por favor, ingrese una idenficación válida."
            pedirIdValido

--Validación del nombre del estudiante
estuNombreValido :: String -> Bool                                     -- Verifica que el nombre del estudiante contenga solo letras y espacios
estuNombreValido "" = False
estuNombreValido nombre = all (\c -> isAlpha c || isSpace c) nombre    -- recorre todo el String nombre y verifica que cada caracter sea una letra o un espacio

pedirNombreValido :: IO String               -- Función para pedir un nombre válido al usuario
pedirNombreValido = do
    putStrLn "Por favor, ingrese el nombre del estudiante:"
    nombre <- getLine
    if estuNombreValido nombre
        then return nombre
        else do
            putStrLn "Nombre inválido. Por favor, ingrese un nombre válido (solo letras y espacios)."
            pedirNombreValido

--Validación de confirmación de Si y No
confirmacionValida :: String ->  Bool
confirmacionValida respuesta = map toUpper respuesta == "SI" || map toUpper respuesta == "NO"  -- Convierte la respuesta a mayúsculas y verifica si es "SI" o "NO"

pedirConfirmacionValida :: String -> IO Bool
pedirConfirmacionValida mensaje = do
    putStrLn mensaje
    respuesta <- getLine
    if confirmacionValida respuesta
        then return (map toUpper respuesta == "SI")
        else do
            putStrLn "Respuesta inválida. Por favor, ingrese 'SI' o 'NO'."
            pedirConfirmacionValida mensaje