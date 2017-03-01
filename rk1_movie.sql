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
