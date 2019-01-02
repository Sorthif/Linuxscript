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
	if [ $? -eq 0 ] ; then
		echo "$USER has been added to the system."
	fi
}

change_user_passwd() 
{
	sudo echo "For which user would you like to change the password?"
	read USER
	sudo passwd $USER
	if [ $? -eq 0 ] ; then
		echo "Password updated for $USER!"
	fi
}

show_user()
{
	GROUP=`getent passwd | grep $USER | cut --delimiter=':' -f 4`			
cat <<END
`getent passwd | grep $USER | cut --delimiter=':' -f 1`	ID:`getent passwd | grep $USER | cut --delimiter=':' -f 3`
-----------------------------------------------------------
User:           `getent passwd | grep $USER | cut --delimiter=':' -f 1`
User ID:        `getent passwd | grep $USER | cut --delimiter=':' -f 3`
Group:          `getent group | grep $GROUP | cut --delimiter=':' -f 1`	
Group ID:       $GROUP
Password:       `getent passwd | grep $USER | cut --delimiter=':' -f 2`
Comment:        `getent passwd | grep $USER | cut --delimiter=':' -f 5`
Home directory: `getent passwd | grep $USER | cut --delimiter=':' -f 6`
Default shell:  `getent passwd | grep $USER | cut --delimiter=':' -f 7`

END
}

view_user()
{
	sudo echo "Which user would you like to see?"
	read USER
	getent passwd | egrep ^$USER: > /dev/null

	if [ ! $? -eq 0 ] ; then
		getent passwd | grep $USER > /dev/null
		echo "That user does not exist."	
	else
	show_user
	fi
}

change_user_attribute()
{
	list_all_users
	sudo echo "---------------------------------------------"
	echo "Which user would you like to make changes to?"
	read USER
	getent passwd | egrep ^$USER: > /dev/null

	if [ ! $? -eq 0 ] ; then
		getent passwd | grep $USER > /dev/null
		echo "$USER does not exist."	
	else
		while true; do
			show_user
			echo "What attributes of $USER would you like to change?"
cat <<END
1)               User Name
2)               User ID
3)               Primary group ID
4)               Home directory
5)               Shell Directory
6)               Comment

0)               Done
END
			read CHOICE
			case $CHOICE in
			1)
				echo "Enter the new name for $USER:"
				read NEWUSER
				sudo usermod -l $NEWUSER $USER
				if [ $? -eq 0 ] ; then
					echo "$USER's name is $NEWUSER."
				fi
				;;
			2)
				echo "Enter the new user ID:"
				read ID
				sudo usermod -u $ID $USER
				if [ $? -eq 0 ] ; then
					echo "$USER's ID is $ID."
				fi		
				;;
			3)
				list_all_groups
				echo "--------------------------------------------"
				echo "Enter the name of $USER's new primary group:"
				read NEWGROUP
				sudo usermod -g $NEWGROUP $USER
				if [ $? -eq 0 ] ; then			
					echo "$USER's primary group is $NEWGROUP"
				fi						
				;;
			4)
				echo "Enter the new home directory:"
				read DIRECTORY
				sudo usermod -d $DIRECTORY -m $USER
				if [ $? -eq 0 ] ; then
					echo "$USER's home directory is $DIRECTORY."
				fi
				;;
			5)
				echo "Enter the new default shell:"
				read SHELL
				sudo usermod -s $SHELL $USER
				if [ $? -eq 0 ] ; then
					echo "$USER's shell is $SHELL."	
				fi
				;;
			6)
				echo "Enter new comment:"
				read COMMENT
				sudo usermod -c $COMMENT $USER
				if [ $? -eq 0 ] ; then
					echo "$USER's comment is $COMMENT."	
				fi
				;;
			0)
				break
				;;
			esac
		done
	fi
}

list_all_users()
{
	getent passwd | cut -d: -f1 | pr --columns=4 --length=1
}

