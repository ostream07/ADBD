DROP DATABASE IF EXISTS "tajinaste";
CREATE DATABASE "tajinaste";

\c "tajinaste"

-- -----------------------------------------------------
-- Table "viveros"
-- -----------------------------------------------------
DROP TABLE IF EXISTS "viveros" CASCADE;

CREATE TABLE  "viveros" (
  "nombre" CHAR(40) NOT NULL,
  "latitud" DOUBLE PRECISION NOT NULL,
  "longitud" DOUBLE PRECISION NOT NULL,
  "direccion" VARCHAR(200) NULL,
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


-- Start inserting data
-- -----------------------------------------------------
-- Data for table "viveros"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "viveros" ("nombre", "latitud", "longitud", "direccion") VALUES ('Santa Cruz', 28.4672612, -16.2544728, 'C/ Castillo, 1');;

COMMIT;


-- -----------------------------------------------------
-- Data for table "zonas"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "zonas" ("nombre", "viveros_latitud", "viveros_longitud") VALUES ('Zona1', 28.4672612, -16.2544728);;

COMMIT;


-- -----------------------------------------------------
-- Data for table "empleados"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "empleados" ("id", "nombre") VALUES (34254, 'Pepe Geranios');;

COMMIT;


-- -----------------------------------------------------
-- Data for table "productos"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "productos" ("id", "nombre") VALUES (1, 'Macetas');;
INSERT INTO "productos" ("id", "nombre") VALUES (2, 'Rosas');;
INSERT INTO "productos" ("id", "nombre") VALUES (3, 'Semillas');;
INSERT INTO "productos" ("id", "nombre") VALUES (4, 'Abono');;

COMMIT;


-- -----------------------------------------------------
-- Data for table "stock_en_zona"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "stock_en_zona" ("productos_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "stock") VALUES (1, 'Zona1', 28.4672612, -16.2544728, 27);;

COMMIT;


-- -----------------------------------------------------
-- Data for table "clientes"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "clientes" ("dni", "telefono") VALUES ('46928192', 622843726);;

COMMIT;


-- -----------------------------------------------------
-- Data for table "pedidos"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "pedidos" ("id", "fecha", "empleados_id", "clientes_dni") VALUES (1, '12-04-2021', 34254, '46928192');;

COMMIT;


-- -----------------------------------------------------
-- Data for table "productos_en_pedido"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "productos_en_pedido" ("pedidos_id", "productos_id", "cantidad") VALUES (1, 1, 3);;

COMMIT;


-- -----------------------------------------------------
-- Data for table "empleado_trabaja_en_zona"
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO "empleado_trabaja_en_zona" ("empleados_id", "zonas_nombre", "zonas_viveros_latitud", "zonas_viveros_longitud", "fecha_inicio", "fecha_final") VALUES (34254, 'Zona1', 28.4672612, -16.2544728, '03-04-2021', NULL);;

COMMIT;

DROP SEQUENCE IF EXISTS "empleados_id_sequence";
CREATE SEQUENCE  "empleados_id_sequence";
ALTER TABLE "empleados" ALTER COLUMN "id" SET DEFAULT NEXTVAL('"empleados_id_sequence"');