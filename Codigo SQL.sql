CREATE TABLE Ubicaciones(
    U_ID SERIAL PRIMARY KEY ,
    Latitud FLOAT NOT NULL ,
    Longitud FLOAT NOT NULL,
    Comuna VARCHAR(30) NOT NULL,
    Region VARCHAR(30) NOT NULL,
    Numeracion INT NOT NULL,
    C_POSTAL INT NOT NULL
);

CREATE TABLE Sucursal_Farmacia(
    F_ID SERIAL PRIMARY KEY ,
    Cadena VARCHAR(30) NOT NULL,
    Horario_Apertura TIME NOT NULL,
    Horario_Cierre TIME NOT NULL,
    U_ID INT NOT NULL,
    CONSTRAINT fk_Ubi
        FOREIGN KEY (U_ID)
            REFERENCES Ubicaciones(U_ID)

);

CREATE TABLE Laboratorio(
    L_ID SERIAL PRIMARY KEY ,
    Ubicacion VARCHAR(30) NOT NULL,
    Numeracion INT NOT NULL,
    Telefono INT NOT NULL,
    Dueño VARCHAR(30)
);

CREATE TABLE Medicamento(
    M_ID SERIAL PRIMARY KEY ,
    L_ID INT NOT NULL,
    Precio INT NOT NULL,
    Dosis FLOAT NOT NULL,
    Nombre_Comercial VARCHAR(30),
    Fecha_Caducidad DATE NOT NULL,
    Principio_Activo VARCHAR(40),
    Excipiente VARCHAR(40),
    CONSTRAINT fk_lab
        FOREIGN KEY (L_ID)
            REFERENCES Laboratorio(L_ID)
);


CREATE TABLE Farmacia_Vende(
    V_ID SERIAL PRIMARY KEY ,
    F_ID INT NOT NULL ,
    M_ID INT NOT NULL,
    CONSTRAINT fk_suc
        FOREIGN KEY (F_ID)
            REFERENCES Sucursal_Farmacia(F_ID),
    CONSTRAINT fk_Med
        FOREIGN KEY (M_ID)
            REFERENCES Medicamento(M_ID)
);

CREATE TABLE Cliente(
    C_ID serial PRIMARY KEY ,
    RUT VARCHAR(15) NOT NULL ,
    Metodo_Pago VARCHAR(20) NOT NULL ,
    Fecha_Compra DATE NOT NULL ,
    Hora_Compra TIME NOT NULL ,
    Nombre VARCHAR(40) NOT NULL ,
    Apellido VARCHAR(40) NOT NULL,
    Edad INT NOT NULL ,
    Mail VARCHAR(50) NOT NULL,
    Contacto INT NOT NULL ,
    U_ID INT NOT NULL,
    CONSTRAINT fk_ubi
        FOREIGN KEY (U_ID)
            REFERENCES Ubicaciones(U_ID)
);

CREATE TABLE Cliente_Desea(
    W_ID SERIAL PRIMARY KEY ,
    C_ID INT NOT NULL,
    M_ID INT NOT NULL,
    CONSTRAINT fk_Cli
        FOREIGN KEY (C_ID)
            REFERENCES Cliente(C_ID),
    CONSTRAINT fk_Med
        FOREIGN KEY (M_ID)
            REFERENCES Medicamento(M_ID)
);

create table Papelera(
    P_id int primary key,
    RUT VARCHAR(15),
    Metodo_Pago VARCHAR(20) ,
    Fecha_Compra DATE ,
    Hora_Compra TIME ,
    Nombre VARCHAR(40),
    Apellido VARCHAR(40),
    Edad INT,
    Mail VARCHAR(50),
    Contacto INT ,
    U_ID INT ,
    CONSTRAINT fk_ubi
        FOREIGN KEY (U_ID)
            REFERENCES Ubicaciones(U_ID)
);

/**
 * Trigger 1: El primer trigger se encarga de mover todos los clientes que se desea eliminar y los lleva a la tabla "papelera"
 */
create or replace function cementerio() returns trigger
as
    $$
    begin
        insert into papelera select * from Cliente where Nombre=old.Nombre;
        return old;
    end
    $$
language plpgsql;

create trigger Vaciado before delete on cliente
    for each row
    execute procedure cementerio();

/** Trigger 2: Cada vez que se agrega una ubicación dentro de la comuna de La Reina, este manda un mensaje a la consola recordando que deben llamar a la
  municipalidad para conseguir la información adicional.
 */
create or replace function Mensaje() returns trigger
as
    $$
    begin
    if(new.comuna = 'La Reina') then
    raise notice 'Tienes que llamar a la municipalidad de La Reina por la información adicional';
    end if;
    return new;
    end
    $$
language plpgsql;

create trigger Oferta after insert or update on Ubicaciones
    for each row
    execute procedure Mensaje();

/**Trigger 3: En este futuro que hemos propuesto, se ha nacionalizado la producción de paracetamol, dejandolo en un precio fijo de $1000. sin importar el
  laboratorio de origen.
 */
