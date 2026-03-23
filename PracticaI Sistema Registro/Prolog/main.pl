% consult('main.pl'). Y iniciar.
:- use_module(library(lists)).
nombre_archivo('University.txt').

% Manejo del tiempo: se guarda como "HH:MM" y se convierte a minutos para calculos
hora_actual(Hora) :-
    get_time(Timestamp),
    stamp_date_time(Timestamp, DateTime, local),
    date_time_value(hour,   DateTime, H),
    date_time_value(minute, DateTime, M),
    rellenar(H, HS),
    rellenar(M, MS),
    atom_concat(HS, ':', Temp),
    atom_concat(Temp, MS, Hora).
% Agrega un cero delante si el número es menor a 10: 8 → '08', 22 → '22'
rellenar(N, Texto) :-
    (N < 10
    ->  atom_concat('0', N, Texto)
    ;   atom_number(Texto, N)
    ).
% Convierte "HH:MM" a minutos totales para facilitar el cálculo de diferencias
convertir_minutos(Hora, Minutos) :-
    atom_string(Hora, Str),
    split_string(Str, ":", "", [HS, MS]),
    number_string(H, HS),
    number_string(M, MS),
    Minutos is H * 60 + M.
% Calcula la diferencia en minutos entre dos horas
% Si la diferencia es negativa, asume que la salida fue al día siguiente
diferencia_minutos(Entrada, Salida, Diferencia) :-
    convertir_minutos(Entrada, ME),
    convertir_minutos(Salida,  MS),
    D is MS - ME,
    (D < 0 -> Diferencia is D + 1440 ; Diferencia = D).
% Convierte minutos a texto legible: 90 → "1 hora y 30 minutos"
minutos_a_texto(Minutos, Texto) :-
    H is Minutos // 60,
    M is Minutos mod 60,
    (H =:= 1 -> TH = '1 hora'   ; format(atom(TH), '~w horas',   [H])),
    (M =:= 1 -> TM = '1 minuto' ; format(atom(TM), '~w minutos', [M])),
    format(atom(Texto), '~w y ~w', [TH, TM]).

calcular_tiempo(Entrada, sin_salida, Texto) :- !,
    hora_actual(Actual),
    diferencia_minutos(Entrada, Actual, D),
    minutos_a_texto(D, DT),
    format(atom(Texto),
        'El estudiante no ha salido. Lleva hasta la hora actual ~w en la universidad.', [DT]).
calcular_tiempo(Entrada, Salida, Texto) :-
    diferencia_minutos(Entrada, Salida, D),
    minutos_a_texto(D, DT),
    format(atom(Texto), 'El estudiante estuvo ~w en la universidad.', [DT]).

% PARA EL MANEJO DE ARCHIVO:
verificar_archivo :-
    nombre_archivo(Archivo),
    (exists_file(Archivo)
    ->  format('Archivo ~w cargado.~n', [Archivo])
    ;   open(Archivo, write, S), close(S),
        format('Archivo ~w creado.~n', [Archivo])
    ).

% Lee los valores separados por comas, linea por linea y construye la lista de terminos estudiante(...)
cargar_estudiantes(Lista) :-
    nombre_archivo(Archivo),
    (exists_file(Archivo)
    ->  open(Archivo, read, Stream),
        leer_lineas(Stream, Lista),
        close(Stream)
    ;   Lista = []
    ).

