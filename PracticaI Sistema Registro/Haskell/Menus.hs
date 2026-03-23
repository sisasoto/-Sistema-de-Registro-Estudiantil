module Menus where

import Estudiante
import Verificacion
import CalculoTiempo
import GestorArchivo
import GestionEstudiantes

--Función para agregar espacios a la derecha de un texto, para alinear las columnas en la tabla de estudiantes registrados
padDerecha :: String -> Int -> String
padDerecha texto ancho =
    texto ++ replicate (max 0 (ancho - length texto)) ' '

--Función para mostrar la opción CHECK IN (registro de entrada de un estudiante)
menuCheckIn :: [Estudiante] -> IO [Estudiante]
menuCheckIn listaActual = do
    putStrLn "\n=== CHECK IN ==="
    idEstudiante <- pedirIdValido
    nombreEstudiante <- pedirNombreValido
    case buscarVisitaAbierta idEstudiante listaActual of
        Just estudianteAbierto -> do
            putStrLn "Detectamos que este estudiante no tiene registro de salida."
            confirmar <- pedirConfirmacionValida "¿Desea cerrarlo con la hora actual y registrar una nueva entrada? (SI/NO)"
            if confirmar
                then do
                    --Primero cierro la visita que no registró salida con la hora actual
                    hora <-horaActual
                    let estudianteCerrado = estudianteAbierto { horaSalida = Just hora } --Actualizo la hora de salida del estudiante encontrado con la hora actual
                    listaConSalida <- actualizarEstudiante estudianteCerrado listaActual --Actualizo la lista de estudiantes con el estudiante cerrado
                    putStrLn ("Salida registrada automáticamente para la visita anterior. Hora de salida: " ++ hora)
                    --Luego registro la nueva visita con la hora de entrada actual
                    horaEntrada <-horaActual
                    let nuevoEstudiante = Estudiante
                            { estudianteId = idEstudiante,
                              nombre       = nombreEstudiante,
                              horaEntrada  = horaEntrada,
                              horaSalida   = Nothing
                            }
                    listaActualizada <- agregarEstudiante nuevoEstudiante listaConSalida
                    putStrLn ("Nueva entrada registrada exitosamente. Hora de entrada: " ++ horaEntrada)
                    return listaActualizada
--En caso de que confirmación sea NO, se cancela el check in y se devuelve la lista sin cambios
                else do
                    putStrLn "Check in cancelado. No se registró ningún cambio."
                    return listaActual
        Nothing -> do    --En caso de que el estudiante si haya salido o no tenga registros
            hora <-horaActual
            let nuevoEstudiante = Estudiante
                    { estudianteId = idEstudiante,
                      nombre       = nombreEstudiante,
                      horaEntrada  = hora,
                      horaSalida   = Nothing
                    }
            listaActualizada <- agregarEstudiante nuevoEstudiante listaActual
            putStrLn ("Check in registrado exitosamente. Hora de entrada: " ++ hora)
            return listaActualizada

--Función para mostrar la opción CHECK OUT (registro de salida de un estudiante)
menuCheckOut :: [Estudiante] -> IO [Estudiante]
menuCheckOut listaActual = do
    putStrLn "\n=== CHECK OUT ==="
    idEstudiante <- pedirIdValido
    case buscarVisitaAbierta idEstudiante listaActual of
        Just estudianteEncontrado -> do
            --Mostramos los datos del estudiante encontrado
            putStrLn "\nEstudiante encontrado:"
            putStrLn ("   Nombre: " ++ nombre estudianteEncontrado)
            putStrLn ("   Hora de entrada: " ++ horaEntrada estudianteEncontrado)
            --Pedimos confirmación para registrar el check out
            confirmar <- pedirConfirmacionValida "¿Desea registrar la salida de este estudiante? (SI/NO)"
            if confirmar
                then do
                    hora <-horaActual
                    let estudianteActualizado = estudianteEncontrado { horaSalida = Just hora } --Actualizo la hora de salida del estudiante encontrado con la hora actual
                    listaActualizada <- actualizarEstudiante estudianteActualizado listaActual --Actualizo la lista de estudiantes con el estudiante cerrado
                    putStrLn ("Check out registrado exitosamente. Hora de salida: " ++ hora)
                    return listaActualizada
            else do
                    putStrLn "Check out cancelado. No se registró ningún cambio."
                    return listaActual
        Nothing -> do
            putStrLn "No se encontró una visita activa para este estudiante."
            return listaActual

