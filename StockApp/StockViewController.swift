/*
Student Name: Di Liu
Student Number: 123717159
Course and Section: UNX511 NZA
Assignment and Labs: Assignment 4
Submission Date: Dec 03, 2024
*/

import UIKit
import CoreData

class StockViewController: UIViewController, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!

    var selectedRowIndex: IndexPath?
    var searchResults: [(name: String, performanceID: String)] = []
    var selectedStockStatus: Int16? = nil // To store the status (0 for Inactive, 1 for Active)
    let searchController = UISearchController(searchResultsController: nil)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false // Prevents hiding the save button
        navigationItem.searchController = searchController
        tableView.delegate = self
        tableView.dataSource = self
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        // Construct the URL with the search text
        let url = "https://ms-finance.p.rapidapi.com/market/v2/auto-complete?q=\(searchText)"
        
        // Call the getData function to fetch search results asynchronously
        getData(url: url, context: context) { [weak self] data in
            // Update the UI on the main thread with the fetched data
            DispatchQueue.main.async {
                self?.searchResults = data // Assign the fetched data to searchResults
                self?.tableView.reloadData()
            }
        }
    }
    
    // fetches stock data from an API, parses the response, and returns a list of stock names and performance IDs via the completion handler.
    func getData(url: String, context: NSManagedObjectContext, completion: @escaping([(name: String, performanceID: String)]) -> Void) {
        let headers = [
            "x-rapidapi-key": "72c3bf0585msh554dad757b4e8b6p1528d2jsn24a095060f7f",
            "x-rapidapi-host": "ms-finance.p.rapidapi.com"
        ]

        var request = URLRequest(url: URL(string: url)!, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.searchResults = []
                    self.tableView.reloadData()
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server.")
                DispatchQueue.main.async {
                    self.searchResults = []
                    self.tableView.reloadData()
                }
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let results = json?["results"] as? [[String: Any]] else {
                    print("Invalid JSON format.")
                    return
                }

                var stockDetails: [(name: String, performanceID: String)] = []
                for stockDict in results {
                    guard let name = stockDict["name"] as? String else { continue }
                    guard let performanceID = stockDict["performanceId"] as? String else { continue }
                    
                    stockDetails.append((name: name, performanceID: performanceID))
                }

                DispatchQueue.main.async {
                    completion(stockDetails)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }

        dataTask.resume()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let selectedIndexPath = selectedRowIndex else {
                print("No row selected")
                return
        }
        
        let selectedStock = self.searchResults[selectedIndexPath.row]
        
        guard let status = self.selectedStockStatus else {
            // Show an alert to force the user to swipe to select a status
            let alert = UIAlertController(
                title: "Status Required",
                message: "Please swipe on the selected stock to mark it as Active or Inactive before saving.",
                preferredStyle: .alert
            )
            let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
            let attributedTitle = NSAttributedString(string: "Status Required", attributes: titleAttributes)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            print("Stock status not selected")
            return
        }
        
        let stock = Stock(context: self.context) // Create a new Stock object
        stock.rank = -1 // Default rank set to -1
        stock.status = status
        stock.name = selectedStock.name
        stock.performanceID = selectedStock.performanceID
        stock.timeStamp = Date()
        stock.id = UUID()
        
        do {
            try self.context.save()
            
            // I did not unwind the exit segue to the Save button.
            // Instead, ctrl+drag from the StockViewContoller itself (the first button (on the left of the First Responder) to the Exit button (on the right side of the First Responder) to create a segue, then in the document outline, name the segue identifier as "mySegue", and programmatically perform the segue here.
            // This approach guarantees that the view transition only occurs if the user selects either 'Active' or 'Inactive' status.
            self.performSegue(withIdentifier: "mySegue", sender: self)
            print("Stock saved successfully: \(stock.name ?? "") with status \(status == 1 ? "Active" : "Inactive")")
        } catch {
            print("Failed to save stock: \(error.localizedDescription)")
        }
    }
}

extension StockViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let stock = searchResults[indexPath.row]
        cell.textLabel?.text = stock.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false // Dismiss the search controller
        
        // Store the selected row index
        selectedRowIndex = indexPath
        
        // Store selected stock information
        let selectedStock = searchResults[indexPath.row]
        print("Selected stock: \(selectedStock.name)")
    }
    
    // Handle swipe actions for setting stock as active or inactive
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Active action
        let activeAction = UIContextualAction(style: .normal, title: "Active") { (action, view, completionHandler) in
            self.selectedStockStatus = 1 // Set as Active
            // Automatically select the row after setting the status
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            // Store the row index when a swipe action is performed
            self.selectedRowIndex = indexPath
            completionHandler(true)
        }
        
        // Inactive action
        let inactiveAction = UIContextualAction(style: .normal, title: "Inactive") { (action, view, completionHandler) in
            self.selectedStockStatus = 0 // Set as Inactive
            // Automatically select the row after setting the status
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            // Store the row index when a swipe action is performed
            self.selectedRowIndex = indexPath
            completionHandler(true)
        }

        // Customize action colors 
        activeAction.backgroundColor = .green
        inactiveAction.backgroundColor = .red

        // Return the swipe actions configuration
        return UISwipeActionsConfiguration(actions: [activeAction, inactiveAction])
    }
}

