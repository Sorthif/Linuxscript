#!/bin/bash

# GENERAL DESIGN CHOICES
# We used the error and success messages native to the 
# commands we used when available, else we used $? to write
# our own message.
# 
# The script will create all new folders in the directory
# it is run from.
# 
# We use sudo a lot in case the admin dont have permission
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 

###########################################################
#                        USERS                            #
###########################################################
add_user()
{
	sudo echo "Enter a user name."
	read USER
	sudo useradd $USER
	if [ $? ] ; then
		echo "$USER has been added to the system."
	fi
}

change_user_passwd()
{
	sudo echo "For wich user would you like to change the password?"
	read USER
	sudo passwd $USER
	if [ $? ] ; then
		echo "Password updated for $USER!"
	fi
}

view_user()
{
	#EJ KLAR - Hantera om anv;ndaren gl;mmer alla namns osm finns
	sudo echo "Wich user would you like to see?"
	read USER
	getent passwd | grep $USER > /dev/null
	while [ $? -ne 0 ] ; do
		clear
		echo "Error: User not found!"
		echo "Which user would you like to see?"
		read USER
		getent passwd | grep $USER > /dev/null
	done

	#EJ KLAR - SNYGGARE
	getent passwd | grep $USER
}

change_user_attribute()
{
	view_user
	echo "What would you like to change about $USER?"
cat <<END
1)               User Name
2)               User ID
3)               Primary group ID
4)               Home directory
5)               Shell Directory
6)               Exit
END
	read CHOICE
	case $CHOICE in
	1)
		echo "Enter a new name for $USER"
		read NEWUSER
		sudo usermod -l $NEWUSER $USER
		if [ $? ] ; then
			echo "Name successfully changed!"
		fi
		;;
	2)
		echo "Enter a new ID for $USER."
		read ID
		sudo usermod -u $ID $USER
		if [ $? ] ; then
			echo "ID changed to $ID."
		fi		
		;;
	3)
		echo "Enter the name of $USER's new primary group."
		read NEWGROUP
		sudo usermod -g $NEWGROUP $USER
		if [ $? ] ; then			
			echo "Primary group changed."
		fi						
		;;
	4)
		echo "Enter name of the new home directory."
		read DIRECTORY
		sudo usermod -d $DIRECTORY -m $USER
		if [ $? ] ; then
			echo "$USER's new home directory is $DIRECTORY."
		fi
		;;
	5)
		echo "Enter the preferred shell"
		read SHELL
		sudo usermod -s $SHELL $USER
		if [ $? ] ; then
			echo "$USER's new shell is $SHELL."	
		fi
		;;
	6)
		;;
	esac
}

list_all_users()
{
	# EJ KLAR - FORMATERA SNYGGARRE
	getent passwd | cut -d: -f1
}

###########################################################
#                        GROUPS                           #
###########################################################
create_group()
{
	sudo echo "Enter name of the new group"
	read GROUP
	sudo groupadd $GROUP
	if [ $? ] ; then
		echo "$GROUP has successfully been added."	
	fi
}

list_users_in_group()
{
	# EJ KLAR - F;RB;TTRA FORMATERING
	echo "Enter the name of the group whose members you want to view"
	read GROUP
	getent group | grep $GROUP | cut -d: -f1
	if [ ! $? ] ; then
		echo "That group exists not."
	fi
}

add_user_to_group()
{
	echo "Which user do you want to add to a group?"
	read USER
	echo "Which group do you want to add $USER to?"
	read GROUP
	sudo usermod -a $USER -G $GROUP
	if [ $? ] ; then
		echo "$USER added to $GROUP"
	fi
}

remove_user_from_group()
{
	echo "Which user do you want to delete from a group?"
	read USER
	echo "Which group do you want to remove $USER from?"
	read GROUP
	sudo gpasswd -d $USER $GROUP
}

modify_group()
{
	sudo echo "1)                Remove user"
	sudo echo "2)                Add user"
	read INPUT
	case $INPUT in
		1)
			remove_user_from_group
			;;
		2)
			add_user_to_group
			;;
	esac
}

list_all_groups()
{
	# EJ KLAR - G:R LITE FINARE
	getent group | egrep "^[a-z|z]" | cut -d: -f1

}

###########################################################
#                        FOLDERS                          #
###########################################################
create_folder()
{
	echo "What is the name for the new folder?"
	read FOLDERNAME	
	sudo mkdir $FOLDERNAME
	if [ $? ] ; then
		echo "$FOLDERNAME added to `pwd`"
	fi
}

list_folders()
{
	sudo ls
}

view_folder()
{
	echo "Which folder would you like to see the contents of?"
	read FOLDERNAME
	sudo ls -l $FOLDERNAME
}

