/* SAS Data Analysis: Factors Affecting Flight Delays and Flight Times */

libname flights '/home/sraksha/final_project/data';
/* Importing Data */
proc import datafile="/home/sraksha/final_project/data/flights_processed.csv"
    OUT=flights_data
    DBMS=CSV
    REPLACE;
    GETNAMES=YES;
RUN;
/* Adding was_delayed boolean column */
DATA flights_data;
    SET flights_data;
    was_delayed = (arr_delay > 0 or dep_delay > 0);
RUN;

PROC PRINT DATA=flights_data (OBS=5); RUN;


/* 1A. Carrier Delay Count */
PROC SQL;
    CREATE TABLE flights_carrier_count AS
    SELECT carrier, COUNT(*) AS count
    FROM flights_data
    WHERE was_delayed = 1
    GROUP BY carrier
    ORDER BY count DESC;
QUIT;
PROC PRINT DATA=flights_carrier_count; RUN;
PROC SGPLOT DATA=flights_carrier_count;
    VBAR carrier / RESPONSE=count DATALABEL GROUP=carrier STAT=SUM;
    TITLE "(Fig. 1A) Count of Delay by Carrier";
    XAXIS LABEL="Carrier";
    YAXIS LABEL="Count";
RUN;

/* 1B. Carrier Delay Frequency */
PROC SQL;
  CREATE TABLE flights_delay_freq AS
  SELECT carrier,
         SUM(was_delayed) AS delayed,
         SUM(CASE WHEN was_delayed = 0 THEN 1 ELSE 0 END) AS notdelayed,
         SUM(was_delayed) / (SUM(was_delayed) + SUM(CASE WHEN was_delayed = 0 THEN 1 ELSE 0 END)) AS delay_freq
  FROM flights_data
  GROUP BY carrier;
QUIT;
PROC PRINT DATA=flights_delay_freq; RUN;
PROC SGPLOT DATA=flights_delay_freq;
    VBAR carrier / RESPONSE=delay_freq DATALABEL GROUP=carrier STAT=SUM;
    TITLE "(Fig. 1B) Frequency of Delay by Carrier";
    XAXIS LABEL="Carrier";
    YAXIS LABEL="Frequency";
RUN;


/* 2A. Count of delays grouped by origin */
PROC SQL;
  CREATE TABLE flights_origin_count AS
  SELECT origin, 
         COUNT(*) AS count
  FROM flights_data
  WHERE was_delayed = 1
  GROUP BY origin
  ORDER BY count DESC;
QUIT;
PROC SGPLOT DATA=flights_origin_count;
  VBAR origin / RESPONSE=count GROUP=origin DATALABEL;
  TITLE "(Fig. 2A) Count of Delays by Origin";
  XAXIS LABEL="Origin";
  YAXIS LABEL="Count";
  STYLEATTRS DATACOLORS=(blue);
RUN;

/* 2B. Origin Delay Frequency */
PROC SQL;
  CREATE TABLE flights_origin_freq AS
  SELECT origin,
         SUM(was_delayed) AS delayed,
         SUM(CASE WHEN was_delayed = 0 THEN 1 ELSE 0 END) AS notDelayed,
         100 * SUM(was_delayed) / 
              (SUM(was_delayed) + SUM(CASE WHEN was_delayed = 0 THEN 1 ELSE 0 END)) AS delay_freq
  FROM flights_data
  GROUP BY origin;
QUIT;
PROC SGPLOT DATA=flights_origin_freq;
  VBAR origin / RESPONSE=delay_freq GROUP=origin DATALABEL;
  TITLE "(Fig. 2B) Frequency of Delay by Origin";
  XAXIS LABEL="Origin";
  YAXIS LABEL="% of Delayed Flights";
RUN;


/* 3A. Mean Departure Delay by Temperature */
PROC SQL;
  CREATE TABLE flights_temp_mean AS
  SELECT temp, 
         MEAN(dep_delay) AS mean_dep_delay
  FROM flights_data
  WHERE temp IS NOT NULL
  GROUP BY temp;