% Lee una linea, si es fin o vacia termina, si no convierte y sigue
leer_lineas(Stream, Lista) :-
    read_line_to_string(Stream, Linea),
    (   Linea == end_of_file
    ->  Lista = []
    ;   Linea == ""
    ->  Lista = []
    ;   string_concat("", Linea, L2),  
        split_string(L2, ",", "", Partes),  % divide la linea en partes usando la coma como separador
        length(Partes, N),     % verifica que tenga exactamente 4 partes (ID, Nombre, Entrada, Salida)
        (N =:= 4
        ->  Partes = [IDS, NomS, EntS, SalS],           % convierte cada parte a atomos
            atom_string(ID,     IDS),
            atom_string(Nombre, NomS),
            atom_string(Ent,    EntS),
            atom_string(SalA,   SalS),
            (SalA == sin_salida -> Sal = sin_salida ; Sal = SalA),
            Est = estudiante(ID, Nombre, Ent, Sal),
            leer_lineas(Stream, Resto),
            Lista = [Est | Resto]               % linea bien formada: agregar a la lista y seguir leyendo los estudiantes
        ;   leer_lineas(Stream, Lista)  % linea malformada: ignorar
        )
    ).

% Escribe la lista completa en el CSV
guardar_estudiantes(Lista) :-
    nombre_archivo(Archivo),
    open(Archivo, write, Stream),
    escribir_lineas(Stream, Lista),
    close(Stream),
    writeln('Datos guardados correctamente.').
% Recorre la lista escribiendo cada estudiante como una línea de la forma "ID,Nombre,Entrada,Salida"
escribir_lineas(_, []).
escribir_lineas(Stream, [estudiante(ID, Nombre, Ent, Sal) | Resto]) :-
    format(Stream, '~w,~w,~w,~w~n', [ID, Nombre, Ent, Sal]),
    escribir_lineas(Stream, Resto).

% PARA BUSCAR ESTUDIANTES EN LA LISTA EN MEMORIA

% Busca el primer estudiante con ese ID que esté DENTRO (sin hora de salida)
% member recorre la lista uno a uno; el ! detiene la búsqueda al encontrar el primero
buscar_visita_abierta(ID, Lista, Estudiante) :-
    member(Estudiante, Lista),
    Estudiante = estudiante(ID, _, _, sin_salida), !.

% Devuelve TODAS las visitas de un ID sin importar si tienen hora de salida o no
buscar_todas_visitas(ID, Lista, Visitas) :-
    include([E]>>(E = estudiante(ID, _, _, _)), Lista, Visitas).

buscar_ultima_visita(ID, Lista, Estudiante) :-
    buscar_todas_visitas(ID, Lista, Visitas),
    Visitas \= [],
    last(Visitas, Estudiante).

% Agrega un estudiante al FINAL de la lista y guarda el archivo actualizado
agregar_estudiante(Nuevo, ListaActual, ListaNueva) :-
    append(ListaActual, [Nuevo], ListaNueva),
    guardar_estudiantes(ListaNueva).

% Reemplaza la visita abierta del estudiante con los datos actualizados
actualizar_estudiante(Actualizado, ListaActual, ListaNueva) :-
    Actualizado = estudiante(ID, _, _, _),
    maplist(reemplazar(ID, Actualizado), ListaActual, ListaNueva),
    guardar_estudiantes(ListaNueva).

% Si el elemento tiene el mismo ID y no tiene salida: lo reemplaza sino lo deja igual
reemplazar(ID, Actualizado, Original, Resultado) :-
    (Original = estudiante(ID, _, _, sin_salida)
    ->  Resultado = Actualizado
    ;   Resultado = Original
    ).

eliminar_todo([]) :-
    guardar_estudiantes([]),
    writeln('Todos los registros han sido eliminados.').

% PARA VALIDAR ENTRADAS DEL USUARIO

% el ID debe ser no vacío y contener solo dígitos
id_valido(ID) :-
    ID \= '',
    atom_chars(ID, Chars),
    Chars \= [],
    maplist([C]>>(char_type(C, digit)), Chars).

pedir_id_valido(ID) :-
    writeln('Ingrese la identificación del estudiante (solo numeros):'),
    read_line_to_string(user_input, Str),
    atom_string(IDAtom, Str),
    (id_valido(IDAtom)
    ->  ID = IDAtom
    ;   writeln('Identificacion invalida. Solo se permiten numeros.'),
        pedir_id_valido(ID)
    ).

