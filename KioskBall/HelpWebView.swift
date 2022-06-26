//
//  HelpWebView.swift
//  KioskBall
//
//  Created by Michael Altobelli on 6/26/22.
//

import Foundation
import WebKit

class HelpWebViewModel : SwiftWebViewModel {
    
    
    override init() {
        super.init();
        self.isHelpWV = true
        
    }
    
    override func loadHomePage() -> Bool {
        
        if(kbConfig.helpButton) {
            
            urlString = kbConfig.helpURL
            return loadPageFromURL()
        }else{
            return false
        }
    }
    
    override func showBlockedPage(webView: WKWebView,domain: String) {
        webView.loadHTMLString("<script>alert('Not on the allowed domains list');</script><h1 style='text-align:center;padding-top:10%'>"+domain+" is not on the allowed sites list.<br/><br/><input type='button' value='Load Help Home' onclick='document.location.href=\""+kbConfig.homeURL+"\"' style='background-color:#d1d1d1; color:#313131; border-radius:3;font-size:20pt;'></h1>", baseURL: URL(string:"localhost"))
    }
}
