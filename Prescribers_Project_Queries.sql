-----1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.-----

SELECT npi,  
	SUM(total_claim_count) AS total_claim_count
FROM prescriber
JOIN prescription USING (npi)
GROUP BY npi
ORDER BY total_claim_count DESC;

-----Prescriber 1881634483 has 99,707 claims-----
	
-----1 b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.-----
	
SELECT nppes_provider_first_name, 
	nppes_provider_last_org_name, 
	specialty_description, 
	SUM(total_claim_count) AS total_claim_count
FROM prescriber
JOIN prescription USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name,specialty_description
ORDER BY total_claim_count DESC;

-----BRUCE PENDLEY, FAMILY PRACTICE, 99,707 CLAIMS-----

-----2.a. Which specialty had the most total number of claims (totaled over all drugs)?-----

SELECT specialty_description, 
	SUM(total_claim_count) AS total_claim_count
FROM prescriber
JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_Count DESC;

-----FAMILY PRACTICE 9,752,347 CLAIMS------

-------2b. Which specialty had the most total number of claims for opioids?-----

SELECT specialty_description, 
	SUM(total_claim_count) AS total_claim_count
FROM prescriber
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claim_Count DESC;

-----NURSE PRACTITIONER 9,000,845 CLAIMS-----

-----2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?-----

SELECT specialty_description,
	    total_claim_count
FROM prescriber
FULL JOIN prescription USING (npi)
WHERE total_claim_count IS NULL
GROUP BY specialty_description,total_claim_count;

-----YES, 92 DIFFERENT SPECIALTIES-----

-----d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?------

WITH opioid_yes (SELECT specialty_description, 
		SUM(total_claim_count) AS tot_claim_count, 
		opioid_drug_flag
FROM prescriber
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, opioid_drug_flag)
	
SELECT specialty_description, 
		SUM(total_claim_count) AS tot_claim_count, 
		opioid_drug_flag
FROM prescriber
JOIN prescription USING (npi)
JOIN drug USING (drug_name)
GROUP BY specialty_description, opioid_drug_flag
-----NO ANSWER-----	

-----3. a. Which drug (generic_name) had the highest total drug cost?-----

SELECT generic_name, 
	MAX(total_drug_cost)::money AS max_drug_cost
FROM prescription
JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY max_drug_cost DESC;

-----PIRFENIDONE WITH $2,829,174.30-----

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**-----

SELECT generic_name, 
	ROUND(MAX(total_drug_cost/365),2)::money AS cost_per_day
