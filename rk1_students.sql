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
