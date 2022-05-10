********************************************************************
*  Assignment:    Final Project                                       
*                                                                    
*  Description:   Using NHANES data to look at prevalence of diabetes 
*                 amongst different group characteristics
*
*  Name:          Alice Yu
*
*  Date:          4/11/2022                                     
*------------------------------------------------------------------- 
*  Job name:      final_alicewyu.sas   
*
*  Purpose:       Convert .XPT to SAS Datasets 
*                 
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         NHANES 2017-March 2020 pre-pandemic data: 
*                 	P_DEMO, P_BMX, P_DIQ
*
*  Output:        SAS Dataset 
*                   
*                                                                    
********************************************************************;
LIBNAME final "c:\Users\alwwi\Documents\bios669\final_proj\data";
libname demoxpt xport "c:\Users\alwwi\Documents\bios669\final_proj\data\P_DEMO.xpt" access=readonly;
proc copy inlib=demoxpt outlib=final; run;

libname bmxxpt xport "c:\Users\alwwi\Documents\bios669\final_proj\data\P_BMX.xpt" access=readonly;
proc copy inlib=bmxxpt outlib=final; run;

libname diqxpt xport "c:\Users\alwwi\Documents\bios669\final_proj\data\P_DIQ.xpt" access=readonly;
proc copy inlib=diqxpt outlib=final; run;