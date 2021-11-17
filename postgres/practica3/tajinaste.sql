-- -----------------------------------------------------
DROP TABLE IF EXISTS "viveros" CASCADE;

CREATE TABLE  "viveros" (
	  "nombre" CHAR(40) NOT NULL,
	  "latitud" DOUBLE PRECISION NOT NULL,
	  "longitud" DOUBLE PRECISION NOT NULL,
	  "direccion" VARCHAR(200) NULL,
		"municipio" VARCHAR(100),
	  PRIMARY KEY ("latitud", "longitud"));


-- -----------------------------------------------------
-- Table "zonas"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "zonas" CASCADE;

CREATE TABLE  "zonas" (
	  "nombre" CHAR(40) NOT NULL,
	  "viveros_latitud" DOUBLE PRECISION NOT NULL,
	  "viveros_longitud" DOUBLE PRECISION NOT NULL,
	  PRIMARY KEY ("nombre", "viveros_latitud", "viveros_longitud"),
	  CONSTRAINT "fk_Zona_Viveros"
	    FOREIGN KEY ("viveros_latitud" , "viveros_longitud")
	    REFERENCES "viveros" ("latitud" , "longitud")
	    ON DELETE CASCADE
	    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table "empleados"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "empleados" CASCADE;

CREATE TABLE  "empleados" (
	  "id" INT NOT NULL ,
	  "nombre" VARCHAR(100) NOT NULL,
	  PRIMARY KEY ("id"));


-- -----------------------------------------------------
-- Table "productos"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "productos" CASCADE;

CREATE TABLE  "productos" (
	  "id" INT NOT NULL,
	  "nombre" VARCHAR(45) NOT NULL,
	  "stock" INT NOT NULL,
	  PRIMARY KEY ("id"));


-- -----------------------------------------------------
-- Table "stock_en_zona"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "stock_en_zona" CASCADE;

CREATE TABLE  "stock_en_zona" (
	  "productos_id" INT NOT NULL,
	  "zonas_nombre" CHAR(40) NOT NULL,
	  "zonas_viveros_latitud" DOUBLE PRECISION NOT NULL,
	  "zonas_viveros_longitud" DOUBLE PRECISION NOT NULL,
	  "stock" INT NOT NULL,
	  PRIMARY KEY ("productos_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud"),
	  CONSTRAINT "fk_stock_en_zona_productos"
	    FOREIGN KEY ("productos_id")
	    REFERENCES "productos" ("id")
	    ON DELETE CASCADE
	    ON UPDATE NO ACTION,
	  CONSTRAINT "fk_stock_en_zona_zonas"
	    FOREIGN KEY ("zonas_nombre" , "zonas_viveros_latitud" , "zonas_viveros_longitud")
	    REFERENCES "zonas" ("nombre" , "viveros_latitud" , "viveros_longitud")
	    ON DELETE RESTRICT
	    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table "clientes"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "clientes" CASCADE;

CREATE TABLE  "clientes" (
	  "dni" CHAR(8) NOT NULL,
	  "email" VARCHAR(200) NOT NULL,
	  /* CONSTRAINT Email CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'), */
  "nombre" VARCHAR(200) NOT NULL,
  "telefono" INT NOT NULL,
  PRIMARY KEY ("dni"));


-- -----------------------------------------------------
-- Table "pedidos"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "pedidos" CASCADE;

CREATE TABLE  "pedidos" (
	  "id" INT NOT NULL,
	  "fecha" TIMESTAMP NOT NULL,
	  "empleados_id" INT NULL,
	  "clientes_dni" CHAR(8) NULL,
	  PRIMARY KEY ("id"),
	  CONSTRAINT "fk_pedidos_empleados1"
	    FOREIGN KEY ("empleados_id")
	    REFERENCES "empleados" ("id")
	    ON DELETE SET NULL
	    ON UPDATE NO ACTION,
	  CONSTRAINT "fk_pedidos_clientes1"
	    FOREIGN KEY ("clientes_dni")
	    REFERENCES "clientes" ("dni")
	    ON DELETE SET NULL
	    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table "productos_en_pedido"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "productos_en_pedido" CASCADE;

CREATE TABLE  "productos_en_pedido" (
	  "pedidos_id" INT NOT NULL,
	  "productos_id" INT NOT NULL,
	  "cantidad" INT NOT NULL,
	  PRIMARY KEY ("pedidos_id"),
	  CONSTRAINT "fk_productos_en_pedido_pedidos"
	    FOREIGN KEY ("pedidos_id")
	    REFERENCES "pedidos" ("id")
	    ON DELETE CASCADE
	    ON UPDATE NO ACTION,
	  CONSTRAINT "fk_productos_en_pedido_productos"
	    FOREIGN KEY ("productos_id")
	    REFERENCES "productos" ("id")
	    ON DELETE RESTRICT
	    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table "empleado_trabaja_en_zona"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "empleado_trabaja_en_zona" CASCADE;

CREATE TABLE  "empleado_trabaja_en_zona" (
	  "empleados_id" INT NOT NULL,
	  "zonas_nombre" CHAR(40) NOT NULL,
	  "zonas_viveros_latitud" DOUBLE PRECISION NOT NULL,
	  "zonas_viveros_longitud" DOUBLE PRECISION NOT NULL,
	  "fecha_inicio" DATE NOT NULL,
	  "fecha_final" DATE NULL,
	  PRIMARY KEY ("empleados_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "fecha_inicio"),
	  CONSTRAINT "fk_empeado_trabaja_en_zona_empleados"
	    FOREIGN KEY ("empleados_id")
	    REFERENCES "empleados" ("id")
	    ON DELETE CASCADE
	    ON UPDATE NO ACTION,
	  CONSTRAINT "fk_empeado_trabaja_en_zona_zonas"
	    FOREIGN KEY ("zonas_nombre" , "zonas_viveros_latitud" , "zonas_viveros_longitud")
	    REFERENCES "zonas" ("nombre" , "viveros_latitud" , "viveros_longitud")
	    ON DELETE NO ACTION
	    ON UPDATE NO ACTION);


-- Create functions

/* CREATE OR REPLACE FUNCTION check_email() RETURNS BOOLEAN AS
$BODY$
BEGIN
  IF (NEW.email !~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$') THEN
    RAISE EXCEPTION 'Error: El email introducido no es valido.';
  END IF
  RETURN TRUE;
END;
$BODY$ */

CREATE OR REPLACE FUNCTION crear_email() RETURNS trigger AS
$BODY$
	BEGIN
  IF NEW.email IS NULL THEN
	    NEW.email = lower(NEW.nombre||'@'||TG_ARGV[0]);
	  ELSIF NEW.email !~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN
		    RAISE EXCEPTION 'Error: El email introducido no es valido.';
		  END IF;
		  RETURN NEW;
	END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_stock() RETURNS trigger AS
$BODY$
	DECLARE
		new_stock INT;
	BEGIN
		IF tg_op = 'UPDATE' THEN 
			new_stock = NEW.stock - OLD.stock;
		ELSIF tg_op = 'INSERT' then
			new_stock = NEW.stock;
		END IF;
			UPDATE productos SET stock = stock + new_stock WHERE id = NEW.productos_id;
			RETURN NEW;
	END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_municipio() RETURNS trigger AS
$BODY$
BEGIN
	IF EXISTS (SELECT * FROM viveros WHERE NEW.municipio=municipio) THEN
		RAISE EXCEPTION 'Error: No pueden haber dos viveros en el mismo municipio';
	END IF;
	RETURN NEW;
END;	
$BODY$
LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS trigger_crear_email_before_insert ON clientes;
CREATE TRIGGER trigger_crear_email_before_insert BEFORE INSERT ON clientes
FOR EACH ROW EXECUTE PROCEDURE crear_email('gmail.com');

DROP TRIGGER IF EXISTS trigger_actualizar_stock_after_insert_or_update ON stock_en_zona;
CREATE TRIGGER trigger_actualizar_stock_after_insert AFTER INSERT OR UPDATE ON stock_en_zona
FOR EACH ROW EXECUTE PROCEDURE actualizar_stock();

DROP TRIGGER IF EXISTS trigger_check_municipio_before_insert ON viveros:
CREATE TRIGGER trigger_check_municipio_before_insert BEFORE INSERT ON viveros
FOR EACH ROW EXECUTE PROCEDURE check_municipio();

-- Start inserting data
-- -----------------------------------------------------
-- Data for table "viveros"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "viveros" ("nombre", "latitud", "longitud", "direccion", "municipio") VALUES ('SantaCruzViveros.SA', 28.4672612, -16.2544728, 'C/ Castillo, 1', 'Los Realejos');
COMMIT;
-- Este falla
INSERT INTO "viveros" ("nombre", "latitud", "longitud", "direccion", "municipio") VALUES ('FakeViveros.SA', 23.414414, 192.23123, 'C/ La Solana, 64', 'Los Realejos');


-- -----------------------------------------------------
-- Data for table "zonas"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "zonas" ("nombre", "viveros_latitud", "viveros_longitud") VALUES ('Zona1', 28.4672612, -16.2544728);

COMMIT;


-- -----------------------------------------------------
-- Data for table "empleados"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "empleados" ("id", "nombre") VALUES (34254, 'Pepe Geranios');

COMMIT;


-- -----------------------------------------------------
-- Data for table "productos"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "productos" ("id", "nombre", "stock") VALUES (1, 'Macetas', 0);
INSERT INTO "productos" ("id", "nombre", "stock") VALUES (2, 'Rosas', 0);
INSERT INTO "productos" ("id", "nombre", "stock") VALUES (3, 'Semillas', 0);
INSERT INTO "productos" ("id", "nombre", "stock") VALUES (4, 'Abono', 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table "stock_en_zona"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "stock_en_zona" ("productos_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "stock") VALUES (1, 'Zona1', 28.4672612, -16.2544728, 27);
INSERT INTO "stock_en_zona" ("productos_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "stock") VALUES (2, 'Zona1', 28.4672612, -16.2544728, 10);
COMMIT;


-- -----------------------------------------------------
-- Data for table "clientes"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "clientes" ("dni", "email", "nombre", "telefono") VALUES ('46928192', NULL, 'Fulanito', 622843726);
INSERT INTO "clientes" ("dni", "email", "nombre", "telefono") VALUES ('46928195', 'email@example.tld', 'Pepe', 622843732);
COMMIT;
-- Este falla
INSERT INTO "clientes" ("dni", "email", "nombre", "telefono") VALUES ('46928123', 'pepe', 'pepe', 622389289);


-- -----------------------------------------------------
-- Data for table "pedidos"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "pedidos" ("id", "fecha", "empleados_id", "clientes_dni") VALUES (1, '12-04-2021', 34254, '46928192');

COMMIT;


-- -----------------------------------------------------
-- Data for table "productos_en_pedido"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "productos_en_pedido" ("pedidos_id", "productos_id", "cantidad") VALUES (1, 1, 3);
COMMIT;

-- -----------------------------------------------------
-- Data for table "empleado_trabaja_en_zona"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "empleado_trabaja_en_zona" ("empleados_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "fecha_inicio", "fecha_final") VALUES (34254, 'Zona1', 28.4672612, -16.2544728, '03-04-2021', NULL);

COMMIT;

DROP SEQUENCE IF EXISTS "empleados_id_sequence";
CREATE SEQUENCE  "empleados_id_sequence";
ALTER TABLE "empleados" ALTER COLUMN "id" SET DEFAULT NEXTVAL('"empleados_id_sequence"');
