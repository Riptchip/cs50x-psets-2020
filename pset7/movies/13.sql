SELECT DISTINCT name
FROM people INNER JOIN stars ON people.id = stars.person_id INNER JOIN movies ON stars.movie_id = movies.id
WHERE (NOT people.name == "Kevin Bacon") AND stars.movie_id IN (
                                                                SELECT movies.id
                                                                FROM movies INNER JOIN stars ON movies.id = stars.movie_id INNER JOIN people ON stars.person_id = people.id
                                                                WHERE people.name == "Kevin Bacon" AND people.birth == 1958
                                                               );