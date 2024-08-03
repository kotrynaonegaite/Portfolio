#1.Pateikite tik tuos mokėjimus, kurių vertė (amount) yra didesnė nei 2. Naudokite lentelę payment.(1t)#

select * from sakila.payment where amount > 2;
----
#2. Pateikite filmus, kurių reitingas (rating) yra „PG“, o pakeitimo kaina (replacement_cost) yra mažesnė
#nei 10. Naudokite lentelę film.(1t)#

select * from sakila.film where rating = 'PG' and replacement_cost <10;
-----
#3. Suskaičiuokite vidutinę nuomos kainą (rental_rate) kiekvieno reitingo filmams, atsakymą pateikite tik
#su 2 skaičiais po kablelio. Ne apvalinti! Tiesiog „nupjauti“ atsakymą ties dviem skaičiais po kablelio. Naudokite lentelę film.(1t)#

select rating, truncate(avg(rental_rate), 2) as 'Vid. nuomos kaina' from sakila.film group by rating;
----
#4. Išspausdinkite visų klientų vardus (first_name), o šalia vardų stulpelio suskaičiuokite kiekvieno vardo
#ilgį (kiek varde yra raidžių). Naudokite lentelę customer. (1t)#

select first_name, length(first_name) as 'Vardo ilgis' from sakila.customer;
----
#5. Ištirkite kelinta raidė yra „e“ kiekvieno filmo aprašyme (description). Naudokite lentelę film.(1t)#

select title, description, locate('e', description) as 'E raides pozicijos sk' from sakila.film;
----
#6. Susumuokite kiekvieno reitingo (rating) bendrą filmų trukmę (length). Išspausdinkite tik tuos reitingus,
#kurių bendra filmų trukmė yra ilgesnė nei 22000.Naudokite lentelę film. (2t)#

select rating, sum(length) as 'Bendras filmu ilgis' from sakila.film group by rating having sum(length) >22000;
---
#7. Išspausdinkite visų filmų aprašymus (description), šalia išspausdinkite aprašymus sudarančių
#elementų skaičių. Trečiame stulpelyje išspausdinkite aprašymų elemetnų skaičių, juose visas raides „a“
#pakeisdami į „OO“. Tai reiškia turite aprašyme visas raides „a“ pakeisti į „OO“ ir tada suskaičiuoti naujo
#objekto elementų skaičių. Naudokite lentelę film_text. (2t)#

select description, length(description) as 'Aprasymo elementu sk.', length(replace(description, 'a', '00')) 'Aprasymo elementu sk. kai vietoje "a" pakeiciama i "00"' from sakila.film_text;
---
#8. Parašykite SQL užklausą, kuri suskirstytų filmus pagal jų reitingus (rating) į tokias kategorijas:
#Jei reitingas yra „PG“ arba „G“ tada „PG_G“
#Jei reitingas yra „NC-17“ arba „PG-13“ tada „NC-17-PG-13“
#Visus kitus reitingus priskirkite kategorijai „Nesvarbu“
#Kategorijas atvaizduokite stulpelyje „Reitingo_grupe“. Naudokite lentelę film.(3t)#

select 
film_id,
title,
case
when rating = 'PG' or rating = 'G' then 'PG_G'
when rating = 'NC-17' or rating = 'PG-13' then 'NC-17-PG-13'
else 'Nesvarbu'
end as Reitingo_grupe
from sakila.film;
----
#9. Susumuokite nuomavimosi trukmę (rental_duration), kiekvienanai filmo kategorijai (name).
#Išspausdinkite tik tas kategorijos, kurių rental_duration suma yra didesnė nei 300. Užduotį atlikite
#apjungiant lenteles. Naudokite lenteles film, film_category, category. (3t)#

