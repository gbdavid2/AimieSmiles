# AimieSmiles
Aimie Smiles is a small macOS application that helps you make batch searches of compounds using their registration number [(CAS)](https://en.wikipedia.org/wiki/CAS_Registry_Number) --> (convert CAS to [SMILES](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system)). The App will retrieve the SMILES string for each entry.

## How to use
1. Create a list of records that you would like to use for your search in an excel file using the following headers:
Name: The compound name
CAS: the registration number of the compound
SMILES: Leave this column empty but make sure you create the header.

2. When your file is ready export it to CSV. If using Microsoft Excel to export your CSV, make sure that you use the simple CSV export (none of the options that have additonal encodings like UTF, and for MS-DOS etc..). Otherwise you can Create your data in [Apple Numbers](https://www.apple.com/numbers/) and export it to CSV that way.

3. Open AimieSmiles (You can either download the source and run from Xcode, or use the latest build found in /Builds/).

4. Click on Load document

5. Make sure that the entries have loaded to the App

6. Click on 'Start search'

7. The App will connect to the web search from https://cactus.nci.nih.gov and retrieve the results for each entry. The results will be shown in the screen.

8. When the search is finished, you can export the results using the 'Save results' button.

9. You can now use your exported file to create structures or for any of your other applications using your tool of choice.

## Developer notes

This App was created using XCode 9 and Swift 4. It uses Storyboards for managing the views. The data is bound to the view via an NSArrayController that uses the ChemData class as model (Object Controller). It then binds its properties to the NSTableView columns of the ViewController. The App uses GDC and URLSession to connect to the web service, and displays a NSProgressIndicator bar to indicate progress which will be useful when the app needs to deal with hundreds of records, and the search will be slow.

You can remove all signing and run the App locally. You're also welcome to contribute and commit any improvements you would like to add.
