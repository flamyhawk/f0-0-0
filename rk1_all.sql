-- 1. Найти названия всех фильмов, снятых Стивеном Спилбергом

select title
from Movie
where director = 'Steven Spielberg'
order by title

-- 2. Найти года, в которых были фильмы с рейтингом 4 или 5, и отсортивать по возрастанию
-- ???

select distinct m.year
from Movie m
join Rating r on m.mID = r.mID
where r.stars = 4 OR r.stars = 5
order by m.year;


-- 3. Найти названия всех фильмов которые не имеют рейтинга, отсортировать по алфавиту.

select title
from Movie m
where m.mID not in (
select mID
from Rating)
order by title


-- 4. Некоторые оценки не имеют даты. Найти имена всех экспертов, имеющих оценки без даты, отсортировать по алфавиту.

select distinct reviewer.name
from rating
join reviewer on rating.rID = reviewer.rID
where rating.ratingDate is null
order by reviewer.name


-- 5. Напишите запрос возвращающий информацию о рейтингах в более читаемом формате: имя эксперта, название фильма, оценка и дата оценки. Отсортируйте данные по имени эксперта, затем названию фильма и наконец оценка

select name, title, stars, ratingDate
from rating
join reviewer on reviewer.rID = rating.rID
join movie on movie.mID = rating.mID
order by name, title, stars


-- 6. Для всех случаев, когда один эксперт оценивал фильм дважды и указал лучший рейтинг второй раз, выведите имя эксперта и навание фильма
-- ???

SELECT name, title
from (
  SELECT rID, mID, max(stars) as max_stars, max(ratingDate) as max_ratingDate
  from Rating
  group by rID
  HAVING count(rID) = 2
) as tmp
join Rating ra ON ra.rID = tmp.rID and ra.mID = tmp.mID
join Movie m ON m.mID = tmp.mID
join Reviewer re ON re.rID = tmp.rID
where stars = max_stars AND ratingDate = max_ratingDate;


-- 7. Для каждого фильма, который имеет, по крайней мере, одну оценку, найти наибольшее количество звезд, что фильм получил. Выбрать название фильма и количество звезд. Сортировать по названию фильма.

select title, max(stars)
from rating
join movie ON rating.mID = movie.mID
group by movie.mID
order by title


-- 8. Для каждого фильма выбрать название и "разброс оценок", то есть разницу между самой высокой и самой низкой оценками для этого фильма. Сортировать по "разбросу оценок" от высшего к низшему и по названию фильма
-- ???

SELECT title,  max(stars) -  min(stars) as diff_stars
from Rating r
join Movie m ON r.mID = m.mID
group by title-- r.mID
order by diff_stars DESC, title;


-- 9. Найти разницу между средней оценкой фильмов. выпущенных до 1980 года, и средней оценкой фильмов, выпущенных после 1980 года
-- ???

SELECT max(tmp2.stars) - min(tmp2.stars) as diff
from (
  SELECT avg(tmp1.stars) as stars
  from (
    SELECT avg(stars) as stars, mID
    from Rating
    group by mID
  ) AS tmp1
  join Movie m ON tmp1.mID = m.mID
  group by m.year < 1980
) as tmp2;


-- 10. Найти имена всех экспертов, кто оценил "Gone with the Wind"

select distinct name
from rating
join reviewer ON rating.rID = reviewer.rID
join movie ON rating.mID = movie.mID
where movie.title = 'Gone with the Wind'


-- 11. Для каждой оценки, где эксперт тот же человек что и режиссер, выбрать имя, название фильма и оценку, отсортировать по имени, названию фильма и оценке

select name, title, stars
from rating
join reviewer on rating.rID = reviewer.rID
join movie on rating.mID = movie.mID
where movie.director = reviewer.name


-- 12. Выберите всех экспертов и названия фильмов в едином списке в алфавитном порядке

select name as data
from reviewer
UNION
select title as data
from movie
order by data


-- 13. Выберите названия всех фильмов, по алфавиту, которым не поставил оценку 'Chris Jackson'.
-- ???

select distinct title
from rating
join reviewer on rating.rID = reviewer.rID
join movie on rating.mID = movie.mID
where reviewer.name != 'Chris Jackson'
order by title


-- 14. Для всех пар экспертов, если оба оценили один и тот же фильм, выбрать именаобоих. Устранить дубликаты, проверить отсутствие пар самих с собой и включать каждую пару только 1 раз. Выбрать имена в паре в алфавитном порядке.
-- ???

