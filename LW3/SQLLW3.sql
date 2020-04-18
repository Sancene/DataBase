--1. INSERT
--��� �������� ������ �����
insert into Standart
values ('2019-03-12', 'pushups', 1, 1)

insert into Organisation
values (0, '1919-03-12', 'Supreme learning', 'Gorkov street 12a')

insert into Organisation
values (0, '2001-03-12', 'Matrix school', 'Bolshoy street 114a')

insert into Organisation
values (1, '2005-03-12', 'Innovation university', 'Galkov street 70a')

insert into Teacher_in_organisation
values (8, 1)

insert into Student
values ('2015-03-15', 'Don Joe', '2000-02-11', 'PS-31')

insert into Result
values (1, 1, 1, '2020-03-03', 'PS-31')

insert into Teacher
values (8, 'Anton Diego', '1965-06-15', 'PS-31')

--� ��������� ������ �����
insert into Organisation(is_licensed, foundation_date, name, adress)
values (1, '1985-05-05', 'Volgatech', 'St. Luisiana brodway 13')

insert into Organisation(is_licensed, foundation_date, name, adress)
values (1, '2000-06-12', 'Innopolis', 'Anton street 51')

--� ������� �������� �� ������ �������
insert into Result (student_id, standart_id, teacher_id, completion_date, student_group) 
select Student.student_id, Standart.standart_id, Teacher.teacher_id, Standart.deadline, Teacher.teaching_group 
from Student, Standart, Teacher

--2. DELETE
--�� �������
delete from Organisation where is_licensed = 0

--���� �������
delete from Organisation

--�������� �������
truncate table Result

--3. UPDATE
-- ���� �������
update Organisation set is_licensed = 1 

--�� ������� �������� ���� �������
update Organisation set is_licensed = 0 where name = 'Matrix school'

--�� ������� �������� ��������� ���������
update Organisation set is_licensed = 0 where foundation_date < '1999-01-01'

-- 4. SELECT
--� ������������ ������� ����������� ���������
select * from Organisation where name = 'Volgatech'

--�� ����� ����������
select foundation_date, name from Organisation

--� �������� �� ��������
select * from Organisation where foundation_date between '1999-01-01' and '2020-12-31'

-- 5. Select ORDER BY + TOP (Limit)
--� ����������� �� ����������� ASC + ����������� ������ ���������� �������
select top(3) name, is_licensed, foundation_date, adress
from Organisation
order by foundation_date ASC

--� ����������� �� �������� DESC
select name, is_licensed, foundation_date, adress
from Organisation
order by foundation_date DESC

--� ����������� �� ���� ��������� + ����������� ������ ���������� �������
select name, is_licensed, foundation_date, adress
from Organisation
order by is_licensed DESC, foundation_date ASC

--� ����������� �� ������� ��������, �� ������ �����������
select name, is_licensed, foundation_date, adress
from Organisation
order by 1

-- 6. ������ � ������
--WHERE �� ����
select * from Organisation where foundation_date = '1985-05-05' 

--������� �� ������� �� ��� ����, � ������ ���.
select YEAR(foundation_date) from Organisation

-- 7. Select group by � ��������� ���������
-- Min
select is_licensed, MIN(foundation_date) as min_date
from Organisation
group by is_licensed

-- Max
select is_licensed, MAX(foundation_date) as max_date
from Organisation
group by is_licensed

-- Avg + where
select is_licensed, AVG(organisation_id) as avg_id
from Organisation where is_licensed = 1
group by is_licensed

--Sum
select is_licensed, SUM(organisation_id) as id_sum
from Organisation
group by is_licensed

--Select
select is_licensed, COUNT(*) as license_count
from Organisation
group by is_licensed

--8. SELECT GROUP BY + HAVING
select is_licensed, COUNT(*) as license_count
from Organisation
group by is_licensed
having COUNT(*) > 2

select is_licensed, SUM(organisation_id) as id_sum
from Organisation
group by is_licensed
having SUM(organisation_id) > 15

select is_licensed, MAX(foundation_date) as max_date
from Organisation
group by is_licensed
having MAX(foundation_date) between '1995-01-01' and '2004-12-31'

-- 9. SELECT JOIN
-- LEFT JOIN ���� ������ � WHERE �� ������ �� ���������
SELECT *
FROM Organisation
LEFT JOIN Teacher_in_organisation ON Organisation.organisation_id = Teacher_in_organisation.organisation_id WHERE teacher_in_organisation_id is not null

-- RIGHT JOIN. �������� ����� �� �������, ��� � � 5.1
SELECT top(3) name, is_licensed, foundation_date, adress
FROM Teacher_in_organisation
RIGHT JOIN Organisation ON Organisation.organisation_id = Teacher_in_organisation.organisation_id
order by foundation_date asc

-- LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������
SELECT Teacher.teacher_id, Teacher.full_name, teaching_group, Teacher.date_of_birth, Organisation.adress, Organisation.name
from Teacher
LEFT JOIN Teacher_in_organisation on Teacher_in_organisation.teacher_id = Teacher.teacher_id
LEFT JOIN Organisation on Organisation.organisation_id = Teacher_in_organisation.organisation_id
where Organisation.is_licensed = 1 and Teacher.date_of_birth is not null

-- FULL OUTER JOIN ���� ������
select * from Student
full OUTER join result
on Student.student_id = result.result_id

-- 10. ����������
-- �������� ������ � WHERE IN (���������)
select * from Organisation
where organisation_id IN(
    select organisation_id from Teacher_in_organisation
    group by organisation_id
)

--�������� ������ SELECT atr1, atr2, (���������) FROM ... 
select student_id, completion_date, (select result_id from Result where student_group = 'PS-31') as result
from Result