//
//  RecentQueries.swift
//  Smashtag
//
//  Created by Yang Zhang on 5/28/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

struct RecentQueries
{
    private static let defaults = UserDefaults.standard
    
    private struct Constants {
        static let key = "RecentQueries"
        static let limit = 100
    }
    
    static var queries: [String] {
        return (defaults.object(forKey: Constants.key) as? [String]) ?? []
    }
    
    static func add(term: String) {
        // checks to see if there are any repeats
        var newArray = queries.filter({ term.caseInsensitiveCompare($0) != .orderedSame })
        newArray.insert(term, at: 0)
        
        // removes until the limit is met
        while newArray.count > Constants.limit {
            newArray.removeLast()
        }
        
        defaults.set(newArray, forKey: Constants.key)
    }
    
    //
    static func removeAtIndex(index: Int) {
        var currentQueries = (defaults.object(forKey: Constants.key) as? [String]) ?? []
        currentQueries.remove(at: index)
        defaults.set(currentQueries, forKey: Constants.key)
    }
}
