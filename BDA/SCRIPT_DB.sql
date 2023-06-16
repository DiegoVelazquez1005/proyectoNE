
SELECT name FROM v$database;
SELECT USER FROM dual;

/*
CREATE TABLE USUARIO (
    IDUSUARIO INT NOT NULL,
    NOMBRE VARCHAR(30) NOT NULL,
    APPATERNO VARCHAR(30) NOT NULL,
    APMATERNO VARCHAR(30) NULL,
    CONTRASENA VARCHAR(30) NOT NULL,
    CORREO VARCHAR(50) NOT NULL,
    CONSTRAINT PK_ID_USUARIO PRIMARY KEY (IDUSUARIO)
)
TABLESPACE USERS STORAGE (
    INITIAL 920K
    NEXT 920K
    PCTINCREASE 50
);

Considerando el analisis:

*/

CREATE TABLE USUARIO (
    IDUSUARIO INT GENERATED ALWAYS AS IDENTITY,
    NOMBRE VARCHAR(30) NOT NULL,
    APPATERNO VARCHAR(30) NOT NULL,
    APMATERNO VARCHAR(30) NULL,
    CONTRASENA VARCHAR(30) NOT NULL,
    CORREO VARCHAR(50) NOT NULL,
    CONSTRAINT PK_ID_USUARIO PRIMARY KEY (IDUSUARIO)
)
TABLESPACE USERS STORAGE (
    INITIAL 920K
    NEXT 920K
    PCTINCREASE 50
);

CREATE INDEX IDX_NOMBRE ON USUARIO (NOMBRE); --Consultas eficionetes por nombre y por correo
CREATE INDEX IDX_CORREO ON USUARIO (CORREO);

-- Alterar la definición de la tabla USUARIO para agregar las opciones de cálculo y almacenamiento
ALTER TABLE USUARIO
    PCTFREE 23
    PCTUSED 68
    INITRANS 1
    MAXTRANS 3;

/*
CREATE TABLE CATEGORIA (
    IDCATEGORIA INT NOT NULL,
    IDUSUARIO INT NOT NULL,
    NOMBRE VARCHAR(30) NOT NULL,
    FECHACREACION DATE NOT NULL,
    CONSTRAINT PK_ID_CATEGORIA PRIMARY KEY (IDCATEGORIA),
    CONSTRAINT FK_ID_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO)
);*/

CREATE TABLE CATEGORIA (
    IDCATEGORIA INT GENERATED ALWAYS AS IDENTITY,
    IDUSUARIO INT NOT NULL,
    NOMBRE VARCHAR(30) NOT NULL,
    FECHACREACION VARCHAR(30) NOT NULL,
    CONSTRAINT PK_ID_CATEGORIA PRIMARY KEY (IDCATEGORIA),
    CONSTRAINT FK_ID_USUARIO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO)
);

CREATE INDEX IDX_NOMBRE_CATEGORIA ON CATEGORIA (NOMBRE);

/*
CREATE TABLE NOTA (
    IDNOTA INT NOT NULL,
    CONTENIDO BLOB NOT NULL,
    TITULO VARCHAR(30) NOT NULL,
    FECHACREACION DATE NOT NULL,
    IDUSUARIO INT NOT NULL,
    IDCATEGORIA INT NOT NULL,
    CONSTRAINT PK_ID_NOTA PRIMARY KEY (IDNOTA),
    CONSTRAINT FK_ID_USUARIO_NOTA FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_ID_CATEGORIA FOREIGN KEY (IDCATEGORIA) REFERENCES CATEGORIA(IDCATEGORIA)
); */

CREATE TABLE NOTA (
    IDNOTA INT GENERATED ALWAYS AS IDENTITY,
    CONTENIDO VARCHAR(100) NOT NULL,
    CONTENIDO_BLOB BLOB NOT NULL,
    TITULO VARCHAR(30) NOT NULL,
    FECHACREACION VARCHAR(30) NOT NULL,
    IDUSUARIO INT NOT NULL,
    IDCATEGORIA INT NOT NULL,
    TIPOARCHIVO VARCHAR(20) NOT NULL,  
    CONSTRAINT PK_ID_NOTA PRIMARY KEY (IDNOTA),
    CONSTRAINT FK_ID_USUARIO_NOTA FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO),
    CONSTRAINT FK_ID_CATEGORIA FOREIGN KEY (IDCATEGORIA) REFERENCES CATEGORIA(IDCATEGORIA)
);

