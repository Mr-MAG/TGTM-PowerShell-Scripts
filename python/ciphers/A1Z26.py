import os

def A1Z26_encrypt(cistring):
# Encrypt string by converting each letter to a number
	string = ""		# Placeholder variable
	cistring = cistring.lower()		# Format to Lowercase
	cistring = "".join(cistring.split())	# Remove spaces from string
	for x in range(0, len(cistring)):		# Loop through each character of string
		char = ord(cistring[x]) - 96# Convert character to numeric 1 - 26
		if char > 0 and char <= 26 : string += str(char) + " "	# Store value in 'string' variable
	return(string)		# Return cipher string

def A1Z26_decrypt(cistring):
# Decrypt string by converting each number to a letter
	string = ""		# Placeholder variable
	data = cistring.split()	# Split string at " "
	
	for char in data:		# Loop through each character
		char = chr(int(char) + 96)	# Convert number to letter
		string += char		# Add character to string
	return(string)		# Return cipher string

def A1Z26():
	os.system('cls')
	print("A1Z26 Cipher")
	print("-------------------------------")
	cistring = input("Please enter a text string below.  All numbers will be stripped.\n")
	print("\nThe starting string is:")
	print (cistring,"\n")
	print("The A1Z26 encrypted string is:")
	print(A1Z26_encrypt(cistring),"\n")
	print("The A1Z26 decrypted string is:")
	print(A1Z26_decrypt(A1Z26_encrypt(cistring)),"\n")
	input("Press Enter to continue...")

A1Z26()