FROM prescription
JOIN drug USING (drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-----PIRFENIDONE WITH $7,751.16-----

------4 a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ -----

SELECT drug_name, 
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' END AS drug_type
FROM drug
-----SEE TABLE-----
	
-----4 b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.-----

SELECT SUM(total_drug_cost)::money,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' END AS drug_type
FROM drug
JOIN prescription USING (drug_name)
WHERE antibiotic_drug_flag = 'Y' OR opioid_drug_flag = 'Y' 	
GROUP BY drug_type, opioid_drug_flag,antibiotic_drug_flag;
-----$38,435,121.26 FOR ANTIBIOTIC AND $105,080,626.37 FOR OPIOID-----

-----5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.-----

SELECT COUNT(DISTINCT cbsa) 
FROM cbsa
JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

----- 10 CBSAs IN TN-----

-----5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.-----

(SELECT cbsaname, 
	SUM(population) AS total_pop, 'largest' AS size
FROM cbsa
JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop DESC
LIMIT 1)
UNION
(SELECT cbsaname, 
	SUM(population) AS total_pop, 'smallest' AS size
FROM cbsa
JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop ASC
LIMIT 1);

-----Morristown, TN TOTAL POP 116,352AS THE smallest AND Nashville-Davidson--Murfreesboro--Franklin, TN TOTAL POP 1,830,410 AS THE largest-----

----- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.-----

SELECT MAX(population) AS largest_pop, 
	county
FROM population
FULL JOIN fips_county USING (fipscounty)
FULL JOIN cbsa USING (fipscounty)
WHERE population IS NOT NULL
AND cbsa IS NULL
GROUP BY county
ORDER by largest_pop DESC
LIMIT 1;
-----SEVIER COUNTY WITH A POPULATION OF 95,523-----

-----6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.-----

SELECT drug_name, SUM(total_claim_count) AS total_claim
FROM prescription
WHERE total_claim_count >= 3000
GROUP by drug_name
	
----- FUROSEMIDE					3,083----- 
----- GABAPENTIN					3,531-----
----- HYDROCODONE-ACETAMINOPHEN	3,376-----
----- LEVOTHYROXINE SODIUM			9,262-----
----- LISINOPRIL					3,655-----
----- MIRTAZAPINE					3,085-----
----- OXYCODONE HCL					4,538-----

-----6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.------

SELECT drug_name, 
	SUM(total_claim_count) AS total_claim, 
	opioid_drug_flag
FROM prescription
JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000 
GROUP by drug_name, opioid_drug_flag;

-----FUROSEMIDE     			3,083	"N"-----
-----GABAPENTIN	   			    3,531	"N"-----
-----HYDROCODONE-ACETAMINOPHEN  3,376	"Y"-----
-----LEVOTHYROXINE SODIUM	    9,262	"N"-----
-----LISINOPRIL	    			3,655	"N"-----
-----MIRTAZAPINE				3,085	"N"-----
-----OXYCODONE HCL				4,538	"Y"-----

-----6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.-----

SELECT drug_name, 
	   SUM(total_claim_count) AS total_claim, 
	   opioid_drug_flag, 
	   nppes_provider_first_name AS provider_first_name, 
	   nppes_provider_last_org_name AS provider_last_name
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE total_claim_count >= 3000 
GROUP BY drug_name, opioid_drug_flag,nppes_provider_first_name,nppes_provider_last_org_name;

-----"FUROSEMIDE"					3,083	"N"	"MICHAEL"	 "COX"-----
-----"GABAPENTIN"					3,531	"N"	"BRUCE" 	 "PENDLEY"-----
-----"HYDROCODONE-ACETAMINOPHEN"	3,376	"Y"	"DAVID"	     "COFFEY"-----
-----"LEVOTHYROXINE SODIUM"			3,023	"N"	"BRUCE"	     "PENDLEY"-----
-----"LEVOTHYROXINE SODIUM"			3,138	"N"	"DEAVER"     "SHATTUCK"-----
-----"LEVOTHYROXINE SODIUM"			3,101	"N"	"ERIC"		 "HASEMEIER"-----
-----"LISINOPRIL"					3,655	"N"	"BRUCE"		 "PENDLEY"-----
-----"MIRTAZAPINE"					3,085	"N"	"BRUCE"		 "PENDLEY"-----
-----"OXYCODONE HCL"				4,538	"Y"	"DAVID"		 "COFFEY"-----

---7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
--    a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi,
		drug_name,
		nppes_provider_last_org_name,
		nppes_provider_first_name
FROM prescriber
CROSS JOIN drug 
WHERE specialty_description = 'Pain Management'
AND opioid_drug_flag = 'Y'
AND nppes_provider_city = 'NASHVILLE';

-----FUROSEMIDE"	            3,083	"N"	"MICHAEL"	"COX"-----
-----GABAPENTIN"	            3,531	"N"	"BRUCE"	"PENDLEY"-----
-----HYDROCODONE-ACETAMINOPHEN	3,376	"Y"	"DAVID"	"COFFEY"-----
-----LEVOTHYROXINE SODIUM	    3,023	"N"	"BRUCE"	"PENDLEY"-----
-----LEVOTHYROXINE SODIUM	    3,138	"N"	"DEAVER" "SHATTUCK"-----
-----LEVOTHYROXINE SODIUM	    3,101	"N"	"ERIC"	"HASEMEIER"-----
-----LISINOPRIL  	            3,655	"N"	"BRUCE"	"PENDLEY"-----
-----MIRTAZAPINE	            3,085	"N"	"BRUCE"	"PENDLEY"-----
-----OXYCODONE HCL	            4,538	"Y"	"DAVID"	"COFFEY"-----

-----7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).-----

SELECT  prescriber.npi,
		drug.drug_name,
		SUM(total_claim_count) as tot_claim_count
