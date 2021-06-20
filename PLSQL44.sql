--obiect pentru a pastra media din fiecare din fiecare semestru 
CREATE TYPE tip as OBJECT
(
    medie NUMBER,
    an NUMBER,
    sem NUMBER
);
/

--declarare tip nested_table
CREATE TYPE my_table_medie AS TABLE OF tip;
/

--adaugare coloana
ALTER TABLE STUDENTI ADD medii my_table_medie nested table medii STORE AS space_storage_tab;
/


--parcurge id-urile studentilor si de fiecare data cand v_id = id(din tabela studenti) in variabila v_lista(nested_table) imi adaug mediile calculate pentru fiecare an in fiecare semestru
DECLARE
    v_lista my_table_medie;
    cursor std is select id from studenti order by id asc;
    v_id std%rowtype;
   
BEGIN
    open std;
    LOOP
    fetch std into v_id;
    exit WHEN std%notfound;
    select tip(avg(n.valoare),c.an,c.semestru) bulk collect into v_lista from note n join cursuri c on n.id_curs=c.id where n.id_student= v_id.id group by n.id_student,c.an,c.semestru;--extragere medii
    update studenti set medii = v_lista where id=v_id.id;--setare coloana cu mediile calculate mai sus
    
    end loop;
    close std;
end;

select * from studenti;
/

--returnez numarul de medii pentru un id
create function numara_medii(v_id STUDENTI.ID%TYPE)
    RETURN NUMBER AS
    v_medii studenti.medii%TYPE;
BEGIN
    select medii into v_medii from studenti where id=v_id;
    RETURN v_medii.count;
end;
SELECT numara_medii(22) FROM DUAL;


