USE vk;

# 1. Написать функцию, которая удаляет всю информацию об указанном пользователе из БД vk. Пользователь задается по id. 
# Удалить нужно все сообщения, лайки, медиа записи, профиль и запись из таблицы users. Функция должна возвращать номер пользователя. 

DROP FUNCTION IF EXISTS DeleteUserFunction;

DELIMITER //

CREATE FUNCTION DeleteUserFunction (delete_user_id INT)
RETURNS INT
BEGIN

    DELETE FROM likes
     WHERE likes.user_id = delete_user_id;
    
    DELETE FROM users_communities
     WHERE users_communities.user_id = delete_user_id;
    
    DELETE FROM messages
     WHERE messages.to_user_id = delete_user_id OR messages.from_user_id = delete_user_id;
    
    DELETE FROM friend_requests
     WHERE friend_requests.initiator_user_id = delete_user_id OR friend_requests.target_user_id = delete_user_id;
    
    DELETE likes
      FROM media
      JOIN likes ON likes.media_id = media.id
     WHERE media.user_id = delete_user_id;
    
    UPDATE profiles
      JOIN media ON profiles.photo_id = media.id
       SET profiles.photo_id = NULL
     WHERE media.user_id = delete_user_id;

    DELETE FROM media
     WHERE media.user_id = delete_user_id;
    
    DELETE FROM profiles
     WHERE profiles.user_id = delete_user_id;

    DELETE FROM users
     WHERE users.id = delete_user_id;
    
    RETURN delete_user_id;

END;  

// DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
SELECT DeleteUserFunction(1) AS user_id_deleted;
SET SQL_SAFE_UPDATES = 1;

# 2. Предыдущую задачу решить с помощью процедуры и обернуть используемые команды в транзакцию внутри процедуры.

DROP PROCEDURE IF EXISTS DeleteUserStoreProcedure;

DELIMITER //

CREATE PROCEDURE DeleteUserStoreProcedure(delete_user_id INT)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    
    BEGIN
    
        ROLLBACK;
    
    END;

	START TRANSACTION;
    
		DELETE FROM likes
		 WHERE likes.user_id = delete_user_id;
    
		DELETE FROM users_communities
		 WHERE users_communities.user_id = delete_user_id;
    
		DELETE FROM messages
		 WHERE messages.to_user_id = delete_user_id OR messages.from_user_id = delete_user_id;
    
		DELETE FROM friend_requests
		 WHERE friend_requests.initiator_user_id = delete_user_id OR friend_requests.target_user_id = delete_user_id;
    
		DELETE likes
		  FROM media
		  JOIN likes ON likes.media_id = media.id
		 WHERE media.user_id = delete_user_id;
    
		UPDATE profiles
		  JOIN media ON profiles.photo_id = media.id
		   SET profiles.photo_id = NULL
		 WHERE media.user_id = delete_user_id;

		DELETE FROM media
		 WHERE media.user_id = delete_user_id;
    
		DELETE FROM profiles
		 WHERE profiles.user_id = delete_user_id;
    
		DELETE FROM users
		 WHERE users.id = delete_user_id;
         
	COMMIT;

END; // 

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
CALL DeleteUserStoreProcedure(1);
SET SQL_SAFE_UPDATES = 1;

# 3. Написать триггер, который проверяет новое появляющееся сообщество. Длина названия сообщества (поле name) должна быть не менее 5 символов. 
# Если требование не выполнено, то выбрасывать исключение с пояснением.

DROP TRIGGER IF EXISTS CommunityNameTrigger;

DELIMITER //

CREATE TRIGGER CommunityNameTrigger BEFORE INSERT ON communities 
FOR EACH ROW BEGIN
   IF (LENGTH(new.name) < 5) THEN
       SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT = 'Длина названия сообщества (поле name) должна быть не менее 5 символов';
       INSERT INTO CommunityNameTrigger_exception_table VALUES();
   END IF; 
END; // 

DELIMITER ;