CREATE INDEX IDX_TITULO ON NOTA (TITULO);

/*CREATE TABLE COMPARTE (
    IDNOTA INT NOT NULL,
    IDUSUARIO INT NOT NULL,
    FECHA DATE NOT NULL,
    CONSTRAINT FK_ID_NOTA FOREIGN KEY (IDNOTA) REFERENCES NOTA(IDNOTA),
    CONSTRAINT FK_ID_COMPARTIDO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO) 
);*/

CREATE TABLE COMPARTE (
    IDNOTA INT NOT NULL,
    IDUSUARIO INT NOT NULL,
    FECHA VARCHAR(30) NOT NULL,
    CONSTRAINT FK_ID_NOTA FOREIGN KEY (IDNOTA) REFERENCES NOTA(IDNOTA),
    CONSTRAINT FK_ID_COMPARTIDO FOREIGN KEY (IDUSUARIO) REFERENCES USUARIO(IDUSUARIO) 
);

CREATE BITMAP INDEX IDX_COMPARTE_IDNOTA ON COMPARTE (IDNOTA);
CREATE INDEX IDX_COMPARTE_IDUSUARIO ON COMPARTE (IDUSUARIO);

/*
En el caso de la columna IDUSUARIO en la tabla COMPARTE, probablemente sea una columna con una alta cardinalidad, 
ya que es una clave externa que hace referencia a la tabla USUARIO, donde es probable que haya muchos usuarios distintos.
 En este escenario, utilizar un índice de tipo BITMAP en esa columna puede no ser eficiente ni proporcionar un beneficio 
 significativo en términos de rendimiento.

En su lugar, puedes utilizar un índice B-tree tradicional en la columna IDUSUARIO. Esto proporcionará 
una búsqueda eficiente para consultas que involucren la columna IDUSUARIO. 
*/

-------------------------------------------------------------
--- VERIFICANDO DONDE PERTENECEN CADA TABLA:
SELECT table_name, tablespace_name
FROM dba_tables
WHERE table_name = 'USUARIO'; 

SELECT table_name, tablespace_name
FROM dba_tables
WHERE table_name = 'CATEGORIA';

SELECT table_name, tablespace_name
FROM dba_tables
WHERE table_name = 'NOTA'; 

SELECT table_name, tablespace_name
FROM dba_tables
WHERE table_name = 'COMPARTE'; 

-- CONSULTA PRA SABER EL TAMAÑO DE TABLESPACE QUE SE UTILIZAN EN LA BD:
SELECT file_name, tablespace_name, BYTES
FROM DBA_DATA_FILES
WHERE tablespace_name = (SELECT tablespace_name
                         FROM dba_tables
                         WHERE table_name = 'USUARIO');

SELECT file_name, tablespace_name, BYTES
FROM DBA_DATA_FILES
WHERE tablespace_name IN (SELECT tablespace_name
                          FROM dba_tables
                          WHERE table_name IN ('CATEGORIA', 'NOTA', 'COMPARTE'));

--SE UTILIZAN DOS TABLESPACE, USER Y SYSTEM.
-- USERS ACTUALMENTE TIENE 5242880 BYTES QUE SON 5 MB suficientes para almacenar usuarios.
-- SYSTEM TIENE 1394606080 BYTES QUE CORRESPONDE 1.2 GB APROX


-- Se creara una nueva TABLESPACE enfocada al user_data;
-- Especialmente para las tablas NOTA, COMPARTE, Y CATEGORIA:

CREATE TABLESPACE USER_DATA
DATAFILE 'C:\oracleXE\oradata\XE\USER_DATA.DBF' SIZE 6G
AUTOEXTEND ON
NEXT 600K;

-- Moving:
/*
ALTER TABLE COMPARTE MOVE TABLESPACE USER_DATA;
ALTER TABLE CATEGORIA MOVE TABLESPACE USER_DATA;
ALTER TABLE NOTA MOVE TABLESPACE USER_DATA;
*/

