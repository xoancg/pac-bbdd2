-- USUARIO SYSTEM --

-- Habilitamos la creación de usuarios locales
-- Fuente: http://www.dba-oracle.com/t_ora_65096_create_user_12c_without_c_prefix.htm
ALTER SESSION SET "_ORACLE_SCRIPT" = true;

-- Habilitamos el visionado de mensajes por consola mediante el paquete DBMS_OUTPUT
-- Fuente: https://docs.oracle.com/database/121/ARPLS/d_output.htm
SET SERVEROUTPUT ON;

-- Creamos un TABLESPACE exclusivo para almacenar los datos de la PAC
-- Ruta por defecto: C:\app\XCG\product\18.0.0\dbhomeXE\database\pacdatafile.dbf
-- Fuente: https://programacion.net/articulo/estructuras_de_oracle_89/2
CREATE TABLESPACE pactablespace
                  DATAFILE 'pacdatafile.dbf' SIZE 10M;
                  
-- Creamos un usuario nuevo exclusivo para la PAC con permisos de sistema
CREATE USER pacuser IDENTIFIED BY root
            DEFAULT TABLESPACE pactablespace;
GRANT ALL PRIVILEGES TO pacuser;

--------------------------------------------------------------------------------
-- USUARIO PACUSER --
-- Nos conectamos con el usuario PACUSER y lo comprobamos
SHOW USER;

-- EJERCICIO 1. Creación de tablas

CREATE TABLE alumnos (
             dni varchar (11),
             nombre varchar (20),
             apellido varchar (20),
             password varchar (20)
);

CREATE TABLE profesores (
             dni varchar (11),
             nombre varchar (20),
             apellido varchar (20),
             password varchar (20)
);

-- EJERCICIO 1.1 Creación de usuario con permisos de sólo conexión
ALTER SESSION SET "_ORACLE_SCRIPT" = true;
CREATE USER Miguel IDENTIFIED BY root
            DEFAULT TABLESPACE pactablespace;
GRANT CREATE SESSION TO Miguel;

-- EJERCICIO 1.2 Creación de usuario con permisos de conexión y edición
-- y eliminación de tablas
CREATE USER Marta
            IDENTIFIED BY root
            DEFAULT TABLESPACE pactablespace;
-- Permisos DDL
-- Fuente: https://www.ibm.com/support/knowledgecenter/es/SSTRGZ_11.3.3/com.ibm.cdcdoc.cdcfororacle.doc/concepts/privilegesfororacledbaandtsusers.html
GRANT
    CREATE SESSION,
    ALTER ANY TABLE,
    SELECT ANY TABLE,
    UPDATE ANY TABLE,
    DELETE ANY TABLE
TO marta;

-- EJERCICIO 1.3 Modificación permisos
GRANT SELECT ON PACUSER.alumnos TO Miguel;

-- USUARIO MARTA --
-- EJERCICIO 1.4 Edición y eliminación de datos en una tabla con MARTA
SHOW USER;


-- Comprobamos que tenemos acceso a las tablas creadas por PACUSER
-- Fuente: https://stackoverrun.com/es/q/464746
SELECT DISTINCT
    OWNER,
    object_name
FROM
    all_objects
WHERE
        object_type = 'TABLE'
    AND OWNER = 'PACUSER';

-- Consultamos los datos de la tabla
SELECT * FROM PACUSER.alumnos;

-- Editamos el nombre de una columna
ALTER TABLE PACUSER.alumnos
            RENAME COLUMN password
            TO clave;
-- Eliminamos una columna de la tabla
ALTER TABLE PACUSER.alumnos
            DROP (apellido);

-- USUARIO SYSTEM --
-- Consulta de privilegios desde usuario SYSTEM
SELECT
    grantee,
    PRIVILEGE
FROM
    dba_sys_privs
WHERE
    grantee = 'MARTA'
ORDER BY
    grantee;
    
--------------------------------------------------------------------------------
-- USUARIO PACUSER --
-- EJERCICIO 2

-- Habilitamos el visionado de mensajes por consola mediante el paquete DBMS_OUTPUT
-- Fuente: https://docs.oracle.com/database/121/ARPLS/d_output.htm
SET SERVEROUTPUT ON