###########################################################
#                        GROUPS                           #
###########################################################
create_group()
{
	sudo echo "Enter name of the new group"
	read GROUP
	sudo groupadd $GROUP
	if [ $? -eq 0 ] ; then
		echo "$GROUP has been successfully added."	
	fi
}

list_users_in_group()
{
	list_all_groups
	echo "----------------------------------------------------------"
	echo "Enter the name of the group whose members you want to view"
	read GROUP
	getent group | cut -d: -f4 | grep $GROUP &> /dev/null
	if [ $? -eq 0 ] ; then
		echo "------------------------MEMBERS---------------------------"
		getent group | grep $GROUP | cut -d: -f1 | pr --columns=4 --length=1
	else
		echo "That group does not exist."
	fi

}

add_user_to_group()
{
	echo "Which user do you want to add to $GROUP?"
	read USER
	sudo usermod -a $USER -G $GROUP
	if [ $? -eq 0 ] ; then
		echo "$USER added to $GROUP"
	fi
}

remove_user_from_group()
{
	echo "Which user do you want to delete from $GROUP?"
	read USER
	sudo gpasswd -d $USER $GROUP
}

modify_group()
{
	list_all_groups
	sudo echo "----------------------------------"
	echo "Which group do you want to modify?"
	while true ; do
		read GROUP
		getent group | cut -d: -f1 | pr --columns=4 --length=1 | grep $GROUP &> /dev/null
		if [ ! $? -eq 0 ] ; then
			echo "$GROUP does not exist."
			echo " "
		else
			echo " "
			echo "Users in $GROUP"
			echo "------------------------MEMBERS----------------------------"
			getent group | cut -d: -f1 | pr --columns=4 --length=1 | grep $GROUP 
			echo "-----------------------------------------------------------"
			echo "1)                Remove a user"
			echo "2)                Add a user"
			echo " "
			echo "0)                Done"
			read INPUT
			case $INPUT in
				1)
					remove_user_from_group
					;;
				2)
					add_user_to_group
					;;
				0)
					break
					;;										
			esac
		fi			
	done
}

list_all_groups()
{
	getent group | egrep "^[a-z|z]" | cut -d: -f1 | pr --columns=4 --length=1
}

###########################################################
#                        FOLDERS                          #
###########################################################
create_folder()
{
	echo "What is the name for the new folder?"
	read FOLDERNAME	
	sudo mkdir $FOLDERNAME
	if [ $? -eq 0 ] ; then
		echo "$FOLDERNAME added to `pwd`"
	fi
}

list_folders()
{
	sudo ls
}

view_folder()
{
	list_folders
	echo "---------------------------------------------------"
	echo "Which folder would you like to see the contents of?"

	read FOLDERNAME
	sudo ls -l $FOLDERNAME
}

folder_is_sticky()
{
	if [ -k $1 ] ; then
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

print_permission_menu()
{
cat <<END
0)               ---  (No permissions)
1)               --x  (Execute)
2)               -w-  (Write)
3)               -wx  (Write, Execute)
4)               r--  (Read)
5)               r-x  (Read, Execute)
6)               -wx  (Write, Execute)
7)               rwx  (Read, Write, Execute)
END
}

modify_folder()
{
	list_folders
	echo "--------------------------------------"
	echo "Which folder would you like to modify?"
	read FOLDERNAME

	while true ; do
		clear
		list_folder_attributes_help
		folder_is_sticky $FOLDERNAME
		echo "What would you like to change about $FOLDERNAME?"
cat <<END
1)               User owner
2)               Group owner
3)               Sticky bit ($ISSTICKY)
4)               Last modified
5)               Permissions

