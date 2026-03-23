module Estudiante where
--Información del estudiante, incluyendo su ID, nombre, hora de entrada y hora de salida
data Estudiante = Estudiante { 
    estudianteId :: String,
    nombre :: String,
    horaEntrada :: String,
    horaSalida :: Maybe String --En caso de  que no haya salido, se guardaría como Nothing
} deriving (Show, Read)