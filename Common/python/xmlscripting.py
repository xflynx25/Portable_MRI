import xml.etree.ElementTree as ET

# Load and parse the XML file
tree = ET.parse('/Users/jflyn/Documents/martinos_docs_windows/Data/Raw/ExtremityScanner/20240824/8674/Proc/0/header.xml')
root = tree.getroot()

# Search for any occurrence of the word 'lego'
lego_mentions = []

for elem in root.iter():
    if elem.text and 'khz' in elem.text.lower():
        lego_mentions.append((elem.tag, elem.text))

print(lego_mentions)