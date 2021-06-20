SET SERVEROUTPUT ON;

/* creare obiect car ce va contine numele, viteza si anul fabricatiei unei masini*/

drop type car force;
create or replace type car as object 
(
 nume varchar2(10),
 speed  number,
 an_fab number,
 member function upgrade_viteza(cip number ) return number,
 NOT FINAL member procedure display,
 map member function compar  return number,
 constructor function car(nume varchar2) return self as result
 
)NOT FINAL;
/

/*implementarea celor doua metode , constructorului explicit si a metodei de comparare MAP*/
create or replace type body car as 
member function upgrade_viteza(cip number) return number 
is 
BEGIN
  return speed + cip;
end upgrade_viteza;

member PROCEDURE display is 
begin 
     dbms_output.put_line('Masina '|| nume||' din '|| an_fab||' are '||speed); 
end display;

map member function compar return number is
begin 
 return an_fab;/* ordonarea o fac mereu dupa an fabriatie*/
end compar;

/*pentru o masina setez viteza 200 si an_fab  2019*/
constructor function car(nume varchar2)
return self as result
is
begin 
 self.nume := nume;
 self.speed := 200;
 self.an_fab := 2019;
 return ;
end;

end;
/

/*tabelul cu masini*/
drop table masini;
create table masini (ceva number,masina car);

/*subclasa masinutza si suprascriu afisarea*/
drop type masinutza force;
create or replace type masinutza under car 
(
  
  OVERRIDING member procedure display
)

/*implementarea */
create or replace type body masinutza  as
OVERRIDING member procedure display is
begin
 dbms_output.put_line('Electrica '|| nume||' nu e buna');
end display;
end;
 
/*bloc anonim ce demonstreaza functionalitatea*/
declare 
c1 car;
c2 car;
c3 car;
i number(3);
c4 masinutza;
begin

c1 := car('Volvo',100,2005);
c2 := car('Dacia',50, 1990);
dbms_output.put_line(c2.upgrade_viteza(23));
c3 := car('BMW');
c3.display;
c4 := masinutza('ElecTric', 200, 2020);
c4.display;

i:=0;
insert into masini values (i,c1);
i:=1;
insert into masini values (i,c2);
i:=2;
insert into masini values (i,c3);


end;

select * from masini; /*masinile neordonate */ 

select * from masini order by masina desc; /* masinile ordonate dupa anul aparitiei descrescator(cele mai noi -> cele mai vechi*/






