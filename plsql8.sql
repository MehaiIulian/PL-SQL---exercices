SET SERVEROUTPUT ON;

/*totul functioneaza cum trebuie*/
/* am creat doua proceduri una de exportare si una  de importare*/
/*la exportare am luat datele sub forma de string (datele separate prin virgule) pe care le scriu pe fiecare linie din fisierul note.csv*/

create or replace procedure export_to_file 
as 
  cursor ceva is select id||','||id_student||','||id_curs||','||valoare||','||data_notare||','||created_at||','||updated_at from note order by id ;
  v_fisier UTL_FILE.FILE_TYPE;
  v_row varchar2(4000);/*pt a salva datele*/
begin
  v_fisier:=UTL_FILE.FOPEN('MYDIR','note.csv','W');
  open ceva;
   loop 
   fetch ceva into v_row;
   exit when ceva%notfound;
   UTL_FILE.putf(v_fisier,'%s\n',v_row);
  end loop;
  close ceva;
  utl_file.fclose(v_fisier);
  
end;

/*importarea datelor din fisier.Pentru a lua datele separate prin virgula am folosit functia regexp_substr(). De asemenea , cand se gasesc date, aruncam si exceptie cand avem no_data_found pentru a nu avea erori(fara nu merge)
Pentru inspiratie am folosit https://profs.info.uaic.ro/~bd/wiki/index.php/Expresii_regulate si https://stackoverflow.com/questions/56329368/oracle-utl-file-read-csv-file-lines?fbclid=IwAR3bSLQygwYIVdGsP8CLbksYjrP0S9n2A8E9ee_liTrshzKyZhNbBpb20lU*/
create or replace procedure import_from_file as 
  v_fisier UTL_FILE.FILE_TYPE;
  v_row varchar2(4000);
BEGIN
  v_fisier:=UTL_FILE.FOPEN('MYDIR','note.csv','R');
  
   loop
   utl_file.get_line(v_fisier, v_row, 4000);
   insert into note values ( regexp_substr(v_row, '[^,]+', 1, 1),
   regexp_substr(v_row, '[^,]+', 1, 2),
   regexp_substr(v_row, '[^,]+', 1, 3),
   regexp_substr(v_row, '[^,]+', 1, 4),
   regexp_substr(v_row, '[^,]+', 1, 5),
   regexp_substr(v_row, '[^,]+', 1, 6),
   regexp_substr(v_row, '[^,]+', 1, 7)
   );
   end loop;
   
   utl_file.fclose(v_fisier);
   exception 
   when no_data_found then null;
   
   
end;

/*utilizarea celor doua operatii*/

BEGIN
 export_to_file;
 delete  from note where rownum < 17000;
 import_from_file;
end;


/*primele 2 proceduri rulate pe rand, apoi procedura cu cele 2 operatii si delete ,apoi acest select
pentru a vedea ca intr-adevar datele din note au fost importante cu succes inapoi*/
select * from note;