SELECT INDEX_NAME
FROM DBA_INDEXES
WHERE TABLE_NAME = 'COMPARTE';

--IDX_COMPARTE_IDNOTA
--IDX_COMPARTE_IDUSUARIO

ALTER TABLE COMPARTE MOVE TABLESPACE USER_DATA;
ALTER INDEX IDX_COMPARTE_IDNOTA REBUILD TABLESPACE USER_DATA;
ALTER INDEX IDX_COMPARTE_IDUSUARIO REBUILD TABLESPACE USER_DATA;

SELECT INDEX_NAME
FROM DBA_INDEXES
WHERE TABLE_NAME = 'CATEGORIA';

--PK_ID_CATEGORIA
--IDX_NOMBRE_CATEGORIA

ALTER TABLE CATEGORIA MOVE TABLESPACE USER_DATA;
ALTER INDEX PK_ID_CATEGORIA REBUILD TABLESPACE USER_DATA;
ALTER INDEX IDX_NOMBRE_CATEGORIA REBUILD TABLESPACE USER_DATA;

SELECT INDEX_NAME
FROM DBA_INDEXES
WHERE TABLE_NAME = 'NOTA';

--PK_ID_NOTA
--IDX_TITULO

ALTER TABLE NOTA MOVE TABLESPACE USER_DATA;
ALTER INDEX PK_ID_NOTA REBUILD TABLESPACE USER_DATA;
ALTER INDEX IDX_TITULO REBUILD TABLESPACE USER_DATA;

--Se verifica que los indices esten en el tablespace correcto:
SELECT OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, TABLESPACE_NAME
FROM DBA_INDEXES
WHERE TABLESPACE_NAME = 'USER_DATA';

SELECT OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, TABLESPACE_NAME
FROM DBA_INDEXES
--WHERE TABLESPACE_NAME = 'USERS'
where INDEX_NAME IN ('IDX_NOMBRE', 'IDX_CORREO');



-- Repetimos la consulta para ver el tamaño de la nueva Tablespace:

SELECT file_name, tablespace_name, BYTES
FROM DBA_DATA_FILES
WHERE tablespace_name IN (SELECT tablespace_name
                          FROM dba_tables
                          WHERE table_name IN ('CATEGORIA', 'NOTA', 'COMPARTE'));

-- CLUSTER, IOT y BITMAP
-- ANALISIS, SOBRE IMPLEMENTACION DE CLUSTER:
/*
Las tablas no tienen muchas columnas y una de ellas almacena datos tipo BLOB, administrarlas como 
clúster no sea la mejor opción en este caso. El clúster suele ser más beneficioso cuando hay una relación estrecha y 
frecuente entre varias tablas y se accede a ellas conjuntamente. 
Sin embargo, en este caso las tablas no tienen muchas columnas y no hay una dependencia fuerte entre ellas en términos de acceso conjunto, 
los beneficios de administrarlas como clúster podrían ser limitados.
Además, al tener una columna de tipo BLOB en una de las tablas, podría dificultar la agrupación física de las filas 
debido al tamaño y a la forma en que se almacenan los datos BLOB. Los datos BLOB se almacenan fuera de la tabla en sí, 
por lo que el clúster no tendría un impacto significativo en el rendimiento de acceso a esos datos.
*/

