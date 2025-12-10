
DROP DATABASE IF EXISTS universite;
CREATE DATABASE universite
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE universite;

CREATE TABLE ETUDIANT (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PROFESSEUR (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    departement VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE COURS (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(150) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    credits INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ENSEIGNEMENT (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cours_id INT NOT NULL,
    professeur_id INT NULL,
    semestre VARCHAR(20),

    FOREIGN KEY (cours_id) REFERENCES COURS(id)
      ON DELETE CASCADE,
    FOREIGN KEY (professeur_id) REFERENCES PROFESSEUR(id)
      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE INSCRIPTION (
    id INT PRIMARY KEY AUTO_INCREMENT,
    etudiant_id INT NOT NULL,
    enseignement_id INT NOT NULL,
    date_inscription DATE NOT NULL,

    FOREIGN KEY (etudiant_id) REFERENCES ETUDIANT(id) ON DELETE CASCADE,
    FOREIGN KEY (enseignement_id) REFERENCES ENSEIGNEMENT(id) ON DELETE CASCADE,

    UNIQUE (etudiant_id, enseignement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE EXAMEN (
    id INT PRIMARY KEY AUTO_INCREMENT,
    inscription_id INT NOT NULL,
    date_examen DATE NOT NULL,
    score INT NOT NULL,
    CHECK (score BETWEEN 0 AND 20),

    FOREIGN KEY (inscription_id) REFERENCES INSCRIPTION(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO PROFESSEUR (nom, email, departement) VALUES
 ('Karim', 'karim@uni.ma', 'Informatique'),
 ('Sofia', 'sofia@uni.ma', 'Math');

INSERT INTO COURS (titre, code, credits) VALUES
 ('Algorithmes', 'CS101', 6),
 ('Bases de Données', 'CS102', 5),
 ('Math Discrète', 'MA201', 4);

INSERT INTO ETUDIANT (nom, email) VALUES
 ('Alice', 'alice@mail.com'),
 ('Omar', 'omar@mail.com');

INSERT INTO ENSEIGNEMENT (cours_id, professeur_id, semestre) VALUES
 (1, 1, 'S1'),
 (2, 1, 'S1'),
 (3, 2, 'S1');

INSERT INTO INSCRIPTION (etudiant_id, enseignement_id, date_inscription) VALUES
 (1, 1, '2025-01-10'),
 (1, 2, '2025-01-12'),
 (2, 1, '2025-01-11'),
 (2, 3, '2025-01-13');


INSERT INTO EXAMEN (inscription_id, date_examen, score) VALUES
 (1, CURDATE(), 15),
 (2, CURDATE(), 12),
 (3, CURDATE(), 18),
 (4, CURDATE(), 10);

SELECT DISTINCT et.nom
FROM ETUDIANT et
JOIN INSCRIPTION i ON i.etudiant_id = et.id
JOIN ENSEIGNEMENT en ON en.id = i.enseignement_id
JOIN COURS c ON c.id = en.cours_id
WHERE c.code = 'CS101';

SELECT nom, email
FROM PROFESSEUR
WHERE departement = 'Informatique';

SELECT i.*
FROM INSCRIPTION i
JOIN ETUDIANT e ON e.id = i.etudiant_id
WHERE e.nom = 'Alice'
ORDER BY i.date_inscription DESC;


SELECT et.nom AS etudiant, c.titre AS cours, en.semestre, i.date_inscription
FROM INSCRIPTION i
JOIN ETUDIANT et ON et.id = i.etudiant_id
JOIN ENSEIGNEMENT en ON en.id = i.enseignement_id
JOIN COURS c ON c.id = en.cours_id
ORDER BY i.date_inscription;

SELECT et.id, et.nom,
  (SELECT COUNT(*) FROM INSCRIPTION ins WHERE ins.etudiant_id = et.id) AS nb_cours
FROM ETUDIANT et;

CREATE OR REPLACE VIEW vue_etudiant_charges AS
SELECT et.id, et.nom,
       COUNT(i.id) AS nb_inscriptions,
       COALESCE(SUM(c.credits),0) AS total_credits
FROM ETUDIANT et
LEFT JOIN INSCRIPTION i ON i.etudiant_id = et.id
LEFT JOIN ENSEIGNEMENT en ON en.id = i.enseignement_id
LEFT JOIN COURS c ON c.id = en.cours_id
GROUP BY et.id, et.nom;

SELECT * FROM vue_etudiant_charges;

SELECT c.titre, COUNT(i.id) AS nb_inscriptions
FROM COURS c
LEFT JOIN ENSEIGNEMENT en ON en.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = en.id
GROUP BY c.id, c.titre;

SELECT c.titre, COUNT(i.id) AS nb_inscriptions
FROM COURS c
LEFT JOIN ENSEIGNEMENT en ON en.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = en.id
GROUP BY c.id, c.titre
HAVING COUNT(i.id) > 10;

SELECT en.semestre, ROUND(AVG(ex.score),2) AS moyenne_score
FROM EXAMEN ex
JOIN INSCRIPTION i ON i.id = ex.inscription_id
JOIN ENSEIGNEMENT en ON en.id = i.enseignement_id
GROUP BY en.semestre;

ALTER TABLE EXAMEN
  ADD COLUMN commentaire TEXT;


