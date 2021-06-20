SET SERVEROUTPUT ON;

--adaugarea constrangerii
alter table note add constraint unique_key unique (id_student,id_curs);
describe note

--interogari doar ca sa vad ce se intampla
select * from note;
select count(*) from note;


--sa vedeti daca exista nota (cu count, cum deja ati mai facut) pentru studentul X la logica si sa inserati doar daca nu exista. Numaram notele la logica si daca valoarea = 0 inser
--prima metoda cu count
create or replace procedure ADD_NOTA(i note.id%type) AS
n NUMBER(10);
new_line note.id%type;

BEGIN
select count(id) into new_line from note;

select count(*) into n from note where id_student = 100 and id_curs = 1;

if(n = 0 ) then INSERT INTO NOTE(ID, ID_STUDENT, ID_CURS, VALOARE) VALUES (new_line + i, 100 , 1 , 10);
end if;
end;

--incercam de 1000000 de ori sa inseram nota 10 pentru studentul 100  la materia Logica(cu id = 1)
BEGIN
for i in 1..1000000
loop
add_nota(i); -- > la 1000 imi lua 0.2 sec, la 10000 imi lua 2 secunde, la 100000 25 de secunde si la 1000000 >2 minutes   
end loop;
end;
 

--cea de a doua metoda cu aruncarea exceptiei 
create or replace procedure ADD_NOTA_WITH_EXCEPTION(i note.id%type) AS
new_line note.id%type;

BEGIN
select count(id) into new_line from note;

  INSERT INTO NOTE(ID, ID_STUDENT, ID_CURS, VALOARE) VALUES (new_line + i , 100 , 1 , 10);
  exception
     when DUP_VAL_ON_INDEX then dbms_output.put_line('Nu se puede');
end;


--incercam de 1000000 de ori sa inseram nota 10 pentru studentul 100  la materia Logica(cu id = 1)
BEGIN
for i in 1..1000000
loop
add_nota_with_exception(i); --~40 seconds 
end loop;
end;


--functie pentru returnarea mediei return 0 daca nu exista studentul si return medie altfel (aruncarea exceptiei o fac in blocul anonim)
create or replace function medie_student(p_nume studenti.nume%type , p_prenume studenti.prenume%type)
return NUMBER as
medie note.valoare%type;
numar_note note.valoare%type;

begin
select avg(n.valoare),count(n.valoare) into medie,numar_note from note n join studenti s on n.id_student=s.id where s.nume = p_nume and s.prenume = p_prenume;
if (numar_note = 0) then return 0;
else return medie;
end if;
end;

/*BEGIN
 DBMS_OUTPUT.PUT_LINE(medie_student('u','Andreea')); -- da 6,doar pentru testat functia 
end;*/



--bloc anonim pentru verificarea celor 6 studenti noi introdusi intr-o colectie de tip nested table (de tip obiect) ce tine minte numecomplet a fiecarui student.
create or replace type numecomplet as object
(
 nume varchar(10),
 prenume varchar(10)
);

DECLARE 
TYPE my_nested_table is table of numecomplet;
var_nt my_nested_table;
valoare note.valoare%type;
student_inexistent exception;
PRAGMA EXCEPTION_INIT(student_inexistent, -20001);

begin
--initialiez lista cu 3 studenti existenti si 3 neexistenti
var_nt := my_nested_table(numecomplet('Tifrea','Maria'),numecomplet('Giosanu','Andreea'),
                          numecomplet('Mihai','Iulian'),numecomplet('Mihaela','Iuliana'),numecomplet('Riscanu','Iolanda'),numecomplet('Popescu','Vlad'));
--primii studenti sunt existenti ,ceilalti nu

for i in 1..var_nt.count--parcurgem si verificam fiecare studenti din structura
loop
begin
valoare:=medie_student(var_nt(i).nume,var_nt(i).prenume);
if(valoare = 0) then raise student_inexistent;--verificam ce returneaza functia
end if;
DBMS_OUTPUT.PUT_LINE('Media este'||' '||valoare);
exception
  when student_inexistent then DBMS_OUTPUT.PUT_LINE('Studentul dat nu exista in DB');
end;
end loop;


end;

--https://we.tl/t-d6Ch6O5qrJ
