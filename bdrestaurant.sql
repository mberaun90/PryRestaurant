
create database restaurant
go
use restaurant
go
create table categorias(
IDCAT varchar(7) NOT NULL PRIMARY KEY ,
	NOMCAT varchar(100) NULL)
go
insert into categorias values('CAT0001', 'POSTRES '),
	('CAT0002', 'VERDULERIAS'),
	('CAT0003', 'CARNE'),
	('CAT0004', 'POLLO'),
	('CAT0005', 'PESCADO'),
	('CAT0006', 'BEBIDAS '),
	('CAT0007', 'PANIFICACIÓN'),
	('CAT0008', 'SERVICIO DE MESA'),
	('CAT0009', 'PIZZERIA');
	go
create proc sp_Listar_categoria --'po'
@criterio varchar(50)
as
begin
select ROW_NUMBER() over(order by idcat)item,
c.IDCAT,c.NOMCAT
 from categorias c where  c.NOMCAT like '%'+@criterio+'%'
order by 1
	end
go
create proc sp_busqueda_categoria --'cat0001'
@cod varchar(50)
as
begin
select 
c.IDCAT,c.NOMCAT
 from categorias c where  c.idcat like '%'+@cod+'%'

	end
go


create proc sp_grabar_categoria --'','Sopas'
@codnew varchar(7) output,
@nom varchar(40)
as
declare @cnt int
select @cnt=COUNT(*) from categorias where NOMCAT =@nom

if(@cnt=0)
begin
--
declare @codmax varchar(7)
set @codmax=(select MAX(idcat) from categorias)
set @codmax=ISNULL(@codmax,'CAT0000')
set @codnew='CAT'+RIGHT(RIGHT(@codmax,4)+10001,4)
--print @codnew
insert into categorias values(@codnew,@nom)
--
end
go
create proc sp_modificar_categoria --'CAT0001','POSTRECITOS',''
@cod varchar(7),
@nomcat varchar(50),
@respta varchar(100) output
as
BEGIN
	declare @cnt int
	select @cnt=COUNT(*) from categorias where NOMCAT=@nomcat
	declare @flag int
	select @flag=COUNT(*) from categorias where IDCAT=@cod and NomCat=@nomcat
	
	if(@cnt=0 or @flag=1)
begin
--

--print @codmax
begin try
        begin transaction --inicio de la transacion
        set arithabort on --si hubiese errores cancela la consulta

begin
update categorias set NomCat=@nomcat
 where IDCAT=@cod
end
 set @respta='Se Modifico correctamente'
commit
	end try

	begin catch
	    if @@TRANCOUNT>0
	       begin
	         set @respta='Se produjo un erroor!!!'
	         rollback
	       end
	end catch
	end

else
	set @respta='No se Pudo Modificar !!!'
	
END
go

CREATE TABLE Productos(
	IDPRO varchar(7) NOT NULL PRIMARY KEY ,
	NOMPRO varchar(100) NULL,
	IDCAT varchar(7) NULL foreign key references categorias(idcat),
	PrePro decimal(11,2) not null,
	Stock int not null,
)
go
insert into productos values('PRO0001', 'Coca Kola','CAT0006',3.50,1000),
('PRO0002', 'INKA Kola','CAT0006',3.50,1000),
('PRO0003', 'Cerveza Pilsen','CAT0006',7.50,1000),
('PRO0004', 'Cerveza Corona','CAT0006',6.50,1000),
('PRO0005', 'Agua San Mateo','CAT0006',3.50,1000);
	
	go

create proc sp_Listar_productos  --'bebi','2'
@criterio varchar(50),
@opcion varchar(10)
as
if(@opcion='1') --por nombr prodc
	begin
select ROW_NUMBER() over(order by idpro)item,
p.IDpro,p.nompro,c.NOMCAT,p.prepro
 from productos p  inner join categorias c on p.idcat=c.idcat where  p.nompro like '%'+@criterio+'%'
order by 1
	end
---opcion 2 = categoria
else if(@opcion='2')
	begin
select ROW_NUMBER() over(order by idpro)item,
p.IDpro,p.nompro,c.NOMCAT,p.prepro
 from productos p  inner join categorias c on p.idcat=c.idcat where  c.nomcat like '%'+@criterio+'%'
order by 1
	end
go

create proc sp_grabar_producto 
@DesProd VARCHAR ( 100 ),
@Prepro DECIMAL ( 8, 2 ) ,
@Cod_Cat VARCHAR ( 7 ) ,
@Stock SMALLINT ,
@respta varchar(100) output
as
begin

declare @cnt int
select @cnt=COUNT(*) from Productos where NOMPRO=@DesProd

if(@cnt=0)
begin
--
declare @codmax varchar(7)
set @codmax=(select MAX(IDPRO) from Productos)
set @codmax=ISNULL(@codmax,'PROD000')
set @codmax='PROD'+RIGHT(RIGHT(@codmax,3)+1001,3)
print @codmax
begin try
        begin transaction --inicio de la transacion
        set arithabort on --si hubiese errores cancela la consulta

begin
insert into Productos values(@codmax,@DesProd,@Cod_Cat,@Prepro,@Stock)
end
 set @respta='Se grabo correctamente con el Codigo ' +@codmax
commit
	end try

	begin catch
	    if @@TRANCOUNT>0
	       begin
	         set @respta='Se produjo un Error!!!'
	         rollback
	       end
	end catch
	end

else
 set @respta='Ya Existe el Producto  ' +@DesProd

end
go