QUIT;
PROC SGPLOT DATA=flights_temp_mean;
  SERIES X=temp Y=mean_dep_delay / LINEATTRS=(THICKNESS=2 COLOR=blue);
  TITLE "(Fig. 3A) Mean Departure Delay by Temperature";
  XAXIS LABEL="Temperature (°F)" GRID;
  YAXIS LABEL="Mean Departure Delay (minutes)" GRID;
RUN;

/* 3B. Mean Departure Delay by Temperature and Carrier */
PROC SQL;
    CREATE TABLE flights_temp_carrier_mean AS
    SELECT carrier,
           temp,
           MEAN(dep_delay) AS mean_dep_delay
    FROM flights_data
    WHERE temp IS NOT NULL
    GROUP BY carrier, temp;
QUIT;
PROC SORT DATA=flights_temp_carrier_mean;
    BY carrier;
RUN;
PROC SGPLOT DATA=flights_temp_carrier_mean;
    SERIES X=temp Y=mean_dep_delay;
    TITLE "(Fig. 3B) Mean Departure Delay by Temperature and Carrier";
    XAXIS LABEL="Temperature (°F)";
    YAXIS LABEL="Mean Departure Delay (minutes)";
    BY carrier;
RUN;

/* 3C. Mean Departure Delay by Temperature and Origin */
PROC SQL;
    CREATE TABLE flights_temp_origin_mean AS
    SELECT origin, temp,
           MEAN(dep_delay) AS mean_dep_delay
    FROM flights_data
    WHERE temp IS NOT NULL
    GROUP BY origin, temp;
QUIT;
PROC SGPLOT DATA=flights_temp_origin_mean;
    SERIES X=temp Y=mean_dep_delay / GROUP=origin LINEATTRS=(THICKNESS=2);
    XAXIS LABEL="Temperature (°F)";
    YAXIS LABEL="Mean Departure Delay (minutes)";
    TITLE "(Fig. 3C) Mean Departure Delay by Temperature and Origin";
RUN;


/* 4A. Mean Departure Delay by Precipitation */
PROC SQL;
    CREATE TABLE flights_precip_mean AS
    SELECT precip,
           MEAN(dep_delay) AS mean_dep_delay
    FROM flights_data
    WHERE precip IS NOT NULL
    GROUP BY precip;
QUIT;
PROC SQL;
    SELECT COUNT(*) INTO :row_count
    FROM flights_precip_mean;
QUIT;
%PUT Number of rows in flights_precip_mean: &row_count;
PROC SGPLOT DATA=flights_precip_mean;
    SERIES X=precip Y=mean_dep_delay / LINEATTRS=(COLOR=BLACK);
    TITLE "(Fig. 4A) Mean Departure Delay by Precipitation";
    XAXIS LABEL="Precipitation (in)";
    YAXIS LABEL="Mean Departure Delay (minutes)";
RUN;


/* 5A. Mean Departure Delay by Visibility */
PROC SQL;
    CREATE TABLE flights_visib_mean AS
    SELECT visib, MEAN(dep_delay) AS mean_dep_delay
    FROM flights_data
    WHERE visib IS NOT NULL
    GROUP BY visib;
QUIT;
PROC SGPLOT DATA=flights_visib_mean;
    SERIES X=visib Y=mean_dep_delay / LINEATTRS=(COLOR=BLACK);
    XAXIS LABEL="Visibility (mi)";
    YAXIS LABEL="Mean Departure Delay (minutes)";
    TITLE "(Fig. 5A) Mean Departure Delay by Visibility";
RUN;


/* 6A. Mean Departure Delay by Plane Manufacture Year */
PROC SQL;
  CREATE TABLE flights_year_mean AS
  SELECT 
    (CASE WHEN year_manufactured <= 2003 THEN 'Before 2003' ELSE 'After 2003' END) AS before_2003,
    MEAN(dep_delay, 'na.rm'='YES') AS dep_delay
  FROM flights_data
  WHERE NOT MISSING(year_manufactured)
  ORDER BY before_2003;
QUIT;
PROC SGPLOT DATA=flights_year_mean;
    VBAR before_2003 / RESPONSE=dep_delay STAT=MEAN DATALABEL GROUP=before_2003;
    XAXIS LABEL="Year of Manufacture (Before 2003)";
    YAXIS LABEL="Mean Departure Delay (minutes)";
    TITLE "(Fig. 6A) Mean Departure Delay by Plane Manufacture Year";
