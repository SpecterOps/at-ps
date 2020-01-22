# This is what we're going to encode. All possible bytes will ensure good B64 alphabet coverage.
[Byte[]] $DataToEncode = 0..255

# Convert to Base64 before the alteration
$EncodedData1 = [Convert]::ToBase64String($DataToEncode)

# Get a reference to the internal base64Table field that we found in dnSpy.
$Base64TableField = [Convert].GetField('base64Table', [Reflection.BindingFlags] 'NonPublic, Static')
$OriginalBase64Alphabet = $Base64TableField.GetValue($null)

# Feel free to get creative in how you choose to alter the Base64 alphabet.
# This is just swapping the first two characters.
$OriginalBase64Alphabet[0] = [Char] 'B'
$OriginalBase64Alphabet[1] = [Char] 'A'

# Set base64Table to our new alphabet
$Base64TableField.SetValue($null, $OriginalBase64Alphabet)

# Convert to Base64 after the alteration
$EncodedData2 = [Convert]::ToBase64String($DataToEncode)

# Print out the before and after for comparison.
$EncodedData1
$EncodedData2