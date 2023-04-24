-- -------------------------------------------
-- (a) Show the total number of incidents and total 
--       incident costs by age group

SELECT
    a.agegroupid,
    a.agegroupdesc,
    SUM(i.num_incidents) AS "Total number of incidents",
    SUM(i.total_cost)    AS "Total incident costs"
FROM
    agegroupdim  a,
    incidentfact i
WHERE
    a.agegroupid = i.agegroupid
GROUP BY
    a.agegroupid,
    a.agegroupdesc;
    


/*b) Show the total number of incidents and total incident costs for the 
 teachers whose roles areEarly childhood teacher, and show the course
they took previously as well. */

SELECT
    t.teacherid,
    t.teacher_name,
    t.course_group_list  AS "Previously Completed Courses",
    SUM(i.num_incidents) AS "Total number of incidents",
    SUM(i.total_cost)    AS "Total incident costs"
FROM
    teacherdim   t,
    coursedim    c,
    incidentfact i
WHERE
        t.teacherid = i.teacherid
    AND i.courseid = c.courseid
    AND t.teacher_role = 'Early childhood teacher'
GROUP BY
    t.teacherid,
    t.teacher_name,
    t.teacher_role,
    t.course_group_list;

/* c) Show the total number of incidents and total incident costs by incident 
type in March. */

SELECT
    i.typeid,
    t.type_description,
    m.monthname,
    SUM(i.num_incidents) AS "Total number of incidents",
    SUM(i.total_cost)    AS "Total incident costs"
FROM
    incidentfact     i,
    monthdim         m,
    incidentstypedim t
WHERE
        i.monthid = m.monthid
    AND i.typeid = t.typeid
    AND upper(m.monthname) = 'MAR'
GROUP BY
    i.typeid,
    t.type_description,
    m.monthname
ORDER BY
    i.typeid;

/* d) Show the total number of incidents and total incident costs by 
daycare center. */

SELECT
    i.centerid,
    SUM(i.num_incidents) AS "Total number of incidents",
    SUM(i.total_cost)    AS "Total incident costs"
FROM
    incidentfact i
GROUP BY
    i.centerid
ORDER BY
    i.centerid;

/* e) Show all information of the teacher who has the smallest 
number of incidents. */

SELECT
    *
FROM
    (
        SELECT
            t.teacherid,
            t.teacher_name,
            t.teacher_role,
            SUM(i.num_incidents) AS "Total number of incidents",
            SUM(i.total_cost)    AS "Total incident costs"
        FROM
            teacherdim   t,
            incidentfact i
        WHERE
            t.teacherid = i.teacherid
        GROUP BY
            t.teacherid,
            t.teacher_name,
            t.teacher_role
        ORDER BY
            SUM(i.num_incidents)
    )
WHERE
    ROWNUM = 1;