-- IOT (Tablas de Indice Organizado) y BITMAP:
/*
Tabla USUARIO:

Dado que la tabla tiene una clave primaria (IDUSUARIO) que tiene una relación estrecha con las columnas de datos, 
podría considerarse el uso de una tabla organizada como índice (IOT). 
Un IOT almacena los datos de la tabla directamente en la estructura del índice, lo que elimina la necesidad de una estructura de datos 
separada para la tabla. Esto puede mejorar el rendimiento en consultas que buscan registros específicos basados en el valor de 
"IDUSUARIO", ya que se evita la búsqueda adicional en la estructura de datos de la tabla.

IOT [OK]

SIN EMBARGO:

En una tabla organizada por índices (IOT), no se puede utilizar la opción "ALTER TABLE" 
para cambiar los parámetros de almacenamiento como PCTFREE, PCTUSED, INITRANS o MAXTRANS. 
Esto se debe a que en una tabla IOT, los datos se almacenan directamente en la estructura del índice y no en bloques de datos separados.

Con dicho analisis, la mejor opcion para esta tabla será usar indices TRADICIONALES.

Tabla CATEGORIA:

la tabla "CATEGORIA" tiene una baja cardinalidad en la columna "IDCATEGORIA" y las consultas suelen involucrar 
igualdad en esa columna, entonces un índice tradicional podría ser suficiente. El índice tradicional mejorará el 
rendimiento de las consultas de igualdad en "IDCATEGORIA".

Por otro lado, si las consultas en la tabla "CATEGORIA" involucran múltiples categorías en condiciones AND y 
la cardinalidad de "IDCATEGORIA" es baja, entonces se podría considerar el uso de un índice bitmap. Un índice bitmap es útil cuando 
las consultas implican operaciones lógicas de combinación de bits, como las operaciones AND, OR y NOT. El índice bitmap permite una 
búsqueda eficiente en múltiples categorías.

El uso de un índice organizado por índice (IOT) en la tabla "CATEGORIA" podría ser menos beneficioso, ya que no parece haber una 
columna clave adecuada para organizar la tabla de manera eficiente.

Para la tabla "CATEGORIA", si las consultas suelen involucrar igualdad en "IDCATEGORIA" y la cardinalidad es baja, 
un índice tradicional podría ser suficiente.

Indice tradicional [OK]

Tabla NOTA:

Dado que la tabla tiene una columna BLOB, que puede ser más pesada en términos de almacenamiento y acceso, 
un índice organizado puede no ser la opción más adecuada. 
En su lugar, se podría considerar un índice tradicional en función de las consultas que se realicen con mayor frecuencia.

Indice tradicional [ok]

Tabla COMPARTE:

Si las consultas en la tabla "COMPARTE" suelen ser principalmente de igualdad basadas en las columnas 
"IDNOTA" e "IDUSUARIO" (consultas del tipo WHERE IDNOTA = valor AND IDUSUARIO = valor),
 entonces un índice tradicional sería adecuado. El índice tradicional mejorará el rendimiento de las consultas de igualdad en estas columnas.

Si las consultas en la tabla "COMPARTE" implican consultas más complejas, como consultas con condiciones adicionales, 
consultas con combinaciones de columnas o consultas que involucran varias columnas a la vez, entonces un índice bitmap podría ser beneficioso. 
El índice bitmap permite una búsqueda eficiente en múltiples condiciones lógicas y puede mejorar el rendimiento de este tipo de consultas.

En cuanto al índice organizado por índice (IOT), su uso depende de si hay una columna adecuada para ser 
la clave de ordenamiento principal de la tabla. En el esquema que has proporcionado, no parece haber una columna 
clave obvia para organizar la tabla mediante un IOT. Por lo tanto, en este caso, un IOT puede no ser la mejor opción.

BITMAP [ok]

*/

-- ASPECTOS DE SEGURIDAD:

