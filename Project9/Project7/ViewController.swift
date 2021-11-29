//
//  ViewController.swift
//  Project7
//
//  Created by Enrique Casas on 9/20/21.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var newFilter = [Petition]()
    var tempArray = [Petition]()
    var tagHolder = 0
    var urlString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filter))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
       
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        performSelector(inBackground: #selector(fetchJSON), with: urlString)
        
        
//        let urlString: String
//        if navigationController?.tabBarItem.tag == 0 {
//           // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
//           urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
//        } else {
//           // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
//           urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let url = URL(string: urlString) {
//                if let data = try? Data(contentsOf: url) {
//                    self.parse(json: data)
//                    return
//                }
//            }
//            self.showError()
//        }
    }
    
    @objc func fetchJSON(urlLink: String) {
//        let urlString: String
//        if navigationController?.tabBarItem.tag == 0 {
//           // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
//           urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
//        } else {
//           // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
//           urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
//        }
        
        if let url = URL(string: urlLink) {
            if let data = try? Data(contentsOf: url) {
                self.parse(json: data)
                return
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    func parse (json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            newFilter = petitions
            //print(petitions[0].title)
            //print(petitions.count)
            //print(jsonPetitions.results)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            //tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newFilter.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
       "Cell", for: indexPath)
        let petition = newFilter[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = newFilter[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let vc = UIAlertController(title: "Credits", message: "Data comes from White House petitions", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(vc, animated: true)
    }
    
    @objc func filter() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
            }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        }
    
    func submit(_ answer: String) {
        
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
           // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
           // urlString = "https://api.whitehouse.gov/v1/petition.json?signatureCountFloor=10000&limit=100"
           urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                filterParse(json: data, search: answer)
            } else {
                showError()
            }
        } else {
            showError()
        }
        
        
    }
    
    func filterParse (json: Data, search: String) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            filteredPetitions = jsonPetitions.results
            //print(petitions.count)
            let lowerSearch = search.lowercased()
            
            for i in 0...99 {
                if filteredPetitions[i].body.lowercased().contains(lowerSearch) {
                    tempArray.append(filteredPetitions[i])
                    //print(filteredPetitions[i])
                } else {
//                    filteredPetitions.remove(at: i)
                }
            }
            newFilter = tempArray
            print(newFilter.count)
            tableView.reloadData()
        }
    }
}