-- EJERCICIO 2.1 Procedimiento para mostrar el año actual
CREATE OR REPLACE
    PROCEDURE anoactual
    AS
    BEGIN
        dbms_output.put_line('Estamos en el año ' ||
        TO_CHAR(SYSDATE, 'YYYY'));
    END anoactual;
 /   
-- Para ejecutar el procedimiento
SET SERVEROUTPUT ON;
EXECUTE anoactual;

--------------------------------------------------------------------------------
-- EJERCICIO 2.2 Procedimiento que sume 1 a una variable numérica cada vez que se ejecute

-- Creamos un paquete para almacenar el valor acumulado de la variable
-- Fuente: https://elbauldelprogramador.com/plsql-paquetes-packages/
CREATE PACKAGE acumulado
    IS valor INT;
END;

CREATE OR REPLACE
    PROCEDURE sumaruno (valor OUT INT)
    AS
    BEGIN
        valor := acumulado.valor;
        IF (valor IS NULL)
            THEN
                valor :=1;
            ELSE
                valor := valor + 1;
        END IF;
            acumulado.valor := valor;
            dbms_output.put_line('valor = ' || valor);
    END sumaruno;
    
-- Para ejecutar el procedimiento
SET SERVEROUTPUT ON;
DECLARE
    valor INT;
BEGIN
    sumaruno(valor);
END;    
/
-- Para resetear el valor de la variable, eliminamos el PACKAGE y lo volvemos a crear después
-- DROP PACKAGE acumulado;


--------------------------------------------------------------------------------
-- EJERCICIO 2.3 Procedimiento para concatenar dos cadenas en mayúsculas
CREATE OR REPLACE
    PROCEDURE concatenar (
              cadena1 IN VARCHAR2,
              cadena2 IN VARCHAR2            
            )
    AS
        resultado VARCHAR2(100);
    BEGIN
        resultado := (UPPER(cadena1) || UPPER(cadena2));
        dbms_output.put_line(resultado);
    END concatenar;
 /   
-- Para ejecutar el procedimiento
SET SERVEROUTPUT ON;

DECLARE
    cadena1 VARCHAR(50);
    cadena2 VARCHAR(50);
BEGIN
    cadena1 := 'cadena1';
    cadena2 := 'cadena2';
    concatenar(cadena1, cadena2);
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.4 Pedir código de empleado y muestre salario,
--               luego lo reduce en un tercio y lo muestra de nuevo
SET SERVEROUTPUT ON;
DECLARE
    empleado_no       pacuser.emp.emp_no%TYPE;
    empleado_salario  pacuser.emp.salario%TYPE;
BEGIN
    empleado_no := &codigo_empleado;
    SELECT
        salario
    INTO empleado_salario
    FROM
        pacuser.emp
    WHERE
        emp_no = empleado_no;

    dbms_output.put_line('Salario inicial: ' || empleado_salario);
    dbms_output.put_line('Salario reducido en un tercio: '
    || round(empleado_salario / 3, 0));
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.5 FUNCTION IF/ ELSIF. Mostrar día de la semana según un valor numérico
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION diasemana (
    numerodia SMALLINT
) RETURN VARCHAR2 AS
    dia VARCHAR2(30);
BEGIN
    IF numerodia = 1 THEN
        dia := 'lunes';
    ELSIF numerodia = 2 THEN
        dia := 'martes';
    ELSIF numerodia = 3 THEN
        dia := 'miércoles';
    ELSIF numerodia = 4 THEN
        dia := 'jueves';
    ELSIF numerodia = 5 THEN
        dia := 'viernes';
    ELSIF numerodia = 6 THEN
        dia := 'sábado';
    ELSIF numerodia = 7 THEN
        dia := 'domingo';
    ELSE
        dia:= 'no es un valor válido.';
    END IF;

    return(dia);
END;
/
-- Bloque para ejecutar la función
DECLARE
    numerodia SMALLINT;
BEGIN
    numerodia := &numerodia;
    dbms_output.put_line(numerodia || ' ' || diasemana(numerodia));
END;  
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.6 CASE. Mostrar día de la semana según un valor numérico
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION diasemanacase (
    numerodia SMALLINT
) RETURN VARCHAR2 AS
    dia VARCHAR2(30);
