select
        u.iduser matricula,
        u.nmuser nombre,
        u.idphone fono,
        u.nmuseremail correo,
        'por declarar' conflicto,
        d.iddepartment,
        d.nmdepartment               
    from
        aduser u                          
    left join
        aduserdeptpos udp                                                                  
            on udp.cduser = u.cduser                         
    LEFT  join
        addepartment d                                                                  
            on udp.cddepartment = d.cddepartment               
    where
        udp.FGDEFAULTDEPTPOS = 1          
        and   u.fguserenabled = 1