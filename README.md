# PAC BBDD2 Project

## Description of BBDD2 PAC Project
This project encompasses various aspects of database management for administrative and educational purposes, focusing on the handling of student and faculty records along with audit functionalities.

## Tables
1. **alumnos**: Contains records of students including their personal and academic details.
2. **profesores**: Stores information about professors, courses taught, and their respective departments.
3. **emp**: Holds employee records for administrative staff, including job roles and contact information.
4. **dept**: Departmental information related to management and their hierarchies.
5. **auditaemple**: Audit logs for employee actions and changes in department records.

## Users and Permissions
- **pacuser**: Basic access to view and manage users.
- **Miguel**: Full access to all data, with editing capabilities across all tables.
- **Marta**: Restricted access, can only view tables without making changes.

## Exercise 1: User Management
This exercise involves creating, updating, and deleting users within the system while ensuring proper permission handling.

## Exercise 2: Procedures and Functions
The following procedures and functions have been implemented:
1. `anoactual`: Retrieves the current year.
2. `sumaruno`: Adds one to a given number.
3. `concatenar`: Concatenates two strings.
4. `sumarenteros`: Sums two integers.
5. `diasemana`: Returns the day of the week for a given date.
6. `diasemanacase`: A CASE statement variant for days of the week.
7. `mayordetres`: Finds the largest of three numbers.
8. `numeroprimo`: Checks if a number is prime.
9. `sumarprimos`: Sums all prime numbers up to a given limit.
10. `comisionistas`: Calculates commission for sales agents based on sales data.

## Exercise 3: Cursor Variations
Explore the following cursor variations for data retrieval:
1. `nombrelocalidad`: Iterates through locations.
2. `empleadosventas`: Fetches employees related to sales.
3. `apellidosfor`: Loops through last names of students.
4. `apellidosfetch`: Fetches last names using cursors.

## Exercise 4: Audit Triggers
To maintain data integrity, these triggers have been implemented:
1. `auditasueldo`: Audits changes to employee salary.
2. `auditaemple`: Monitors changes to employee records.
3. `auditaemple2`: Additional audit for specific employee actions.

## Installation Instructions
1. Clone the repository.
2. Ensure you have the necessary database and configuration setup.
3. Run the initialization scripts.

## Usage Examples
- To create a new user: `CREATE USER 'new_user'...`
- Fetching data from alumnos: `SELECT * FROM alumnos;`

## Key Concepts
- Understanding of tables, relationships, and user permissions.
- Awareness of procedures, functions, and triggers in managing database behavior.