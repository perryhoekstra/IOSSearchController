//
//  ViewController.swift
//  IOSSearchController
//
//  Created by Perry Hoekstra on 10/24/19.
//  Copyright © 2019 Perry Hoekstra. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultTable: UITableView!
    
    var fetcher: GMSAutocompleteFetcher?
    var resultList: [String] = []
    
    func insertEntryIntoList(entry: String) {
        if (resultList.count < 10) {
            resultList.insert(entry, at: 0)
        }
        else {
            resultList.remove(at: 9)
            resultList.insert(entry, at: 0)
        }
    }
    
    func searchForAddress(searchText: String) {
        fetcher?.sourceTextHasChanged(searchText)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let searchText = textField.text, searchText.count >= 3 {
            searchForAddress(searchText: searchText)
        }
        else {
            resultTable.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Create a new session token.
        let token: GMSAutocompleteSessionToken = GMSAutocompleteSessionToken.init()

        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher()
        
        fetcher?.delegate = self
        fetcher?.provide(token)
        
        searchTextField?.addTarget(self, action: #selector(textFieldDidChange(textField:)),
                             for: .editingChanged)
        searchTextField.delegate = self
        
        resultTable.delegate = self
        resultTable.dataSource = self
        resultTable.isHidden = true
    }
}

extension ViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        for prediction in predictions {
            insertEntryIntoList(entry: prediction.attributedFullText.string)
        }

        //resultsStr.appendFormat("Place ID: %@\n", prediction.placeID)
        
        resultTable.reloadData()
        resultTable.isHidden = false
    }

    func didFailAutocompleteWithError(_ error: Error) {
        insertEntryIntoList(entry: error.localizedDescription)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (resultTable.dequeueReusableCell(withIdentifier: "SearchResultCell") as UITableViewCell?)!
        
        cell.textLabel?.text = resultList[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.text = resultList[indexPath.row]
        resultTable.isHidden = true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resultList = []
        resultTable.reloadData()
        
        return true
    }
}
