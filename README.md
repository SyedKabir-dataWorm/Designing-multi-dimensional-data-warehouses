
**Case Study: G9 Education**

G9 Education is a private Australian provider of quality early childhood education and care. They
recently implemented a simple database system. The system includes information about their
daycare centers, teachers, and children who attend the center. The simple database system consists
of the following tables and attributes.

![alt text](https://github.com/SyedKabir-dataWorm/Designing-multi-dimensional-data-warehouses/blob/main/ERD.png)

Due to an increasing number of incidents happening in the daycare centers, the manager of G9
Education requires a data warehouse for analysis purposes. Analysis is needed for identifying the
incident type that occurs with highest frequency, total cost per incident type, etc.
You are required to design a small data warehouse to keep track of the statistics. The manager is
particularly interested in analysing the number of incidents and total incident cost by incident type,
month (e.g., Jan, Feb), daycare center, teacher, course, and age group points of view.

For the age group, the manager wants to be able to drill down based on two different age groups:
pre-kinder (between 1 and 2 years old), and kinder (between 3 and 5 years old).
The operational database tables from G9 Education can be accessed through the MonChild
account. For example, execute the following query:
select * from MonChild.<table_name>;

**Tasks:**

1. Develop a G9 Education star schema. Identify the fact table, dimensions and attributes required
to support the schema. The result of this task is a star schema diagram. If you are using a
bridge table, make sure to include weight factor and list aggregate attributes.
You can use any drawing tool, such as Lucidchart, to draw the star schema.

2. Validate your star schema using the two-column table methodology. You are required to
illustrate the two-column tables for all fact measures and dimensions in your star schema
design.

3. Write the SQL commands to create the fact and dimension tables. You need to create a script
file containing the appropriate SQL commands to create the fact and dimension tables. Each
dimension must have an ID or a surrogate key. The operational database tables are accessible
through the MonChild account.

The result of this task is the SQL commands. You will also need to show SQL commands and
the contents of the tables that you have created.

4. Write the SQL commands to answer the following queries, and show the results:

		a) Show the total number of incidents and total incident costs by age group.

		b) Show the total number of incidents and total incident costs for the teachers whose roles are Early 			childhood teacher, and show the course they took previously as well.

		c) Show the total number of incidents and total incident costs by incident type in March.

		d) Show the total number of incidents and total incident costs by daycare center.

		e) Show all information of the teacher who has the smallest number of incidents