-- CREACION DE USUARIOS Y PRIVILEGIOS
/*
Se ocupan 4 usuarios:
1. db_admin
2. app_user
3. read_only
4. backup_user

Considerando el esquema elaborado hasta el momento,
db_admin debe pertenecer al tablespace de USER y USER_DATA
app_user debe pertenecer al tablespace de USER y USER_DATA
read_only debe pertenecer al tablespace de USER y USER_DATA
backup_user debe pertenecer al tablespace de USER y USER_DATA

Con todo ello, se les asigna cuota ilimitada:
Una cuota ilimitada significa que el usuario tiene 
asignado un espacio de almacenamiento sin límite en el 
tablespace especificado. Esto le permite al usuario utilizar 
todo el espacio disponible en el tablespace para almacenar 
objetos (tablas, índices, etc.) sin restricciones en cuanto 
al tamaño.

El usuario "db_admin" se le asignan los siguientes privilegios:

CREATE SESSION: Permite al usuario conectarse a la base de datos.
GRANT ANY PRIVILEGE: Permite al usuario otorgar cualquier privilegio a otros usuarios.
UNLIMITED TABLESPACE: Le da al usuario la capacidad de utilizar espacio de almacenamiento ilimitado en los tablespaces especificados.

El usuario "app_user" se le asignan los siguientes privilegios:

CREATE SESSION: Permite al usuario conectarse a la base de datos.
CREATE TABLE: Permite al usuario crear tablas en su propio esquema.
CREATE VIEW: Permite al usuario crear vistas en su propio esquema.
CREATE PROCEDURE: Permite al usuario crear procedimientos almacenados en su propio esquema.
SELECT ANY TABLE: Permite al usuario seleccionar datos de cualquier tabla en la base de datos.
INSERT ANY TABLE: Permite al usuario insertar datos en cualquier tabla en la base de datos.
UPDATE ANY TABLE: Permite al usuario actualizar datos en cualquier tabla en la base de datos.

UNLIMITED TABLESPACE: Le da al usuario la capacidad de utilizar espacio de almacenamiento ilimitado en los tablespaces especificados.

El usuario "read_only" se le asignan los siguientes privilegios:

CREATE SESSION: Permite al usuario conectarse a la base de datos.
SELECT ANY TABLE: Permite al usuario realizar consultas en cualquier tabla de la base de datos.

El usuario "backup_user" se le asignan los siguientes privilegios:

CREATE SESSION: Permite al usuario conectarse a la base de datos.
SELECT ANY TABLE: Permite al usuario realizar consultas en cualquier tabla de la base de datos.
BACKUP ANY TABLE: Permite al usuario realizar copias de seguridad de cualquier tabla de la base de datos.

*/

-- Si hay error al ejecutar comandos; alter session set "_ORACLE_SCRIPT"=true;

-- Crear el usuario db_admin con privilegios y asignar tablespaces
CREATE USER db_admin IDENTIFIED BY abc123 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
ALTER USER db_admin QUOTA UNLIMITED ON USERS;
ALTER USER db_admin QUOTA UNLIMITED ON USER_DATA;
GRANT DBA TO db_admin;

-- Crear el usuario app_user con privilegios y asignar tablespaces
CREATE USER app_user IDENTIFIED BY abc123 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
ALTER USER app_user QUOTA 500k ON USERS;
ALTER USER app_user QUOTA 2G ON USER_DATA;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE TO app_user;

-- Crear el usuario read_only con privilegios y asignar tablespaces
CREATE USER read_only IDENTIFIED BY abc123 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
ALTER USER read_only QUOTA UNLIMITED ON USERS;
ALTER USER read_only QUOTA UNLIMITED ON USER_DATA;
GRANT CREATE SESSION, SELECT ANY TABLE TO read_only;

-- Crear el usuario backup_user con privilegios y asignar tablespaces
CREATE USER backup_user IDENTIFIED BY abc123 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
ALTER USER backup_user QUOTA UNLIMITED ON USERS;
ALTER USER backup_user QUOTA UNLIMITED ON USER_DATA;
GRANT CREATE SESSION, SELECT ANY TABLE, BACKUP ANY TABLE TO backup_user;

SELECT username FROM dba_users;

SELECT * 
FROM dba_role_privs 
WHERE grantee = 'DB_ADMIN' 
  AND granted_role = 'DBA';

SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'APP_USER';

SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'READ_ONLY';

SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = 'BACKUP_USER';

SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username IN ('DB_ADMIN', 'APP_USER', 'READ_ONLY', 'BACKUP_USER');

SELECT username, tablespace_name, 
       CASE 
           WHEN max_bytes = -1 THEN 'UNLIMITED'
           ELSE round(max_bytes / 1024 / 1024 / 1024, 2) || ' GB'
       END AS quota
FROM dba_ts_quotas
WHERE username IN ('DB_ADMIN', 'APP_USER', 'READ_ONLY', 'BACKUP_USER')
  AND tablespace_name IN ('USERS', 'USER_DATA');

-- CREACION DE ROLES Y PERFILES

