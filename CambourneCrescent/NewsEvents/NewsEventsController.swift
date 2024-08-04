//
//  NewsEventsController.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import UIKit
import WebKit

class NewsEventsController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webview.load(URLRequest(url: (URL(string: "https://www.cambournecrescent.org/news-events/")!)))
        navigationItem.title = "News & Events"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
