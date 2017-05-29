//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Yang Zhang on 5/24/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {

    private var mentions = [Mentions]()
    
    private struct Mentions: CustomStringConvertible
    {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title): \(data)" }
    }
    
    private enum MentionItem: CustomStringConvertible
    {
        case Keyword(String)
        case Image(URL, Double)
        
        var description: String {
            switch self {
            // For hashtags, urls and user screen names
            case .Keyword(let keyword):
                return keyword
            // For images
            case .Image(let url, _):
                return url.path
                
            }
        }
    }
    
    var tweet: Twitter.Tweet? {
        didSet {
            // Transform Tweet into internal data structure [Mentions]
            title = tweet?.user.screenName
            if let media = tweet?.media, !media.isEmpty {
                mentions.append(Mentions(title: Title.images,
                                         data: media.map { MentionItem.Image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls, !urls.isEmpty{
                mentions.append(Mentions(title: Title.urls,
                                         data: urls.map { MentionItem.Keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags, !hashtags.isEmpty{
                mentions.append(Mentions(title: Title.hashtags,
                                         data: hashtags.map { MentionItem.Keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions, !users.isEmpty{
                mentions.append(Mentions(title: Title.users,
                                         data: users.map { MentionItem.Keyword($0.keyword) }))
            }
        }
    }
    
    private struct Title {
        static let images = "Images"
        static let urls = "URLs"
        static let hashtags = "Hashtags"
        static let users = "Users"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return mentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentions[section].data.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageURL = url
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }

    
    private struct Storyboard {
        static let search = "search"
        static let showImage = "showImage"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            if identifier == Storyboard.search {
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    let text = cell.textLabel?.text {
                    ttvc.searchText = text
                }
            } else if identifier == Storyboard.showImage {
                if let ivc = segue.destination as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {
                    
                    ivc.imageURL = cell.imageURL
                    ivc.title = title
                    
                }
            }
        }
    }
 
    // We don't want to perform a segue for URL as for a .Keyword
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: (Any)?) -> Bool {
        if identifier == Storyboard.search {
            if let cell = sender as? UITableViewCell,
                let indexPath =  tableView.indexPath(for: cell),
                let urlText = cell.textLabel?.text,
                mentions[indexPath.section].title == Title.urls {
                if urlText.hasPrefix("http"), let url = URL(string: urlText) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                    return false
                }
            }
        }
        return true
    }
}
