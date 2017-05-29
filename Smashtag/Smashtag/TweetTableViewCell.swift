//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor on 2/8/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    // outlets to the UI components in our Custom UITableViewCell
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    // public API of this UITableViewCell subclass
    // each row in the table has its own instance of this class
    // and each instance will have its own tweet to show
    // as set by this var
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        
        if let text = tweet {
            tweetTextLabel?.attributedText = setColor(tweet: text)
        }
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            // sends to different thread
            let urlContents = try? Data(contentsOf: profileImageURL)
            DispatchQueue.global(qos: .userInitiated) .async { [weak self] in
                if let imageData = urlContents, profileImageURL == self?.tweet?.user.profileImageURL {
                    // does UI stuff on mainthread
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
    private struct Color {
        static let user = UIColor.orange
        static let hashtag = UIColor.blue
        static let url = UIColor.gray
    }
    
    // sets the color of NSMutableAttributedString by mention
    private func setColor(tweet: Twitter.Tweet) -> NSMutableAttributedString {
        let text = tweet.text
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.setMentionsColor(mentions: tweet.userMentions, color: Color.user)
        attributedText.setMentionsColor(mentions: tweet.hashtags, color: Color.hashtag)
        attributedText.setMentionsColor(mentions: tweet.urls, color: Color.url)
        return attributedText
    }
}

// changes the color of every mention in Mention array
private extension NSMutableAttributedString {
    func setMentionsColor(mentions: [Mention], color: UIColor) {
        for mention in mentions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
        }
    }
}
