//
//  ViewController.swift
//  AimieSmiles
//
//  Created by David Garces on 09/10/2017.
//  Copyright © 2017 David Garces. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @objc var  chemData:[ChemData] = []
    
    var selectedCSVFile: URL!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var ProgressLabel: NSTextField!
    @IBOutlet var chemDataController: NSArrayController!
    @IBOutlet weak var smilesTableView: NSTableView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearData()

    }
        
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: Actions
    
    @IBAction func startSearch(_ sender: Any) {
        let totalItems = chemData.count
        var itemsRemaining = chemData.count
        self.progressIndicator.doubleValue = 0
        
        
        OperationQueue().addOperation() {
            
            self.startProgressAnimation(sender: sender as AnyObject)
            for item in self.chemData {
                //sleep(1)
                
                DispatchQueue.main.async {
                    self.chemDataController.removeObject(item)

                    
                    if item.cas.isEmpty {
                        item.smiles = "CAS was empty"
                    } else {
                        
                        DispatchQueue.main.async {
                            self.callSMILESServer(cas: item.cas.removingWhitespaces(),  completion: { (response) in
                                item.smiles = response
                            })
                        }
                    }
                    self.chemDataController.addObject(item)
                }
      
                OperationQueue.main.addOperation() {
                    
                    itemsRemaining = itemsRemaining - 1
                    
                    self.ProgressLabel.stringValue = "Remaining: \(itemsRemaining)"
                    
                    let fractionalProgress = Double((totalItems - itemsRemaining) * 100) / Double(totalItems)
                    self.progressIndicator.doubleValue = fractionalProgress
  
                }
            }
            self.stopProgressAnimation(sender: sender as AnyObject)
            
        }
    }
    
    
    @IBAction func loadDocument(_ sender: Any) {
        
        clearData()
        
        let panel = NSOpenPanel()
        panel.title = "Select CSV file"
        panel.prompt = "Select file"
        panel.message = "Please select your CSV file with the list of names and CAS numbers"
        panel.allowedFileTypes = ["csv"]
        
        panel.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
            
            if (result == NSApplication.ModalResponse.OK) {
                self.selectedCSVFile =  panel.url!
                print(self.selectedCSVFile.absoluteString)
                
                guard let thePath = self.selectedCSVFile, let theData = self.readFile(url: thePath) else {
                    self.showErrorPanel(message: "something is wrong trying to parse the file")
                    return
                }
                
                let parser = CSwiftV(with: theData)
 
                let mapped = parser.headers.map({$0.lowercased()})
                
                guard let nameIndex = mapped.index(of: "name"), let casIndex = mapped.index(of: "cas") else {
                    self.showErrorPanel(message: "could not find column headers: Name / CAS")
                    
                    return
                }
                
                if parser.rows.count == 0 {
                    self.showErrorPanel(message: "The CSV parser didn't find rows in the CSV file, check format, and make sure all the headers are filled")
                    return
                }
                
                for item in parser.rows {
                    
                    let newChemItem = ChemData(name: item[nameIndex], cas: item[casIndex])
                    self.chemDataController.addObject(newChemItem)
                    
                }
                
            }
        })
        
       
        
        
    }
    
    @IBAction func saveResultsToFile(_ sender: Any) {
        
        let panel = NSSavePanel()
        panel.title = "Select the save location"
        panel.prompt = "Select file"
        panel.message = "Please location to save your results"
        panel.allowedFileTypes = ["csv"]
        
        
        panel.beginSheetModal(for: self.view.window!, completionHandler: { (result) in

            if (result == NSApplication.ModalResponse.OK) {
                
                let mappedData = self.chemData.map({
                    ["\"\($0.name)\"","\"\($0.cas)\"", "\"\($0.smiles)\""].joined(separator: ",")
                })
                
                let stringMapped =  mappedData.joined(separator: "\n")
                
                let withHeaders = "Name, CAS, SMILES\n" + stringMapped
                
                self.saveFile(data: withHeaders, path: panel.url!)

            }

        })
        
    }
    
    @IBAction func clearTableData(_ sender: Any) {
        
        clearData()
    }
    
    
    

    func callSMILESServer(cas: String, completion: @escaping (_ response: String) ->()) {
        
        let url = URL(string: "https://cactus.nci.nih.gov/chemical/structure/\(cas)/smiles")!
        
        //let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        
        
        print("URL for request is: \(String(describing: url))")
        
   
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in

                guard let data = data, error == nil else { return }
                //semaphore.signal()
                group.enter()
                if let theData = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    completion(theData)
                    
                } else {
                    completion(error.debugDescription)
                }
                
                group.leave()
            }
        
            task.resume()
        
        group.wait()
        
    }

    // MARK: TableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (chemDataController.arrangedObjects as AnyObject).count!
    }
    
    // MARK: Other operations
    
    func showErrorPanel(message: String) {
        
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    
    }
    
    func startProgressAnimation(sender: AnyObject) {
        OperationQueue.main.addOperation() {
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimation(sender)
        }
    }
    
    func stopProgressAnimation(sender: AnyObject) {
        OperationQueue.main.addOperation() {
            self.progressIndicator.stopAnimation(sender)
            //self.progressIndicator.isHidden = true
        }
    }
    
    func readFile(url: URL) -> String? {
        do {
            let data = try String(contentsOf: url)
            return data
            
        } catch {
            showErrorPanel(message: "error reading file!")
            return nil
        }
        
    }
    
    func saveFile(data: String, path: URL) {
        
        //let joined = array.joinWithSeparator("\n")
        do {
            try data.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            showErrorPanel(message: "error writing file to path: \(path)!")
        }
    }
    
    // MAKR: Data
    
    func clearData() {
        guard let x = (chemDataController.arrangedObjects as AnyObject).count, x > 0 else { return }
        let indexSet = IndexSet(0..<x)
        chemDataController.remove(atArrangedObjectIndexes: indexSet)
    }

}

