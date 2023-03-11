-- Какие самолеты имеют более 50 посадочных мест?
select model, a.aircraft_code, count(seat_no)
from seats s 
join aircrafts a on a.aircraft_code = s.aircraft_code 
group by 1,2
having count(seat_no) > 50


-- В каких аэропортах есть рейсы, в рамках которых можно добраться
-- бизнес - классом дешевле, чем эконом - классом?
-- Используй CTE

with cte as(
	select distinct tf2.flight_id
	from ticket_flights tf 
	inner join ticket_flights tf2 on tf.flight_id = tf2.flight_id and tf2.fare_conditions = 'Economy' and tf.fare_conditions = 'Business' and tf.amount < tf2.amount)
select distinct a.airport_name 
from flights f 
inner join cte c on f.flight_id = c.flight_id
inner join airports a on f.departure_airport = a.airport_code


-- Есть ли самолеты, не имеющие бизнес - класса?
-- Используй array_agg



select a.aircraft_code,model, t.nobus
from (
	select*,
		case 
			when nobus && array['Business'] then 1
			else 0 
		end nobus_case	
	from(
		select aircraft_code , array_agg(fare_conditions::text) as nobus
		from seats s 
		group by 1) t) t 
join aircrafts a on a.aircraft_code = t.aircraft_code
where nobus_case = 0




--Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
-- Оконная функция
-- Оператор ROUND

select  *, (round(count_mod / (sum(count_mod) over ()) ,4 ) * 100) as Процент
from(
	select  f.aircraft_code ,a2.model , count(*) as count_mod
	from airports a 
	join flights f on a.airport_code  =f.departure_airport 
	join aircrafts a2 on a2.aircraft_code = f.aircraft_code
	group by 1,2) t 



-- Выведите количество пассажиров по каждому коду сотового оператора,
-- если учесть, что код оператора - это три символа после +7

select substring(contact_data ->> 'phone', 3,3) as phone_code, count(*)
from tickets t 
group by 1


--Между какими городами не существует перелетов?
-- Используй Декартово произведение и оператор EXCEPT

select distinct a.city as one ,a2.city as two
from airports a, airports a2
where a.city <> a2.city
except 
select a_city, a2_city 
from (
	select distinct a.city as a_city ,a2.city as a2_city
	from flights f
	inner join airports a on f.departure_airport = a.airport_code 
	inner join   airports a2 on f.arrival_airport  = a2.airport_code )t
	
-- Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
-- До 50 млн - low
-- От 50 млн включительно до 150 млн - middle
-- От 150 млн включительно - high
-- Выведите в результат количество маршрутов в каждом классе.
-- Используй оператор CASE

select Размер_оборота, count(*)
from (
	select *,
		case 
			when  финансовые_обороты < 50000000 then 'low'
			when  50000000 <= финансовые_обороты  and финансовые_обороты <  150000000 then 'middle'
			when  финансовые_обороты >= 150000000 then 'high'
		end Размер_оборота	
	from (
		select sum( amount) as финансовые_обороты , f.departure_airport , f.arrival_airport 
		from ticket_flights tf 
		join flights f on tf.flight_id = f.flight_id 
		group by 2,3 ) t )t 
group by 1


	

--Выведите пары городов между которыми расстояние более 5000 км
-- Используй оператор RADIANS или sind/cosd


select  *
from(
	select distinct a.airport_name, a2.airport_name , 
		round ( acos(sind(a.latitude)*sind(a2.latitude) + cosd(a.latitude)*cosd(a2.latitude)*cosd(a.longitude - a2.longitude))* 6371) as Растояние 
	from airports a , airports a2 
	where a.airport_name < a2.airport_name ) t
where t.Растояние > 5000

