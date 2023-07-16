# Создайте представление с произвольным SELECT-запросом из прошлых уроков [CREATE VIEW]

CREATE OR REPLACE VIEW users_p AS 
   SELECT firstname, lastname, gender, birthday, count(*) AS Count
   FROM users 
   JOIN profiles ON users.id = profiles.user_id 
   JOIN users_communities ON users.id = users_communities.user_id 
   WHERE gender = 'f' AND TIMESTAMPDIFF(YEAR, birthday, NOW()) > 25
   GROUP BY	users_communities.user_id
   ORDER BY Count DESC;

# Выведите данные, используя написанное представление [SELECT] 

SELECT firstname, lastname, gender, birthday, Count
  FROM users_p;
  
# Удалите представление [DROP VIEW] 

DROP VIEW users_p;

# *Сколько новостей (записей в таблице media) у каждого пользователя? Вывести поля: news_count (количество новостей), 
# user_id (номер пользователя), user_email (email пользователя). Попробовать решить с помощью CTE или с помощью обычного JOIN.

-- JOIN 

  SELECT COUNT(media.id) AS news_count,
         media.user_id,
         users.email AS user_email
    FROM media
    JOIN users ON media.user_id = users.id
GROUP BY users.id;

-- CTE

  WITH newscounter AS (
       SELECT COUNT(id) AS news_count,
	      user_id
         FROM media
     GROUP BY user_id)
SELECT newscounter.news_count, 
       newscounter.user_id, 
       users.email AS user_email
  FROM newscounter, users
 WHERE newscounter.user_id = users.id