-- Algunos roles detectados son:
/*
MANAGER_ROLE:
Este rol está diseñado para los usuarios con funciones de administración y gestión. 
Les otorga privilegios para crear, alterar y eliminar usuarios y roles, así como también para crear, alterar y eliminar tablas.

Privilegios asignados:
CREATE USER, ALTER USER, DROP USER
CREATE ROLE, ALTER ROLE, DROP ROLE
CREATE TABLE, ALTER ANY TABLE, DROP ANY TABLE
SELECT ANY DICTIONARY

DEVELOPER_ROLE:
Este rol está destinado a los desarrolladores de la base de datos. 
Les permite crear, alterar y eliminar tablas, vistas, procedimientos almacenados y secuencias.

Privilegios asignados:
CREATE TABLE, ALTER TABLE, DROP TABLE
CREATE VIEW, DROP VIEW
CREATE PROCEDURE, ALTER PROCEDURE, DROP PROCEDURE
CREATE SEQUENCE, ALTER SEQUENCE, DROP SEQUENCE

REPORTING_ROLE:
Este rol está dirigido a los usuarios encargados de generar informes y consultas. 
Les otorga privilegios de selección, inserción, actualización y eliminación en tablas específicas o en todas las tablas de la base de datos.
Privilegios asignados:
SELECT, INSERT, UPDATE, DELETE en tablas específicas o en todas las tablas (según se especifique)

DATA_ENTRY_ROLE:
 Este rol está diseñado para los usuarios encargados de ingresar y actualizar datos en una tabla específica.
Privilegios asignados:
INSERT, UPDATE, DELETE en una tabla específica
*/

alter session set "_ORACLE_SCRIPT"=true;

CREATE ROLE NK_MANAGER_ROLE; 
GRANT CREATE USER TO NK_MANAGER_ROLE;
GRANT ALTER USER TO NK_MANAGER_ROLE;
GRANT DROP USER TO NK_MANAGER_ROLE;
GRANT CREATE ROLE TO NK_MANAGER_ROLE;
GRANT ALTER ANY ROLE TO NK_MANAGER_ROLE;
GRANT DROP ANY ROLE TO NK_MANAGER_ROLE;
GRANT CREATE TABLE TO NK_MANAGER_ROLE;
GRANT ALTER ANY TABLE TO NK_MANAGER_ROLE;
GRANT DROP ANY TABLE TO NK_MANAGER_ROLE;
GRANT SELECT ANY DICTIONARY TO NK_MANAGER_ROLE;

CREATE ROLE NK_DEVELOPER_ROLE; 
GRANT CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE TO NK_DEVELOPER_ROLE;
GRANT CREATE VIEW TO NK_DEVELOPER_ROLE;
GRANT DROP ANY VIEW TO NK_DEVELOPER_ROLE;
GRANT CREATE PROCEDURE, ALTER ANY PROCEDURE, DROP ANY PROCEDURE TO NK_DEVELOPER_ROLE;
GRANT CREATE SEQUENCE, ALTER ANY SEQUENCE, DROP ANY SEQUENCE TO NK_DEVELOPER_ROLE;

CREATE ROLE NK_REPORTING_ROLE; 
GRANT SELECT, INSERT, UPDATE, DELETE ON USUARIO TO NK_REPORTING_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON CATEGORIA TO NK_REPORTING_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON COMPARTE TO NK_REPORTING_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON NOTA TO NK_REPORTING_ROLE;
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO NK_REPORTING_ROLE;

CREATE ROLE NK_DATA_ENTRY_ROLE;
GRANT INSERT, UPDATE, DELETE ON USUARIO TO NK_DATA_ENTRY_ROLE;
GRANT INSERT, UPDATE, DELETE ON CATEGORIA TO NK_DATA_ENTRY_ROLE;
GRANT INSERT, UPDATE, DELETE ON COMPARTE TO NK_DATA_ENTRY_ROLE;
GRANT INSERT, UPDATE, DELETE ON NOTA TO NK_DATA_ENTRY_ROLE;

GRANT NK_MANAGER_ROLE TO db_admin;
GRANT NK_DEVELOPER_ROLE,NK_REPORTING_ROLE,NK_DATA_ENTRY_ROLE TO app_user;

SELECT granted_role, grantee
FROM dba_role_privs
WHERE grantee = 'DB_ADMIN';

---Puede no mostrar info:
SELECT granted_role, grantee
FROM dba_role_privs
WHERE grantee = 'app_user'; 

