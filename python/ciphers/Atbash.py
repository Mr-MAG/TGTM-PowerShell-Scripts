import os # Only used to clear the command prompt

def Atbash_crypt(cistring):
# Atbash_crypt splits string to characters, converts to numeric, then flips value
	string = ""		# Placeholder variable
	cistring = formatString(cistring)
	for x in range(0, len(cistring)):	# Loop through each character of string
		string += flipChar(cistring[x])
	return(string)	# Return cipher string

def formatString (string):
	fmtString = string.lower()	# Format to Lowercase
	fmtString = "".join(fmtString.split())	# Remove spaces from string
	return fmtString
	
def flipChar(char):
	# Convert character to numeric 1 - 26 and flip value
	flip = abs((ord(char) - 96) - 27)
	# Convert back to letter if within range, else remove character
	return chr(flip + 96) if flip > 0 and flip <= 26 else ""

def Atbash():
	os.system('cls')
	print("Atbash Cipher")
	print("-------------------------------")
	cistring = input("Please enter a text string below.  All numbers will be stripped.\n")
	print("\nThe starting string is:")
	print (cistring,"\n")
	print("The Atbash encrypted string is:")
	print(Atbash_crypt(cistring),"\n")
	print("The Atbash decrypted string is:")
	print(Atbash_crypt(Atbash_crypt(cistring)),"\n")
	input("Press Enter to continue...")
	
print(Atbash())