create or replace function nacionalizacion() returns trigger
as
    $$
    begin
        if new.Principio_Activo='Paracetamol' then new.precio=1000;
    end if;
      return new;
    end;
    $$
language plpgsql;

create trigger fijar_precios before insert or update on Medicamento
    for each row
    execute procedure nacionalizacion();


INSERT INTO Ubicaciones(latitud, longitud, comuna, region, numeracion, c_postal)
VALUES (-33.452669607076174, -70.56228653277687, 'La Reina', 'Metropolitana', 6564, 7850383),
       (-33.45272331614641, -70.56122437816327, 'La Reina', 'Metropolitana', 6637, 7850392),
       (-33.45330963788599, -70.57194784992178, 'Ñuñoa', 'Metropolitana', 5662, 7750495),
       (-33.44788996832493, -70.58079063933535, 'Ñuñoa', 'Metropolitana', 4800, 7750300),
       (-33.470302895098285, -70.56849539118822, 'Peñalolen', 'Metropolitana', 1720, 7910745),
       (-33.4422527898765, -70.5729614990182,'Ñuñoa', 'Metropolitana',1220, 7750945 ),
       (-33.44805387294492, -70.57660930234266, 'Ñuñoa', 'Metropolitana',671, 7750488),
       (-33.4520444963704, -70.56947557257298, 'La Reina', 'Metropolitana', 5862, 7870154),
       (-33.45213401209692, -70.56994764131464, 'La Reina', 'Metropolitana', 5862, 7870154),
       (-33.45320819360808, -70.56979743762412, 'La Reina', 'Metropolitana', 5862, 7870154);

INSERT INTO Sucursal_Farmacia(Cadena, Horario_Apertura, Horario_Cierre, U_ID)
VALUES ('Salco Brand', '8:00:00', '21:00:00', 1),
       ('Farmacias Ahumada', '8:00:00', '21:00:00', 2),
       ('Cruz Verde', '8:00:00', '21:00:00', 3),
       ('Salco Brand', '8:00:00', '21:00:00', 4),
       ('La Botika', '8:00:00', '21:00:00', 5),
       ('Salco Brand', '8:00:00', '21:00:00', 6),
       ('Cruz Verde', '8:00:00', '21:00:00', 7),
       ('Salco Brand', '8:00:00', '21:00:00', 8),
       ('Cruz Verde', '8:00:00', '21:00:00', 9),
       ('Dr Simi', '8:00:00', '21:00:00', 10);

INSERT INTO Laboratorio (ubicacion,numeracion,telefono,dueño)
    VALUES ('Av. Pedro de valdivia', 1215, 225949200,'Laboratorio Tecnofarma'),
           ('Isidora Goyenechea',3477,223731300,'Astrazeneca Sa'),('Luis Thayer Ojeda',166,222442526,'ISDIN'),
           ('Andres Bello',2457,225208200,'Bayer'),('Cerro El Plomo',5630,800365365,'Laboratorio Roche'),
           ('Cerro Colorado',5240,222320756,'Johnson & Johnson'),('La Concepcion',191,226586069,'D&M Pharma'),
           ('Alfredo Barros Errazuriz',1900,223659615,'Deutsche Pharma'),('Isidora Goyenechea',2934,226513500,'Ferrer Chile'),
           ('Av Vitacura',2909,224350377,'Laboratorios Garden House');

