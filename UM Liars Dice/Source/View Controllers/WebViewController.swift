//
//  WebViewController.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/20/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate
{
    @IBOutlet weak var webView: UIWebView!
    @IBInspectable var resource: String = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()

        webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: resource, ofType: "html")!)))
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
            return false
        }

        return true
    }
}