% el nombre debe ser no vacío
nombre_valido(Nombre) :-
    Nombre \= '',
    atom_length(Nombre, Largo),
    Largo > 0.

pedir_nombre_valido(Nombre) :-
    writeln('Ingrese el nombre del estudiante:'),
    read_line_to_string(user_input, Str),
    atom_string(NombreAtom, Str),
    (nombre_valido(NombreAtom)
    ->  Nombre = NombreAtom
    ;   writeln('Nombre inválido. No puede estar vacio.'),
        pedir_nombre_valido(Nombre)
    ).

% Muestra un mensaje y espera SI o NO; devuelve true o false
pedir_confirmacion(Mensaje, Bool) :-
    writeln(Mensaje),
    read_line_to_string(user_input, Str),
    upcase_atom(Str, Resp),
    (Resp == 'SI' -> Bool = true
    ;Resp == 'NO' -> Bool = false
    ;(writeln('Respuesta invalida. Ingrese SI o NO.'),
      pedir_confirmacion(Mensaje, Bool))
    ).

% PARA VISUALIZAR LOS DATOS

separador :- writeln('------------------------------------------------------------').

%  Para alinear columnas en las tablas del menú
pad_derecha(Texto, Ancho, Resultado) :-
    atom_length(Texto, Largo),
    Espacios is max(0, Ancho - Largo),
    length(ListaEsp, Espacios),
    maplist(=(' '), ListaEsp),
    atom_chars(Relleno, ListaEsp),
    atom_concat(Texto, Relleno, Resultado).

% Convierte sin_salida a texto legible 'Aun dentro'; si ya salió muestra la hora
mostrar_salida(sin_salida, 'Aun dentro') :- !.
mostrar_salida(Hora, Hora).

mostrar_fila(estudiante(ID, Nombre, Entrada, Salida)) :- !,
    (Salida = sin_salida -> Estado = 'Dentro' ; Estado = 'Salio'),
    mostrar_salida(Salida, SalidaTexto),
    pad_derecha(ID,          10, C1),
    pad_derecha(Nombre,      40, C2),
    pad_derecha(Entrada,     10, C3),
    pad_derecha(SalidaTexto, 10, C4),
    pad_derecha(Estado,      10, C5),
    format('~w| ~w| ~w| ~w| ~w~n', [C1, C2, C3, C4, C5]).

mostrar_visita(N, estudiante(_, _, Entrada, Salida)) :- !,
    calcular_tiempo(Entrada, Salida, Tiempo),
    mostrar_salida(Salida, SalidaTexto),
    pad_derecha(N,           8,  C1),
    pad_derecha(Entrada,     10, C2),
    pad_derecha(SalidaTexto, 10, C3),
    format(' ~w | ~w | ~w | ~w~n', [C1, C2, C3, Tiempo]).

% PARA LOS MENUS INDIVIDUALES
% Registra la entrada de un estudiante. Si ya tiene una visita abierta: pregunta si desea cerrarla y abrir una nueva.Si no: registra la entrada directamente
menu_check_in(ListaActual, ListaNueva) :-
    writeln('\n=== CHECK IN ==='),
    pedir_id_valido(ID),
    pedir_nombre_valido(Nombre),
    (buscar_visita_abierta(ID, ListaActual, EstudianteAbierto)
    ->  writeln('Detectamos que este estudiante no tiene registro de salida.'),
        pedir_confirmacion('Desea cerrarlo con la hora actual y registrar nueva entrada? (SI/NO)', Ok),
        (Ok == true
        ->  hora_actual(HoraCierre),
            EstudianteAbierto = estudiante(ID, NombreViejo, EntradaVieja, _),
            EstudianteCerrado = estudiante(ID, NombreViejo, EntradaVieja, HoraCierre),
            actualizar_estudiante(EstudianteCerrado, ListaActual, ListaConSalida),
            format('Salida registrada automaticamente. Hora de salida: ~w~n', [HoraCierre]),
            hora_actual(HoraEntrada),
            Nuevo = estudiante(ID, Nombre, HoraEntrada, sin_salida),
            agregar_estudiante(Nuevo, ListaConSalida, ListaNueva),
            format('Nueva entrada registrada. Hora de entrada: ~w~n', [HoraEntrada])
        ;   writeln('Check in cancelado.'),
            ListaNueva = ListaActual
        )
    ;   hora_actual(HoraEntrada),
        Nuevo = estudiante(ID, Nombre, HoraEntrada, sin_salida),
        agregar_estudiante(Nuevo, ListaActual, ListaNueva),
        format('Check in registrado exitosamente. Hora de entrada: ~w~n', [HoraEntrada])
    ).

