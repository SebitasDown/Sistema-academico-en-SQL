CREATE DATABASE gestion_academica;
USE gestion_academica;

-- Tabla estudiantes
CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    genero ENUM('M', 'F', 'Otro') NOT NULL,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    carrera VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_ingreso DATE NOT NULL
);

-- Tabla docentes
CREATE TABLE docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_institucional VARCHAR(100) NOT NULL UNIQUE,
    departamento_academico VARCHAR(100) NOT NULL,
    anios_experiencia INT NOT NULL CHECK (anios_experiencia >= 0)
);

-- Tabla cursos
CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    creditos INT NOT NULL CHECK (creditos > 0),
    semestre INT NOT NULL CHECK (semestre >= 1 AND semestre <= 10),
    id_docente INT,
    FOREIGN KEY (id_docente) REFERENCES docentes(id_docente) ON DELETE SET NULL
);

-- Tabla inscripciones
CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    calificacion_final DECIMAL(3,1) CHECK (calificacion_final BETWEEN 0 AND 5),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
);

-- Estudiantes
INSERT INTO estudiantes (nombre_completo, correo_electronico, genero, identificacion, carrera, fecha_nacimiento, fecha_ingreso) VALUES
('Ana Torres', 'ana.torres@mail.com', 'F', '1001', 'Ingeniería de Sistemas', '2002-05-10', '2021-01-15'),
('Carlos Díaz', 'carlos.diaz@mail.com', 'M', '1002', 'Medicina', '2001-09-22', '2020-01-15'),
('Lucía Gómez', 'lucia.gomez@mail.com', 'F', '1003', 'Psicología', '2003-07-01', '2022-02-01'),
('Mario Ruiz', 'mario.ruiz@mail.com', 'M', '1004', 'Derecho', '2000-02-28', '2019-08-01'),
('Valentina López', 'valentina.lopez@mail.com', 'F', '1005', 'Arquitectura', '2002-12-11', '2021-07-15');

-- Docentes
INSERT INTO docentes (nombre_completo, correo_institucional, departamento_academico, anios_experiencia) VALUES
('Dr. Juan Pérez', 'juan.perez@uni.edu', 'Ingeniería', 10),
('Dra. Sofía Ramírez', 'sofia.ramirez@uni.edu', 'Salud', 6),
('Mg. Andrés Salazar', 'andres.salazar@uni.edu', 'Ciencias Sociales', 3);

-- Cursos
INSERT INTO cursos (nombre, codigo, creditos, semestre, id_docente) VALUES
('Programación I', 'SIS101', 4, 1, 1),
('Anatomía Humana', 'MED202', 5, 2, 2),
('Psicología Infantil', 'PSI301', 3, 3, 3),
('Derecho Constitucional', 'DER101', 4, 1, 1);

-- Inscripciones
INSERT INTO inscripciones (id_estudiante, id_curso, fecha_inscripcion, calificacion_final) VALUES
(1, 1, '2024-02-10', 4.5),
(1, 2, '2024-02-10', 4.0),
(2, 2, '2024-02-12', 3.8),
(3, 3, '2024-02-15', 4.7),
(4, 4, '2024-02-16', 3.5),
(5, 1, '2024-02-18', 4.2),
(5, 3, '2024-02-20', 3.9),
(2, 1, '2024-02-22', 4.6);

-- Listado de todos los estudiantes
SELECT 
	e.id_estudiante,
    e.nombre_completo,
    e.correo_electronico,
    i.id_inscripcion,
    i.fecha_inscripcion,
    i.calificacion_final,
    c.nombre AS nombre_curso,
    c.codigo AS codigo_curso,
    c.semestre
FROM estudiantes e
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON i.id_curso = c.id_curso;

-- Consulta de cursos
SELECT
    c.nombre AS nombre_curso,
    c.codigo AS codigo_curso,
    d.nombre_completo AS nombre_docente,
    d.anios_experiencia AS experiencia_docente,
    c.semestre
FROM cursos c
JOIN docentes d ON d.id_docente = c.id_docente
WHERE d.anios_experiencia > 5;


-- Consulta de promedio 
SELECT
    c.nombre AS nombre_curso,
    ROUND(AVG(i.calificacion_final), 2) AS promedio_calificacion
FROM inscripciones i
JOIN cursos c ON i.id_curso = c.id_curso
GROUP BY c.nombre;
    
-- Inscripcion a mas de un curso
SELECT
    e.id_estudiante,
    e.nombre_completo,
    COUNT(i.id_curso) AS cantidad_cursos
FROM inscripciones i
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre_completo
HAVING COUNT(i.id_curso) > 1;
    
-- Estado academico
ALTER TABLE estudiantes
ADD estado_academico ENUM('Activo', 'Inactivo', 'Egresado', 'Suspendido') NOT NULL DEFAULT 'Activo';
SELECT * FROM estudiantes;

-- Eliminar
DELETE FROM docentes WHERE id_docente = 3;
SELECT * FROM cursos;


-- Mas de dos cursos
SELECT c.nombre, COUNT(*) AS cantidad_inscritos
FROM inscripciones i
JOIN cursos c ON i.id_curso = c.id_curso
GROUP BY c.id_curso
HAVING COUNT(*) > 2;


-- Estudiantes con promedio superior
SELECT e.nombre_completo,  AVG(i.calificacion_final) AS promedio_estudiante
FROM estudiantes e
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
GROUP BY e.id_estudiante, i.calificacion_final
HAVING AVG(i.calificacion_final) > (
    SELECT AVG(calificacion_final) FROM inscripciones
);

-- Superior a dos semestres
SELECT DISTINCT e.carrera
FROM estudiantes e
WHERE EXISTS (
    SELECT 1
    FROM inscripciones i
    JOIN cursos c ON i.id_curso = c.id_curso
    WHERE i.id_estudiante = e.id_estudiante AND c.semestre >= 2
);

-- Explorando
SELECT 
    MAX(calificacion_final) AS maximo,
    MIN(calificacion_final) AS minimo,
    ROUND(AVG(calificacion_final), 2) AS promedio,
    SUM(calificacion_final) AS suma,
    COUNT(*) AS total_inscripciones
FROM inscripciones;

-- Vista creada
CREATE VIEW vista_historial_academico AS
SELECT 
    e.nombre_completo AS estudiante,
    c.nombre AS curso,
    d.nombre_completo AS docente,
    c.semestre,
    i.calificacion_final
FROM inscripciones i
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
JOIN cursos c ON i.id_curso = c.id_curso
LEFT JOIN docentes d ON c.id_docente = d.id_docente;

SELECT * FROM vista_historial_academico;


-- Rol
GRANT SELECT ON vista_historial_academico TO 'revisor_academico'@'localhost';
REVOKE INSERT, UPDATE, DELETE ON inscripciones FROM 'revisor_academico'@'localhost';

-- Iniciar transacción
START TRANSACTION;

-- Crear un punto de restauración
SAVEPOINT antes_de_actualizar;

-- Actualizar calificación de prueba
UPDATE inscripciones
SET calificacion_final = 4.9
WHERE id_inscripcion = 1;

-- Supón que detectas un error, restauras al punto anterior
ROLLBACK TO antes_de_actualizar;

-- Realizas una actualización válida
UPDATE inscripciones
SET calificacion_final = 4.8
WHERE id_inscripcion = 1;

-- Confirmar todos los cambios realizados después del SAVEPOINT
COMMIT;
