//
//  ViewController.swift
//  Interview-series-098
//
//  Created by user-gy-cg-pds2
//

import UIKit



class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let baseURL = "https://fileupload.rick-and-friends.site/search?keyword="
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    
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
        //TODO: - introduce complexity
        searchTask = DispatchWorkItem { [weak self] in
            debugPrint("making API call")
            guard let self = self else { return }
            self.fetchResults(for: searchText)
        }
        
        //TODO: - remove debouncing
        if let task = searchTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
        }
    }
    
    private func fetchResults(for query: String) {
        guard !query.isEmpty else { return }
        //TODO: - remove cancellation
        currentTask?.cancel()
        
        //TODO: - implement logic
        //TODO: - introduce complexity - secure storage
        guard let apiKey = UserDefaults.standard.string(forKey: "apiKey") else {
            print("Error: API Key is missing")
            return
        }
        
        let urlString = baseURL + query
        
        guard let url = URL(string: urlString) else { return }
        
        //TODO: - introduce complexity
        currentTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                self.results = decodedResponse.results.map{ $0.key }
                //TODO: - introduce complexity
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadData()
                }
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


struct Response: Codable {
    let success: Bool
    let count: Int
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let key: String
    let size: Int
    let uploaded: String
    let url: String
}

//Complexities to resolve
// 1 - fix memory leaks retain cycles
// 2 - fix wrong usage of threads
// 3 - implement search cancel button delegate and remove the extra call on cancel button & remove extra calls on empty spaces
// 4 - convert the code to mvvm

