# Proyecto PAC BBDD2

## Descripción del Proyecto PAC BBDD2
Este proyecto abarca diversos aspectos de la gestión de bases de datos para fines administrativos y educativos, centrándose en el manejo de expedientes de alumnos y profesores, junto con funcionalidades de auditoría.

## Tablas
1. **alumnos**: Contiene registros de estudiantes, incluyendo sus detalles personales y académicos.
2. **profesores**: Almacena información sobre los profesores, las asignaturas impartidas y sus respectivos departamentos.
3. **emp**: Contiene los registros de los empleados del personal administrativo, incluyendo puestos de trabajo e información de contacto.
4. **dept**: Información departamental relacionada con la gestión y sus jerarquías.
5. **auditaemple**: Registros de auditoría para las acciones de los empleados y cambios en los registros de los departamentos.

## Usuarios y Permisos
- **pacuser**: Acceso básico para visualizar y gestionar usuarios.
- **Miguel**: Acceso total a todos los datos, con capacidad de edición en todas las tablas.
- **Marta**: Acceso restringido; solo puede visualizar las tablas sin realizar cambios.

## Ejercicio 1: Gestión de Usuarios
Este ejercicio consiste en la creación, actualización y eliminación de usuarios en el sistema, garantizando al mismo tiempo el manejo adecuado de los permisos.

## Ejercicio 2: Procedimientos y Funciones
Se han implementado los siguientes procedimientos y funciones:
1. `anoactual`: Obtiene el año actual.
2. `sumaruno`: Suma uno a un número dado.
3. `concatenar`: Concatena dos cadenas de texto.
4. `sumarenteros`: Suma dos números enteros.
5. `diasemana`: Devuelve el día de la semana para una fecha determinada.
6. `diasemanacase`: Una variante con la sentencia CASE para los días de la semana.
7. `mayordetres`: Encuentra el mayor de tres números.
8. `numeroprimo`: Comprueba si un número es primo.
9. `sumarprimos`: Suma todos los números primos hasta un límite dado.
10. `comisionistas`: Calcula la comisión de los agentes comerciales basada en los datos de ventas.

## Ejercicio 3: Variaciones de Cursores
Explora las siguientes variaciones de cursores para la recuperación de datos:
1. `nombrelocalidad`: Itera a través de las localidades.
2. `empleadosventas`: Obtiene los empleados relacionados con ventas.
3. `apellidosfor`: Recorre los apellidos de los alumnos mediante un bucle.
4. `apellidosfetch`: Obtiene los apellidos utilizando cursores.

## Ejercicio 4: Triggers de Auditoría
Para mantener la integridad de los datos, se han implementado estos disparadores (triggers):
1. `auditasueldo`: Audita los cambios en el salario de los empleados.
2. `auditaemple`: Supervisa los cambios en los registros de los empleados.
3. `auditaemple2`: Auditoría adicional para acciones específicas de los empleados.

## Instrucciones de Instalación
1. Clona el repositorio.
2. Asegúrate de tener configurada la base de datos y los ajustes necesarios.
3. Ejecuta los scripts de inicialización.

## Ejemplos de Uso
- Para crear un nuevo usuario: `CREATE USER 'nuevo_usuario'...`
- Obtener datos de alumnos: `SELECT * FROM alumnos;`

## Conceptos Clave
- Comprensión de tablas, relaciones y permisos de usuario.
- Conocimiento de procedimientos, funciones y triggers en la gestión del comportamiento de la base de datos.
