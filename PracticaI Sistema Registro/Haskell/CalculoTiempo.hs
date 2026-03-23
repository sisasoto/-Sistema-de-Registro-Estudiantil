module CalculoTiempo where

import Data.Time (getZonedTime, zonedTimeToLocalTime)  --Obtener la hora local, la zona horaria y extraer solo la hora
import Data.Time.LocalTime (localTimeOfDay, todHour, todMin)  --Para extrar las horas y minutos de la hora de entrada y salida
--Obtener la hora actual en formato "HH:MM"
horaActual :: IO String
horaActual = do
    tiempo <- getZonedTime --Obtiene la hora actual con zona horaria
    let hora = localTimeOfDay (zonedTimeToLocalTime tiempo)    --Convierte el tiempo a hora local y extrae solo la hora
    return (formatearHora (todHour hora) (todMin hora))  --Formatea la hora en formato "HH:MM"

--Función para obtener la hora en formato "HH:MM"
formatearHora :: Int -> Int-> String
formatearHora hora minuto = rellenar hora ++ ":" ++ rellenar minuto
    where
        rellenar n = if n < 10 then "0" ++ show n else show n  --En caso de que sea una hora 8 o un minuto 5, se le agrega un 0 al inicio para mantener el formato "HH:MM"  
    

convertirMinutos :: String -> Int
convertirMinutos hora = 
    let (h,m) = break (== ':') hora                  --separa la hora y los minutos utilizando el carácter ':' como delimitador 5:30 -> h = "5", m = ":30"
    in (read h :: Int) * 60 + (read (tail m) :: Int) --Convierte la hora en minutos totales para facilitar el cálculo de la diferencia entre horas

--Calcular la diferencia entre dos horas en minutos, considerando el caso en que la hora de salida sea al día siguiente
diferenciaMinutos :: String -> String -> Int
diferenciaMinutos horaEntrada horaSalida = 
    let diferencia = convertirMinutos horaSalida - convertirMinutos horaEntrada
    in if diferencia < 0 
        then diferencia + 24*60 -- Si la diferencia es negativa, se asume que el estudiante salió al día siguiente, por lo que se suma 1440 minutos (24 horas)
        else diferencia

--Función para convertir los minutos en horas y minutos
minutosATexto :: Int -> String
minutosATexto minutos = 
    let horas = div minutos 60
        minutosRestantes = mod minutos 60
        textoHoras = if horas == 1 then "1 hora" else show horas ++ " horas"
        textoMinutos = if minutosRestantes == 1 then "1 minuto" else (show minutosRestantes) ++ " minutos"
    in textoHoras ++ " y " ++ textoMinutos

--Funcion para calcular el tiempo del estudiante en la universidad (caso en que haya hora de salido y no)
calcularTiempo:: String -> Maybe String ->  IO String
calcularTiempo horaEntrada Nothing = do               --Si no hay hora de salida, se calcula el tiempo desde la hora de entrada hasta la hora actual
    actual <- horaActual                              --Obtener la hora actual para calcular el tiempo que lleva el estudiante en la universidad
    let diferencia = diferenciaMinutos horaEntrada actual  --llama a la funcion diferenciaMinutos para calcular la diferencia entre la hora de entrada y la hora actual
    return ("El estudiante  no ha salido. Lleva hasta la hora actual " ++ minutosATexto diferencia ++ " en la universidad.")  --convierte la dif de minutos en texto de horas y minutos

calcularTiempo horaEntrada (Just actual) = do        --Si hay hora de salida, se calcula el tiempo desde la hora de entrada hasta la hora de salida
    let diferencia = diferenciaMinutos horaEntrada actual
    return ("El estudiante estuvo " ++ minutosATexto diferencia ++ " en la universidad.")