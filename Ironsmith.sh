#!/bin/bash

#Path=`pwd` #Folder where the container is situated

#Path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

Path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_file=$(echo "$Path/LogFiles/Output.Ironsmith_$(date +"%m_%d_%Y_%H_%M_%S").txt")
exec &> >(tee -a "$log_file")

#Authored by Valentinos Zachariou on 08/24/2020
#
#	Master QSM toolkit script. Checks paths and file availability and creates variables for use by subsequent scripts.
#	The Master QSM script also creates the output directory in the user specified path.	
#
#
#
#
#       _---~~(~~-_.			
#     _{        )   )
#   ,   ) -~~- ( ,-' )_
#  (  `-,_..`., )-- '_,)
# ( ` _)  (  -~( -_ `,  }
# (_-  _  ~_-~~~~`,  ,' )
#   `~ -^(    __;-,((()))
#         ~~~~ {_ -_(())
#                `\  }
#                  { }
#
#


#File.txt format:
#File has to be CSV
#Each row corresponds to a different participant
#File must have 4 columns in each row with MEDI_Yes and 5 Columns in each row with MEDI_No (see below)

#If MEDI is required to create QSM images:
#Column1 = Subj (Nominal subject variable e.g. S0001 or 01 or Xanthar_The_Destroyer)
#Column2 = MEDI_Yes
#Column3 = Absolute path to directory with MPRAGE nifti OR DICOM files. Ex. /home/subjecs/S01/MPR
#Column4 = Absolute path to folder with QSM DICOM files. /home/subjecs/S01/QSM_Dicom


#If MEDI is NOT required. That is QSM Maps, Phase and Magnitude images are already available then: 
#Column1 = Subj (Nominal subject variable e.g. S0001 or 01 or Xanthar_The_Destroyer)
#Column2 = MEDI_No
#Column3 = Absolute path to directory with MPRAGE nifti OR DICOM files
#Column4 = Absolute path including filename to QSM magnitude image. Ex. /home/subjecs/S01/QSM/QSM_Magnitude.nii.gz
#Column5 = Absolute path including filename to QSM map. Ex. /home/subjects/S01/QSM/QSM_Map.nii.gz


clear

#Font Name: ANSI Regular
echo ""
echo "██ ██████   ██████  ███    ██     ███████ ███    ███ ██ ████████ ██   ██ "
echo "██ ██   ██ ██    ██ ████   ██     ██      ████  ████ ██    ██    ██   ██ "
echo "██ ██████  ██    ██ ██ ██  ██     ███████ ██ ████ ██ ██    ██    ███████ "
echo "██ ██   ██ ██    ██ ██  ██ ██          ██ ██  ██  ██ ██    ██    ██   ██ "
echo "██ ██   ██  ██████  ██   ████     ███████ ██      ██ ██    ██    ██   ██ "                                                                  
echo ""                                                                         
echo ""
echo -e "\t\t             _---~~(~~-_.		    "	
echo -e "\t\t           _{        )   )		    "
echo -e "\t\t         ,   ) -~~- ( ,-' )_	    "
echo -e "\t\t        (  '-,_..'., )-- '_,)	    "
echo -e "\t\t       ( ' _)  (  -~( -_ ',  }	    "
echo -e "\t\t       (_-  _  ~_-~~~~',  ,' )         "
echo -e "\t\t         '~ -^(    __;-,((()))	    "
echo -e "\t\t               ~~~~ {_ -_(())          "
echo -e "\t\t                      '\  }            "
echo -e "\t\t                       { }             "
echo -e "				            "
echo -e "\t	  Ironsmith QSM Toolkit V1.0 (09/24/2020)		       "
echo -e "\t	  Created by Valentinos Zachariou	    		       "
echo -e "\t	  University of Kentucky 	                               "
echo -e "-------------------------------------------------------------------------"
echo ""

sleep 3s

echo ""
echo "Path set to $Path"
echo ""
   
CSVFile=$1
OutFolder=$2
TooManyInputs=$3
MPRType=0
ExCode=0
First_DICOM=0
DICOM_Error=0
ContainerFlag=0 #1 = Singularity, 2 = Docker
MatlabFlag=0
MatPath="MATLAB PATH NOT SET"

#Check if QSM_Container.simg is in /Functions

if [ -f "$Path/Functions/QSM_Container.simg" ] && [[ $(find $Path/Functions/QSM_Container.simg -type f -size +8G 2>/dev/null) ]]; then

	echo ""	
	echo "QSM_Container.simg FOUND in $Path/Functions"
	echo ""