BEGIN
    CASE numerodia
        WHEN 1 THEN
            dia := 'lunes';
        WHEN 2 THEN
            dia := 'martes';
        WHEN 3 THEN
            dia := 'miércoles';
        WHEN 4 THEN
            dia := 'jueves';
        WHEN 5 THEN
            dia := 'viernes';
        WHEN 6 THEN
            dia := 'sábado';
        WHEN 7 THEN
            dia := 'domingo';
        ELSE
            dia := 'no es un valor válido.';
    END CASE;

    return(dia);
END;
/

-- Bloque para ejecutar la función
DECLARE
    numerodia SMALLINT;
BEGIN
    numerodia := &numerodia;
    dbms_output.put_line(numerodia
                         || ' '
                         || diasemanacase(numerodia));
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.7 CASE. Función que devuelva el mayor de tres números pasados por parámetro
-- Con estructura CASE
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION mayordetresCase (
    num1  SMALLINT,
    num2  SMALLINT,
    num3  SMALLINT
) RETURN VARCHAR2 AS
    mayor VARCHAR2(50);
BEGIN
    CASE
        WHEN
            num1 > num2
            AND num1 > num3
                THEN
                    mayor := num1;
        WHEN
            num2 > num1
            AND num2 > num3
                THEN
                    mayor := num2;
        WHEN
            num3 > num1
            AND num3 > num2
                THEN
                    mayor := num3;
    END CASE;

    return(mayor);
END;
/
-- Bloque para ejecutar la función
DECLARE
    num1  SMALLINT;
    num2  SMALLINT;
    num3  SMALLINT;
BEGIN
    num1 := &num1;
    num2 := &num2;
    num3 := &num3;
    dbms_output.put_line('El mayor de los tres números introducidos es: '
                         || mayordetresCase(num1, num2, num3));
END;

--------------------------------------------------------------------------------
-- EJERCICIO 2.7 CASE. Función que devuelva el mayor de tres números pasados por parámetro
-- Con estructura IF/ELSE
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION mayordetres (
    num1  SMALLINT,
    num2  SMALLINT,
    num3  SMALLINT
) RETURN VARCHAR2 AS
    mayor VARCHAR2(50);
BEGIN
    IF num1 > num2 THEN
        IF num1 > num3 THEN
            mayor := num1;
        ELSE
            mayor := num3;
        END IF;
    ELSE
        IF num2 > num3 THEN
            mayor := num2;
        ELSE
            mayor := num3;
        END IF;
    END IF;

    return(mayor);
END;
/

-- Bloque para ejecutar la función
DECLARE
    num1  SMALLINT;
    num2  SMALLINT;
    num3  SMALLINT;
BEGIN
    num1 := &num1;
    num2 := &num2;
    num3 := &num3;
    dbms_output.put_line('El mayor de los tres números introducidos es: '
                         || mayordetres(num1, num2, num3));
END; 
/

--------------------------------------------------------------------------------
-- EJERCICIO 2.8 Procedimiento que muestre la suma de los primeros n números enteros
-- Se deduce que debemos trabajar con enteros positivos
-- Fuente: https://elbauldelprogramador.com/plsql-estructuras-basicas-de-control/
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE sumarenteros (
    n IN SMALLINT
) AS
    i     SMALLINT;
    suma  SMALLINT;
BEGIN
    i := 0;
    suma := i;
    FOR i IN 0..n LOOP
        suma := suma + i;
    END LOOP;
    dbms_output.put_line('La suma de los primeros '
                         || n
                         || ' números enteros es: '
                         || suma);
END;
/

-- Bloque para ejecutar el procedimiento anterior
DECLARE
    n SMALLINT;
BEGIN
  n := &numero;
  sumarenteros(n);
END;
/
-- Bloque para ejecutar el procedimiento anterior con parámetro fijo
EXECUTE sumarenteros(50);

--------------------------------------------------------------------------------
-- EJERCICIO 2.9 Función que devuelve 1 si el número es primo y 0 si no lo es
-- Un número natural 'n' es primo si y sólo si tiene dos divisores positivos: 1 y él mismo
-- El número entero 'b' es divisor del número entero 'a' cuando (a / b) = 0
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION numeroprimo (
    n IN SMALLINT
) RETURN SMALLINT AS
    divisor   SMALLINT := 1;
    contador  SMALLINT := 0;
    primo     SMALLINT;
