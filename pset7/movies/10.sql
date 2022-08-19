SELECT DISTINCT people.name
FROM people INNER JOIN directors INNER JOIN movies INNER JOIN ratings
WHERE ratings.rating >= 9.0 AND people.id == directors.person_id AND directors.movie_id == movies.id AND movies.id == ratings.movie_id;