else

	echo ""	
	echo -e "\e[31m----------------------------------------------"
	echo "ERROR: QSM_Container.simg NOT FOUND in $Path/Functions or is the wrong size (should be 8.8G)! (⊙_◎) "
	echo ""	
	echo "Please download QSM_Container.simg from:"
	echo ""
	echo "https://drive.google.com/file/d/1wPdd2Xa0oLV2wwpHneXZ7nlIZB3XoKFb/view?usp=sharing"
	echo ""
	echo "Then place in $Path/Functions"
	echo -e "----------------------------------------------\e[0m"	
	echo ""	
	exit

fi

echo ""
echo "---------------------------------------------------------------"
echo "*** Checking arguments provided with Master_Script commnad: ***"
echo "---------------------------------------------------------------"
echo ""

#Check if path to output folder is valid

if [[ `echo $OutFolder | grep -o '.$'` == "/" ]]; then
	
	#echo "${OutFolder%?}"
	#echo "Eternal sunshine of the spotless mind"
	OutFolder=${OutFolder%?}
	#echo $OutFolder
fi

#Check arguments provided with Master_Script command

if [ -z "$CSVFile" ]; then
	
	echo ""	
	echo -e "\e[31m----------------------------------------------"
	echo "ERROR: No input file provided! "
	echo "Syntax: Ironsmith MyInputFile.txt  /path/to/output/folder"
	echo "Please see $Path/README.md for details"
	echo -e "----------------------------------------------\e[0m"	
	echo ""	
	exit

elif [ -z "$OutFolder" ]; then

	echo ""	
	echo -e "\e[31m----------------------------------------------"
	echo "ERROR: No output folder provided! "
	echo "Syntax: Ironsmith MyInputFile.txt  /path/to/output/folder"
	echo "Please see $Path/README.md for details"
	echo -e "----------------------------------------------\e[0m"	
	echo ""	
	exit

elif [ ! -z "$TooManyInputs" ]; then
	echo ""
	echo -e "\e[31m----------------------------------------------"
	echo "ERROR: Too many arguments provided! "
	echo "Syntax: Ironsmith MyInputFile.txt /path/to/output/folder"
	echo "Please see $Path/README.md for details"
	echo -e "----------------------------------------------\e[0m"	
	echo ""
	echo $TooManyInputs	
	exit
fi

echo ""
#echo "---------------------------------------------------------------"
#echo -e "Input CSV File is \e[44m$CSVFile\e[0m"
echo "Input CSV File is $CSVFile"
#echo "---------------------------------------------------------------"
echo ""


#Check if input CSV file exists

if [ -f "$CSVFile" ]; then
	
	echo ""	
	#echo -e "\e[44m$CSVFile\e[0m Found"
	echo "$CSVFile Found"
	echo ""
else
	echo -e "\e[31m----------------------------------------------"	
	echo "ERROR: $CSVFile NOT FOUND! "
	echo -e "----------------------------------------------\e[0m"	
	exit

fi

PathToOut=$(echo $OutFolder | awk -F '/' '{OFS = FS} {$NF=""; print $0}')

if [ -d "$PathToOut" ]; then

	echo ""	
	#echo -e "Output folder path \e[44m$PathToOut\e[0m is a valid path!"
	#echo -e "Output files for each participant will be placed under \e[44m$OutFolder\e[0m in individual folders"
	#echo -e "\e[44m$OutFolder\e[0m will be created if nescessary"	
	echo "Output folder path $PathToOut is a valid path"
	echo "Output files for each participant will be placed under $OutFolder in individual folders"
	echo "$OutFolder will be created if nescessary"	
	echo ""

elif [ -z "$PathToOut" ]; then

	echo -e "\e[31m----------------------------------------------"	
	echo "ERROR: NOT SURE WHAT $OutFolder IS. Check OUTPUT FOLDER INPUT"
	echo -e "----------------------------------------------\e[0m"	
	exit
else
	echo -e "\e[31m----------------------------------------------"	
	echo "ERROR: $PathToOut NOT FOUND or INVALID. Check OUTPUT FOLDER PATH"
	echo -e "----------------------------------------------\e[0m"	
	exit

fi


echo ""
echo "---------------------------------------------------------------"
echo "*** Checking if Singularity and/or Docker are installed: ***"
echo "---------------------------------------------------------------"
echo ""

#Check for Singularity or docker


if command -v singularity &> /dev/null; then

	#SingVer1=$(singularity --version | awk -F 'version' '{print $1}')
	SingVer2=$(singularity --version | awk -F 'version' '{print $2}')
	echo ""
	#echo -e "singularity Ver \e[44m$SingVer2\e[0m installed. All good! "
	echo "Singularity Ver$SingVer2 installed. All good! "
	#echo -e "singularity is installed. All good! "
	echo ""
	ContainerFlag=1