BEGIN
    -- Si 'n' es un número positivo mayor que 1, entramos a comprobar si es primo
    IF n > 1 THEN   
        -- Dividimos 'n' entre todos los números enteros positivos desde 1 a 'n'
        FOR divisor IN 1..n LOOP
            IF MOD(n, divisor) = 0 THEN
                /*Si el resto de la división es igual a cero, incrementamos
                el contador en una unidad*/
                contador := contador + 1;
            END IF;
        END LOOP;
    
    -- Si encontramos más de dos divisores, 'n' NO es un número primo
    IF contador > 2 THEN
        primo := 0;
    
    -- En caso contrario, tendremos dos divisores
    ELSE
        primo := 1;
    END IF;
    
    -- Si 'n' es 1 (sólo tiene un divisor) o negativo, nunca será un número primo
    ELSE
        primo := 0;
    END IF;

    return(primo);
END; 
/

-- Bloque para ejecutar el procedimiento anterior
DECLARE
    n      SMALLINT;
    primo  SMALLINT;
BEGIN
    n := &numero;
    primo := numeroprimo(n);
    IF primo = 0 THEN
        dbms_output.put_line('El número '
                             || n
                             || ' NO es primo.');
    ELSE
        dbms_output.put_line('El número '
                             || n
                             || ' SÃ? es primo.');
    END IF;

END;

--------------------------------------------------------------------------------
-- EJERCICIO 2.10 Sumar los primeros 'm' números primos, empezando por 1
-- Un número natural 'n' es primo si y sólo si tiene dos divisores positivos: 1 y él mismo
-- El número entero 'b' es divisor del número entero 'a' cuando (a / b) = 0
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION sumarprimos (
    m IN SMALLINT
) RETURN SMALLINT AS

    primo           SMALLINT;
    cantidadprimos  SMALLINT := 0;
    numero          SMALLINT := 1; /* Empezamos desde 1*/
    suma            SMALLINT := 0;
BEGIN
    /*En la última ejecucio de WHILE, cantidadprimos será igual a 'm'
    porque la condición del bucle se evalúa DESPUÃ‰S de haberse ejecutado*/
    WHILE ( cantidadprimos < m ) LOOP
        -- Comprobamos los números que son primos desde 1 hasta 'm'
        primo := numeroprimo(numero);
        
        -- Si 'numero' es primo, lo incorporamos a la suma y a la cantidad de primos
        IF primo = 1 THEN
            suma := suma + numero;
            cantidadprimos := cantidadprimos + 1;
        END IF;
        
        -- Si no es primo, continuamos el bucle con el siguiente número
        numero := numero + 1;
    
    -- Salimos del bucle después de haberse ejecutado con cantidadprimos = m
    END LOOP;

    return(suma);
END;
/

-- Bloque para ejecutar el procedimiento anterior
DECLARE
    m     SMALLINT;
    suma  SMALLINT;
BEGIN
    m := &numero;
    suma := sumarprimos(m);
    dbms_output.put_line('La suma de los primeros '
                         || m
                         || ' números primos es: '
                         || suma);
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 3.1 Consultar nombre y localidad de todos los departamentos
-- Fuente: https://elbauldelprogramador.com/plsql-cursores/
SET SERVEROUTPUT ON;

DECLARE
    CURSOR nombrelocalidad IS
    -- Consultamos los datos en la tabla
        SELECT
        dnombrebre,
        lugar
    FROM
        pacuser.dept;
    
    -- Almacenamos los datos en variables locales del mismo tipo de dato
        nombre     pacuser.dept.dnombrebre%TYPE;
        localidad  pacuser.dept.lugar%TYPE;
BEGIN
    -- Abrimos el cursor
        OPEN nombrelocalidad;
    -- Imprimimos los datos recuperamos los datos a medida que recorremos cada fila
        LOOP
        FETCH nombrelocalidad INTO
            nombre,
            localidad;
        EXIT WHEN nombrelocalidad%notfound;
        dbms_output.put_line('Departamento '
                             || nombre
                             || ', con localidad en '
                             || localidad);
    END LOOP;
    -- Cerramos el cursor
        CLOSE nombrelocalidad;
