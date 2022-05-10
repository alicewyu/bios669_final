# bios669_final
## Contents:
-  Data Folder: Contains original dataset files, SAS converted datasets, and codebooks
-  Logs Folder: Contains the logs of SAS programs
-  final_alicewyu PDF: Contains output of findings that was created by running *final2_alicewyu.sas*
-  final_alicewyu SAS File: Contains code that was used to convert datasets into SAS datasets
-  final2_alicewyu SAS File: Contains code that creates analysis dataset, figures, and reports

## Goals:
1)  Using NHANES 2017 - March 2020 Pre-Pandemic data to look at prevalence of diabetes amongst different group characteristics such as race, age, gender
2)  Look at trends of BMI amongst different characteristics. Also, taking a closer look specifically at children/youth study participants and BMI category

## Data Background:
The NHANES program suspended field operations in March 2020 due to the coronavirus disease 2019 (COVID-19) pandemic. As a result, data collection for the NHANES 2019-2020 cycle was not completed and the collected data are not nationally representative. Therefore, data collected from 2019 to March 2020 were combined with data from the NHANES 2017-2018 cycle to form a nationally representative sample of NHANES 2017-March 2020 pre-pandemic data.

## Methods Applied: 
The following datasets were combined: P_DEMO, P_BMX, P_DIQ based on SEQN (Study Participant ID). Created a sgpanel macro that created a boxplot showing the relationship between BMI and diabetes grouping by different characteristics of choice. Also created graphs specifically for children/youth where only this age group had a BMI grouping. A similar boxplot to the above was created for the children/youth except the category was by BMI category. Then an extra scatterplot was created to show the trend between age and BMI. Then, another macro was developed to create a report to show prevalence of diabetes between all different groups of one characteristic. A third macro was created to compare two different groups of one characteristic and a Rao-Scott Chi-square test was used to compare the groups. Sample weights were used to perform such analyses. 

## Results/Findings:
When grouped by whether participants have diabetes, the Blacks seemed to have the most variance in BMI for all four categories (yes, no, borderline, don’t know). Furthermore, most of the data for the groups are skewed to the right. When comparing in terms of gender, females have more varying BMIs as compared to males. For children/youth study participants (2 to 19 years), those with a “higher” (from underweight, normal weight, overweight, to obese) BMI classification tended to have a higher BMI. This was further shown in the scatterplot. For those with diabetes, as a study participant got older, the trend was the person’s BMI increased. There was no data for those who were classified as obese until age 11. Of those who were diagnosed with diabetes, whites had the highest prevalence (n=428). In contrast, others had the least prevalence (n=71). When comparing just male and females, males (n=724) had a higher prevalence of diabetes than females (n=624). The rao-scott chi-square test was insignificant (p-value=0.2967 >0.05), concluding that we cannot say there is a relationship between gender and diabetes. 
  