elif ! command -v singularity &> /dev/null; then
	echo ""	
	echo -e "\e[93m----------------------------------------------"
	echo "WARNING: Singularity NOT FOUND! "
	echo "Checking for DOCKER"
	echo -e "----------------------------------------------\e[0m"	
	echo ""	
	
	if command -v docker &> /dev/null; then
		
		
		DockVer2=$(docker --version | awk -F 'version' '{print $2}')
		echo ""
		echo -e "\e[93m----------------------------------------------"		
		echo "ERROR: Docker Ver $DockVer2 installed. However, only Singularity supported at the moment (╯°□°）╯︵ ┻━┻ "
		echo -e "----------------------------------------------\e[0m"			
		echo ""
		ContainerFlag=2

		

	elif ! command -v docker &> /dev/null; then

		echo ""	
		echo -e "\e[93m----------------------------------------------"
		echo "ERROR: Singularity not FOUND! "
		echo "Singularity needs to be installed for this toolkit to work ¯\_(ツ)_/¯"
		echo -e "----------------------------------------------\e[0m"	
		echo ""	
		exit
	fi
fi	

echo ""
echo "---------------------------------------------------------------"
echo "*** Parsing $CSVFile : ***"
echo "---------------------------------------------------------------"
echo ""

#Figure out how many rows the CSVFile has
CSVFileRows=`awk 'END{print NR}' $CSVFile`

echo ""
#echo -e "$CSVFile has \e[44m$CSVFileRows\e[0m Rows, \e[44m$CSVFileRows\e[0m participants will be processed."
echo "$CSVFile has $CSVFileRows Rows ---> $CSVFileRows participants will be processed."
echo ""	

for Rows in `seq $CSVFileRows`