END;
/
--------------------------------------------------------------------------------
-- EJERCICIO 3.2 Consultar apellidos de los trabajadores de VENTAS. Numerar líneas
SET SERVEROUTPUT ON;

DECLARE
    CURSOR empleadosventas IS
    SELECT
        apellido
    FROM
        pacuser.emp
    WHERE
        dept_no = 30;

    apellido  pacuser.emp.apellido%TYPE;
    linea     SMALLINT;
BEGIN
    -- Inicializamos en 1 la variable para enumerar las líneas a mostrar
        linea := 1;
    -- Abrimos el cursor
        OPEN empleadosventas;
    -- Ejecutamos la recuperación de datos línea por línea e imprimimos los resultados
        LOOP
        FETCH empleadosventas INTO apellido;
        EXIT WHEN empleadosventas%notfound;
        dbms_output.put_line(linea
                             || ' '
                             || apellido);
        linea := linea + 1;
    END LOOP;
    -- Cerramos el cursor
        CLOSE empleadosventas;
END;

--------------------------------------------------------------------------------
-- EJERCICIO 3.3.a) FOR. Consultar apellidos. Parámetro: código departamento.
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE apellidosfor (
    dept_cod IN NUMBER
) IS

    CURSOR apellidos IS
    SELECT
        apellido
    FROM
        pacuser.emp
    WHERE
        dept_no = dept_cod;

    apellido               pacuser.emp.apellido%TYPE;
    departamento           pacuser.dept.dnombrebre%TYPE;
    linea                  SMALLINT := 0;
    contador_empleado      SMALLINT := 0;
    contador_departamento  SMALLINT := 0;
    nodatafound_empleado     EXCEPTION;
    nodatafound_departamento EXCEPTION;
BEGIN 
    -- Almacenamos el número de departamentos y de apellidos que genera la consulta
    SELECT
        COUNT(*)
    INTO contador_empleado
    FROM
        pacuser.emp
    WHERE
        dept_no = dept_cod;

    SELECT
        COUNT(*)
    INTO contador_departamento
    FROM
        pacuser.dept
    WHERE
        dept_no = dept_cod;
    
        /* Si el departamento no existe en la base de datos, se informa de ello 
           al usuario vía EXCEPTION y se detiene la ejecución del programa */
    IF contador_departamento = 0 THEN
        RAISE nodatafound_departamento;
    END IF;

    -- Si existe el departamento, se recopilan e imprimen los apellidos de los empleados
    FOR i IN apellidos LOOP
        apellido := i.apellido;
        linea := linea + 1;
        dbms_output.put_line(linea
                             || ' '
                             || apellido);
    END LOOP;
    
    /* En caso de que no exista ningún registro en el departamento consultado,
        se informa de ello al usuario vía EXCEPTION y se detiene la ejecución */
    IF contador_empleado = 0 THEN
        RAISE nodatafound_empleado;
    END IF;

exception
    -- Caso: existe el departamento pero éste no contiene ningún registro
    WHEN nodatafound_empleado THEN
        SELECT
                dnombrebre
            INTO departamento
            FROM
                pacuser.dept
            WHERE
                dept_no = dept_cod;
        dbms_output.put_line('No existe ningún empleado en el departamento de ' || departamento);
        
    -- Caso: no existe ningún departamento con el código consultado
    WHEN nodatafound_departamento THEN
dbms_output.put_line('No existe ningún departamento con el código: ' || dept_cod);
END;
/

-- Código para ejecutar el procedimiento anterior
DECLARE
dept_cod NUMBER;

BEGIN
    dept_cod := &codigo_departamento;
    apellidosfor(dept_cod);
END;
/
--------------------------------------------------------------------------------
-- EJERCICIO 3.3.b) SIN FOR. Consultar apellidos. Parámetro: código departamento.
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE apellidosfetch (
    dept_cod IN NUMBER
) IS

    CURSOR apellidos IS
    SELECT
        apellido
    FROM
        pacuser.emp
    WHERE
        dept_no = dept_cod;

    apellido               pacuser.emp.apellido%TYPE;
    departamento           pacuser.dept.dnombrebre%TYPE;
    linea                  SMALLINT := 0;
    contador_empleado      SMALLINT := 0;
    contador_departamento  SMALLINT := 0;
    nodatafound_empleado     EXCEPTION;
    nodatafound_departamento EXCEPTION;
