SELECT * FROM exercise_workout;

-- Duplicate Table
CREATE TABLE exercise_workout_staging
LIKE exercise_workout;

INSERT exercise_workout_staging
SELECT * 
FROM exercise_workout;

SELECT * FROM exercise_workout_staging;

-- Remove Dulplicate
with dumplicate AS
(
SELECT *,
row_number() OVER(
	partition by  exercise_name) row_num
FROM exercise_workout_staging
)
SELECT * FROM dumplicate
WHERE row_num > 1;

CREATE TABLE `exercise_workout_staging2` (
  `exercise_name` text,
  `Primary_Muscle` text,
  `library_id` int DEFAULT NULL,
  `exercise_video_link` text,
  `exercise_description` text,
  `row_num` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM exercise_workout_staging2;

INSERT exercise_workout_staging2
SELECT *,
row_number() OVER(
	partition by  exercise_name) row_num
FROM exercise_workout_staging;

DELETE
FROM exercise_workout_staging2
WHERE row_num > 1
;


-- Split Muscle to Secondary and Teriary
SELECT * FROM exercise_workout_staging2;
SELECT 
exercise_name, 
Primary_Muscle, 
ROUND (   
        (
            LENGTH(Primary_Muscle)
            - LENGTH( REPLACE ( Primary_Muscle, ",", "") ) 
        ) / LENGTH(",")        
    )+1 as total_muscle_hit
FROM exercise_workout_staging2;

-- ADD TOTAL MUSCLE HIT
ALTER TABLE `portfolio`.`exercise_workout_staging2` 
ADD COLUMN `Tot_Muscle_Hit` INT NULL;

UPDATE exercise_workout_staging2
SET Tot_Muscle_Hit = ROUND (   
							(
								LENGTH(Primary_Muscle)
								- LENGTH( REPLACE ( Primary_Muscle, ",", "") ) 
							) / LENGTH(",")        
						)+1;


-- ADD Secondary Muscle Column
SELECT COUNT(*) FROM exercise_workout_staging2
WHERE Tot_Muscle_Hit = 2 ;
SELECT exercise_name, Primary_Muscle,
SUBSTRING(Primary_Muscle, 1, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1)))New_Primary_Muscle,
SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))+3) Secondary_Muscle
FROM exercise_workout_staging2
WHERE Tot_Muscle_Hit = 2 ;

SELECT * FROM exercise_workout_staging2 WHERE Tot_Muscle_Hit = 2 ;

ALTER TABLE `portfolio`.`exercise_workout_staging2` 
ADD COLUMN `Secondary_Muscle` TEXT NULL AFTER `Primary_Muscle`;

UPDATE exercise_workout_staging2
SET 
Secondary_Muscle = SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))+3),
Primary_Muscle = SUBSTRING(Primary_Muscle, 1, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1)))
WHERE Tot_Muscle_Hit = 2 ;


-- ADD Tertiary Muscle
SELECT COUNT(*) FROM exercise_workout_staging2
WHERE Tot_Muscle_Hit = 3 ;
SELECT exercise_name, Primary_Muscle,
SUBSTRING(Primary_Muscle, 1, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1)))New_Primary_Muscle,
SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))+3, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",2))-LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))-2) Secondary_Muscle,
SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",2))+3) Tertiary_Muscle
FROM exercise_workout_staging2
WHERE Tot_Muscle_Hit = 3 ;

ALTER TABLE `portfolio`.`exercise_workout_staging2` 
ADD COLUMN `Tertiary_Muscle` TEXT NULL AFTER `Secondary_Muscle`;

UPDATE exercise_workout_staging2
SET 
Secondary_Muscle = SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))+3, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",2))-LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1))-2),
Tertiary_Muscle = SUBSTRING(Primary_Muscle, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",2))+3),
Primary_Muscle = SUBSTRING(Primary_Muscle, 1, LENGTH(SUBSTRING_INDEX(Primary_Muscle, ",",1)))
WHERE Tot_Muscle_Hit = 3 ;

SELECT * FROM exercise_workout_staging2 WHERE Tot_Muscle_Hit = 3 ;