/*
Student Name: Di Liu
Student Number: 123717159
Course and Section: UNX511 NZA
Assignment and Labs: Assignment 4
Submission Date: Dec 03, 2024
*/

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var activeStocks: [Stock] = []
    var watchingStocks: [Stock] = []
    var priceCache: [String: String] = [:]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Stocks"
        fetchStocks()
        tableView.reloadData()
    }
    
    // Fetches stocks from the Core Data database, sorts them by 'name' in ascending order,
    // and filters them into active and watching (inactive) stocks for display in the table view.
    func fetchStocks() {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        
        // Add a sort descriptor to sort by 'name' in ascending order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let stocks = try context.fetch(fetchRequest)
            activeStocks = stocks.filter { $0.status == 1 } // Active stocks
            watchingStocks = stocks.filter { $0.status == 0 } // Watching (inactive) stocks
            tableView.reloadData()
        } catch {
            print("Failed to fetch stocks: \(error.localizedDescription)")
        }
    }
    
    // Fetches the real-time stock price for a given performanceID from the API and returns it via a completion handler.
    func fetchStockPrice(for performanceID: String, completion: @escaping (String?, Error?) -> Void) {
        let headers = [
            "x-rapidapi-key": "72c3bf0585msh554dad757b4e8b6p1528d2jsn24a095060f7f",
            "x-rapidapi-host": "ms-finance.p.rapidapi.com"
        ]
        let urlString = "https://ms-finance.p.rapidapi.com/stock/v2/get-realtime-data?performanceId=\(performanceID)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 120 // Increase timeout to 120 seconds
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -1, userInfo: nil))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let price = json["lastPrice"] as? Double {
                    completion(String(format: "%.2f", price), nil)
                } else {
                    completion(nil, NSError(domain: "Invalid JSON structure", code: -1, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        dataTask.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeStocks.count : watchingStocks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Active" : "Watching"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]

        // Set initial cell properties
        cell.textLabel?.text = stock.name
        
        cell.detailTextLabel?.text = stock.isFavorite ? "⭐" : "☆" // Displaying favorite status with star
        // Favorite Button
        let favoriteButton = UIButton(type: .custom)
        favoriteButton.setImage(UIImage(systemName: stock.isFavorite ? "star.fill" : "star"), for: .normal)
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.addTarget(self, action: #selector(toggleFavoriteStatus(_:)), for: .touchUpInside)
        cell.accessoryView = favoriteButton

        // Check if price is already cached
        if let performanceID = stock.performanceID, let cachedPrice = priceCache[performanceID] {
            cell.detailTextLabel?.text = "$\(cachedPrice)" // Use cached price
        } else {
            cell.detailTextLabel?.text = "Fetching price..." // Default message

            // Fetch price if not cached
            if let performanceID = stock.performanceID {
                fetchStockPrice(for: performanceID) { [weak self] price, error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if let price = price {
                            // Cache the price
                            self.priceCache[performanceID] = price

                            // Update the cell only if it is still visible
                            if let visibleIndexPath = tableView.indexPath(for: cell), visibleIndexPath == indexPath {
                                cell.detailTextLabel?.text = "$\(price)"
                            }
                        } else {
                            if let visibleIndexPath = tableView.indexPath(for: cell), visibleIndexPath == indexPath {
                                cell.detailTextLabel?.text = "Price unavailable"
                            }
                        }
                    }
                }
            } else {
                cell.detailTextLabel?.text = "Invalid ID"
            }
        }

        // Update cell appearance based on rank
        switch stock.rank {
        case 0:
            cell.backgroundColor = UIColor.lightGray // "Cold"
        case 1:
            cell.backgroundColor = UIColor.systemOrange // "Hot"
        case 2:
            cell.backgroundColor = UIColor.red // "Very Hot"
        default:
            cell.backgroundColor = UIColor.white
        }

        return cell
    }
    
    @objc func toggleFavoriteStatus(_ sender: UIButton) {
        // Navigate up the view hierarchy to find the UITableViewCell
        guard let cell = sender.superview as? UITableViewCell ?? sender.superview?.superview as? UITableViewCell else {
            print("Failed to get cell from button's superview")
            return
        }

        // Get the indexPath of the cell
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Failed to get indexPath from cell")
            return
        }

        // Retrieve the stock based on section and row
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]

        // Toggle the favorite status
        stock.isFavorite.toggle()

        // Save the updated favorite status to CoreData
        do {
            try context.save()
            print("Favorite status saved successfully")
        } catch {
            print("Failed to update favorite status: \(error)")
        }

        // Reload the row to reflect the updated star icon
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stock = indexPath.section == 0 ? activeStocks[indexPath.row] : watchingStocks[indexPath.row]
        
        // Action to move the stock to the other section (Active <-> Watching)
        let moveAction = UIContextualAction(style: .normal, title: indexPath.section == 0 ? "Move to Watching" : "Move to Active") { _, _, completionHandler in
            // Toggle stock status (active <-> watching)
            stock.status = indexPath.section == 0 ? 0 : 1 // 0 for Watching, 1 for Active
            
            // Save the updated stock in Core Data
            do {
                try self.context.save()
                
                // Update the arrays
                self.fetchStocks()  // Re-fetch the stocks and update arrays
                tableView.reloadData() // Reload the table view to reflect changes
            } catch {
                print("Failed to save updated stock status: \(error)")
            }
            
            completionHandler(true)
        }
        
        moveAction.backgroundColor = .blue  // Color for the move action button
        
        // Action to update the rank (Cold, Hot, Very Hot)
        let rankOptions = ["Cold", "Hot", "Very Hot"]
        var rankActions: [UIContextualAction] = []
        
        for (index, option) in rankOptions.enumerated() {
            let action = UIContextualAction(style: .normal, title: option) { _, _, completionHandler in
                stock.rank = Int16(index)
                
                // Save the updated stock rank
                do {
                    try self.context.save()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                } catch {
                    print("Failed to update rank: \(error)")
                }
                
                completionHandler(true)
            }
            
            // Set background color based on rank
            action.backgroundColor = index == 0 ? .lightGray : (index == 1 ? .orange : .red)
            rankActions.append(action)
        }
        
        // Combine both the rank actions and move action
        let actions = rankActions + [moveAction]
        return UISwipeActionsConfiguration(actions: actions)
    }

    
    @IBAction func unwindToHomeTableViewController(_ segue: UIStoryboardSegue) {
        fetchStocks()
    }
}