% Registra la salida de un estudiante buscando su visita abierta por ID
menu_check_out(ListaActual, ListaNueva) :-
    writeln('\n=== CHECK OUT ==='),
    pedir_id_valido(ID),
    (buscar_visita_abierta(ID, ListaActual, Encontrado)
    ->  Encontrado = estudiante(_, Nombre, Entrada, _),
        writeln('\nEstudiante encontrado:'),
        format('   Nombre: ~w~n',         [Nombre]),
        format('   Hora de entrada: ~w~n', [Entrada]),
        pedir_confirmacion('Desea registrar la salida? (SI/NO)', Ok),
        (Ok == true
        ->  hora_actual(HoraSalida),
            Actualizado = estudiante(ID, Nombre, Entrada, HoraSalida),
            actualizar_estudiante(Actualizado, ListaActual, ListaNueva),
            format('Check out registrado. Hora de salida: ~w~n', [HoraSalida])
        ;   writeln('Check out cancelado.'),
            ListaNueva = ListaActual
        )
    ;   writeln('No se encontro una visita activa para este estudiante.'),
        ListaNueva = ListaActual
    ).

% Muestra todas las visitas de un estudiante por ID en formato de tabla
menu_buscar_por_id(ListaActual) :-
    writeln('\n=== BUSCAR POR ID ==='),
    pedir_id_valido(ID),
    buscar_todas_visitas(ID, ListaActual, Visitas),
    (Visitas = []
    ->  writeln('No se encontraron visitas para esta identificación.')
    ;   Visitas = [Primera | _],
        Primera = estudiante(_, NombreEst, _, _),
        format('~nEstudiante: ~w  | ID: ~w~n', [NombreEst, ID]),
        separador,
        format('~w ~w ~w ~w~n',
            ['Visita  |', 'Entrada   |', 'Salida    |', 'Tiempo']),
        separador,
        mostrar_visitas_numeradas(1, Visitas)
    ).

mostrar_visitas_numeradas(_, []) :- !.
mostrar_visitas_numeradas(N, [H | T]) :-
    atom_number(NAtom, N),
    mostrar_visita(NAtom, H),
    N1 is N + 1,
    mostrar_visitas_numeradas(N1, T).

% Muestra el tiempo de permanencia de la ÚLTIMA visita de un estudiante
menu_calcular_tiempo(ListaActual) :-
    writeln('\n=== CALCULAR TIEMPO DE PERMANENCIA ==='),
    pedir_id_valido(ID),
    (buscar_ultima_visita(ID, ListaActual, Estudiante)
    ->  Estudiante = estudiante(_, Nombre, Entrada, Salida),
        calcular_tiempo(Entrada, Salida, Tiempo),
        writeln('\nInformacion del estudiante:'),
        separador,
        format('Nombre  : ~w~n', [Nombre]),
        format('ID      : ~w~n', [ID]),
        format('Entrada : ~w~n', [Entrada]),
        mostrar_salida(Salida, SalidaTexto),
        format('Salida  : ~w~n', [SalidaTexto]),
        separador,
        format('Resultado: ~w~n', [Tiempo])
    ;   writeln('No se encontraron visitas para esta identificacion.')
    ).

