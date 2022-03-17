SELECT      
        COUNT(EVALUADOR.IDUSER) CANTEVALCONFINTE
    FROM
        WFPROCESS WFP           
    JOIN
        GNASSOCFORMREG REG                           
            ON WFP.CDASSOCREG = REG.CDASSOC           
    LEFT JOIN
        DYNFORMUSRGRIDEVAL EVALUADOR                           
            ON REG.OIDENTITYREG=EVALUADOR.OID      
    WHERE
        WFP.CDPROCESSMODEL = 199 
        AND WFP.IDPARENTPROCESS IN (
            SELECT
                IDOBJECT 
            FROM
                WFPROCESS 
            WHERE
                IDPROCESS = :paramIDWfProyecto 
        )  
AND EVALUADOR.CONFINTE = 'si'