folder_is_sticky()
{
	if [ -k $1 ]; then
		ISSTICKY="ON"
	else
		ISSTICKY="OFF"
	fi
}
list_folder_attributes_help()
{
ls -ld $FOLDERNAME &> /dev/null
if [ $? -eq 0 ] ; then

	folder_is_sticky $FOLDERNAME

cat <<END
`stat $FOLDERNAME | cut -c9- | egrep ^[a-Z]+`
-----------------------------------------------------------
Owner:          `ls -ld $FOLDERNAME | cut --delimiter=' ' -f 3`/`ls -ld $FOLDERNAME |cut --delimiter=' ' -f 4`
Permissions:    `ls -ld $FOLDERNAME | cut --delimiter=' ' -f 1`
Sticky bit:     `echo $ISSTICKY`
Last modified:  `ls -ld $FOLDERNAME | cut --delimiter=' ' -f 6-8`

END

fi
}

modify_folder()
{
	echo "Which folder would you like to modify?"
	read FOLDERNAME
	list_folder_attributes_help
	
	echo "What would you like to change about $FOLDERNAME?"
cat <<END
1)               User owner
2)               Group owner
3)               Sticky bit (ON/OFF)
4)               Last modified
5)               Permissions
6)               Exit
END
	read CHOICE
	case $CHOICE in
	1)
		echo "Enter a new owner for $FOLDERNAME"
		read OWNER		
		sudo chown $OWNER $FOLDERNAME
		if [ $? ] ; then
			echo "Owner for $FOLDERNAMEsuccessfully changed to $OWNER!"
		fi
		;;
	2)
		echo "Enter a new group to own $FOLDERNAME."
		read GROUP
		sudo chown :$GROUP $FOLDERNAME
		if [ $? ] ; then
			echo "Group owner for $FOLDERNAME successfully changed to $GROUP."	
		fi		
		;;
	3)
		folder_is_sticky $FOLDERNAME
		echo "Set sticky bit ($ISSTICKY):"
		echo "1) Turn on"
		echo "2) Turn off"
		read TOGGLE
		
		if [ $TOGGLE = "1" ] ; then
			sudo chmod +t $FOLDERNAME
		elif [ $TOGGLE = "2" ] ; then
			sudo chmod -t $FOLDERNAME
		fi
		;;
	4)
		echo "Change last modified, enter time: (ex: now, 11:15, 16 october 2011 23:00 ...)"
		read TIME
		sudo touch -c $FOLDERNAME --date=$TIME
		if [ $? ] ; then
			echo "Updated last modified for $FOLDERNAME"
		fi
		;;
	5)
		# EJ KLAR - FORTS:TT H:R
		;;
	6)
		;;
	esac
}

list_folder_attributes()
{
	echo "Which folder would you like to see the attributes of?"
	read FOLDERNAME
	list_folder_attributes_help
}	


###########################################################
#                        SSH                              #
###########################################################
install_ssh()
{
	sudo apt install ssh
	echo "SSH is successfully installed!"
}

remove_ssh()
{
	sudo apt-get --purge remove ssh
	echo "SSH is successfully removed!"
}

ssh_choice()
{
	echo "1)               Add SSH to your system."
	echo "2)               Remove SSH from your system."
	read INPUT
	case $INPUT in
	1)
		install_ssh
		;;
	2)
		remove_ssh
		;;
	esac
}

ssh_on_off()
{
	echo "fff"
}

print_main_menu()
{
clear
# Important that the closing "END" has no white spaces 
# after it on the same line!
cat <<END
***********************************************************
                      SYSTEM MODIFIER
===========================================================

GROUP
-----------------------------------------------------------
1)              add group                   
2)              list groups                  
3)              view group                  
4)              modify a group                

USER
-----------------------------------------------------------
6)              add user                   
7)              list users                   
8)              view user                  
9)              modify user                
10)             change password        

FOLDER
-----------------------------------------------------------
11)             create                 
12)             list folders           
13)             view contents          
14)             modify folder          
15)             list attributes

SSH
-----------------------------------------------------------
16)             install or remove SSH               
17)             toggle (on/off)        
===========================================================
q)				Exit program
Enter action: 
END
}

###########################################################
#                        MAIN                             #
###########################################################

###### OBS TA BORT SEN!!!!!!!!!!!!!!!!!! ##################
cd /home/
###########################################################

while [ "$INPUT" != "q" ]
do
	print_main_menu
	read INPUT
	clear
	case $INPUT in
		1)
			create_group
			;;
		2)
			list_all_groups
			;;
		3)
			list_users_in_group
			;;
		4)
			modify_group
			;;
		5)
			echo "JAG FINNS INTE"
			;;
		6)
			add_user
			;;
		7)
			list_all_users
			;;
		8)
			view_user
			;;
		9)
			change_user_attribute
			;;
		10)
			change_user_passwd
			;;
		11)
			create_folder
			;;
		12)
			list_folders
			;;
		13)
			view_folder
			;;
		14)
			modify_folder
			;;
		15)
			list_folder_attributes
			;;
		16)
			ssh_choice
			;;
		17)
			ssh_on_off
			;;
		q)
			exit
			;;
		esac
	read -p "press enter to continue"
done
