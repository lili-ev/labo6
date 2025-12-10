
USE universite;

SELECT 
    et.nom AS etudiant,
    c.titre AS cours,
    ex.date_examen,
    ex.score
FROM EXAMEN ex
INNER JOIN INSCRIPTION i ON i.id = ex.inscription_id
INNER JOIN ETUDIANT et ON et.id = i.etudiant_id
INNER JOIN ENSEIGNEMENT en ON en.id = i.enseignement_id
INNER JOIN COURS c ON c.id = en.cours_id;

SELECT 
    et.id,
    et.nom,
    COUNT(ex.id) AS nb_examens
FROM ETUDIANT et
LEFT JOIN INSCRIPTION i ON i.etudiant_id = et.id
LEFT JOIN EXAMEN ex ON ex.inscription_id = i.id
GROUP BY et.id, et.nom;

SELECT 
    c.id,
    c.titre,
    COUNT(i.id) AS nb_etudiants
FROM COURS c
RIGHT JOIN ENSEIGNEMENT en ON en.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = en.id
GROUP BY c.id, c.titre;


SELECT 
    et.nom AS etudiant,
    p.nom AS professeur
FROM ETUDIANT et
CROSS JOIN PROFESSEUR p
LIMIT 20;


CREATE OR REPLACE VIEW vue_performances AS
SELECT
    et.id AS etudiant_id,
    et.nom,
    AVG(ex.score) AS moyenne_score
FROM ETUDIANT et
LEFT JOIN INSCRIPTION i ON i.etudiant_id = et.id
LEFT JOIN EXAMEN ex ON ex.inscription_id = i.id
GROUP BY et.id, et.nom;

WITH top_cours AS (
    SELECT
        c.id,
        c.titre,
        c.credits,
        AVG(ex.score) AS moyenne_score
    FROM COURS c
    JOIN ENSEIGNEMENT en ON en.cours_id = c.id
    JOIN INSCRIPTION i ON i.enseignement_id = en.id
    JOIN EXAMEN ex ON ex.inscription_id = i.id
    GROUP BY c.id, c.titre, c.credits
    ORDER BY moyenne_score DESC
    LIMIT 3
)
SELECT
    titre,
    credits,
    moyenne_score
FROM top_cours;