% Muestra todos los registros en memoria en formato de tabla
menu_listar_estudiantes([]) :- !,
    writeln('\n=== LISTAR ESTUDIANTES REGISTRADOS ==='),
    writeln('No hay estudiantes registrados.').
menu_listar_estudiantes(ListaActual) :-
    writeln('\n=== LISTAR ESTUDIANTES REGISTRADOS ==='),
    format('~w ~w ~w ~w ~w~n',
        ['ID        |', 'Nombre                                   |',
         'Entrada   |', 'Salida    |', 'Estado']),
    separador,
    forall(member(E, ListaActual), mostrar_fila(E)),
    separador,
    length(ListaActual, Total),
    format('Total de registros: ~w~n', [Total]).

% Elimina todos los registros previa confirmación del usuario
menu_borrar_registros(ListaActual, ListaNueva) :-
    writeln('\n=== ELIMINAR TODOS LOS REGISTROS ==='),
    (ListaActual = []
    ->  writeln('No hay registros para eliminar.'),
        ListaNueva = ListaActual
    ;   length(ListaActual, Total),
        format('Actualmente hay ~w registro(s) en el sistema.~n', [Total]),
        writeln('ADVERTENCIA: Esta accion eliminara todos los registros permanentemente.'),
        pedir_confirmacion('Esta seguro que desea continuar? (SI/NO)', Ok),
        (Ok == true
        ->  eliminar_todo(ListaNueva)
        ;   writeln('Operacion cancelada. No se elimino ningun registro.'),
            ListaNueva = ListaActual
        )
    ).

% MOSTRAR EL MENU PRINCIPAL Y LAS OPCIONES

menu_principal(ListaActual) :-
    writeln('================================================='),
    writeln('                 MENU PRINCIPAL                 '),
    writeln('================================================='),
    writeln('1. Registrar entrada (CHECK IN)'),
    writeln('2. Registrar salida (CHECK OUT)'),
    writeln('3. Buscar estudiante por ID'),
    writeln('4. Calcular tiempo de permanencia'),
    writeln('5. Listar todos los estudiantes'),
    writeln('6. Eliminar todos los registros'),
    writeln('0. Salir'),
    writeln('================================================='),
    writeln('Seleccione una opcion:'),
    read_line_to_string(user_input, Opcion),
    procesar_opcion(Opcion, ListaActual).

procesar_opcion("1", ListaActual) :- !,
    menu_check_in(ListaActual, ListaNueva),
    menu_principal(ListaNueva).

procesar_opcion("2", ListaActual) :- !,
    menu_check_out(ListaActual, ListaNueva),
    menu_principal(ListaNueva).

procesar_opcion("3", ListaActual) :- !,
    menu_buscar_por_id(ListaActual),
    menu_principal(ListaActual).

procesar_opcion("4", ListaActual) :- !,
    menu_calcular_tiempo(ListaActual),
    menu_principal(ListaActual).

procesar_opcion("5", ListaActual) :- !,
    menu_listar_estudiantes(ListaActual),
    menu_principal(ListaActual).

procesar_opcion("6", ListaActual) :- !,
    menu_borrar_registros(ListaActual, ListaNueva),
    menu_principal(ListaNueva).

procesar_opcion("0", _) :- !,
    writeln('Gracias por usar el sistema. Hasta luego!').

procesar_opcion(_, ListaActual) :-
    writeln('Opcion no valida. Intente de nuevo.'),
    menu_principal(ListaActual).

% Esto es como el main en Haskell
iniciar :-
    writeln('================================================='),
    writeln('   SISTEMA DE REGISTRO DE ENTRADAS Y SALIDAS   '),
    writeln('================================================='),
    verificar_archivo,
    cargar_estudiantes(Lista),
    length(Lista, Total),
    format('Bienvenido al sistema.~n'),
    format('Se cargaron ~w registro(s) en memoria.~n', [Total]),
    menu_principal(Lista), !.
iniciar.