RUN;


/* 7A. Models of Planes with On Time or Early Arrival After Late Departure */
PROC SQL;
    CREATE TABLE flights_model AS
    SELECT model,
           MEAN(arr_delay) AS arr_delay
    FROM flights_data
    WHERE model IS NOT NULL AND dep_delay > 0
    GROUP BY model;
QUIT;
PROC CONTENTS DATA=flights_model; 
RUN;
DATA flights_model_bar;
    SET flights_model;
    IF arr_delay <= 0;
RUN;
ODS HTML FILE='flights_model_bar.html';
PROC PRINT DATA=flights_model_bar NOOBS;
    TITLE "(Fig. 7A) Models of Planes with On Time or Early Arrival After Late Departure";
RUN;
ODS HTML CLOSE;

/* 7B. Mean Arrival Delay For Delayed Departure Flights by Plane Model */
PROC SGPLOT DATA=flights_model_bar;
    VBAR model / RESPONSE=arr_delay FILLATTRS=(COLOR=turquoise) STAT=MEAN;
    TITLE "(Fig. 7B) Mean Arrival Delay For Delayed Departure Flights by Plane Model";
    XAXIS LABEL="Plane Model";
    YAXIS LABEL="Mean Arrival Delay (minutes)";
RUN;

/* 7C. Early Arrivals For Delayed Departure Flights by Plane Model */
PROC SQL;
  CREATE TABLE flights_model_box AS
  SELECT model,
         arr_delay
    FROM flights_data
   WHERE model IS NOT NULL
     AND dep_delay > 0
     AND model IN (SELECT model FROM flights_model_bar)
  ;
QUIT;
PROC SGPLOT DATA=flights_model_box;
  VBOX arr_delay / CATEGORY=model;
  XAXIS LABEL="Plane Model";
  YAXIS LABEL="Mean Arrival Delay (minutes)";
  TITLE "(Fig. 7C) Early Arrivals For Delayed Departure Flights by Plane Model";
RUN;

/* 7D. Late Arrivals For On-Time or Early Departure Flights by Plane Model */
PROC SQL;
    CREATE TABLE flights_model_box_worst6 AS
    SELECT model, MEAN(arr_delay) AS arr_delay
    FROM flights_data
    WHERE model IS NOT NULL AND arr_delay > 0 AND dep_delay <= 0
    GROUP BY model
    ORDER BY arr_delay DESC;
QUIT;
PROC SORT DATA=flights_data;
    BY model;
RUN;
PROC SORT DATA=flights_model_box_worst6;
    BY model;
RUN;
DATA flights_model_box_worst6_data;
    MERGE flights_data(in=a) flights_model_box_worst6(in=b);
    BY model;
    IF a AND b AND dep_delay <= 0;
RUN;
PROC SGPLOT DATA=flights_model_box_worst6_data;
    VBOX arr_delay / CATEGORY=model;
    TITLE "(Fig. 7D) Late Arrivals For On-Time or Early Departure Flights by Plane Model";
    XAXIS LABEL="Plane Model";
    YAXIS LABEL="Mean Arrival Delay (minutes)";
RUN;

/* 7E. Most Popular Model For Each Carrier  */
PROC SQL;
  CREATE TABLE flights_model_carrier AS
  SELECT carrier, model, COUNT(*) AS count
  FROM flights_data
  WHERE model IS NOT NULL AND carrier IS NOT NULL
  GROUP BY carrier, model
  ORDER BY carrier, count DESC;
QUIT;
PROC SORT DATA=flights_model_carrier;
  BY carrier descending count;
RUN;
DATA flights_model_carrier_top;
  SET flights_model_carrier;
  BY carrier;
  RETAIN top_model top_count;
  IF FIRST.carrier THEN top_model = model;
  IF FIRST.carrier THEN top_count = count;
  IF LAST.carrier;
RUN;
ODS HTML FILE="flights_model_carrier_top.html";
PROC PRINT DATA=flights_model_carrier_top NOOBS LABEL;
  TITLE "(Fig. 7E) Most Popular Model For Each Carrier";
