set serveroutput on;

/*am creat o procedura ce parseaza urmatoarele: delete unui tabel care exista,crearea unuia si inserarea de date*/

create or replace procedure create_insert_table(id_c number) as
stmt varchar2(1000);
stmt1 varchar2(1000);
stmt2 varchar2(1000);
cursor_name integer;
cursor_name1 integer;
cursor_name2 integer;
row_processed integer;
v_nume varchar2(100);
nota number;
datanotare date;
nume_std varchar2(50);
prenume_std varchar2(50);
nr_mat varchar2(50);
begin
select titlu_curs into v_nume from cursuri where id=id_c;
v_nume := regexp_replace(v_nume, '[[:space:]]*','');
dbms_output.put_line(v_nume);

cursor_name2 := dbms_sql.open_cursor;
stmt2 := 'drop table '||v_nume;
dbms_sql.parse(cursor_name2,stmt2,dbms_sql.native);
row_processed:=dbms_sql.execute(cursor_name2);
dbms_sql.close_cursor(cursor_name2);

cursor_name :=dbms_sql.open_cursor;
/*Catalogul va contine nota, 
data notarii, 
numele, prenumele si numarul matricol al studentului ce a luat nota respectiva.*/
stmt := 'create table '||v_nume||' (nota number, 
data_notare date, 
nume varchar2(50), 
prenume varchar2(50), 
matricol varchar2(50)
)';
dbms_sql.parse(cursor_name,stmt,dbms_sql.native);
row_processed:=dbms_sql.execute(cursor_name);
dbms_sql.close_cursor(cursor_name);


for i in (select valoare,data_notare, nume,prenume,nr_matricol 
from studenti s join note n on n.id_student=s.id 
join cursuri c on c.id=n.id_curs where id_curs=id_c)
loop
cursor_name1 :=dbms_sql.open_cursor;
nota := i.valoare;
datanotare := i.data_notare;
nume_std := i.nume;
prenume_std := i.prenume;
nr_mat := i.nr_matricol;
stmt1 := 'insert into '||v_nume||' values ('||nota||','||datanotare||','||nume_std||','||prenume_std||','||nr_mat||')';
dbms_sql.parse(cursor_name1,stmt1,dbms_sql.native);
row_processed:=dbms_sql.execute(cursor_name1);
dbms_sql.close_cursor(cursor_name1);
end loop;
end;

begin
 create_insert_table(3);
end;

select table_name from user_tables;
select * from INTRODUCEREÎNPROGRAMARE;

describe note;

select titlu_curs from cursuri;



describe studenti;
select valoare,data_notare, nume,prenume,nr_matricol from studenti s join note n on n.id_student=s.id join cursuri c on c.id=n.id_curs where id_curs=3;