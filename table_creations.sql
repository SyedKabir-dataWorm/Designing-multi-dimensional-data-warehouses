

/* Creating all dimesion tables at first */
DROP TABLE coursedim;

DROP TABLE incidentstypedim;

DROP TABLE teacherdim;

DROP TABLE monthdim;

DROP TABLE daycaredim;

DROP TABLE agegroupdim;

DROP TABLE bridgetable;

DROP TABLE incidentfact;

DROP TABLE tempfact;

-- Creating IncidentType dimension table

CREATE TABLE incidentstypedim
    AS
        SELECT
            *
        FROM
            monchild.incidentstype;

SELECT
    *
FROM
    incidentstypedim; --incidentstypedim;

-- Creating Month dimension table

CREATE TABLE monthdim
    AS
        SELECT DISTINCT
            to_char(incident_date, 'MON') AS monthname
        FROM
            monchild.children_incidents;

ALTER TABLE monthdim ADD (
    monthid VARCHAR2(2)
);

-- Updating MonthDim table
UPDATE monthdim
SET
    monthid = '1'
WHERE
    monthname = 'JAN';

UPDATE monthdim
SET
    monthid = '2'
WHERE
    monthname = 'FEB';

UPDATE monthdim
SET
    monthid = '3'
WHERE
    monthname = 'MAR';

UPDATE monthdim
SET
    monthid = '4'
WHERE
    monthname = 'APR';

UPDATE monthdim
SET
    monthid = '5'
WHERE
    monthname = 'MAY';

UPDATE monthdim
SET
    monthid = '6'
WHERE
    monthname = 'JUN';

UPDATE monthdim
SET
    monthid = '7'
WHERE
    monthname = 'JUL';

UPDATE monthdim
SET
    monthid = '8'
WHERE
    monthname = 'AUG';

UPDATE monthdim
SET
    monthid = '9'--Won't update as Sept is absent in SourceTable
WHERE
    monthname = 'SPT';

UPDATE monthdim
SET
    monthid = '10'--Won't update as Oct is absent in Source Table 
WHERE
    monthname = 'OCT';

UPDATE monthdim
SET
    monthid = '11'--Won't update as Nov is absent in Source Table
WHERE
    monthname = 'NOV';

UPDATE monthdim
SET
    monthid = '12'--Won't update as Dec is absent in Source Table 
WHERE
    monthname = 'DEC';

SELECT
    MonthID, monthname
FROM
    monthdim
ORDER BY
    MonthID;

-- Creating DayCare Dimension

CREATE TABLE daycaredim
    AS
        SELECT DISTINCT
            centerid,
            center_capacity,
            center_postcode
        FROM
            monchild.daycare_center;

SELECT
    *
FROM
    daycaredim;

-- Creating AgeGroup Dimension table
CREATE TABLE agegroupdim (
    agegroupid   CHAR(1),
    agegroupdesc VARCHAR2(10)
);

INSERT INTO agegroupdim VALUES (
    1,
    'pre-kinder'
);

INSERT INTO agegroupdim VALUES (
    2,
    'kinder'
);

SELECT
    *
FROM
    agegroupdim;

-- Creating Teacher Dimension table

CREATE TABLE teacherdim
    AS
        SELECT DISTINCT
            t.teacherid,
            t.teacher_role,
            t.teacher_name,
            1 / COUNT(*) AS weight_factor,
            LISTAGG(tr.courseid, '_') WITHIN GROUP(
            ORDER BY
                tr.courseid
            )            AS course_group_list
        FROM
            monchild.teacher  t,
            monchild.training tr
        WHERE
            t.teacherid = tr.teacherid
        GROUP BY
            t.teacherid,
            t.teacher_role,
            t.teacher_name;

SELECT
    *
FROM
    teacherdim;

-- Creating BridgeTable Dimension

CREATE TABLE bridgetable
    AS
        SELECT
            *
        FROM
            monchild.training;

SELECT
    *
FROM
    bridgetable
ORDER BY
    teacherid,courseid,training_year,training_location;

-- Creating Course Dimension Table

CREATE TABLE coursedim
    AS
        SELECT
            *
        FROM
            monchild.course;

SELECT
    *
FROM
    coursedim;

