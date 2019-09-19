CREATE DATABASE WK12
GO
USE WK12
GO
CREATE TABLE Student
	(Student VARCHAR(10) NOT NULL,
	CONSTRAINT PK_Student PRIMARY KEY (Student)
)
GO
CREATE TABLE StudentInKlas
	(Klas	VARCHAR(10) NOT NULL,
	Student VARCHAR(10) NOT NULL,
	CONSTRAINT PK_StudentInKlas PRIMARY KEY (Klas, Student)
)
GO
CREATE TABLE StudentCijfer
	(Course	VARCHAR(10) NOT NULL,
	Student VARCHAR(10) NOT NULL,
	Cijfer	INT NULL, 
	CONSTRAINT PK_StudentCijfer PRIMARY KEY (Course, Student)
)
GO

INSERT INTO Student
VALUES	 ('Jan')
		,('Karel')
		,('Truus')
		,('Marij')
GO
INSERT INTO StudentInKlas
VALUES	 ('1a','Jan')
		,('1a','Karel')
		,('1a','Truus')
		,('1b','Marij')
		,('2a','Truus')
		,('2b','Karel')
		,('2a','Jan')
		,('2a','Marij')
		,('3c','Truus')
		,('3b','Karel')
		,('3b','Marij')
		,('3c','Jan')	

GO
INSERT INTO StudentCijfer
VALUES	 ('ISE DI', 'Jan', 7)
		,('ISE DI', 'Karel', 5)
		,('ISE DI', 'Truus', 8)
		,('ISE DI', 'Marij', 7)



--Welke studenten zaten gedurende de hele opleiding bij elkaar in de klas?
SELECT	S1.Student , S2.Student 
FROM	Student S1, Student S2
WHERE NOT EXISTS (SELECT *
					FROM	StudentInKlas SIK1
					WHERE	SIK1.Student = S1.Student 
					AND NOT EXISTS(
						SELEct *
						FROM	StudentInKlas SIK2
						WHERe	SIK2.Student = S2.Student 
						AND		SIK2.Klas = SIK1.Klas )
				)
 AND NOT EXISTS (SELECT *
					FROM	StudentInKlas SIK1
					WHERE	SIK1.Student = S2.Student 
					AND NOT EXISTS(
						SELECT *
						FROM	StudentInKlas SIK2
						WHERE	SIK2.Student = S1.Student 
						AND		SIK2.Klas = SIK1.Klas )
				)
AND S1.Student > S2.Student 

--Welke studenten behoren tot de 3 beste ISE DI studenten?

SELECT *
FROM StudentCijfer S1
WHERE (SELECT COUNT(*)
		FROM StudentCijfer S2
		WHERE S2.Cijfer > S1.Cijfer) < 3

--Sorteer de studenten op resulaat (cijfer) en geef ze een rangnummer

SELECT COUNT(*) AS RangNr, S1.Student, S1.Course, S1.Cijfer
FROM StudentCijfer S1, StudentCijfer S2
WHERE S1.Cijfer <= S2.Cijfer
GROUP BY S1.Student, S1.Course, S1.Cijfer 
ORDER BY S1.Course, S1.Cijfer DESC 

--of mbv windowed function
SELECT  S1.Student, S1.Course, S1.Cijfer, RANK() OVER (ORDER BY Cijfer DESC) AS RangNr
FROM StudentCijfer S1

USE MASTER
GO

DROP DATABASE WK12
GO