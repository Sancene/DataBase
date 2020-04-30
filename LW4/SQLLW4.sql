--#1. Добавить внешние ключи.
ALTER TABLE room 
ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room 
ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_booking) REFERENCES booking (id_booking);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_room) REFERENCES room (id_room);

ALTER TABLE booking
ADD FOREIGN KEY (id_client) REFERENCES client (id_client);

--#2.Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах категории “Люкс” на 1 апреля 2019г.
SELECT client.id_client, client.name, client.phone 
FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room_in_booking.id_room = room.id_room
INNER JOIN hotel ON room.id_hotel = hotel.id_hotel
INNER JOIN room_category ON room.id_room_category = room_category.id_room_category
WHERE 
	hotel.name = 'Космос' AND
	room_category.name = 'Люкс' AND 
	('2019-04-01' >= room_in_booking.checkin_date AND '2019-04-01' < room_in_booking.checkout_date);

--#3.Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT * from room
EXCEPT
SELECT room.* from room
left outer join room_in_booking on room_in_booking.id_room = room.id_room
WHERE
    checkin_date <= '2019-04-22' AND
	checkout_date >= '2019-04-22'

--#4.Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT room_category.id_room_category, room_category.name, COUNT(*) AS booked
FROM room
INNER JOIN room_in_booking on room_in_booking.id_room = room.id_room
INNER JOIN room_category on room_category.id_room_category = room.id_room_category
INNER JOIN hotel on hotel.id_hotel = room.id_hotel
WHERE
	hotel.name = 'Космос' AND
    checkin_date <= '2019-03-23' AND
	checkout_date > '2019-03-23'
GROUP BY room_category.id_room_category, room_category.name

--#5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, выехавшиx в апреле с указанием даты выезда.
SELECT room.id_room, client.id_client, client.name, client.phone, room_in_booking.checkout_date
FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON room_in_booking.id_booking = booking.id_booking
INNER JOIN room on room_in_booking.id_room = room.id_room
INNER JOIN (SELECT id_hotel, hotel.name FROM hotel 
		    WHERE hotel.name = 'Космос'
		   ) AS hotel
		   ON hotel.id_hotel = room.id_hotel
INNER JOIN (SELECT room_in_booking.id_room,  MAX(room_in_booking.checkout_date) AS last_checkout_date
			FROM (
					SELECT *
					FROM room_in_booking
					WHERE DATEFROMPARTS ( 2019, 04, 1 ) <= checkout_date
						  and checkout_date < DATEFROMPARTS ( 2019, 05, 1 )
				 ) AS room_in_booking
			GROUP BY room_in_booking.id_room) AS b
ON b.id_room =  room_in_booking.id_room
WHERE (room_in_booking.id_room = b.id_room and b.last_checkout_date = room_in_booking.checkout_date)
ORDER BY room.id_room

--#6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.

UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
WHERE room_in_booking.id_room_in_booking in (
          SELECT room_in_booking.id_room_in_booking
          FROM room_in_booking
                   left join booking ON room_in_booking.id_booking = booking.id_booking
                   left join room ON room.id_room = room_in_booking.id_room
                   left join room_category ON room_category.id_room_category = room.id_room_category
                   left join hotel ON hotel.id_hotel = room.id_hotel
          WHERE checkin_date = '2019-05-10'
            and hotel.name = 'Космос'
            and room_category.name = 'Бизнес'
      )

--#7. Найти все "пересекающиеся" варианты проживания...
SELECT *
	FROM room_in_booking room1, room_in_booking room2
	WHERE 
		room1.id_room = room2.id_room AND
		room1.id_room_in_booking != room2.id_room_in_booking AND
		(room2.checkin_date <= room1.checkin_date AND room1.checkout_date < room2.checkout_date)
	ORDER BY room1.id_room_in_booking

--#8. Создать бронирование в транзакции
	BEGIN TRANSACTION
		INSERT INTO booking VALUES(8, '2020-04-21');  
	COMMIT;

--#9.Добавить необходимые индексы для всех таблиц
--hotel
CREATE NONCLUSTERED INDEX index_hotel_id_hotel_name ON hotel
(
	id_hotel ASC,
	name ASC
)
CREATE NONCLUSTERED INDEX index_hotel_name ON hotel
(
	name ASC
)

--room_category
CREATE NONCLUSTERED INDEX index_room_category_id_room_category_name ON room_category
(
	id_room_category ASC,
	name ASC
)
CREATE NONCLUSTERED INDEX index_room_category_name ON room_category
(
	name ASC
)

--room
CREATE NONCLUSTERED INDEX index_room_id_hotel ON room
(
	id_hotel ASC
)
CREATE NONCLUSTERED INDEX index_room_id_room_category ON room
(
	id_room_category ASC
)

--booking
CREATE NONCLUSTERED INDEX index_booking_id_client ON booking
(
	id_client ASC
)

--room_in_booking
CREATE NONCLUSTERED INDEX index_room_in_booking_id_room ON room_in_booking
(
	id_room ASC
)
CREATE NONCLUSTERED INDEX index_room_in_booking_id_booking ON room_in_booking
(
	id_booking ASC
)
CREATE NONCLUSTERED INDEX index_room_in_booking_checkin_date_checkout_date ON room_in_booking
(
	checkin_date ASC,
	checkout_date ASC
)
CREATE NONCLUSTERED INDEX index_room_in_booking_checkout_date ON room_in_booking
(
	checkout_date ASC
)