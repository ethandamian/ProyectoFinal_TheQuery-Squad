/* Un SP que se encarga de eliminar un proveedor a traves de su RFC, en este SP, se eliminan todas
las referencias del proveedor de las demas tablas.*/


CREATE OR REPLACE PROCEDURE eliminarProveedor(IN RFCProveedorBuscado VARCHAR(13)) AS 
$$
BEGIN
  -- Verifica si el RFC del proveedor existe en la tabla Proveedor
  IF NOT EXISTS (SELECT 1 FROM Proveedor WHERE RFCProveedor = RFCProveedorBuscado) THEN
    RAISE EXCEPTION 'El proveedor con RFC % no existe en la base de datos', RFCProveedorBuscado
    USING hint = 'Verifica que el RFC ingresado sea el correcto';
   
  ELSE
  	 -- Elimina de Proveedor, por el mantenimiento de llaves foraneas, las tablas que contengan
  	-- a ese Proveedor se eliminaran tambien
    DELETE FROM Proveedor WHERE RFCProveedor = RFCProveedorBuscado;
   	
  END IF;
	 
     
END;
$$
LANGUAGE plpgsql;

-- Obtenemos la informacion de la tabla proveedor con un RFC que si existe 
SELECT * FROM Proveedor WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerMedicina WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerAlimento WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM TelefonoProveedor WHERE RFCProveedor = 'JDMW8923470EB';

-- Llamamos al SP con ese RFC
CALL eliminarProveedor('JDMW8923470EB');

-- Verificamos que no se encuentre en la tabla Proveedor o en cualquiera donde se encuentra el RFC
SELECT * FROM Proveedor WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerMedicina WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerAlimento WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM TelefonoProveedor WHERE RFCProveedor = 'JDMW8923470EB';

------------------------------------------------------------------------------------------------------------------

/*Proceso almacenado que regresa la cantidad de animales que estan en un bioma, dado su ID*/
CREATE OR REPLACE FUNCTION cantidad_animales_en_bioma(p_IDBioma INT)
RETURNS INT AS $$
DECLARE
    cantidad_animales INT;
BEGIN
    SELECT COUNT(*) INTO cantidad_animales
    FROM Animal
    WHERE IDBioma = p_IDBioma;

    RETURN cantidad_animales;
END;
$$ 
LANGUAGE plpgsql;

-- Ejemplo de llamada al procedimiento para obtener la cantidad de animales en el bioma con IDBioma = 1: desierto
SELECT IDBioma, TipoBioma, cantidad_animales_en_bioma(1) FROM Bioma WHERE IDBioma =1;

----------------------------------------------------------------------------------------------------------------------

/*Proceso almacenado que devulve una tabla con dos columnas: cantidad de veterinario y cantidad de cuidadores 
 * en un Bioma, de parametro se le pasa el ID del Bioma del cual queremos obtener esta informacion*/
CREATE OR REPLACE FUNCTION cantidad_cuidadores_veterinarios_en_bioma(p_IDBioma INT)
RETURNS TABLE (cantidad_cuidadores INT, cantidad_veterinarios INT) AS $$
DECLARE
    cantidad_cuidadores INT;
    cantidad_veterinarios INT;
BEGIN
    SELECT COUNT(*) INTO cantidad_cuidadores
    FROM Cuidador
    WHERE IDBioma = p_IDBioma;

    SELECT COUNT(*) INTO cantidad_veterinarios
    FROM Trabajar
    WHERE IDBioma = p_IDBioma;

    RETURN QUERY SELECT cantidad_cuidadores, cantidad_veterinarios;
END;
$$ LANGUAGE plpgsql;


-- Ejemplo de llamada al procedimiento para obtener la cantidad de veterinarios y cuidadores 
-- que trabajan en el bioma con IDBioma = 3: desierto
SELECT IDBioma, TipoBioma, cantidad_cuidadores_veterinarios_en_bioma(3) FROM Bioma 
WHERE IDBioma = 3 ;

SELECT * FROM cantidad_cuidadores_veterinarios_en_bioma(3);


------------------------------------------------------------------
/* Proceso almacenado que calcula el costo total de cada ticket usando la formula: CostoUnitario - (CostoUnitario * Descuento / 100) 
	la cual ajusta el costo unitario restando el descuento correspondiente. Esto se hace con la finalidad de calcular el costo total de
	un servicio en especifico despues de aplicar cualquier descuento asociado*/

-- Agregar la columna "CostoTotal" a la tabla "Ticket"
ALTER TABLE Ticket
ADD COLUMN CostoTotal decimal;

-- Crear o reemplazar el procedimiento almacenado
CREATE OR REPLACE FUNCTION calcular_costo_total()
RETURNS VOID AS $$
BEGIN
    -- Actualizar el atributo "CostoTotal" en la tabla "Ticket"
    UPDATE Ticket
    SET CostoTotal = CostoUnitario - (CostoUnitario * Descuento / 100);
END;
$$ LANGUAGE plpgsql;

-- Llamar al procedimiento para calcular y actualizar el "CostoTotal"
SELECT calcular_costo_total();



-- Consulta para ver la tabla "Ticket" completa
SELECT * FROM Ticket;