----------------------------------------------

-- Creating Temporary Fact Table

CREATE TABLE tempfact
    AS
        SELECT
            ci.incidentid,
            it.typeid,
            to_char(ci.incident_date, 'Mon') AS month,
            ch.centerid,
            t.teacherid,
            c.courseid,
            ch.child_age,
            ci.incidents_cost
        FROM
            monchild.incidentstype      it,
            monchild.children_incidents ci,
            monchild.course             c,
            monchild.teacher            t,
            monchild.children           ch,
            monchild.training           tr
        WHERE
                ci.typeid = it.typeid
            AND ch.childrenid = ci.childrenid
            AND ci.teacherid = t.teacherid
            AND t.teacherid = tr.teacherid
            AND tr.courseid = c.courseid;

ALTER TABLE tempfact ADD (
    agegroupid CHAR(1)
);

UPDATE tempfact
SET
    agegroupid = 1
WHERE
        child_age > 0
    AND child_age < 3;

UPDATE tempfact
SET
    agegroupid = 2
WHERE
        child_age > 2
    AND child_age < 6;

ALTER TABLE tempfact ADD (
    monthid VARCHAR2(2)
);

UPDATE tempfact
SET
    monthid = '1'
WHERE
    upper(month) = 'JAN';

UPDATE tempfact
SET
    monthid = '2'
WHERE
    upper(month) = 'FEB';

UPDATE tempfact
SET
    monthid = '3'
WHERE
    upper(month) = 'MAR';

UPDATE tempfact
SET
    monthid = '4'
WHERE
    upper(month) = 'APR';

UPDATE tempfact
SET
    monthid = '5'
WHERE
    upper(month) = 'MAY';

UPDATE tempfact
SET
    monthid = '6'
WHERE
    upper(month) = 'JUN';

UPDATE tempfact
SET
    monthid = '7'
WHERE
    upper(month) = 'JUL';

UPDATE tempfact
SET
    monthid = '8'
WHERE
    upper(month) = 'AUG';
    
SELECT * FROM tempfact;

-- Creating Incident Fact Table

CREATE TABLE incidentfact
    AS
        SELECT
            typeid,
            monthid,
            centerid,
            teacherid,
            courseid,
            agegroupid,
            COUNT(incidentid)   AS num_incidents,
            SUM(incidents_cost) AS total_cost
        FROM
            tempfact
        GROUP BY
            typeid,
            monthid,
            centerid,
            teacherid,
            courseid,
            agegroupid;

SELECT
    *
FROM
    incidentfact
ORDER BY
    typeid,
    monthid,
    centerid,
    teacherid,
    courseid,
    agegroupid;

COMMIT;
-- --------------------------------------------------------------
/* Two Column Methodology */

-- Validation of IncidentsType Dimension
SELECT
    d.type_description as Incident_Type,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    incidentfact     i,
    incidentstypedim d
WHERE
    d.typeid = i.typeid
GROUP BY
    d.type_description;

-- Validation of DayCare Dimension

SELECT
    dc.centerid,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    daycaredim        dc,
    incidentfact      i,
    monchild.children ch
WHERE
        i.centerid = dc.centerid
    AND ch.centerid = dc.centerid
GROUP BY
    dc.centerid;

-- Validation of MonthDim

SELECT
    m.monthname,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    monthdim     m,
    incidentfact i
WHERE
    m.monthid = i.monthid
GROUP BY
    m.monthname;

-- Valiadation of TeacherDim

SELECT
    t.teacher_name,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    teacherdim   t,
    incidentfact i
WHERE
    t.teacherid = i.teacherid
GROUP BY
    t.teacher_name; 

-- Valiadation of CourseDim

SELECT
    c.course_name,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    coursedim    c,
    incidentfact i
WHERE
    c.courseid = i.courseid
GROUP BY
    c.course_name;

-- Valiadation of AgeGroupDim
SELECT
    a.agegroupdesc,
    SUM(i.total_cost)    AS sum_cost,
    SUM(i.num_incidents) AS sum_incidents
FROM
    agegroupdim  a,
    incidentfact i
WHERE
    a.agegroupid = i.agegroupid
GROUP BY
    a.agegroupdesc;

-- -------------------------------------------