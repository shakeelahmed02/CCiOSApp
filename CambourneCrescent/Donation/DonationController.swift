//
//  DonationController.swift
//  CambourneCrescent
//
//  Created by Ahmed, Shakeel on 27/07/2024.
//

import UIKit
import WebKit

class DonationController: UIViewController, WKUIDelegate {

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      webview.uiDelegate = self
        webview.load(URLRequest(url: (URL(string: "https://www.cambournecrescent.org/cambourne-mosque-project/")!)))
        navigationItem.title = "Mosque Project"
    }
    
  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    if let url = navigationAction.request.url?.absoluteURL {
        UIApplication.shared.open(url, options: [:])
      }
    
      return nil
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
