SELECT
        PROY.IDPROYECTO,
        PROY.NMPROYECTO,
        EVALCONC.* 
    FROM
        (SELECT
            WFP.IDPROCESS idproyecto,
            WFP.NMPROCESS nmproyecto,
            PROYECTOS.nombconc nmconvocatoria     
        FROM
            WFPROCESS WFP           
        JOIN
            GNASSOCFORMREG REG                           
                ON WFP.CDASSOCREG = REG.CDASSOC           
        JOIN
            DYNFORM PROYECTOS                           
                ON REG.OIDENTITYREG=PROYECTOS.OID               
        WHERE
            CDPROCESSMODEL = 14   
            AND PROYECTOS.nombconc = :paramNombreConcurso) PROY CROSS 
    JOIN
        (
            SELECT
                EVAL.IDCONCURSO,
                EVAL.NMCONCURSO,
                EVAL.TIPOCONC TIPOCONCURSO,
                EVAL.EVALUACION  TIPOEVALUACION   
            FROM
                WFPROCESS WFP           
            JOIN
                GNASSOCFORMREG REG                           
                    ON WFP.CDASSOCREG = REG.CDASSOC           
            JOIN
                DYNFORM EVAL                           
                    ON REG.OIDENTITYREG=EVAL.OID               
            WHERE
                EVAL.idworkflow = :paramIDWorkflow
        )  EVALCONC