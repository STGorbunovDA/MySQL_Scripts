-- Установим текущую БД
use vk;	

# Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке. [ORDER BY]

-- SELECT DISTINCT firstname FROM users

SELECT 
	firstname 
    FROM users 
		GROUP BY firstname 
        ORDER BY firstname ASC;
        
# Выведите количество мужчин старше 35 лет [COUNT].

SELECT 
	COUNT(*) AS count_man
    FROM profiles WHERE gender = 'm' AND TIMESTAMPDIFF(YEAR, birthday, NOW()) > 35;
 
SELECT firstname 
FROM
  users, profiles
  WHERE
     profiles.user_id = users.id 
     AND (gender = 'm' AND TIMESTAMPDIFF(YEAR, birthday, NOW()) > 35) 
     ORDER BY firstname ASC;
     
# Сколько заявок в друзья в каждом статусе? (таблица friend_requests) [GROUP BY]

-- SELECT count(*) FROM friend_requests WHERE status = 'requested'; 

/*
	Несовсем понял суть задания. 
    Мне кажется в статусе всего одна заявка на добавление в друзья.
*/

SELECT 
	firstname 
FROM
	users, friend_requests
  WHERE
     friend_requests.initiator_user_id = users.id 
     AND status = 'requested';
     
# Выведите номер пользователя, который отправил больше всех заявок в друзья (таблица friend_requests) [LIMIT].

/*
	Несовсем понял суть задания. 
    Добавил дополнительный запрос в друзья:
    INSERT INTO `friend_requests` (`initiator_user_id`, `target_user_id`, `status`, `requested_at`, `confirmed_at`) VALUES ('7', '2', 'requested', '1989-10-26 06:20:23', '2001-08-05 16:01:03');
*/

SELECT 
		firstname, 
		COUNT(*) as count
    FROM 
		users, friend_requests 
	WHERE 
		friend_requests.initiator_user_id = users.id 
        AND status = 'requested' 
        GROUP BY initiator_user_id
        ORDER BY count DESC 
        LIMIT 1;

# Выведите названия и номера групп, имена которых состоят из 5 символов [LIKE].
/*
	Несовсем понял суть задания. 
	Не понял каких групп и какие имена. Всей БД? 
*/

    
    
    
    
    