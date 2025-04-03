//
//  ViewController.swift
//  Interview-series-098
//
//  Created by user-gy-cg-pds2
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var results: [String] = []
    private var searchTask: DispatchWorkItem?
    private var currentTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //simulation
        UserDefaults.standard.set("SensitiveAPIKey123", forKey: "apiKey")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTask?.cancel()
        searchTask = DispatchWorkItem {
            print("making API call")
            self.fetchResults(for: searchText)
        }
        
        if let task = searchTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
        }
    }
    
    private func fetchResults(for query: String) {
        guard !query.isEmpty else { return }
        currentTask?.cancel()
        
        guard let apiKey = UserDefaults.standard.string(forKey: "apiKey") else {
            print("Error: API Key is missing")
            return
        }
        
        let urlString = "https://mockapi.example.com/search?q=\(query)&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        currentTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode([String].self, from: data)
                self.results = decodedResponse
                self.tableView.reloadData()
            } catch {
                print("Decoding error: \(error)")
            }
        }
        
        currentTask?.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
}




