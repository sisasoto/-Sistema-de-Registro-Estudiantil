module Main where

import Estudiante
import GestorArchivo
import Menus

main :: IO ()
main = do


    putStrLn "================================================="
    putStrLn "    SISTEMA DE REGISTRO DE ENTRADAS Y SALIDAS    "
    putStrLn "================================================="
    verificarArchivo
    listaInicial <- cargarEstudiantes
    putStrLn "Bienvenido al sistema de registro de entradas y salidas de la universidad."
    putStrLn ("Se cargaron " ++ show (length listaInicial) ++ " registro(s) en memoria.")
    menuPrincipal listaInicial

menuPrincipal :: [Estudiante] -> IO ()
menuPrincipal listaActual = do
    putStrLn "================================================="
    putStrLn "                  MENÚ PRINCIPAL                  "
    putStrLn "================================================="
    putStrLn "1. Registrar entrada (CHECK IN)"
    putStrLn "2. Registrar salida (CHECK OUT)"
    putStrLn "3. Buscar estudiante por ID"
    putStrLn "4. Calcular tiempo de permanencia de un estudiante"
    putStrLn "5. Listar todos los estudiantes"
    putStrLn "6. Eliminar todos los registros"
    putStrLn "0. Salir"
    putStrLn "================================================="
    putStrLn "Seleccione una opción:"
    opcion <- getLine
    case opcion of
        "1" -> do
            listaActualizada <- menuCheckIn listaActual
            menuPrincipal listaActualizada
        "2" -> do
            listaActualizada <- menuCheckOut listaActual
            menuPrincipal listaActualizada
        "3" -> do
            menuBuscarPorId listaActual
            menuPrincipal listaActual
        "4" -> do
            menuCalcularTiempo listaActual
            menuPrincipal listaActual
        "5" -> do
            menuListarEstudiantes   listaActual
            menuPrincipal listaActual 
        "6" -> do
            listaActualizada <- menuBorrarRegistros listaActual
            menuPrincipal listaActualizada
        "0" -> putStrLn "Gracias por usar el sistema. ¡Hasta luego!"
        _   -> do
            putStrLn "Opción no válida. Por favor, seleccione una opción del menú."
            menuPrincipal listaActual