SELECT granted_role, grantee
FROM dba_role_privs
WHERE grantee = 'APP_USER'
UNION ALL
SELECT granted_role, grantee
FROM dba_role_privs
WHERE granted_role IN (
    SELECT granted_role
    FROM dba_role_privs
    WHERE grantee = 'APP_USER'
);

alter session set "_ORACLE_SCRIPT"=true;
-- perfil para usuarios con límite de tiempo de sesión y límite de consumo de CPU:

CREATE PROFILE limited_session_cpu LIMIT
  SESSIONS_PER_USER 3
  CPU_PER_SESSION 1000;

--perfil para usuarios con límite de uso de recursos y límite de conexiones concurrentes:

CREATE PROFILE limited_resources LIMIT
  COMPOSITE_LIMIT 1000000
  SESSIONS_PER_USER 5
  CPU_PER_SESSION 1000
  CPU_PER_CALL 100
  LOGICAL_READS_PER_SESSION 1000
  LOGICAL_READS_PER_CALL 100;

--  perfil para usuarios con límites de tiempo de inactividad y tiempo de contraseña:

CREATE PROFILE password_expiry LIMIT
  INACTIVE_ACCOUNT_TIME 30
  PASSWORD_LIFE_TIME 60;

ALTER USER APP_USER PROFILE limited_resources;

SELECT profile
FROM dba_profiles;

SELECT username
FROM dba_users
WHERE profile = 'LIMITED_RESOURCES';


-- Tabla USUARIO
INSERT INTO USUARIO (NOMBRE, APPATERNO, APMATERNO, CONTRASENA, CORREO)
VALUES ('Juan', 'Perez', 'Gomez', '123456', 'juan@example.com');

INSERT INTO USUARIO (NOMBRE, APPATERNO, APMATERNO, CONTRASENA, CORREO)
VALUES ('Maria', 'Lopez', 'Garcia', 'abcdef', 'maria@example.com');

-- Tabla CATEGORIA
INSERT INTO CATEGORIA (IDUSUARIO, NOMBRE, FECHACREACION)
VALUES (1, 'Trabajo', '2023-06-01');

INSERT INTO CATEGORIA (IDUSUARIO, NOMBRE, FECHACREACION)
VALUES (1, 'Personal', '2023-06-02');

-- Tabla NOTA opcional, se hace desde el front end
INSERT INTO NOTA (CONTENIDO, CONTENIDO_BLOB, TITULO, FECHACREACION, IDUSUARIO, IDCATEGORIA)
VALUES ('Contenido nota 1', EMPTY_BLOB(), 'Nota 1', '2023-06-01', 1, 1);

INSERT INTO NOTA (CONTENIDO, CONTENIDO_BLOB, TITULO, FECHACREACION, IDUSUARIO, IDCATEGORIA)
VALUES ('Contenido nota 2', EMPTY_BLOB(), 'Nota 2', '2023-06-02', 1, 2);

-- Tabla COMPARTE, despues de hacer el insert en NOTA 
INSERT INTO COMPARTE (IDNOTA, IDUSUARIO, FECHA)
VALUES (1, 2, '2023-06-01');

INSERT INTO COMPARTE (IDNOTA, IDUSUARIO, FECHA)
VALUES (2, 2, '2023-06-02');

--Correcioones de insert 
--Categoria
INSERT INTO CATEGORIA (IDUSUARIO, NOMBRE, FECHACREACION)
VALUES (1, 'Trabajo', TO_DATE('2023-06-11', 'YYYY-MM-DD'));
INSERT INTO CATEGORIA (IDUSUARIO, NOMBRE, FECHACREACION)
VALUES (1, 'Personal', TO_DATE('2023-06-11', 'YYYY-MM-DD'));

--Comparte
INSERT INTO COMPARTE (IDNOTA, IDUSUARIO, FECHA)
VALUES (78, 1, TO_DATE('2023-06-01', 'YYYY-MM-DD'));
INSERT INTO COMPARTE (IDNOTA, IDUSUARIO, FECHA)
VALUES (79, 2, TO_DATE('2023-06-01', 'YYYY-MM-DD'));