INSERT INTO medicamento (L_ID, Precio, Dosis, Nombre_Comercial, Fecha_Caducidad, Principio_Activo, Excipiente)
    VALUES (1,899,500,'Paracetamol','01/01/2022','Paracetamol','Acetaminofeno'),(2,2099,600,'Ibuprofeno','02/02/2022','Ibuprofeno','fosfato tricálcico'),
           (3,4899,500,'Amoxicilina','03/03/2022','trihidrato','Aspartamo (E-951)'),(4,2399,50,'Losartan','04/04/2022','losartán potásico',' lactosa monohidrato'),
           (5,1299,10,'Ketorolaco Trometamol','05/05/2022','Ketorolaco trometamol','Etanol'),(6,2199,50,'Ketoprofeno','06/06/2022','Ketoprofeno','Almidón de maíz'),
           (7,1599,500,'Acido Mefenamico','07/07/2022','ACIDO MEFENAMICO','Almidón glicolato de sodio'),(8,799,4,'Clorfenamina','08/08/2022','Clorfenamina maleato','Almidón glicolato de sodio'),
           (9,5599,550,'Naproxeno','09/09/2022','Naproxeno sódico','Polividona'),(10,1199,20,'Famotidina','10/10/2022','Famotidina','Lactosa'),
           (8,1695,600,'Ibuprofeno','05/04/2022','Ibuprofeno','fosfato tricálcico'),(1,1795,100,'Trimebutino','04/08/2022','Trimebutina Maleato','Lactosa Monohidrato'),
           (3,945,500,'Paracetamol','03/09/2022','Paracetamol','Acetaminofeno'),(5,7395,500,'Amoxicilina','07/03/2022','trihidrato','Aspartamo (E-951)'),
           (8,1545,5,'Enalapril','08/04/2022','enalapril cinfa','sorbitol'),(3,1345,10,'Loratadina','07/03/2022','Loratadina NORMON',' Benzoato de sodio (E-211)'),
           (2,1295,500,'Kitadol','02/07/2022','Paracetamol','Almidón pregelatinizado'), (9,4095,100,'Aspirina','04/08/2022', 'ácido acetilsalicílico', 'Citrato de sodio'),
           (5,26295,200,'Prolopa','09/07/2022', 'levodopa-benserazida', 'Estearato de magnesio'),(9,35395,40,'Neuleptil','05/06/2022', 'Periciazina', 'Periciazina'),
           (7, 13695, 100,'Lertus', '04/20/2022', 'Diclofenaco sodico', 'c.s'),
           (9, 1790, 500, 'Cloxacilina', '04/24/2022',  'Cloxacilina', 'Sodio'),
           (4, 29570, 500, 'Keppra Levetiracetam', '04/21/2022', 'Levetiracetam', 'Parahidroxibenzoato de metilo'),
           (5, 1390, 20, 'Omeprazol', '04/22/2022', 'Omeprazol normon', 'Manitol'),
           ( 6, 25695, 25, 'Quetidin', '04/23/2022', 'Quetiapina', 'Celulosa microcristalina'),
           ( 8, 10795, 100, 'Quetiapina', '04/23/2022', 'Quetiapona fumarato', 'Lactosa monohidrato'),
           ( 3, 12095, 25, 'Oticum', '04/27/2022','Oticum', 'Polimixina'),
           ( 2, 1099, 10, 'Diazepam', '04/28/2022', 'Diazepam', 'Lactosa'),
           ( 8, 14895, 50, 'Tramal',' 05/20/2022', 'Hidrocloruro', 'Tartrazina'),
           ( 1, 15495, 10, 'Domperidona', '06/30/2022', 'Maleato', 'Sorbitol'),
           ( 8, 14895, 10, 'Idon', '08/15/2022', 'Domperidona', 'c.s.'),
           ( 9, 15695, 15, 'Nastizol', '10/07/22', 'Clorfenamina', 'Anhídrido Silícico Coloidal'),
           ( 7, 13195, 10, 'Rinobanedif', '04/04/2022', 'Bacitracina-zinc', 'Neomicina Sulfato'),
           ( 5, 7895, 10, 'Rigotax', '05/04/2022','Cetirizina', 'Celulosa microcristalina'),
           ( 4, 35095, 50, 'Bagomicina', '11/04/2022', 'Minociclina', 'Clorhidrato');
INSERT INTO farmacia_vende (F_ID, M_ID)
VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(6,6),
(7,7),
(8,8),
(9,9),
(10,10);
INSERT INTO Cliente (RUT, Metodo_Pago, Fecha_Compra, Hora_Compra, Nombre, Apellido, Edad, Mail, Contacto, U_ID)
VALUES
    ('7.477.226-9', 'EFECTIVO','4/2/2021','11:20:11','Jose Antonio','Kast', 55, 'pepetoño@gmail.com', 912315569, 10),
    ('10.951.413-6	', 'CREDITO','4/20/2021','16:20:00','Felipe','Kast', 44, 'tiopipe@gmail.com', 942314469, 9),
    ('13.191.172-6	', 'DEBITO','11/6/2021','17:17:11','Sebastian','Sichel', 44, 'elindependiente@gmail.com', 932313369, 8),
    ('8.653.179-8', 'CREDITO','10/17/2021','14:23:58','Yasna','Provoste', 51, '600Musd@gmail.com', 952312269, 7),
    ('6.195.038-9', 'EFECTIVO','11/28/2021','15:30:45','Eduardo','Artes', 70, 'rojoreal@gmail.com', 992311169, 6),
    ('6.872.197-0', 'DEBITO','11/23/2021','7:50:17','Franco','Parisi', 54, 'papitocorazon@gmail.com', 972317769, 5),
    ('13.436.389-4', 'EFECTIVO','9/19/2021','18:33:55','Marco Enrique','Ominami', 48, 'ahorasiquesi@tvn.cl', 982318869, 4),
    ('16.163.631-2', 'CREDITO','7/21/2021','9:28:23','Gabriel','Boric', 35, 'noconozcolacifra@gmail.com', 922319969, 3),
    ('9.400.544-2', 'DEBITO','5/14/2021','11:22:44','Daniel','Jadue', 54, 'camaradajd@gmail.com', 932316669, 2),
    ('5.126.663-3', 'CREDITO','3/11/2021','13:30:31','Sebastian','Piñera', 71, 'sebastian.piraña@gmail.com', 942315369, 1);


    INSERT INTO Cliente_Desea (C_ID, M_ID)
    VALUES
        (10, 3),
        (9, 2),
        (8, 1),
        (7, 4),
        (5, 5),
        (5, 6),
        (4, 7),
        (3, 8),
        (2, 9),
        (1, 10);


delete from cliente where C_ID=6;
