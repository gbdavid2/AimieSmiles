# AimieSmiles
Aimie Smiles is a small macOS application that helps you make batch searches of compounds using their registration number (CAS). The App will retrieve the SMILES string for each entry.

## How to use
1. Create a list of records that you would like to use for your search in an excel file using the following headers:
Name: The compound name
CAS: the registration number of the compound
SMILES: Leave this column empty but make sure you create the header.

2. When your file is ready export it to CSV

3. Open AmimieSiles (You can either download the source and run from Xcode, or use the latest build found in /Builds/).

4. Click on Load document

5. Make sure that the entries have loaded to the App

6. Click on 'Start search'

7. The App will connect to the web search from https://cactus.nci.nih.gov and retrieve the results for each entry. The results will be shown in the screen.

8. When the search is finished, you can export the results using the 'Save results' button.

9. You can now use your exported file to create structures or for any of your other applications using your tool of choice.
