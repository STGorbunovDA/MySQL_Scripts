DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамиль', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) UNIQUE,
 	password_hash VARCHAR(100), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
	phone BIGINT UNSIGNED UNIQUE, 
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'юзеры';

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
	
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE RESTRICT; -- (значение по умолчанию)

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('requested', 'approved', 'declined', 'unfriended'), # DEFAULT 'requested',
    -- `status` TINYINT(1) UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP, -- можно будет даже не упоминать это поле при обновлении
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)-- ,
    -- CHECK (initiator_user_id <> target_user_id)
);
-- чтобы пользователь сам себе не отправил запрос в друзья
-- ALTER TABLE friend_requests 
-- ADD CHECK(initiator_user_id <> target_user_id);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	
	INDEX communities_name_idx(name), -- индексу можно давать свое имя (communities_name_idx)
	FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
    name VARCHAR(255), -- записей мало, поэтому в индексе нет необходимости
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    -- file BLOB,    	
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_vk 
FOREIGN KEY (media_id) REFERENCES vk.media(id);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_vk_1 
FOREIGN KEY (user_id) REFERENCES vk.users(id);

ALTER TABLE vk.profiles 
ADD CONSTRAINT profiles_vk_1 
FOREIGN KEY (photo_id) REFERENCES media(id);

# Написать скрипт, добавляющий в созданную БД vk 2-3 
# новые таблицы (с перечнем полей, указанием индексов и внешних ключей) 
# (CREATE TABLE)

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
        `id` SERIAL,
        `name` VARCHAR(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,
 
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
      PRIMARY KEY (`id`)
);
 
DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
        id SERIAL PRIMARY KEY,
        `album_id` BIGINT UNSIGNED NOT NULL,
        `media_id` BIGINT UNSIGNED NOT NULL,
 
        FOREIGN KEY (album_id) REFERENCES photo_albums(id) ON UPDATE CASCADE ON DELETE CASCADE,
		FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);
 
ALTER TABLE `profiles` ADD CONSTRAINT vk_photo_id
    FOREIGN KEY (photo_id) REFERENCES photos(id)
    ON UPDATE CASCADE ON DELETE SET NULL;

# Заполнить 2 таблицы БД vk данными (по 10 записей в каждой таблице) (INSERT)
insert into vk.users (firstname, lastname, email, phone) values
	('Вася', 'Пупкин', '1@mail.ru', '9040976885'),
	('Петя', 'Федин', '2@mail.ru', '9040976884'),
	('Иван', 'Иванов', '3@mail.ru', '9040976883'),
	('Иван', 'Пупкин', '4@mail.ru', '9040976882'),
	('Вася', 'Федин', '5@mail.ru', '9040976881'),
	('Дима', 'Васечкин', '6@mail.ru', '9040976880'),
	('Клавдия', 'Гришкович', '7@mail.ru', '9040976879'),
	('Карим', 'Пупкин', '8@mail.ru', '9040976878'),
	('Залуддин', 'Алладинов', '9@mail.ru', '9040976887'),
	('Петр', 'Петров', '10@mail.ru', '90409768878')
;
INSERT INTO vk.friend_requests (`initiator_user_id`, `target_user_id`, `status`) values
	('1', '2', 'requested'),
	('1', '3', 'requested'),
	('1', '4', 'requested'),
	('1', '5', 'requested'),
	('1', '6', 'requested'),
	('3', '2', 'requested'),
	('4', '2', 'requested'),
	('5', '2', 'requested'),
	('6', '2', 'requested'),
	('7', '2', 'requested')
;

UPDATE vk.friend_requests SET 
	status = 'declined',
	updated_at = now()
WHERE
	initiator_user_id = 1 and target_user_id = 2
;
    
UPDATE vk.friend_requests SET 
	status = 'approved',
	updated_at = now()
WHERE
	initiator_user_id = 1 and target_user_id = 3
;
    
UPDATE vk.friend_requests SET 
	status = 'unfriended',
	updated_at = now()
WHERE
	initiator_user_id = 1 and target_user_id = 4
;
    
UPDATE vk.friend_requests SET 
	status = 'approved',
	updated_at = now()
WHERE
	initiator_user_id = 1 and target_user_id = 5
;
    
UPDATE vk.friend_requests SET 
	status = 'declined',
	updated_at = now()
WHERE
	initiator_user_id = 1 and target_user_id = 6
;
    
# Написать скрипт, отмечающий несовершеннолетних пользователей 
# как неактивных (поле is_active = true). При необходимости 
# предварительно добавить такое поле в таблицу profiles со значением 
# по умолчанию = false (или 0) (ALTER TABLE + UPDATE)

INSERT INTO vk.profiles (`user_id`, `gender`, `birthday`) values
	('1', 'М', '2010-01-02'),
	('2', 'М', '2011-01-02'),
	('3', 'м', '2012-01-02'),
	('4', 'м', '2013-01-02')
;

-- Добавим колонку is_active с дефолтным значением false (0)
ALTER TABLE profiles ADD is_active BIT DEFAULT false NULL;


SET SQL_SAFE_UPDATES = 0;

-- Проставим в колонке is_active значение true (1) пользователям < 18 лет.
UPDATE profiles
SET is_active = 1
WHERE 
	YEAR(CURRENT_TIMESTAMP) - YEAR(birthday) - (RIGHT(CURRENT_TIMESTAMP, 5) 
    < RIGHT(birthday, 5)) < 18
;

-- Для наглядности добавим колонку с возрастом пользователя
ALTER TABLE profiles ADD age int(5);

-- Выведем в колонку age возраст пользователей
	UPDATE profiles
		SET age = YEAR(CURRENT_TIMESTAMP) - YEAR(birthday) - 
        (RIGHT(CURRENT_TIMESTAMP, 5) < RIGHT(birthday, 5))
;



#  Написать скрипт, удаляющий сообщения 
# «из будущего» (дата позже сегодняшней) (DELETE)

-- добавим несколько сообщений
INSERT INTO messages values
	('1','1','2','Voluptatem ut quaerat quia. Pariatur esse amet ratione qui quia. In necessitatibus reprehenderit et. Nam accusantium aut qui quae nesciunt non.','1995-08-28 22:44:29'),
	('2','2','1','Sint dolores et debitis est ducimus. Aut et quia beatae minus. Ipsa rerum totam modi sunt sed. Voluptas atque eum et odio ea molestias ipsam architecto.',now()),
	('3','3','1','Sed mollitia quo sequi nisi est tenetur at rerum. Sed quibusdam illo ea facilis nemo sequi. Et tempora repudiandae saepe quo.','1993-09-14 19:45:58'),
	('4','1','3','Quod dicta omnis placeat id et officiis et. Beatae enim aut aliquid neque occaecati odit. Facere eum distinctio assumenda omnis est delectus magnam.','1985-11-25 16:56:25'),
	('5','1','5','Voluptas omnis enim quia porro debitis facilis eaque ut. Id inventore non corrupti doloremque consequuntur. Molestiae molestiae deleniti exercitationem sunt qui ea accusamus deserunt.','1999-09-19 04:35:46')
;
--  Поставим сообщению с id 4 дату из будущего
UPDATE messages
	SET created_at='2224-10-14 08:11:39'
	WHERE id = 4;

-- Удалим сообщение из будущего
DELETE FROM messages
		WHERE created_at > now()
;

SET SQL_SAFE_UPDATES = 1;