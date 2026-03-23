module GestionEstudiantes where
import Data.List (find)  --Para buscar un estudiante por su ID en la lista de estudiantes
import Estudiante
import GestorArchivo
import CalculoTiempo

buscarVisitaAbierta :: String -> [Estudiante] -> Maybe Estudiante --Recibe un ID y una lista de estudiantes, devuelve el estudiante con ese ID que no tenga hora de salida (es decir, que aún esté en la universidad)
buscarVisitaAbierta idBuscado estudiantes = find (\e -> estudianteId e == idBuscado && horaSalida e == Nothing) estudiantes

buscarTodasVisitas :: String -> [Estudiante] -> [Estudiante] --Recibe un ID y una lista de estudiantes, devuelve todas las visitas (estudiantes) con ese ID, sin importar si tienen hora de salida o no
buscarTodasVisitas idBuscado estudiantes = filter (\e -> estudianteId e == idBuscado) estudiantes 

--Función para buscar la última visita de un estudiante por su ID, devolviendo el estudiante con la hora de entrada más reciente
buscarUltimaVisita :: String -> [Estudiante] -> Maybe Estudiante
buscarUltimaVisita idBuscado estudiantes =
    let visitas = buscarTodasVisitas idBuscado estudiantes
    in if null visitas
        then Nothing
        else Just (last visitas)

--Función para agregar una nueva visita de un estudiante
agregarEstudiante :: Estudiante -> [Estudiante] -> IO [Estudiante]
agregarEstudiante estudiante listaActual = do
    let nuevaLista = listaActual ++ [estudiante]
    guardarEstudiantes nuevaLista
    return nuevaLista
--Función para actualizar la hora de salida de un estudiante, buscando su última visita abierta (sin hora de salida) y actualizándola con la hora actual
actualizarEstudiante :: Estudiante -> [Estudiante] -> IO [Estudiante]
actualizarEstudiante estudianteActualizado listaActual = do
    let nuevaLista = map reemplazar listaActual
    guardarEstudiantes nuevaLista
    return nuevaLista
  where
    reemplazar e =                                                
        if estudianteId e == estudianteId estudianteActualizado ----Si el Id del estudiante en la lista coincide con el ID del estudiante actualizado y no tiene hora de salida
            && horaSalida e == Nothing              -- se reemplaza por el estudiante actualizado (con la hora de salida actualizada),
            then estudianteActualizado              --de lo contrario se mantiene el mismo estudiante en la lista
            else e              

--Función para eliminar todos los registros de estudiantes, guardando una lista vacía en el archivo de texto
eliminarTodo :: IO [Estudiante]
eliminarTodo = do
    guardarEstudiantes []   --Guarda una lista vacía en el archivo, eliminando todos los registros anteriores
    putStrLn "Todos los registros han sido eliminados."
    return []      --devuelve una lista vacía para actualizar la lista de estudiantes en memoria después de eliminar todo