BEGIN 
    -- Almacenamos el número de departamentos y de apellidos que genera la consulta
    SELECT
        COUNT(*)
    INTO contador_empleado
    FROM
        pacuser.emp
    WHERE
        dept_no = dept_cod;

    SELECT
        COUNT(*)
    INTO contador_departamento
    FROM
        pacuser.dept
    WHERE
        dept_no = dept_cod;
    
        /* Si el departamento no existe en la base de datos, se informa de ello 
           al usuario vía EXCEPTION y se detiene la ejecución del programa */
    IF contador_departamento = 0 THEN
        RAISE nodatafound_departamento;
    END IF;

    -- Si existe el departamento, se recopilan e imprimen los apellidos de los empleados
    -- Abrimos el cursor
    OPEN apellidos;
     -- Ejecutamos la recuperación de datos línea por línea e imprimimos los resultados
    LOOP
        FETCH apellidos INTO apellido;
        EXIT WHEN apellidos%notfound;
            linea := linea + 1;
            dbms_output.put_line(linea
                                 || ' '
                                 || apellido);
    END LOOP;
    -- Cerramos el cursor
    CLOSE apellidos;
    
    /* En caso de que no exista ningún registro en el departamento consultado,
        se informa de ello al usuario vía EXCEPTION y se detiene la ejecución */
    IF contador_empleado = 0 THEN
        RAISE nodatafound_empleado;
    END IF;

exception
    -- Caso: existe el departamento pero éste no contiene ningún registro
    WHEN nodatafound_empleado THEN
        SELECT
                dnombrebre
            INTO departamento
            FROM
                pacuser.dept
            WHERE
                dept_no = dept_cod;
        dbms_output.put_line('No existe ningún empleado en el departamento de ' || departamento);
        
    -- Caso: no existe ningún departamento con el código consultado
    WHEN nodatafound_departamento THEN
dbms_output.put_line('No existe ningún departamento con el código: ' || dept_cod);
END;
/

-- Código para ejecutar el procedimiento anterior
DECLARE
dept_cod NUMBER;

BEGIN
    dept_cod := &codigo_departamento;
    apellidosfetch(dept_cod);
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 3.4 Calcular cuántos empleados cobran comisión. Sin usar COUNT().
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION comisionistas (
    dept_cod IN NUMBER
) RETURN SMALLINT AS
    -- Declaración del cursor
        CURSOR comisionistas_cursor IS
    -- Consultamos todos los registros de la tabla EMP
    -- Condiciones: código departamento y comisión mayor que cero
        SELECT
        *
    FROM
        pacuser.emp
    WHERE
            dept_no = dept_cod
        AND comision > 0;

    dept_no                 pacuser.emp.dept_no%TYPE;
    apellido                pacuser.emp.apellido%TYPE;
    contador                SMALLINT := 0;
    max_dept                SMALLINT;

BEGIN 
    -- Consultamos el código de departamento más alto que devuelve la siguiente consulta
        SELECT
        MAX(dept_no)
    INTO comisionistas_cursor
    FROM
        pacuser.emp
    WHERE
        dept_no = dept_cod;

    -- Si no hay ninguno, la función devolverá un valor nulo
        IF max_dept IS NULL THEN
        contador := max_dept;
    ELSE 
    -- Si el valor es distinto de nulo, la consulta devuelve el código del departamento
    -- Recorremos los registros de empleados que cobren comisión > 0 en dicho departamento
                FOR i IN comisionistas_cursor LOOP
            apellido := i.apellido;
            contador := contador + 1;
        END LOOP;
    END IF;

    return(contador);
END;
/
-- Bloque para ejecutar la función anterior
DECLARE
    dept_cod   NUMBER;
    resultado  SMALLINT;
BEGIN
    dept_cod := &codigo_departamento;
    resultado := comisionistas(dept_cod);
    CASE
        WHEN resultado = 0 THEN
            dbms_output.put_line('No existe ningún empleado que cobre comisión en el departamento consultado.');
        
        WHEN resultado > 0 THEN
            dbms_output.put_line('Hay '
                                 || resultado
                                 || ' empleados que cobran comisión en el departamento consultado.');
        ELSE
            dbms_output.put_line('No existe ningún departamento con el código seleccionado o no tiene empleados.');
    END CASE;

