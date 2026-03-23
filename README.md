<div align="center">

# 🎓 Sistema de Registro Estudiantil
### Práctica I — ST0244 Lenguajes de Programación
**Universidad EAFIT — Escuela de Ciencias Aplicadas e Ingeniería**

![Haskell](https://img.shields.io/badge/Haskell-5D4F85?style=for-the-badge&logo=haskell&logoColor=white)
![Prolog](https://img.shields.io/badge/Prolog-E61B23?style=for-the-badge&logo=swi-prolog&logoColor=white)
![Universidad](https://img.shields.io/badge/EAFIT-003087?style=for-the-badge&logoColor=white)

</div>

---

## 👤 Información General

<table>
  <tr><td><b>📚 Materia</b></td><td>ST0244 — Lenguajes de Programación</td></tr>
  <tr><td><b>👨‍🏫 Docente</b></td><td>Alexander Narváez Berrío</td></tr>
  <tr><td><b>👨‍💻 Estudiante</b></td><td>Simón Santiago Soto Berrío</td></tr>
  <tr><td><b>📝 Tipo</b></td><td>Práctica individual</td></tr>
  <tr><td><b>📅 Fecha de entrega</b></td><td>23 de marzo de 2026</td></tr>
  <tr><td><b>💯 Valor</b></td><td>15% de la nota final</td></tr>
</table>

---

## 📖 Descripción del Proyecto

Este proyecto implementa un **Sistema de Registro Estudiantil** que permite gestionar la entrada y salida de estudiantes en una universidad. El sistema fue desarrollado en **dos versiones** que resuelven el mismo problema desde paradigmas de programación completamente diferentes:

<table>
  <tr>
    <th>🔷 Versión A</th>
    <th>🔶 Versión B</th>
  </tr>
  <tr>
    <td align="center"><b>Haskell</b><br/>Paradigma Funcional</td>
    <td align="center"><b>Prolog</b><br/>Paradigma Lógico</td>
  </tr>
</table>

Ambas versiones comparten el mismo comportamiento funcional: registrar entradas y salidas de estudiantes, buscar por ID, calcular tiempos de permanencia y persistir la información en un archivo `University.txt`.

---

## 🗂️ Estructura del Repositorio

```
PracticaI Sistema Registro/
│
├── 📁 Haskell/
│   ├── 📄 Main.hs                  ← Punto de entrada y menú principal
│   ├── 📄 Estudiante.hs            ← Definición del tipo Estudiante
│   ├── 📄 Verificacion.hs          ← Validación de datos del usuario
│   ├── 📄 CalculoTiempo.hs         ← Manejo y cálculo de tiempos
│   ├── 📄 GestorArchivo.hs         ← Lectura y escritura de University.txt
│   ├── 📄 GestionEstudiantes.hs    ← Operaciones sobre la lista
│   ├── 📄 Menus.hs                 ← Lógica de cada opción del menú
│   └── 📄 University.txt           ← Archivo de datos persistentes
│
├── 📁 Prolog/
│   ├── 📄 main.pl                  ← Programa completo en un solo archivo
│   └── 📄 University.txt           ← Archivo de datos persistentes (CSV)
│
└── 📄 README.md
```

---

## ⚙️ Funcionalidades del Sistema

Ambas versiones implementan las siguientes opciones:

<table>
  <tr>
    <th>Opción</th>
    <th>Funcionalidad</th>
    <th>Descripción</th>
  </tr>
  <tr>
    <td align="center"><b>1</b></td>
    <td>✅ Check In</td>
    <td>Registra la entrada del estudiante con hora automática del sistema</td>
  </tr>
  <tr>
    <td align="center"><b>2</b></td>
    <td>🚪 Check Out</td>
    <td>Registra la salida del estudiante con hora automática del sistema</td>
  </tr>
  <tr>
    <td align="center"><b>3</b></td>
    <td>🔍 Buscar por ID</td>
    <td>Muestra todas las visitas del estudiante con tiempos de permanencia</td>
  </tr>
  <tr>
    <td align="center"><b>4</b></td>
    <td>⏱️ Calcular Tiempo</td>
    <td>Calcula el tiempo de permanencia de la visita más reciente</td>
  </tr>
  <tr>
    <td align="center"><b>5</b></td>
    <td>📋 Listar Estudiantes</td>
    <td>Muestra todos los registros en una tabla alineada con estado</td>
  </tr>
  <tr>
    <td align="center"><b>6</b></td>
    <td>🗑️ Eliminar Registros</td>
    <td>Elimina todos los registros previa confirmación del usuario</td>
  </tr>
  <tr>
    <td align="center"><b>0</b></td>
    <td>🚫 Salir</td>
    <td>Cierra el programa</td>
  </tr>
</table>

---

## ✨ Características Adicionales

Estas características van más allá de los requisitos mínimos de la práctica:

### 🛡️ Validación de Datos
Todos los datos ingresados por el usuario son validados antes de procesarse:

<table>
  <tr>
    <th>Campo</th>
    <th>Validación</th>
  </tr>
  <tr>
    <td>ID del estudiante</td>
    <td>Solo dígitos, no puede estar vacío</td>
  </tr>
  <tr>
    <td>Nombre del estudiante</td>
    <td>Solo letras y espacios, no puede estar vacío</td>
  </tr>
  <tr>
    <td>Confirmaciones</td>
    <td>Solo acepta SI o NO (sin importar mayúsculas o minúsculas)</td>
  </tr>
</table>

Si el dato es inválido, el programa muestra un mensaje de error y vuelve a solicitarlo hasta recibir un valor correcto.

### 🕐 Hora Automática del Sistema
- Tanto la hora de **entrada** como la de **salida** se toman automáticamente del reloj del sistema
- Formato militar de 24 horas (HH:MM) para evitar ambigüedad entre AM y PM
- Manejo de cruce de medianoche: si la salida es al día siguiente, el cálculo sigue siendo correcto

### 📚 Historial Completo de Visitas
- Un estudiante puede entrar y salir **múltiples veces** en el día
- Cada visita queda registrada como una línea independiente
- La opción *Buscar por ID* muestra el historial completo con el tiempo de cada visita

### 🔄 Gestión Inteligente de Check In
- Si un estudiante intenta hacer Check In pero ya tiene una visita abierta, el sistema lo detecta
- Ofrece **cerrar automáticamente** la visita anterior con la hora actual antes de registrar la nueva entrada
- Así no se pierde información de ninguna visita

### 💾 Persistencia Automática
- Al iniciar, carga automáticamente todos los registros del archivo `University.txt`
- Después de cada Check In o Check Out, **guarda automáticamente** la lista actualizada
- Si el archivo no existe al iniciar, lo **crea automáticamente**

---

## 🔷 Versión Haskell — Paradigma Funcional

### ▶️ ¿Cómo se ejecuta?

**Opción 1 — Desde GHCi (para pruebas):**
```bash
cd Haskell
ghci Main.hs
main
```

**Opción 2 — Compilado (recomendado para presentación):**
```bash
cd Haskell
ghc Main.hs -o SistemaRegistro
.\SistemaRegistro        # Windows
./SistemaRegistro        # Mac/Linux
```

### 📄 Formato del Archivo `University.txt`

Cada línea representa una visita serializada con el formato nativo de Haskell (`Show`/`Read`):

```
Estudiante {estudianteId = "12345", nombre = "Juan Perez", horaEntrada = "08:30", horaSalida = Just "10:45"}
Estudiante {estudianteId = "67890", nombre = "Maria Lopez", horaEntrada = "09:00", horaSalida = Nothing}
Estudiante {estudianteId = "12345", nombre = "Juan Perez", horaEntrada = "13:00", horaSalida = Nothing}
```

> `horaSalida = Nothing` indica que el estudiante aún está dentro de la universidad.

---

## 🔶 Versión Prolog — Paradigma Lógico

### ▶️ ¿Cómo se ejecuta?

```bash
cd Prolog
swipl
```
Luego dentro de SWI-Prolog:
```prolog
?- consult('main.pl').
?- iniciar.
```

### 📄 Formato del Archivo `University.txt`

Formato CSV separado por comas. Cada línea representa una visita:

```
12345,Juan Perez,08:30,10:45
67890,Maria Lopez,09:00,sin_salida
12345,Juan Perez,13:00,sin_salida
```

> `sin_salida` indica que el estudiante aún está dentro de la universidad.

---

## 📝 Notas de Implementación

- **Hora del sistema:** Se usa el reloj del sistema en ambas versiones. En Haskell con `Data.Time` y en Prolog con `get_time` y `stamp_date_time`.
- **Cruce de medianoche:** Ambas versiones manejan el caso donde la hora de salida es menor a la de entrada sumando 1440 minutos (24 horas).
- **Múltiples visitas:** Un mismo estudiante puede tener varios registros — uno por cada visita del día.
- **Persistencia:** Cada cambio (Check In / Check Out / Borrar) se guarda inmediatamente en `University.txt`.
- **Formato de archivo diferente:** Haskell usa el formato `Show`/`Read` nativo del lenguaje, mientras que Prolog usa CSV separado por comas. Cada versión lee y escribe su propio formato.

---

<div align="center">

*ST0244 — Lenguajes de Programación — EAFIT University — 2026*

</div>