0)               Exit
END
		read CHOICE
		case $CHOICE in
		1)
			echo "Enter a new owner for $FOLDERNAME"
			read OWNER		
			sudo chown $OWNER $FOLDERNAME
			if [ $? -eq 0 ] ; then
				echo "Owner for $FOLDERNAME successfully changed to $OWNER!"
			fi
			;;
		2)
			echo "Enter a new group to own $FOLDERNAME."
			read GROUP
			sudo chown :$GROUP $FOLDERNAME
			if [ $? -eq 0 ] ; then
				echo "Group owner for $FOLDERNAME successfully changed to $GROUP."	
			fi
			;;
		3)
			if [ $ISSTICKY = "OFF" ] ; then
				sudo chmod +t $FOLDERNAME
			elif [ $ISSTICKY = "ON" ] ; then
				sudo chmod -t $FOLDERNAME
			else
				echo "Faulty input"
			fi
			;;
		4)
			echo "Change last modified, enter time: (ex: now, 11:15, 16 october 2011 23:00 ...)"
			read TIME
			sudo touch -c $FOLDERNAME --date=$TIME
			if [ $? -eq 0 ] ; then
				echo "Updated last modified for $FOLDERNAME"
			fi
			;;
		5)
			clear
			list_folder_attributes_help

			echo "		 Set user permission."
			print_permission_menu
			read USER
			echo " "

			echo "		 Set group permission."
			print_permission_menu
			read GROUP
			echo " "

			echo "		 Set other permission."
			print_permission_menu
			read OTHER
			echo " "

			clear
			sudo chmod "$USER$GROUP$OTHER" $FOLDERNAME
			list_folder_attributes_help
			;;
		0)
			break
			;;
		esac
	done
}

list_folder_attributes()
{
	list_folders
	echo "-----------------------------------------------------"
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
	if [ $? -eq 0 ] ; then
		echo " "
		echo "SSH is successfully installed!"
	fi
}

remove_ssh()
{
	sudo apt-get --purge remove ssh
	if [ $? -eq 0 ] ; then
		echo " "
		echo "SSH is successfully removed!"
	fi
}

status_ssh()
{
	/etc/init.d/ssh status
}

ssh_is_on()
{
	/etc/init.d/ssh status &> /dev/null
	if [ $? -eq 0 ] ; then
		SSHSTATUS="ON"
	else
		SSHSTATUS="OFF"
	fi
}

ssh_on_off()
{
	case $SSHSTATUS in
	"OFF")	
		sudo /etc/init.d/ssh start
		echo "SSH has been turned on."
		;;
	"ON")
		sudo /etc/init.d/ssh stop
		echo "SSH has been turned off."
		;;
	esac
}

print_main_menu()
{
clear
ssh_is_on
cat <<END
****************************************************
		  SYSTEM MODIFIER
====================================================
		  GROUP
----------------------------------------------------
1)                Add group                   
2)                List groups                  
3)                View a group                  
4)                Modify a group                

		  USER
----------------------------------------------------
5)                Add user                   
6)                List users                   
7)                View a user                  
8)                Modify a user                
9)                Change a users password        

		  FOLDER
----------------------------------------------------
10)               Create a folder               
11)               List folders           
12)               View contents of a folder         
13)               Modify a folder          
14)               List a folder's attributes

		  SSH
----------------------------------------------------
15)               Install/Update
16)               Uninstall
17)               Check status
18)               Toggle on/off ($SSHSTATUS)
====================================================
0)                Exit program

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
			add_user
			;;
		6)
			list_all_users
			;;
		7)
			view_user
			;;
		8)
			change_user_attribute
			;;
		9)
			change_user_passwd
			;;
		10)
			create_folder
			;;
		11)
			list_folders
			;;
		12)
			view_folder
			;;
		13)
			modify_folder
			;;
		14)
			list_folder_attributes
			;;
		15)
			install_ssh
			;;
		16)
			remove_ssh
			;;
		17)
			status_ssh
			;;
		18)
			ssh_on_off
			;;
		0)
			exit
			;;
		esac
	read -p "press enter to continue"
done