--Función para el menú de buscarPorId, para mostrar todas las visitas de un estudiante
menuBuscarPorId :: [Estudiante] -> IO ()
menuBuscarPorId listaActual = do
    putStrLn "\n=== BUSCAR POR ID ==="
    idEstudiante <- pedirIdValido
    let visitas = buscarTodasVisitas idEstudiante listaActual
    if null visitas
        then putStrLn "No se encontraron visitas para esta identificación."
        else do
            let nombreEstudiante = nombre (head visitas) --Obtenemos el nombre del estudiante de la primera visita encontrada
            putStrLn ("\nEstudiante : " ++ nombreEstudiante ++ "  |  ID: " ++ idEstudiante)
            putStrLn (replicate 60 '-')
            putStrLn (padDerecha "Visita" 8 ++ "| " ++
                      padDerecha "Entrada" 10 ++ "| " ++
                      padDerecha "Salida" 10 ++ "| " ++
                      "Tiempo")
            putStrLn (replicate 60 '-')
            mapM_ mostrarVisita (zip [1..] visitas) --Mostramos cada visita con su número correspondiente   
--Función para mostrar los datos de las visitas
mostrarVisita :: (Int, Estudiante) -> IO ()
mostrarVisita (numero, estudiante) = do
    tiempo <- calcularTiempo (horaEntrada estudiante) (horaSalida estudiante)
    let col1 = padDerecha (show numero) 8
    let col2 = padDerecha (horaEntrada estudiante) 10
    let col3 = padDerecha (mostrarSalida (horaSalida estudiante)) 10
    putStrLn (" " ++ col1 ++ " | " ++col2 ++ " | " ++ col3 ++ " | " ++ tiempo)

--Función menú para calcularTiempo el tiempo de permanencia de la ultima visita de un estudiante
menuCalcularTiempo :: [Estudiante] -> IO ()
menuCalcularTiempo listaActual = do
    putStrLn "\n=== CALCULAR TIEMPO DE PERMANENCIA ==="
    idEstudiante <- pedirIdValido
    case buscarUltimaVisita idEstudiante listaActual of
        Nothing ->
            putStrLn "No se encontraron visitas para esta identificación."
        Just estudiante -> do
            tiempo <- calcularTiempo (horaEntrada estudiante) (horaSalida estudiante)
            putStrLn "\nInformacion del estudiante:"
            putStrLn (replicate 40 '-')
            putStrLn ("Nombre  : " ++ nombre estudiante)
            putStrLn ("ID      : " ++ estudianteId estudiante)
            putStrLn ("Entrada : " ++ horaEntrada estudiante)
            putStrLn ("Salida  : " ++ mostrarSalida (horaSalida estudiante))
            putStrLn (replicate 40 '-')
            putStrLn ("Resultado: " ++ tiempo)

--Función para mostrar la hora de salida
mostrarSalida :: Maybe String -> String
mostrarSalida Nothing    = "Aun dentro"
mostrarSalida (Just horaSal) = horaSal

--Menú para Mostrar todos los estudiantes registrados
menuListarEstudiantes :: [Estudiante] -> IO ()
menuListarEstudiantes listaActual = do
    putStrLn "\n=== LISTAR ESTUDIANTES REGISTRADOS ==="
    if null listaActual
        then putStrLn "No hay estudiantes registrados."
        else do

            putStrLn (padDerecha "ID" 10 ++ "| " ++
                      padDerecha "Nombre" 35 ++ "| " ++
                      padDerecha "Entrada" 10 ++ "| " ++
                      padDerecha "Salida" 10 ++ "| "++
                      padDerecha "Estado" 17)
            putStrLn (replicate 60 '-')
            mapM_ mostrarFila listaActual
            putStrLn (replicate 60 '-')
            putStrLn ("Total de registros: " ++ show (length listaActual))
--Función para mostrar cada fila de la tabla de estudiantes registrados
mostrarFila :: Estudiante -> IO ()
mostrarFila estudiante = do
    let estado = case horaSalida estudiante of
                    Just _ -> "Salió"
                    Nothing -> "Dentro"
    let salida = mostrarSalida (horaSalida estudiante)
    putStrLn (padDerecha (estudianteId estudiante) 10 ++ "| " ++
             padDerecha (nombre estudiante) 35 ++ "| " ++
             padDerecha (horaEntrada estudiante) 10 ++ "| " ++
             padDerecha salida 10 ++ "| "++
             padDerecha estado 10)

--Función para el menú para eliminar todos los registros de estudiantes
menuBorrarRegistros :: [Estudiante] -> IO [Estudiante]
menuBorrarRegistros listaActual = do
    putStrLn "\n=== ELIMINAR TODOS LOS REGISTROS ==="
    if null listaActual             --Si ya está vacía la lista, no preguntamos por confirmación y simplemente informamos que no hay registros para eliminar
        then do
            putStrLn "No hay registros para eliminar."
            return listaActual
        else do
            putStrLn ("Actualmente hay " ++ show (length listaActual) ++ " registro(s) en el sistema.") --Mostrar la cantidad de registros
            putStrLn "ADVERTENCIA: Esta accion eliminará todos los registros permanentemente."    
            confirmar <- pedirConfirmacionValida "¿Esta seguro que desea continuar?"
            if confirmar
                then eliminarTodo
                else do
                    putStrLn "Operación cancelada. No se eliminó ningún registro."
                    return listaActual