select
c.name,
sum(a.rental_duration) as 'Nuomos trukme is viso'
from sakila.film a
left join sakila.film_category b on a.film_id = b.film_id
left join sakila.category c on b.category_id = c.category_id
group by c.name
having sum(a.rental_duration) > 300;
-----
#10.Pateikite klientų vardus (first_name) ir pavardes (last_name), kurie išsinuomavo filmą „AGENT
#TRUMAN“. Užduotį atlikite naudodami subquery. Užduotis atlikta teisingai be subquery vertinama 2t.
#Naudokite lenteles customer, rental, inventory, film. (4t)

select first_name, last_name from sakila.customer where customer_id in (
select customer_id from sakila.rental where inventory_id in (
select inventory_id from sakila.inventory where film_id in (
select film_id from sakila.film where title = 'AGENT TRUMAN')));
------
#11-toje užduotyje atliekamos užduotys sukuriant lentelės kopiją. Todėl jei gaunate "safe update"
#klaidą prieš pagrindinį query paleiskite komandą SET SQL_SAFE_UPDATES=0;;
#11.1 Sukurkite lentelę pavadinimu FILMFILTR ir į ją patalpinkite:
#11.1.1. Lentelėje FILMFILTR patalpinkite 8 užduotyje sukurtą lentelę, bet tik reitingus PG_G pagal naujai
#sukurtą filtrą. Lentelėje patalpinkite tik Film_id, title, desription, rating, bei naujai sukurtą reitingą
#(PG_G)

CREATE TABLE FILMFILTR (
Film_id integer, 
title varchar(255), 
desription varchar(255), 
rating varchar(255),
PG_G_ratingas varchar(255));

Alter table sakila.FILMFILTR
change column desription description varchar(255);

Insert into sakila.FILMFILTR (
Film_id,
title, 
description, 
rating,
PG_G_ratingas)
select 
Film_id,
title, 
description, 
rating,
case
when rating = 'PG' or rating = 'G' then 'PG_G'
when rating = 'NC-17' or rating = 'PG-13' then 'NC-17-PG-13'
else 'Nesvarbu'
end as Reitingo_grupe
from sakila.film;

---
#11.2.1 Sukurkite laikiną lentelę pavadinimu AKTORSK ir į ją patalpinkite:
#11.2.2 Lentelėje AKTORSK patalpinkite kiek aktorių (kiekis) vaidino konkrečiame filmo numeryje.

Create temporary table
AKTORSK
select
b.title,
count(a.actor_id) as 'Aktoriu sk. is viso'
from sakila.film_actor a
left join sakila.film b on a.film_id = b.film_id
group by b.title;
----
#11.3.1. Apjunkite naujai sukurtas lenteles ir atvaizduokite kiek konkrečiame filme film_id, title,
#description, rating, ir naujai sukurtą reitingą vaidino aktorių.
#11.3. Rezultatą pateikite naujai sukurtoje lentelėje REZULTATAS.
#11.4. Parašykite kodą arba kodus kuris ištrintu visas laikinas ir ne laikinas lenteles.

select 
a.film_id, 
a.title,
a.description,
a.rating,
a.PG_G_ratingas,
b.`Aktoriu sk. is viso`
from sakila.FILMFILTR a
left join sakila.AKTORSK b on a.title = b.title;

CREATE TABLE REZULTATAS (
film_id integer,
title varchar(255),
description varchar(255),
rating varchar(255),
PG_G_ratingas varchar(255),
`Aktoriu sk. is viso` varchar(255));

Insert into sakila.REZULTATAS (
film_id,
title,
description,
rating,
PG_G_ratingas,
`Aktoriu sk. is viso`)
select 
a.film_id, 
a.title,
a.description,
a.rating,
a.PG_G_ratingas,
b.`Aktoriu sk. is viso`
from sakila.FILMFILTR a
left join sakila.AKTORSK b on a.title = b.title;

DROP TABLE sakila.AKTORSK;
DROP TABLE sakila.REZULTATAS;
DROP TABLE sakila.FILMFILTR ;