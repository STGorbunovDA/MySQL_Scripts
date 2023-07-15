
# Подсчитать количество групп (сообществ), в которые вступил каждый пользователь.

select 	 
	  ANY_VALUE((select lastname from users where id = user_id)) as lastname
	, ANY_VALUE((select firstname from users where id = user_id)) as firstname
    , ANY_VALUE((select email from users where id = user_id)) as email
    , count(*)
from users_communities
group by user_id;


# Подсчитать количество пользователей в каждом сообществе

INSERT INTO `users_communities` (`user_id`, `community_id`) VALUES ('88', '10');
select
	  ANY_VALUE((select name from communities where id = community_id)) as communities
	, count(*)
    from users_communities
    group by communities;

# Пусть задан некоторый пользователь. 
# Из всех пользователей соц. сети найдите человека, 
# который больше всех общался с выбранным пользователем (написал ему сообщений).

SELECT
     ANY_VALUE((select concat(firstname,' ', lastname) from users where id = messages.from_user_id)) as Sender,
     ANY_VALUE((select concat(firstname,' ', lastname) from users where id = messages.to_user_id)) as Receiving,
    COUNT(*) as send
FROM messages
JOIN friend_requests ON to_user_id = target_user_id and from_user_id = initiator_user_id and status ='approved'
GROUP BY Sender
ORDER BY send desc ; 

# * Подсчитать общее количество лайков, которые получили пользователи младше 18 лет..

SELECT 
	COUNT(*) AS 'Общее кол-во лайков'
FROM likes
WHERE user_id IN (
	SELECT user_id 
	FROM profiles
	WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18);

# * Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT CASE (gender)
	WHEN 'm' THEN 'Мужчины'
	WHEN 'f' THEN 'Женщины'
    END AS 'Больше лайков ставят:', COUNT(*) as 'Кол-во лайков'
FROM profiles p 
JOIN likes l 
WHERE l.user_id = p.user_id
GROUP BY gender 
LIMIT 1; -- для проверки можно увеличить LIMIT