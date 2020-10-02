# Ironsmith QSM Toolkit		       
Created by Valentinos Zachariou
University of Kentucky

## 1) Software requirements:

#### a) MATLAB

Ironsmith requires Matlab to run MEDI and supports versions R2017b to R2019b.  Matlab is not needed if MEDI is not required. The symbolic link/command "matlab" must exist and should open one of the required Matlab versions.

#### b) Singularity

Ironsmith tested on Singularity version 3.5.3
Installation guide:
https://sylabs.io/guides/3.5/admin-guide/installation.html

Please download QSM_Container.simg (8.8GB) from: https://drive.google.com/file/d/1wPdd2Xa0oLV2wwpHneXZ7nlIZB3XoKFb/view?usp=sharing

Place QSM_Container.simg in IronSmithQSM/Functions

#### c) Bash Unix shell version 4.2.46(2) or later. 


## 2) Syntax: 
	
**Ironsmith [MyInputFile] [absolute path to output folder]** 

Example: Ironsmith File.csv /home/data/MyAmazingExp/QSM_Analysis"

a) The output folder does not need to exist.

b) The output folder does not need to be empty but Ironsmith will skip any participant specified in MyInputFile that has a corresponding folder inside the output folder.

*Ex. if S0001 is specified in MyInputFile and folder S0001 exists in output folder, S0001 will be skipped.*

c) Freesurfer is a reserved folder name under output folder and may be used by Ironsmith. See section #4 on quality of life features below.

## 3) MyInputFile format:  

a) File has to be CSV formatted (entries separated by commas ',').

b) Each row corresponds to a different participant.  

see Example_File.CSV in IronSmithQSM folder:  

### If MEDI is required to create QSM images/maps:  

**Column1** = Subj (Nominal subject variable e.g. S0001 or 01 or Xanthar_The_Destroyer)  **Column2** = MEDI_Yes <-- This is case sensitive  	
**Column3** = Absolute path to directory with MPR/MEMPR files 
*(e.g. /home/subjecs/S01/MPR).* 

MPR/MEMPR files can be:  

a) DICOMS 

Only MPR/MEMPR DICOMS should be present in the MPR folder if you want IronSmith to process DICOMS. If NIFTI files exist together with DICOMS, they will be selected instead (see "b" below). 

b) Multiple .nii/.nii.gz files each corresponding to a different echo. 

Each NIFTI file needs to have _e# in the file name, where # is the echo# *(e.g. S0001_MEMPR_e1.nii.gz, S0001_MEMPR_e2.nii.gz...).* This is the default **dcm2niix** output format for multiple echos. 
    
c) Single .nii/nii.gz file with multiple timepoints, each corresponding to a different echo.

d) Single .nii/nii.gz file with a single echo/timepoint. 
This can be rms/averaged across echos or just a single echo T1 MPRAGE.
 
**Column4** = Absolute path to folder with QSM DICOM files 
*(e.g. /home/subjecs/S01/QSM_Dicom).* 

Preferably only QSM DICOMS should be present in the QSM_Dicom folder.  However, IronSmith can filter out the following filetypes .nii .json .txt .nii.gz .HEAD .BRIK .hdr .img

All 4 columns need to be provided, otherwise Ironsmith will exit with errors.

### If MEDI is NOT required. That is QSM Maps, Phase and Magnitude images are already available:  

**Column1** = Subj (Nominal subject variable e.g. S0001 or 01 or Xanthar_The_Destroyer).  
**Column2** = MEDI_No <-- This is case sensitive.	
**Column3** = Absolute path to directory with MPR/MEMPR files 
(e.g. /home/subjecs/S01/MPR). MPR/MEMPR files can be:  

a) DICOMS 

Only MPR/MEMPR DICOMS should be present in the MPR folder if you want IronSmith to process DICOMS. If NIFTI files exist together with DICOMS, they will be selected instead (see "b" below).  

b) Multiple .nii/.nii.gz files each corresponding to a different echo. 

Each NIFTI file needs to have _e# in the file name, where # is the echo# *(e.g. S0001_MEMPR_e1.nii.gz, S0001_MEMPR_e2.nii.gz...).* This is the default dcm2niix output format for multiple echos and protects against errors.

c) Single .nii/nii.gz file with multiple timepoints, each corresponding to a different echo.    

d) Single .nii/nii.gz file with a single echo/timepoint 
 This can be rms/averaged across echos or just a single echo T1 MPRAGE.

**Column4** = Absolute path including filename to QSM magnitude image 
*(e.g. /home/subjecs/S01/QSM/QSM_Magnitude.nii.gz).*  

**Column5** = Absolute path including filename to QSM map 
*(e.g. /home/subjects/S01/QSM/QSM_Map.nii.gz).*  

All 5 columns need to be provided, otherwise Ironsmith will exit with errors


## 4) Quality of life features:  

If a participant already has a completed freesurfer recon-all -all segmentation folder and you would like Ironsmith to skip the freesurfer segmentation step, do the following: 

a) Copy the freesurfer recon-all folder (the one containing the label, *mri*, *scripts*, *stats*, *surf*... folders) into **/OutputFolder/Freesurfer**, where **OutputFolder** is the one specified/to be specified in the Ironsmith command. 

You can create the /OutputFolder/Freesurfer folder or Ironsmith will create it for you if you have run it at least once previously for OutputFolder.
 
b) Rename the recon-all folder to **Subj_FreeSurfSeg_Skull**. Subj should match the one provided in MyInputFile and should correspond to the participant you want the segmentation step skipped.

## 5) Outputs:

Each participant processed by Ironsmith will have a corresponding folder in **OutputFolder**. For example, if "**/home/QSM_Analysis**" is the OutputFolder and "**S0001**" is one of the participants processed, then **/home/QSM_Analysis/S0001** will be created and populated with data.

a) All masks/ROIs are placed under:

**S0001/QSM/Freesurf_QSM_Masks/Cort_Masks_AL_QSM_RS_Erx1
S0001/QSM/Freesurf_QSM_Masks/SubC_Masks_AL_QSM_RS_Erx1**

b) All QSM maps/images created are under S0001/QSM/Freesurf_QSM_Masks and are labelled as: 
			
**Subj_QSM_Map_FSL.nii.gz**		<-- Default MEDI
**Subj_QSM_Map_New_CSF_FSL.nii.gz** <-- Lateral ventricles as the QSM reference structure
**Subj_QSM_Map_New_WM_FSL.nii.gz**  <-- White matter as the QSM reference structure

c) All QSM maps warped to MNI space are placed in 

**S0001/QSM/Freesurf_QSM_Masks/MNI152_QSM**

d) QSM per ROI means (87 ROIs) are under **/QSM_Analysis/Group** as follows:

Group_QSM_Mean.csv <--- Using only positive QSM voxels
Group_QSM_Adj_Mean.csv <--- Using only positive QSM voxels and adjusting for ROI size
Group_QSM_SNR.csv <--- Per ROI SNR measures. 

SNR is calculated as follows: 
mean signal intensity of magnitude image within an ROI / standard deviation of magnitude signal outside the head.

The outside the head mask can be found here: **/QSM_Analysis/S0001/QSM/Freesurf_QSM_Masks/Subj_QSM_Mag_FSL_rms_OH_Mask.nii.gz**