FROM prescriber
CROSS JOIN drug
FULL JOIN prescription USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND opioid_drug_flag = 'Y'
AND nppes_provider_city = 'NASHVILLE'
GROUP BY prescriber.npi,
		drug.drug_name;

-----SEE TABLE-----

--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT  prescriber.npi,
		drug.drug_name,
		COALESCE(SUM(total_claim_count),0) AS total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING (drug_name)
WHERE specialty_description = 'Pain Management'
AND opioid_drug_flag = 'Y'
AND nppes_provider_city = 'NASHVILLE'
GROUP BY prescriber.npi,
		drug.drug_name;

-----SEE TABLE-----

----------*BONUS QUESTIONS*----------

-----1. How many npi numbers appear in the prescriber table but not in the prescription table?-----

SELECT (COUNT(DISTINCT prescriber.npi)) - (COUNT(DISTINCT prescription.npi)) AS diff
		FROM prescription
FULL JOIN prescriber USING (npi);

-----4,458-----

-----2.a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.-----

SELECT specialty_description,
	   generic_name,
	   SUM(total_claim_count) AS sum_total_claim_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description ILIKE '%family practice%'
GROUP BY generic_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 5;

-----"Family Practice"	"LEVOTHYROXINE SODIUM"	406,547-----
-----"Family Practice"	"LISINOPRIL"	        311,506-----
-----"Family Practice"	"ATORVASTATIN CALCIUM"	308,523-----
-----"Family Practice"	"AMLODIPINE BESYLATE"	304,343-----
-----"Family Practice"	"OMEPRAZOLE"	        273,570-----

-----2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology-----

SELECT specialty_description,
	   generic_name,
	   SUM(total_claim_count) AS sum_total_claim_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description ILIKE '%Cardiology%'
GROUP BY generic_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 5;

-----"Cardiology"	"ATORVASTATIN CALCIUM"	120,662-----
-----"Cardiology"	"CARVEDILOL"	        106,812-----
-----"Cardiology"	"METOPROLOL TARTRATE"	93,940-----
-----"Cardiology"	"CLOPIDOGREL BISULFATE"	87,025-----
-----"Cardiology"	"AMLODIPINE BESYLATE"	86,928-----

-----2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.-----

(SELECT specialty_description,
	   generic_name,
	   SUM(total_claim_count) AS sum_total_claim_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description ILIKE '%family practice%'
GROUP BY generic_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 5)
UNION 
(SELECT specialty_description,
	   generic_name,
	   SUM(total_claim_count) AS sum_total_claim_count
FROM drug
JOIN prescription USING (drug_name)
JOIN prescriber USING (npi)
WHERE specialty_description ILIKE '%Cardiology%'
GROUP BY generic_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 5)
ORDER BY sum_total_claim_count DESC
LIMIT 10;

-----"Family Practice"	"LEVOTHYROXINE SODIUM"	  406,547-----
-----"Family Practice"	"LISINOPRIL"	          311,506-----
-----"Family Practice"	"ATORVASTATIN CALCIUM"	  308,523-----
-----"Family Practice"	"AMLODIPINE BESYLATE"	  304,343-----
-----"Family Practice"	"OMEPRAZOLE"	          273,570-----
-----"Cardiology"	    "ATORVASTATIN CALCIUM"	  120,662-----
-----"Cardiology"	    "CARVEDILOL"	          106,812-----
-----"Cardiology"	    "METOPROLOL TARTRATE"	  93,940-----
-----"Cardiology"	    "CLOPIDOGREL BISULFATE"	  87,025-----

-----3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee. a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.-----

SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Nashville'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

-----1538103692	  53,622	 "NASHVILLE"-----
-----1497893556	  29,929	 "NASHVILLE"-----
-----1659331924   26,013	 "NASHVILLE"-----
-----1881638971	  25,511	 "NASHVILLE"-----
-----1962499582	  23,703	 "NASHVILLE"-----

-----3b. Now, report the same for Memphis.-----
SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Memphis'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5;

