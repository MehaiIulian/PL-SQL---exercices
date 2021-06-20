SET SERVEROUTPUT ON;

/*A functionat tot si am luat prin exemplu. Am inceput prin a crea view ul, cu nume,prenume,nota si materia la care are nota */
drop view catalog;
create or replace view catalog as select s.nume,s.prenume,n.valoare,c.titlu_curs from studenti s join note n on s.id=n.id_student join cursuri c on n.id_curs=c.id group by s.nume,s.prenume,c.titlu_curs,n.valoare;
select * from catalog;


/* urmatoarele comenzi le am efectuat pentru a vedea constrangerile care sunt aplicate si ce valori trebuie introduce obligatoriu*/
describe studenti;
describe note;
describe cursuri;

/*Primul trigger insert. Voi explica detaliat in bloc idea ce sta la baza*/
drop trigger operatie_insert;
CREATE OR REPLACE TRIGGER operatie_insert
   INSTEAD OF INSERT  ON catalog
DECLARE
val_stud number;
val_cursuri number;
val_line number(38);
val_matricol studenti.nr_matricol%type;
val_line_note number(38);
val_line_cursuri number(38);
rand_mat studenti.nr_matricol%type;
rand_an studenti.an%type;
rand_grupa studenti.grupa%type;
rand_bursa studenti.bursa%type;
rand_credite cursuri.credite%type;
rand_semestru cursuri.semestru%TYPE;
id_stud studenti.id%type;
id_curs cursuri.id%type;
/*declarari*/

BEGIN
  dbms_output.put_line('Operatia INSERT in view catalog !');
  select count(id) into val_stud from studenti where nume=:NEW.nume and prenume=:new.prenume;/*verific daca exista student*/
  select count(id) into val_cursuri from cursuri where titlu_curs=:NEW.titlu_curs;/*verific daca exista curs*/
  
  rand_mat:=DBMS_random.string('X',6);
  rand_grupa:=DBMS_random.string('X',2);
  rand_bursa:=DBMS_random.value(100,500);
  rand_an:=DBMS_random.value(1,3);
  rand_credite:=DBMS_random.value(4,6);
  rand_semestru:=DBMS_random.value(1,3);
  /*generez valori random*/
  
  /*primul caz cand nu exista nici cursul nici studentul ,deci adaugam ambele valori in tabelele corespunzatoare.
  Pentru a adauga am luat valoare max a ultimei linii adaugate si am adaugat dupa aceasta*/
  if(val_stud = 0 and val_cursuri = 0) then
  BEGIN
  select max(id) into val_line from studenti;
  select max(id) into val_line_note from note;
  select max(id) into val_line_cursuri from cursuri;
  insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa) values (val_line+1,rand_mat,:NEW.nume,:NEW.prenume,1,rand_grupa,rand_bursa);
  insert into cursuri(id,titlu_curs,an,semestru,credite) values(val_line_cursuri+1,:NEW.titlu_curs,rand_an,rand_semestru,rand_credite);
  insert into note(id,id_student,id_curs,valoare) values(val_line_note+1,val_line+1,val_line_cursuri+1,:NEW.valoare);
  END;
  end if;
  
  /*al doilea caz cand avem studentul dar nu aveam cursul.Ideea este aceeasi cu id-ul max , dar din cauza ca studentul exista ,vom prelua doar id ul existent,nu vom mai adauga*/
  if(val_stud > 0 and val_cursuri = 0) then 
  begin
  select id into id_stud from studenti where nume=:NEW.nume and prenume=:NEW.prenume;
  select max(id) into val_line_cursuri from cursuri;
  select max(id) into val_line_note from note;
  insert into cursuri(id,titlu_curs,an,semestru,credite) values(val_line_cursuri+1,:NEW.titlu_curs,rand_an,rand_semestru,rand_credite);
  insert into note(id,id_student,id_curs,valoare) values(val_line_note+1,id_stud,val_line_cursuri+1,:NEW.valoare);
  end;
  end if;
  
  /*Al treilea caz.Viceversa cu cel anterior (exista curs si nu student)*/
  if(val_stud = 0 and val_cursuri > 0) then
  begin
  select id into id_curs from cursuri where titlu_curs=:NEW.titlu_curs;
  select max(id) into val_line from studenti;
  select max(id) into val_line_note from note;
  insert into studenti(id,nr_matricol,nume,prenume,an,grupa,bursa) values (val_line+1,rand_mat,:NEW.nume,:NEW.prenume,1,rand_grupa,rand_bursa);
  insert into note(id,id_student,id_curs,valoare) values(val_line_note+1,val_line+1,id_curs,:NEW.valoare);
  end;
  end if;
END;
  
/*interogari efectuate pentru a testa interogarea.Le am efectuat pe rand pe fiecare*/  
insert into catalog values ('Popescu', 'Mircea', 10, 'Yoga');/* nu curs nu student*/
insert into catalog values ('Popescu', 'Mircea', 5 , 'LoL'); /*nu curs ,student existent*/
insert into catalog values ('Mihai', 'Iulian', 7, 'Yoga');/*nu student,curs existent*/
select * from catalog where titlu_curs='Yoga';


/*Trigger delete.Am luat id-ul corespunzator numelui si prenumelui dat de comanda delete catalog.. . Am sters din studenti studentul respectiv si notele lui*/
drop trigger operatie_delete;
CREATE OR REPLACE TRIGGER operatie_delete
   INSTEAD OF DELETE  ON catalog
DECLARE 
idstudent number(38);
BEGIN
  dbms_output.put_line('Operatia delete in view catalog !');
    select id into idstudent from studenti where nume=:OLD.nume and prenume=:OLD.prenume;
    delete from note where id_student = idstudent;
    delete from studenti where id= idstudent;
  
END;

/*exemple interogari. Pentru mircea avem id 1026 si 2 note iar pentru Mihai Iulian cu id ul 1027 si o nota*/
select * from note;
delete from catalog where nume='Mihai' and prenume='Iulian';/*l am sters pe mihai iulian si notele lui*/
select * from catalog where nume='Popescu' and prenume='Mircea';/*pentru a vedea notele lui mircea popescu*/
/*select * from note where id_student=1027;*/
select * from catalog where nume='Mihai' and prenume='Iulian';/*verificam daca a fost sters*/



/*Trigger update. La fel ca la delete , am luat id ul studentul a carui nume este dat in update si id ul cursului la care se doreste marirea note*/
drop trigger operatie_update;
CREATE OR REPLACE TRIGGER operatie_update
   INSTEAD OF UPDATE  ON catalog
DECLARE

idstd number;
idcrs number;
nota number;

BEGIN
  dbms_output.put_line('Operatia update in view catalog !');
  select id into idstd from studenti where nume=:NEW.nume and prenume=:NEW.prenume;
  select id into idcrs from cursuri where titlu_curs=:NEW.titlu_curs;
  select valoare into nota from note where id_student=idstd and id_curs=idcrs;
  /*intrebam intai daca noua valoare este mai mare decat nota actuala.Daca nu este mai mare nu are rost sa o schimbam*/
  /*este adaugata si data la care a fost modificata nota */
  if(nota < :NEW.valoare) then update note set valoare = :NEW.valoare,created_at=to_date(sysdate) where id_student=idstd and id_curs=idcrs;
  end if;
  
  
END;

/*interogari exemple. Inainte mircea avea nota 5 la LoL (vedeti insert ul) si acum va avea nota 8 in urma maririi*/
update catalog set valoare = 8 where nume='Popescu' and prenume='Mircea' and titlu_curs='LoL';
select * from note where id_student=1026;


