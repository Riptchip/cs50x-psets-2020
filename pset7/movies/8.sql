SELECT name FROM people INNER JOIN stars INNER JOIN movies WHERE movies.title  == "Toy Story" AND people.id == stars.person_id AND stars.movie_id == movies.id;