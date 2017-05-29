//
//  RecentQueriesTableViewController.swift
//  Smashtag
//
//  Created by Yang Zhang on 5/27/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class RecentQueriesTableViewController: UITableViewController {

    // MARK: Model
    
    var recentQueries: [String] {
        return RecentQueries.queries
    }
    
    // MARK: View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentQueries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = recentQueries[indexPath.row]
        return cell
    }
    
    // delete 
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RecentQueries.removeAtIndex(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier, identifier == "searchTweet",
            let cell = sender as? UITableViewCell,
            let ttvc = segue.destination as? TweetTableViewController {
            ttvc.searchText = cell.textLabel?.text
        }
    }
}
