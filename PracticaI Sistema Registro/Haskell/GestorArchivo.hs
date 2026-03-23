module GestorArchivo where
import System.IO
import System.Directory (doesFileExist)  --Para verificar si el archivo existe antes de intentar leerlo
import Estudiante

nombreArchivo :: String
nombreArchivo = "University.txt"
--función para crear o cargar el arcivo de texto donde se guardarán los datos de los estudiantes
verificarArchivo :: IO ()
verificarArchivo = do
    existe <- doesFileExist nombreArchivo
    if existe
        then putStrLn "Archivo University.txt cargado."
        else do
            writeFile nombreArchivo ""
            putStrLn "Archivo University.txt creado."

--Función para cargar los datos de los estudiantes desde el archivo de texto, devolviendo una lista de estudiantes
cargarEstudiantes :: IO [Estudiante]
cargarEstudiantes = do
    existe <- doesFileExist nombreArchivo
    if not existe
        then return []
        else do
            contenido <- readFile nombreArchivo
            let lineas = filter (not . null) (lines contenido)
            let estudiantes = map read lineas
            length estudiantes `seq` return estudiantes

--Función para guardar la lista de estudiantes en el archivo de texto
guardarEstudiantes :: [Estudiante] -> IO ()
guardarEstudiantes estudiantes = do
    handle <- openFile nombreArchivo WriteMode
    let contenido = unlines (map show estudiantes)
    hPutStr handle contenido
    hClose handle
    putStrLn "Datos guardados correctamente."