-----1346291432		65,659	"MEMPHIS"-----
-----1225056872		62,301	"MEMPHIS"-----
-----1801896881		40,169	"MEMPHIS"-----
-----1669470316		39,491	"MEMPHIS"-----
-----1275601346		36,190	"MEMPHIS"-----

-----3c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.-----

(SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Nashville'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Memphis'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Knoxville'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5)
UNION
(SELECT p.npi,
	SUM(total_claim_count) AS total_claims,
	nppes_provider_city
FROM prescription AS p 
JOIN prescriber USING (npi) 
WHERE nppes_provider_city ILIKE 'Chattanooga'
	AND total_claim_count IS NOT NULL
GROUP BY p.npi, prescriber.nppes_provider_city
ORDER BY total_claims DESC
LIMIT 5)
ORDER BY nppes_provider_city, total_claims DESC;

-----1568494474		31,552	"CHATTANOOGA"-----
-----1548234826		25,127	"CHATTANOOGA"-----
-----1013994615		19,305	"CHATTANOOGA"-----
-----1437191749		18,415	"CHATTANOOGA"-----
-----1891734711		17,139	"CHATTANOOGA"-----
-----1295762276		31,952	"KNOXVILLE"-----
-----1528094000		24,872	"KNOXVILLE"-----
-----1508868969		21,995	"KNOXVILLE"-----
-----1194793679		21,719	"KNOXVILLE"-----
-----588638019		21,349	"KNOXVILLE"-----
-----1346291432		65,659	"MEMPHIS"-----
-----1225056872		62,301	"MEMPHIS"-----
-----1801896881		40,169	"MEMPHIS"-----
-----1669470316		39,491	"MEMPHIS"-----
-----1275601346		36,190	"MEMPHIS"-----
-----1538103692		53,622	"NASHVILLE"-----
-----1497893556		29,929	"NASHVILLE"-----
-----1659331924		26,013	"NASHVILLE"-----
-----1881638971		25,511	"NASHVILLE"-----
-----1962499582		23,703	"NASHVILLE"-----

-----4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.-----


SELECT fp.county, SUM(od.overdose_deaths) AS total_ods
FROM overdose_deaths AS od
FULL JOIN fips_county AS fp
ON (fp.fipscounty::integer) = od.fipscounty
WHERE overdose_deaths > (SELECT AVG(overdose_deaths)
							FROM overdose_deaths)
GROUP BY fp.county
ORDER BY total_ods DESC

-----"DAVIDSON"		689-----
-----"KNOX"			683-----
-----"SHELBY"		567-----
-----"RUTHERFORD"	205-----
-----"HAMILTON"		191-----
-----"SULLIVAN"		131-----
-----"MONTGOMERY"	101-----
-----"SUMNER"		100-----
-----"BLOUNT"		99-----
-----"WILSON"		98-----
-----"SEVIER"		97-----
-----"ANDERSON"		96-----
-----"WILLIAMSON"	94-----
-----"ROANE"		77-----
-----"CHEATHAM"		73-----
-----"WASHINGTON"	71-----
-----"GREENE"		48-----
-----"DICKSON"		33-----
-----"MAURY"		33-----
-----"HAWKINS"		33-----
-----"BRADLEY"		31-----
-----"CARTER"		30-----
-----"HAMBLEN"		19-----
-----"LOUDON"		18-----
-----"CAMPBELL"		16-----
-----"TIPTON"		16-----
-----"ROBERTSON"	15-----
-----"COFFEE"		13-----

------5.a. Write a query that finds the total population of Tennessee.

SELECT SUM(population) AS tn_total_population
FROM population
JOIN fips_county USING (fipscounty)
WHERE state = 'TN'

-----659,7381-----

------ 5b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

SELECT SUM(population) AS tn_total_population
FROM population
JOIN fips_county USING (fipscounty)
WHERE state = 'TN'

SELECT county,
	population,
	ROUND(population/(SELECT SUM(population) AS tn_total_population
				FROM population
				JOIN fips_county USING (fipscounty))*100,2) AS percent_of_tn_pop
FROM population
JOIN fips_county USING (fipscounty)
GROUP BY percent_of_tn_pop, county, population
ORDER BY percent_of_tn_pop DESC

-----SEE TABLE-----