SELECT DisTINCT r1.name, r2.name
from (
  SELECT ra.rID, name, mID
  from Rating ra
  join Reviewer re ON ra.rID = re.rID
) as r1
join  (
  SELECT ra.rID, name, mID
  from Rating ra
  join Reviewer re ON ra.rID = re.rID
) as r2 ON r1.mID = r2.mID
where r1.name < r2.name;

-- ???
Select distinct rv1.name, rv2.name
From reviewer as rv1
Join raiting as r1 using rid
Join rating as r2 on r1.mid = r2.mid
Join reviewer as rv2 on rv2.rid = r2.rid
Where rv1.name < rv2.name
Group by rv1.name, rv2.name
Order by rv1.name, rv2.name


-- 15. Для каждой минимальной оценки выбрать имя эксперта, название фильма, количество звезд
-- ???

SELECT name, title, stars
from Rating ra
join Reviewer re ON ra.rID = re.rID
join Movie m ON ra.mID = m.mID
where ra.stars = (
  SELECT min(stars)
  from Rating
);


-- 16. Выбрать список названий фильмов и средний рейтинг, от самого низкого до самого высокого. Если два или более фильмов имеют одинаковый средний балл, перечислить их в алфавитном порядке

select title, avg(stars) as average
from rating
join movie on rating.mID = movie.mID
group by movie.mID
order by average, title


-- 17. Найти имена всех экспертов, которые поставили три или более оценок, сортировка по алфавиту

select reviewer.name
from rating
join reviewer on rating.rID = reviewer.rID
group by reviewer.rID
having count(reviewer.rID) >= 3
order by reviewer.name


-- 18. Некоторые режиссеры сняли более чем один фильм. Для всех таких режиссеров, выбрать названия всех фильмов режиссера, его имя. Сортировка по имени режиссера. Имена фильмов собрать в строку через запятую в алфавитном порядке. Пример: Avatar,Titanic | James Cameron

select string_agg(title, ',' order by title), director
from movie
where director in (
select director
from movie
group by director
having count(director) > 1
)
group by director
order by director




-- 1. Find the names of all students who are friends with someone named Gabriel.
-- 1. Найти имена всех студентов кто дружит с кем-то по имени Gabriel.

SELECT H1.name
FROM Highschooler H1
INNER JOIN Friend ON H1.ID = Friend.ID1
INNER JOIN Highschooler H2 ON H2.ID = Friend.ID2
WHERE H2.name = "Gabriel";


-- 2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
-- 2. Для всех студентов, кому понравился кто-то на 2 или более классов младше, чем он вывести имя этого студента и класс, а так же имя и класс студента который ему нравится.

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1
INNER JOIN Likes ON H1.ID = Likes.ID1
INNER JOIN Highschooler H2 ON H2.ID = Likes.ID2
WHERE (H1.grade - H2.grade) >= 2;


-- 3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
-- 3. Для каждой пары студентов, которые нравятся друг другу взаимно вывести имя и класс обоих студентов. Включать каждую пару только 1 раз с именами в алфавитном порядке.

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
WHERE (H1.ID = L1.ID1 AND H2.ID = L1.ID2) AND (H2.ID = L2.ID1 AND H1.ID = L2.ID2) AND H1.name < H2.name
ORDER BY H1.name, H2.name;


-- 4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
-- 4. Найти всех студентов, которые не встречаются в таблице лайков (никому не нравится и ему никто не нравится), вывести их имя и класс. Отсортировать по классу, затем по имени в классе.

SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (
  SELECT DISTINCT ID1
  FROM Likes
  UNION
  SELECT DISTINCT ID2
  FROM Likes
)
ORDER BY grade, name;


-- 5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
-- 5. Для каждой ситуации, когда студенту A нравится студент B, но B никто не нравится, вывести имена и классы A и B.

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1
INNER JOIN Likes ON H1.ID = Likes.ID1
INNER JOIN Highschooler H2 ON H2.ID = Likes.ID2
WHERE (H1.ID = Likes.ID1 AND H2.ID = Likes.ID2) AND H2.ID NOT IN (
  SELECT DISTINCT ID1
  FROM Likes
);


-- 6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
-- 6. Найти имена и классы, которые имеют друзей только в том же классе. Вернуть результат, отсортированный по классу, затем имени в классе.

SELECT name, grade
FROM Highschooler H1
WHERE ID NOT IN (
  SELECT ID1
  FROM Friend, Highschooler H2
  WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2 AND H1.grade <> H2.grade
)
ORDER BY grade, name;


