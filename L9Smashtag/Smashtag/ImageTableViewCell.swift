//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Yang Zhang on 5/27/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet { fetchImage() }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            // we're going to start something on another queue soon
            // so let's start a spinner going in the UI to let the user know
            // we'll stop this any time an image actually gets set
            // (we'd never want the spinner and an image appearing at the same time!)
            spinner.startAnimating()
            // try? Data(contentsOf:) blocks the thread it is on
            // we are currently on the main thread
            // so we must dispatch that call off to a background queue
            // we'll use one of the shared, global, concurrent background queues
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                // now that we're back from blocking
                // are we still even interested in this url (i.e. does it == self.imageURL)?
                if let imageData = urlContents, url == self?.imageURL {
                    // now we want to set the image in the UI
                    // but we are not on the main thread right now
                    // so we are not allowed to do UI
                    // no problem: just dispatch the UI stuff back to the main queue
                    DispatchQueue.main.async {
                        self?.tweetImage?.image = UIImage(data: imageData)
                        self?.spinner.stopAnimating()
                    }

                }
            }
            
        }
    }
    
    
    
}