END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 4.1 Histórico cambio salario empleados en tabla EMP
-- Fuente: https://elbauldelprogramador.com/plsql-disparadores-o-triggers/

-- Tabla AUDITAEMPLE
CREATE TABLE auditaemple (
    id_cambio           NUMBER(5),
    descripcion_cambio  VARCHAR2(100),
    fecha_cambio        DATE,
    PRIMARY KEY ( id_cambio )
);
/
-- Trigger AUDITASUELDO
CREATE OR REPLACE TRIGGER auditasueldo AFTER
    UPDATE OF salario ON pacuser.emp
    FOR EACH ROW
DECLARE
    cambio pacuser.auditaemple.id_cambio%TYPE;
BEGIN
    -- Comprobamos el valor actual más alto de id_cambio para incrementarlo en 1
        SELECT
        ( MAX(id_cambio) )
    INTO cambio
    FROM
        pacuser.auditaemple;
    -- Si todavía no existen cambios, se inicilizará id_cambio a partir de 1
        IF cambio IS NULL THEN
        cambio := 1;
    -- Si ya existen cambios anteriores, se incrementará id_cambio en 1
        ELSE
        cambio := cambio + 1;
    END IF;
    -- Registramos los cambios realizados en la tabla AUDITAEMPLE
        INSERT INTO pacuser.auditaemple (
        id_cambio,
        descripcion_cambio,
        fecha_cambio
    ) VALUES (
        cambio,
        'El salario del empleado '
        || :old.emp_no
        || ' antes era de '
        || :old.salario
        || ' y, ahora, será '
        || :new.salario,
        sysdate
    );

END;
/
--DROP TABLE pacuser.auditaemple;

-- Bloque para ejecutar el Trigger AUDITASUELDO
SET SERVEROUTPUT ON;
DECLARE
    codiempleado  pacuser.emp.emp_no%TYPE;
    sueldonuevo   pacuser.emp.salario%TYPE;
BEGIN
    codiempleado := &codigo_empleado;
    sueldonuevo := &sueldo_nuevo;
    UPDATE pacuser.emp
    SET
        pacuser.emp.salario = sueldonuevo
    WHERE
        pacuser.emp.emp_no = codiempleado;

END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 4.2 Histórico alta nuevos empleados
SET SERVEROUTPUT ON;

-- Trigger AUDITAEMPLE
CREATE OR REPLACE TRIGGER auditaemple AFTER
    INSERT ON pacuser.emp
    FOR EACH ROW
DECLARE
    cambio pacuser.auditaemple.id_cambio%TYPE;
BEGIN
    -- Comprobamos el valor actual más alto de id_cambio para incrementarlo en 1
        SELECT
        ( MAX(id_cambio) )
    INTO cambio
    FROM
        pacuser.auditaemple;
    -- Si todavía no existen cambios, se inicilizará id_cambio a partir de 1
        IF cambio IS NULL THEN
        cambio := 1;
    -- Si ya existen cambios anteriores, se incrementará id_cambio en 1
        ELSE
        cambio := cambio + 1;
    END IF;
    -- Registramos los cambios realizados en la tabla AUDITAEMPLE
        INSERT INTO pacuser.auditaemple (
        id_cambio,
        descripcion_cambio,
        fecha_cambio
    ) VALUES (
        cambio,
        'Nuevo empleado con código '
        || :new.emp_no,
        sysdate
    );

END;
/

-- Bloque para ejecutar el Trigger AUDITAEMPLE. Datos fijos en bloque anónimo
BEGIN
    -- Insertamos los datos del nuevo empleado en la tabla EMP
    INSERT INTO pacuser.emp (
        emp_no,
        apellido,
        oficio,
        jefe,
        fecha_alta,
        salario,
        comision,
        dept_no
    ) VALUES (
        8002,
        'SALGADO',
        'EMPLEADO',
        7788,
        sysdate,
        350001,
        10001,
        20
    );
END;
/

--------------------------------------------------------------------------------
-- EJERCICIO 4.3 Histórico cambio salario empleados sólo si el sueldo sube más de 10 %
SET SERVEROUTPUT ON;

-- Trigger AUDITAEMPLE2
CREATE OR REPLACE TRIGGER auditaemple2 AFTER
    UPDATE OF salario ON pacuser.emp
    FOR EACH ROW
