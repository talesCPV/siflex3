-- DROP FUNCTION fn_get;
DELIMITER $$
	CREATE FUNCTION fn_calcDist(lat1 DOUBLE, lng1 DOUBLE, lat2 DOUBLE,lng2 DOUBLE)
    RETURNS DOUBLE 
    DETERMINISTIC
	BEGIN    
		RETURN ROUND(6371 *
        acos(
            cos(radians(lat1)) *
            cos(radians(lat2)) *
            cos(radians(lng1) - radians(lng2)) +
            sin(radians(lat1)) *
            sin(radians(lat2))
        ),3);        			
	END $$
DELIMITER ;