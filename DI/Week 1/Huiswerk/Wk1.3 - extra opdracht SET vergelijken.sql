-- CREATE DATABASE WK13
-- GO
-- USE WK13
-- GO
-- CREATE TABLE Student
-- 	(Student VARCHAR(10) NOT NULL,
-- 	CONSTRAINT PK_Student PRIMARY KEY (Student)
-- )
-- GO
-- CREATE TABLE StudentInKlas
-- 	(Klas	VARCHAR(10) NOT NULL,
-- 	Student VARCHAR(10) NOT NULL,
-- 	CONSTRAINT PK_StudentInKlas PRIMARY KEY (Klas, Student)
-- )
-- GO
-- CREATE TABLE StudentCijfer
-- 	(Course	VARCHAR(10) NOT NULL,
-- 	Student VARCHAR(10) NOT NULL,
-- 	Cijfer	INT NULL, 
-- 	CONSTRAINT PK_StudentCijfer PRIMARY KEY (Course, Student)
-- )
-- GO

-- INSERT INTO Student
-- VALUES	 ('Jan')
-- 		,('Karel')
-- 		,('Truus')
-- 		,('Marij')
-- GO
-- INSERT INTO StudentInKlas
-- VALUES	 ('1a','Jan')
-- 		,('1a','Karel')
-- 		,('1a','Truus')
-- 		,('1b','Marij')
-- 		,('2a','Truus')
-- 		,('2b','Karel')
-- 		,('2a','Jan')
-- 		,('2a','Marij')
-- 		,('3c','Truus')
-- 		,('3b','Karel')
-- 		,('3b','Marij')
-- 		,('3c','Jan')	

-- GO
-- INSERT INTO StudentCijfer
-- VALUES	 ('ISE DI', 'Jan', 7)
-- 		,('ISE DI', 'Karel', 5)
-- 		,('ISE DI', 'Truus', 8)
-- 		,('ISE DI', 'Marij', 7)


--Welke studenten zaten gedurende de hele opleiding bij elkaar in de klas?

select *
from student
select *
from StudentInKlas
select *
from StudentCijfer

select *
from StudentInKlas sk
where exists(
	select *
from StudentInKlas sk2
where sk.Klas + sk.Student = sk2.Klas + sk2.Student
)

--Welke studenten behoren tot de 3 beste ISE DI studenten?

--Sorteer de studenten op resultaat (cijfer) en geef ze een rangnummer