-- 7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
-- 7. Для каждого студента A, которому нравится студент B, и они не друзья, найти есть ли у них общий друг. Для каждой такой тройки вернуть имя и класс A, B, и C.

SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L, Friend F1, Friend F2
WHERE (H1.ID = L.ID1 AND H2.ID = L.ID2) AND H2.ID NOT IN (
  SELECT ID2
  FROM Friend
  WHERE ID1 = H1.ID
) AND (H1.ID = F1.ID1 AND H3.ID = F1.ID2) AND (H2.ID = F2.ID1 AND H3.ID = F2.ID2);


-- 8. Find the difference between the number of students in the school and the number of different first names.
-- 8. Найти разницу между числом учащихся и числом различных имен.

SELECT COUNT(*) - COUNT(DISTINCT name)
FROM Highschooler;


-- 9. Find the name and grade of all students who are liked by more than one other student.
-- 9. Найти имя и класс студентов, которые нравятся более чем 1 другому студенту.

SELECT name, grade
FROM Highschooler
INNER JOIN Likes ON Highschooler.ID = Likes.ID2
GROUP BY ID2
HAVING COUNT(*) > 1;




--***********************************************






-- 10. It's time for the seniors to graduate. Remove all 5th graders from Highschooler.
-- 10. Пора студентам выпускаться. Удалите всех с 5 курса из Highschooler (каскадного удаления в базе нет).

DELETE FROM Highschooler
WHERE grade = 5;


-- 11. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
-- 11. Если два школьника - А и В - друзья и А нравится В, но не наоборот, то удалите соответствующую строку из Likes.

DELETE FROM Likes
WHERE ID2 IN (
  SELECT ID2
  FROM Friend
  WHERE Friend.ID1 = Likes.ID1
) AND ID2 NOT IN (
  SELECT L.ID1
  FROM Likes L
  WHERE L.ID2 = Likes.ID1
);

DELETE FROM Likes
WHERE ID1 IN (
  SELECT Likes.ID1
  FROM Friend
  INNER JOIN Likes USING(ID1)
  WHERE Friend.ID2 = Likes.ID2
) AND ID2 NOT IN (
  SELECT Likes.ID1
  FROM Friend
  INNER JOIN Likes USING(ID1)
  WHERE Friend.ID2 = Likes.ID2
);


-- 12. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself.
-- 12. Для всех случаев, когда А нравится В, а В нравится С - получите имена и классы А, В и С.

INSERT INTO Friend
SELECT DISTINCT F1.ID1, F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2 = F2.ID1 AND F1.ID1 <> F2.ID2 AND F1.ID1 NOT IN (
  SELECT F3.ID1
  FROM Friend F3
  WHERE F3.ID2 = F2.ID2
);

INSERT INTO Friend
SELECT F1.ID1, F2.ID2
FROM Friend F1
INNER JOIN Friend F2 ON F1.ID2 = F2.ID1
WHERE F1.ID1 <> F2.ID2
EXCEPT
SELECT * FROM Friend;


-- 13. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
-- 13. Найдите всех студентов, у которых все друзья в других классах. Получите имена и классы таких студентов.

SELECT name, grade
FROM Highschooler H1
WHERE grade NOT IN (
  SELECT H2.grade
  FROM Friend, Highschooler H2
  WHERE H1.ID = Friend.ID1 AND H2.ID = Friend.ID2
);


-- 3. What is the average number of friends per student? (Your result should be just one number.)
-- 10. Каково среднее число друзей у студента? (Вы должны получить одно число).

SELECT AVG(count)
FROM (
  SELECT COUNT(*) AS count
  FROM Friend
  GROUP BY ID1
);


-- 4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
-- 10. Найдите всех студентов, которые являются друзьями Cassandra, либо друзьями друзей Кассандра. Только не считайте саму Кассандру.

SELECT COUNT(*)
FROM Friend
WHERE ID1 IN (
  SELECT ID2
  FROM Friend
  WHERE ID1 IN (
    SELECT ID
    FROM Highschooler
    WHERE name = 'Cassandra'
  )
);

-- 5. Find the name and grade of the student(s) with the greatest number of friends.
-- 10. Найдите имена и классы студентов(-а) с наибольшим количеством друзей.

SELECT name, grade
FROM Highschooler
INNER JOIN Friend ON Highschooler.ID = Friend.ID1
GROUP BY ID1
HAVING COUNT(*) = (
  SELECT MAX(count)
  FROM (
    SELECT COUNT(*) AS count
    FROM Friend
    GROUP BY ID1
  )
);