RUN;
ODS HTML CLOSE;


/* 8A. Arrival Delay For Delayed Departure Flights by Number of Engines */
PROC SQL;
  CREATE TABLE flights_num_engine_bar AS
  SELECT num_engines, ROUND(MEAN(arr_delay), 1) AS arr_delay
  FROM flights_data
  WHERE num_engines IS NOT NULL AND dep_delay > 0
  GROUP BY num_engines;
QUIT;
PROC SGPLOT DATA=flights_num_engine_bar;
  VBAR num_engines / RESPONSE=arr_delay STAT=SUM GROUP=num_engines DATALABEL;
  XAXIS LABEL="Number of Engines";
  YAXIS LABEL="Mean Arrival Delay (minutes)";
  TITLE "(Fig. 8A) Arrival Delay For Delayed Departure Flights by Number of Engines";
RUN;

/* 8B. Count of Each Number of Engines */
PROC SQL;
    CREATE TABLE num_engines_table AS
    SELECT num_engines, COUNT(*) AS count
    FROM flights_data
    WHERE num_engines > 0
    GROUP BY num_engines;
QUIT;
ODS HTML FILE="num_engines_table.html";
PROC PRINT DATA=num_engines_table;
    TITLE "(Fig. 8B) Count of Each Number of Engines";
RUN;
ODS HTML CLOSE;

/* 8C. Models of Three Engine Planes */
PROC SQL;
  CREATE TABLE models_table AS
  SELECT model, COUNT(*) AS count
  FROM flights_data
  WHERE num_engines = 3
  GROUP BY model;
QUIT;
ODS HTML FILE="models_table.html";
PROC PRINT DATA=models_table NOOBS;
	TITLE "(Fig. 8C) Models of Three Engine Planes";
RUN;
ODS HTML CLOSE;


/* 9A. Count of Each Engine Type */
PROC SQL;
    CREATE TABLE engines_table AS
    SELECT engine, COUNT(*) AS count
    FROM flights_data
    WHERE engine IS NOT NULL
    GROUP BY engine;
QUIT;
PROC SGPLOT DATA=engines_table;
    VBAR engine / RESPONSE=count GROUP=engine DATALABEL;
    XAXIS LABEL="Engine Type" DISPLAY=(NOLABEL);
    YAXIS LABEL="Count of Plane Models";
    TITLE "(Fig. 9A) Count of Each Engine Type";
RUN;

/* 9B. Arrival Delay for Delayed Departure Flights by Type of Engines */
PROC SQL;
   CREATE TABLE flights_engine_arr_delay AS
   SELECT engine, ROUND(MEAN(arr_delay), 1) AS arr_delay
   FROM flights_data
   WHERE engine IS NOT NULL AND dep_delay > 0
   GROUP BY engine;
QUIT;
PROC SGPLOT DATA=flights_engine_arr_delay;
   VBAR engine / RESPONSE=arr_delay STAT=SUM GROUP=engine DATALABEL;
   XAXIS LABEL="Engine Type";
   YAXIS LABEL="Mean Arrival Delay (minutes)";
   TITLE "(Fig. 9B) Arrival Delay for Delayed Departure Flights by Type of Engines";
RUN;


/* 10A. Arrival Delay vs Speed for Delayed Departure Flights */
PROC SQL;
   CREATE TABLE flights_speed_arr_delay AS
   SELECT speed, MEAN(arr_delay) AS arr_delay
   FROM flights_data
   WHERE speed IS NOT NULL AND dep_delay > 0
   GROUP BY speed;
QUIT;
PROC SQL;
   SELECT COUNT(*) AS row_count, COUNT(DISTINCT speed) AS unique_speeds
   FROM flights_speed_arr_delay;
QUIT;
PROC SGPLOT DATA=flights_speed_arr_delay;
    SERIES X=speed Y=arr_delay / LINEATTRS=(COLOR=RED);
    TITLE "(Fig. 10A) Arrival Delay vs Speed for Delayed Departure Flights";
    XAXIS LABEL="Speed (MPH)";
    YAXIS LABEL="Mean Arrival Delay (minutes)";
RUN;