do
	
	echo ""
	echo "---------------------------------------------------------------"
	echo "*** Processing $CSVFile row $Rows ***"
	echo "---------------------------------------------------------------"
	echo ""

	#Parse CSV file into variables
	CSVFileColumns=`awk -v r=$Rows -F ',' 'FNR == r {print NF}' $CSVFile`

	#Check if MEDI is needed on a participant by participant basis

	MEDIFlag=`awk -v r=$Rows -F ',' 'FNR == r {print $2}' $CSVFile`


	if  [[ $MEDIFlag == "MEDI_Yes" ]]; then

		if [[ $CSVFileColumns < 4 ]]; then

			echo -e "\e[31m----------------------------------------------"	
			echo "ERROR: $CSVFile row $Rows is missing columns, please check, skipping..."
			echo -e "----------------------------------------------\e[0m"
			continue

		elif [[ $CSVFileColumns == 4 ]]; then

			echo ""
			echo "$CSVFile row $Rows has $CSVFileColumns columns! Column test PASSED! " 
			echo ""
		fi
		

		Subj=`awk -v r=$Rows -F ',' 'FNR == r {print $1}' $CSVFile`
		MPRDir=`awk -v r=$Rows -F ',' 'FNR == r {print $3}' $CSVFile`
		QSM_Dicom_Dir=`awk -v r=$Rows -F ',' 'FNR == r {print $4}' $CSVFile`		

		echo "Participant $Subj requires MEDI processing! " 
			
		if [[ $MatlabFlag == 0 ]]; then
			
			# First check for Matlab
			unset MatVer
			
			MatPath=$(grep -v "#" Matlab_Config.txt | grep "MATLAB_Path=" | awk -F'"' '{print $2}')
	
			#MatVer=$($MatPath -nodisplay -nosplash -nodesktop -r "try; v=version; disp(v); catch; end; quit;" | tail -n2 | head -c 3)
			bash $Path/Functions/MatlabVer.sh $Path $MatPath < /dev/null
			MatVer=$(cat $Path/Functions/MatTempFile.txt)
			rm $Path/Functions/MatTempFile.txt		

			if (( $(echo "$MatVer >= 9.3" | bc -l) )) && (( $(echo "$MatVer < 9.8" | bc -l) )); then

				echo ""
				#echo -e "Matlab Ver \e[44m$MatVer\e[0m installed. All good! "
				echo "Matlab Ver $MatVer installed. All good! "
				echo ""
				unset MatlabFlag
				MatlabFlag=1 #correct Version of Matlab found

			elif ((  $(echo "$MatVer < 9.3" | bc -l) )); then

				echo ""	
				echo -e "\e[31m----------------------------------------------"
				echo "ERROR: The Matlab version installed (ver $MatVer) is too old! "
				echo "Matlab versions between R2017b (9.3) and R2019b (9.7) required for this Toolkit"
				echo -e "----------------------------------------------\e[0m"	
				echo ""	
				exit

			elif ((  $(echo "$MatVer > 9.7" | bc -l) )); then

				echo ""	
				echo -e "\e[31m----------------------------------------------"
				echo "ERROR: The Matlab version installed (ver $MatVer) is too new! "
				echo "Matlab versions between R2017b (9.3) and R2019b (9.7) required for this Toolkit"
				echo -e "----------------------------------------------\e[0m"	
				echo ""	
				exit

			else
				echo ""	
				echo -e "\e[31m----------------------------------------------"
				echo "ERROR: No Matlab installation found! (ver $MatVer)"
				echo "Matlab versions between R2017b (9.3) and R2019b (9.7) required for this Toolkit"
				echo -e "----------------------------------------------\e[0m"	
				echo ""	
				exit
			fi
		
		elif [[ $MatlabFlag == 1 ]]; then
			
			echo ""
			echo "Skipping Matlab test. Matlab Ver $MatVer already found"	
			echo ""
		fi
			 			

	elif [[	$MEDIFlag == "MEDI_No" ]]; then

		
		if [[ $CSVFileColumns < 5 ]]; then

			echo -e "\e[31m----------------------------------------------"	
			echo "ERROR: $CSVFile row $Rows is missing columns, please check, skipping..."
			echo -e "----------------------------------------------\e[0m"
			continue

		elif [[ $CSVFileColumns == 5 ]]; then

			echo ""
			echo "$CSVFile row $Rows has $CSVFileColumns columns! Column test PASSED! " 
			echo ""
		fi


		Subj=`awk -v r=$Rows -F ',' 'FNR == r {print $1}' $CSVFile`
		MPRDir=`awk -v r=$Rows -F ',' 'FNR == r {print $3}' $CSVFile`
		MAG=`awk -v r=$Rows -F ',' 'FNR == r {print $4}' $CSVFile`
		QSMFile=`awk -v r=$Rows -F ',' 'FNR == r {print $5}' $CSVFile`

	else
		
		Subj=`awk -v r=$Rows -F ',' 'FNR == r {print $1}' $CSVFile`
		echo ""		
		echo -e "\e[31m----------------------------------------------"	
		echo "ERROR: Column 2 needs to be either MEDI_Yes or MEDI_No and is case sensitive." 
		echo "$Subj Column 2 entry is $MEDIFlag which cannot be interepreted, skipping $Subj...."
		echo -e "----------------------------------------------\e[0m"
		echo ""		
		continue
		
	fi

	
	echo ""
	echo "---------------------------------------------------------------"
	echo "*** Evaluating inputs provided in $CSVFile row $Rows: ***"
	echo "---------------------------------------------------------------"
	echo ""


	# MPR Check

	if [ ! -d "$MPRDir" ]; then
		echo ""
		echo -e "\e[31m----------------------------------------------"
		echo "ERROR: MPR/MEMPR Directory: $MPRDir NOT FOUND! Skipping $Subj..."
		echo -e "----------------------------------------------\e[0m"
		echo ""
		continue	

	else
		echo ""		
		#echo -e "\e[44m$MPRDir\e[0m FOUND! Checking folder contents"
		echo "MPR/MEMPR Directory: $MPRDir FOUND! Checking folder contents..."			
		echo ""

		if [ ! "$(ls -A $MPRDir)" ]; then
		
			echo ""
			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: $MPRDir is EMPTY, check FOLDER, skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""			
			continue	
		else
			
			if ! ls $MPRDir/*.nii* 1> /dev/null 2>&1; then
			
				echo ""
				echo "No NIFTI files found in $MPRDir, Checking for DICOMS..."
				echo ""				
				#continue

				unset First_DICOM Dicom_Err

				First_DICOM=$(singularity run -e --bind $MPRDir:/mnt $Path/Functions/QSM_Container.simg find /mnt -mindepth 1 \
						-maxdepth 1 -type f ! -regex '.*\(nii\|json\|txt\|nii.gz\|HEAD\|BRIK\|hdr\|img\)$' | awk -F '/' 'FNR == 1')
				
				Dicom_Err=$(singularity run -e --bind $MPRDir:/mnt $Path/Functions/QSM_Container.simg dicom_hdr $First_DICOM | awk 'NR==2 {print $2}')


				if [[ $Dicom_Err == "ERROR:" ]]; then
					
					echo ""	
					echo -e "\e[31m----------------------------------------------"
					echo "ERROR: MPR/MEMPR directory $MPRDir has one or more of these issues:" 
					echo "1. Folder has DICOMs but also other files that are not DICOMS (excluding: NIFTI/AFNI/Analyze formats)"
					echo "2. Folder has files in it but are neither NIFTI nor DICOM! It's a mystery ¿ⓧ_ⓧﮌ "
					echo "PLEASE check $MPRDir! Skipping $Subj..."
					echo -e "----------------------------------------------\e[0m"
					echo ""					
					continue
				else
					
					echo ""					
					echo "DICOMS FOUND in $MPRDir. They will be processed by 01_MPRAGE.sh ! ( •̀ᴗ•́ )و ̑̑"
					echo ""
					MPRType=4
				fi				

				unset First_DICOM Dicom_Err


			elif [[ -n $(find $MPRDir -mindepth 1 -maxdepth 1 -type f -name "*_e*nii*") ]] && [ $(ls -1 $MPRDir/*_e*nii* 2>/dev/null | wc -l) -gt 1 ]; then 
				
				echo ""				
				echo "Multiple echos found as separate NIFTI files:"
				echo ""
				echo "`ls -l $MPRDir/*_e*nii* | awk -F '[/]' '{print $NF}'`"
				echo ""
				echo "Will calculate RMS across files" 
				MPRType=1 # Multiple echos as separate _e files			
				echo ""	
		
			#elif ls $MPRDir/*.nii* 1> /dev/null 2>&1 && [[ -n $(find . -mindepth 1 -maxdepth 1 -type f ! -name "*_e*") ]]; then
			 elif ls $MPRDir/*.nii* 1> /dev/null 2>&1 && [ $(ls -1 $MPRDir/*.nii* 2>/dev/null | wc -l) -eq 1 ]; then
			
				echo ""	
				echo "Single NIFTI file found, checking if multiple echos exist within file:"
				echo ""
				echo "`ls $MPRDir/*nii* | awk -F '[/]' '{print $NF}'`"
				echo ""	

				TimePoints=$(singularity run -e --bind $MPRDir:/mnt $Path/Functions/QSM_Container.simg 3dinfo -nv /mnt/*.nii*)				

				if [[ $TimePoints > 1 ]]; then

					echo ""			
					echo "$TimePoints echos found in `ls $MPRDir/*nii* | awk -F '[/]' '{print $NF}'`" 
					echo ""
					echo "Will calculate RMS across echos for `ls $MPRDir/*nii* | awk -F '[/]' '{print $NF}'`" 
					MPRType=2 # Multiple echos in a single file					
					echo ""

				elif [[ $TimePoints == 1 ]]; then

								
					echo ""			
					echo "$TimePoints echo found in `ls $MPRDir/*nii* | awk -F '[/]' '{print $NF}'`"
					echo ""
					echo "`ls $MPRDir/*nii* | awk -F '[/]' '{print $NF}'` will be used as is"
					MPRType=3 #Single file, single echo					
					echo ""
				fi
					
			else
				echo ""				
				echo -e "\e[31m----------------------------------------------"
				echo "Unexpected ERROR: Please check $MPRDir, Skipping $Subj..."
				echo -e "----------------------------------------------\e[0m"
				echo ""				
				continue

			fi
		fi

	fi

	
	if [[ $MEDIFlag == "MEDI_No" ]]; then 
		# MAG File
		if [ ! -f "$MAG" ]; then

			echo ""
			echo -e "\e[31m----------------------------------------------"	
			echo "ERROR: QSM Magnitude image: $MAG NOT in specified path! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""
			continue
		else

			echo ""			
			#echo -e "\e[44m$MAG\e[0m Found in specified path!"
			echo "QSM Magnitude image: $MAG found in specified path"
			echo ""
		fi

		# QSM File
		if [ ! -f "$QSMFile" ]; then
			
			echo ""
			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: QSM Map: $QSMFile NOT in specified path! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""			
			continue
		else

			echo ""	
			#echo -e "\e[44m$QSMFile\e[0m Found in specified path!"
			echo "QSM Map: $QSMFile Found in specified path"
			echo ""			
		fi

	
	elif [[	$MEDIFlag == "MEDI_Yes" ]]; then
	
		#QSM Dicom Directory
		if [ -d "$QSM_Dicom_Dir" ]; then

			echo ""			
			#echo -e "\e[44m$QSM_Dicom_Dir\e[0m FOUND! Checking folder contents"
			echo "QSM DICOM directory: $QSM_Dicom_Dir FOUND! Checking folder contents"
			echo ""			

			if [ ! "$(ls -A $QSM_Dicom_Dir)" ]; then
				
				echo ""	
				echo -e "\e[31m----------------------------------------------"
				echo "ERROR: QSM DICOM directory $QSM_Dicom_Dir is EMPTY! Please check FOLDER, skipping $Subj..."
				echo -e "----------------------------------------------\e[0m"
				echo ""	
				continue	

			else
				First_DICOM=$(singularity run -e --bind $QSM_Dicom_Dir:/mnt $Path/Functions/QSM_Container.simg find /mnt -mindepth 1 \
						-maxdepth 1 -type f ! -regex '.*\(nii\|json\|txt\|nii.gz\|HEAD\|BRIK\|hdr\|img\)$' | awk -F '/' 'FNR == 1')
				
				Dicom_Err=$(singularity run -e --bind $QSM_Dicom_Dir:/mnt $Path/Functions/QSM_Container.simg dicom_hdr $First_DICOM | awk 'NR==2 {print $2}')


				if [[ $Dicom_Err == "ERROR:" ]]; then
					
					echo ""	
					echo -e "\e[31m----------------------------------------------"
					echo "ERROR: QSM DICOM directory $QSM_Dicom_Dir has one or more of these issues:" 
					echo "1. Folder has DICOMs but also other files that are not DICOMS (excluding: NIFTI/AFNI/Analyze formats)"
					echo "2. Folder has files in it but they are not DICOMs"
					echo "PLEASE check $QSM_Dicom_Dir! Skipping $Subj..."
					echo -e "----------------------------------------------\e[0m"
					echo ""					
					continue
				else
					
					echo ""					
					echo "DICOMS FOUND in $QSM_Dicom_Dir. They will be processed by MEDI! ( •̀ᴗ•́ )و ̑̑"
					echo ""
				fi			

			fi		
		else
			echo ""	
			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: QSM DICOM directory: $QSM_Dicom_Dir NOT FOUND in specified path! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""				
			continue
		fi	

	fi
		
	echo ""
	echo "All files/folders specifed in $CSVFile FOUND in specified paths" 
	echo "Cue the happy dance ♪┏(・o･)┛♪"
	echo "---------------------------------------------------------------"
	echo ""

	
	echo ""
	echo "---------------------------------------------------------------"
	echo "*** Evaluating output directory:"
	echo " $OutFolder : ***"
	echo "---------------------------------------------------------------"
	echo ""


	# Output folder Check
	if [ -d "$OutFolder" ]; then

		#Check if directory is empty
		if [ "$(ls -A $OutFolder)" ]; then
			
			echo ""	
			echo -e "\e[93m------------------------------------------------------"	
			echo "WARNING: $OutFolder already EXISTS and is NOT empty! " 
			echo "Checking if $Subj folder exists in $OutFolder."
			echo -e "------------------------------------------------------\e[0m"
			echo ""

			if [ -d "$OutFolder/$Subj" ]; then		
				
				echo ""				
				echo -e "\e[31m----------------------------------------------"	
				echo "ERROR: $OutFolder/$Subj already EXISTS! Please check folders. Skipping $Subj..."
				echo -e "----------------------------------------------\e[0m"
				echo ""				
				continue
					
			else
				echo ""								
				echo "$Subj folder does not exist in $OutFolder, Creating Folder"		
				echo ""
				mkdir $OutFolder/$Subj
				mkdir $OutFolder/$Subj/LogFiles

				if [ ! -d "$OutFolder/Freesurfer" ]; then
					
					mkdir $OutFolder/Freesurfer
				fi
					
			fi

		else
			echo ""				
			echo -e "\e[93m----------------------------------------------"
			echo "WARNING: $OutFolder Already EXISTS! However, it is empty. $Subj folder will be created"
			echo -e "----------------------------------------------\e[0m"
			echo ""				
			mkdir $OutFolder/$Subj
			mkdir $OutFolder/$Subj/LogFiles
			mkdir $OutFolder/Freesurfer
				
		fi
	else
		echo ""			
		echo -e "\e[44m$OutFolder\e[0m does not exist, it will be created." 	
		echo ""			
		mkdir $OutFolder
		mkdir $OutFolder/$Subj
		mkdir $OutFolder/$Subj/LogFiles
		mkdir $OutFolder/Freesurfer	

	fi


############ Analyses start running here. Different scripts will be called depending on the MEDI flag ############

	if [[ $MEDIFlag == "MEDI_Yes" ]]; then

		
		#****************************************************
		#1) MEDI
		#****************************************************

		#Passed varialbes to MEDI.sh 
		#1) Suject
		#2) Output Folder
		#3) Path
		#4) QSM_Dicom_Dir
		#5) Matlab path

		#Command		
		bash $Path/Functions/MEDI.sh $Subj $OutFolder $Path $QSM_Dicom_Dir $MatPath < /dev/null #|& tee $OutFolder/$Subj/$Subj.Output.MEDI.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then
			echo ""	
			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: MEDI.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""	
			continue

		elif [[ $ExCode == 0 ]]; then
			echo ""
			echo "----------------------------------------------"				
			echo "QSM Map file set to $OutFolder/$Subj/QSM/${Subj}_QSM_Map.nii.gz"
			echo "QSM Magnitude file set to $OutFolder/$Subj/QSM/${Subj}_QSM_Mag.nii.gz"
			echo "----------------------------------------------"			
			echo ""
			MAG="$OutFolder/$Subj/QSM/${Subj}_QSM_Mag.nii.gz"
			QSMFile="$OutFolder/$Subj/QSM/${Subj}_QSM_Map.nii.gz"
		fi
	
		#****************************************************
		#2) 01_MPRAGE.sh
		#****************************************************

		#Passed varialbes to 01_MPRAGE.sh 
		#1) Suject
		#2) Output Folder
		#3) MPRAGE Directory
		#4) MPRAGE Type
		#5) Path
		
		#Command
		bash $Path/Functions/01_MPRAGE.sh $Subj $OutFolder $MPRDir $MPRType $Path #|& tee $OutFolder/$Subj/$Subj.Output.01.MPRAGE.txt
		
		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 01_MPRAGE.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		
		#****************************************************
		#3) 02_Create_QSM_Masks.sh
		#****************************************************
		
		#Passed varialbes to 02_Create_QSM_Masks.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#4) MEDI Flag

		#Command
		bash $Path/Functions/02_Create_QSM_Masks.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.02_Create_QSM_Masks.txt
		
		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 02_Create_QSM_Masks.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#4) 03_AlignQSM.sh
		#****************************************************
		
		#Passed varialbes to 03_AlignQSM.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#4) QSM File
		#5) QSM Magnitude
		#6) MEDI Flag
		
		#Command
		bash $Path/Functions/03_AlignQSM.sh $Subj $OutFolder $Path $QSMFile $MAG $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.03_AlignQSM.txt
		
		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 03_AlignQSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#5) 04_Erode_QSM_Masks.sh
		#****************************************************
		
		#Passed varialbes to 04_Erode_QSM_Masks.sh
		#1) Suject
		#2) Output Folder
		#3) Path
				
		#Command
		bash $Path/Functions/04_Erode_QSM_Masks.sh $Subj $OutFolder $Path #|& tee $OutFolder/$Subj/$Subj.Output.04_Erode_QSM_Masks.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 04_Erode_QSM_Masks.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#6) MEDI_QSM_New_Ref.sh
		#****************************************************
		
		#Passed varialbes to 04_Erode_QSM_Masks.sh
		#1) Suject
		#2) Output folder
		#3) Path
		#4) QSM DICOM Dir
		#5) Matlab path
				
		#Command
		bash $Path/Functions/MEDI_QSM_New_Ref.sh $Subj $OutFolder $Path $QSM_Dicom_Dir $MatPath < /dev/null #|& tee $OutFolder/$Subj/$Subj.Output.MEDI_QSM_New_Ref.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then
			echo ""	
			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: MEDI_QSM_New_Ref.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			echo ""	
			continue

		elif [[ $ExCode == 0 ]]; then
			echo ""
			echo "---------------------------------------------------------------"				
			echo "New CSF ref QSM Map set to $OutFolder/$Subj/QSM/${Subj}_QSM_Map_New_CSF.nii.gz"
			echo "New WM ref QSM Map set to $OutFolder/$Subj/QSM/${Subj}_QSM_Map_New_WM.nii.gz"
			echo "---------------------------------------------------------------"			
			echo ""
			#QSMFileCSF="$OutFolder/$Subj/QSM/${Subj}_QSM_Map_New_CSF.nii.gz"
			#QSMFileWM="$OutFolder/$Subj/QSM/${Subj}_QSM_Map_New_WM.nii.gz"	
		fi

		#****************************************************
		#7) 05_Extract_QSM.sh
		#****************************************************
		
		#Passed varialbes to 05_Extract_QSM.sh 
		#1) Subject
		#2) Output folder
		#3) Path
		#4) MEDI Flag
		
		#Command
		bash $Path/Functions/05_Extract_QSM.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.05_Extract_QSM.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 05_Extract_QSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi


		#****************************************************
		#8) 06_QSM_SNR.sh
		#****************************************************

		#Passed varialbes to 05_Extract_QSM.sh 
		#1) Subject
		#2) Output folder
		#3) Path
	

		#Command
		bash $Path/Functions/06_QSM_SNR.sh $Subj $OutFolder $Path #|& tee $OutFolder/$Subj/$Subj.Output.06_QSM_SNR.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 06_QSM_SNR.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#9) 07_MNI_NL_WarpQSM.sh
		#****************************************************
		
		#Passed varialbes to 03_AlignQSM.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#6) MEDI Flag
		
		#Command
		bash $Path/Functions/07_MNI_NL_WarpQSM.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.07_MNI_NL_WarpQSM.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 07_MNI_NL_WarpQSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi
	

	elif [[ $MEDIFlag == "MEDI_No" ]]; then
		
		#****************************************************
		#1) 01_MPRAGE.sh
		#****************************************************

		#Passed varialbes to 01_MPRAGE.sh 
		#1) Suject
		#2) Output Folder
		#3) MPRAGE Directory
		#4) MPRAGE Type
		#5) Path
		
		#Command
		bash $Path/Functions/01_MPRAGE.sh $Subj $OutFolder $MPRDir $MPRType $Path #|& tee $OutFolder/$Subj/$Subj.Output.01.MPRAGE.txt
		
		#Error Handling
		ExCode=$?
		#echo "The Exit Code is $ExCode"
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 01_MPRAGE.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		
		#****************************************************
		#2) 02_Create_QSM_Masks.sh
		#****************************************************
		
		#Passed varialbes to 02_Create_QSM_Masks.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#4) MEDI Flag

		#Command
		bash $Path/Functions/02_Create_QSM_Masks.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.02_Create_QSM_Masks.txt
		
		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 02_Create_QSM_Masks.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#3) 03_AlignQSM.sh
		#****************************************************
		
		#Passed varialbes to 03_AlignQSM.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#4) QSM File
		#5) QSM Magnitude
		#6) MEDI Flag
		
		#Command
		bash $Path/Functions/03_AlignQSM.sh $Subj $OutFolder $Path $QSMFile $MAG $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.03_AlignQSM.txt
		
		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 03_AlignQSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#4) 04_Erode_QSM_Masks.sh
		#****************************************************
		
		#Passed varialbes to 04_Erode_QSM_Masks.sh
		#1) Suject
		#2) Output Folder
		#3) Path
				
		#Command
		bash $Path/Functions/04_Erode_QSM_Masks.sh $Subj $OutFolder $Path #|& tee $OutFolder/$Subj/$Subj.Output.04_Erode_QSM_Masks.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 04_Erode_QSM_Masks.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi


		#****************************************************
		#5) 05_Extract_QSM.sh
		#****************************************************
		
		#Passed varialbes to 05_Extract_QSM.sh 
		#1) Subject
		#2) Output folder
		#3) Path
		#4) MEDI Flag
		
		#Command
		bash $Path/Functions/05_Extract_QSM.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.05_Extract_QSM.txt

		#Error Handling
		ExCode=$?
		#echo "The exit code was $ExCode"		
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 05_Extract_QSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi


		#****************************************************
		#6) 06_QSM_SNR.sh
		#****************************************************

		#Passed varialbes to 05_Extract_QSM.sh 
		#1) Subject
		#2) Output folder
		#3) Path
	
		#Command
		bash $Path/Functions/06_QSM_SNR.sh $Subj $OutFolder $Path #|& tee $OutFolder/$Subj/$Subj.Output.06_QSM_SNR.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 06_QSM_SNR.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi

		#****************************************************
		#7) 07_MNI_NL_WarpQSM.sh
		#****************************************************
		
		#Passed varialbes to 03_AlignQSM.sh
		#1) Suject
		#2) Output Folder
		#3) Path
		#6) MEDI Flag
		
		#Command
		bash $Path/Functions/07_MNI_NL_WarpQSM.sh $Subj $OutFolder $Path $MEDIFlag #|& tee $OutFolder/$Subj/$Subj.Output.07_MNI_NL_WarpQSM.txt

		#Error Handling
		ExCode=$?
		if [[ $ExCode > 0 ]]; then

			echo -e "\e[31m----------------------------------------------"
			echo "ERROR: 07_MNI_NL_WarpQSM.sh FAILED! Skipping $Subj..."
			echo -e "----------------------------------------------\e[0m"
			continue
		fi
		
	fi

done

echo ""
echo "---------------------------------------------------------------"
echo "Ironsmith.sh finished running on `date`"
echo "---------------------------------------------------------------"	
echo ""

#   .-'  /           
# .'    /   /`.    
# |    /   /  |   
# |    \__/   |   
# `.         .'   
#   `.     .'    
#     | ][ |      
#     | ][ |
#     | ][ |
#     | ][ |    
#     | ][ |  
#     | ][ |      
#     | ][ |    
#     | ][ |    
#     | ][ |
#   .'  __  `.
#   |  /  \  | 
#   |  \__/  |
#   `.      .'
#     `----'