DECLARE
    cambio pacuser.auditaemple.id_cambio%TYPE;
BEGIN
    -- Comprobamos el valor actual más alto de id_cambio para incrementarlo en 1
        SELECT
        ( MAX(id_cambio) )
    INTO cambio
    FROM
        pacuser.auditaemple;
    -- Si todavía no existen cambios, se inicilizará id_cambio a partir de 1
        IF cambio IS NULL THEN
        cambio := 1;
    -- Si ya existen cambios anteriores, se incrementará id_cambio en 1
        ELSE
        cambio := cambio + 1;
    END IF;
    
    -- Verificamos si el nuevo salario es mayor que el antiguo en más de un 10 %
    IF :new.salario > 1.1 * :old.salario THEN        
        -- Si la condición se cumple, registramos los cambios realizados
            INSERT INTO pacuser.auditaemple (
            id_cambio,
            descripcion_cambio,
            fecha_cambio
        ) VALUES (
            cambio,
            'El salario del empleado '
            || :old.emp_no
            || ' antes era de '
            || :old.salario
            || ' y, ahora, será '
            || :new.salario,
            sysdate
        );
    END IF;
END;
/

-- Bloque para ejecutar el Trigger AUDITAEMPLE2
SET SERVEROUTPUT ON;
DECLARE
    codiempleado  pacuser.emp.emp_no%TYPE;
    sueldonuevo   pacuser.emp.salario%TYPE;
BEGIN
    codiempleado := &codigo_empleado;
    sueldonuevo := &sueldo_nuevo;
    UPDATE pacuser.emp
    SET
        pacuser.emp.salario = sueldonuevo
    WHERE
        pacuser.emp.emp_no = codiempleado;

END;
/

--DROP TRIGGER auditasueldo;

-- EJERCICIO 4.4 Trigger para INSERT/UPDATE de CANTIDAD en la tabla DETALLE
-- Fuente: https://elbauldelprogramador.com/plsql-excepciones/
SET SERVEROUTPUT ON;

-- Trigger VERIFICA_UNIDADES
CREATE OR REPLACE TRIGGER verifica_unidades BEFORE
    -- El trigger se ejecutará al añadir registros o al actualizar el campo cantidad
    INSERT OR UPDATE OF cantidad ON pacuser.detalle
    FOR EACH ROW
BEGIN
    -- Lanzaremos una excepción con un mensaje cuando el usuario introduzca cantidad > 999
    IF :new.cantidad > 999 THEN
        raise_application_error(-20001, 'No se puede registrar un valor mayor que 999 unidades');
    ELSE
    -- Si cantidad <= 999, el proceso continúa y se actualiza también el campo importe
        :new.importe := :new.cantidad * :new.precio_venda;
    END IF;
END;
/

-- Bloque para ejecutar el Trigger VERIFICA_UNIDADES con INSERT
SET SERVEROUTPUT ON;
DECLARE
    com_num       pacuser.detalle.com_num%TYPE := 605;
    detalle_num   pacuser.detalle.detalle_num%TYPE := 10;
    prod_num      pacuser.detalle.prod_num%TYPE := 101860;
    precio_venda  pacuser.detalle.precio_venda%TYPE := 100;
    cantidad      pacuser.detalle.cantidad%TYPE;
BEGIN
    cantidad := &nueva_cantidad;
    
    INSERT INTO pacuser.detalle (
        com_num,
        detalle_num,
        prod_num,
        precio_venda,
        cantidad
    ) VALUES
        (
            com_num,
            detalle_num,
            prod_num,
            precio_venda,
            cantidad
        );

END;
/

-- Bloque para ejecutar el Trigger VERIFICA_UNIDADES con UPDATE
DECLARE
    nueva_cantidad  pacuser.detalle.cantidad%TYPE;
    comnum         pacuser.detalle.com_num%TYPE := 604;
    prodnum        pacuser.detalle.prod_num%TYPE := 100861;
BEGIN
    nueva_cantidad := &nueva_cantidad;
    UPDATE pacuser.detalle
    SET
        cantidad = nueva_cantidad
    WHERE
            prod_num = prodnum
        AND com_num = comnum;

END;
/

--DROP TABLE DETALLE;