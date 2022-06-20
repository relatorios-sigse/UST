SELECT
/**
Creación: 
20-06-2022. Andrés Del Río. Crea campos tipo fecha/hora (en Postgres) usando campos fecha y hora independientes
del SE Formulario.
**/
LISTCONC.*

FROM

(SELECT
		WFP.IDPROCESS,
		WFP.dtstart,
		TO_TIMESTAMP(TO_CHAR(WFP.DTSTART, 'YYYY-MM-DD') || ' ' || WFP.TMSTART, 'YYYY-MM-DD HH24:MI:SS') AS DTSTART_conv,
		
        CONCURSO.fapertura,
		CONCURSO.horaaper,
		CONCURSO.fcierre,
		CONCURSO.horacierr,
		
		TO_CHAR(CAST('1970-01-01 00:00:00' AS timestamp) + (CONCURSO.horaaper || ' second')::INTERVAL - '3 hours'::INTERVAL,'HH24:MI:SS') hora_apertura,
		TO_CHAR(CAST('1970-01-01 00:00:00' AS timestamp) + (CONCURSO.horacierr|| ' second')::INTERVAL - '3 hours'::INTERVAL,'HH24:MI:SS') hora_cierre,
		
		TO_TIMESTAMP(TO_CHAR(CONCURSO.fapertura, 'YYYY-MM-DD') || ' ' || TO_CHAR(CAST('1970-01-01 00:00:00' AS timestamp) + (CONCURSO.horaaper || ' second')::INTERVAL - '3 hours'::INTERVAL,'HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') AS apertura_conv,
		TO_TIMESTAMP(TO_CHAR(CONCURSO.fcierre, 'YYYY-MM-DD') || ' ' || TO_CHAR(CAST('1970-01-01 00:00:00' AS timestamp) + (CONCURSO.horacierr || ' second')::INTERVAL - '3 hours'::INTERVAL,'HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') AS cierre_conv,
		
 		NOW() - INTERVAL '1 hour' ahora
 
        FROM
            WFPROCESS WFP                                                                                  
        LEFT JOIN
            GNASSOCFORMREG REG                                                                 
                ON WFP.CDASSOCREG = REG.CDASSOC                                                                        
        LEFT JOIN
            DYNform CONCURSO                                                           
                ON REG.OIDENTITYREG=CONCURSO.OID                                  
        WHERE
            WFP.CDPROCESSMODEL = 230                 
            AND WFP.FGSTATUS <= 5   
            AND WFP.IDPROCESS LIKE 'UST0010000%') LISTCONC
			/**
			WHERE LISTCONC.apertura_conv <= LISTCONC.ahora AND LISTCONC.cierre_conv > LISTCONC.ahora
			**/