//
//  SwiftWebView.swift
//  KioskBall
//
//  Created by Michael Altobelli on 6/20/22.
//

import SwiftUI
import WebKit


struct SwiftWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
     

}

struct SwiftWebView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftWebView(webView: SwiftWebViewModel().swWebView)
    }
}


class SwiftWebViewModel : NSObject, ObservableObject, WKNavigationDelegate {
    let swWebView: WKWebView
    
    @Published var lastInteraction: Date = Date.init()
    var idleTimer : Timer = Timer()
    let warningText = "<h1>Error loading kiosk homepage, please verify the below:</h1><ul><li>That your iPad has internet access</li><li>That your domain is allowed in settings</li><li>That you have  set a valid homepage in settings</li></ul></h1>"
    @Published var alertText: String = ""
    var isHelpWV: Bool = false
    
    @Published var urlString: String = "https://kioskball.maltob.info/appwelcome"
    
    var kbConfig : KioskBallConfig = KioskBallConfig()
    
    
    @objc func defaultsChanged() {
        DispatchQueue.main.async {  self.kbConfig.loadDefaults() }
    }
    
    @objc func checkIdle() {
        if(isHelpWV) {
            return
        }
        if kbConfig.idleTimeoutTime == 0 {
            return
        }
        
        
        var warningTime = 1;
        if kbConfig.idleTimeoutTime > 30 {
            warningTime = 10
        }else if kbConfig.idleTimeoutTime > 10 {
            warningTime = 5
        }
        
        if Int64(lastInteraction.timeIntervalSinceNow) < ((-1*kbConfig.idleTimeoutTime)+warningTime) {
            if kbConfig.showTimeoutWarning {
                debugPrint("Showing warning")
                alertText = "Session is idle, will reload homepge"
            }
            if Int64(lastInteraction.timeIntervalSinceNow) < (-1*kbConfig.idleTimeoutTime) {
                debugPrint("Idle for timeout, loading homepage")
                alertText = ""
                self.loadHomePage()
            }
        }
        
    }
    

    
    override init() {
        let wvConfig = WKWebViewConfiguration()
        wvConfig.websiteDataStore = .nonPersistent()
        swWebView = WKWebView(frame: .zero, configuration: wvConfig)
        swWebView.allowsLinkPreview = false
        swWebView.allowsBackForwardNavigationGestures = false
        
        super.init()
        
        idleTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkIdle), userInfo: nil, repeats: true)
        
        //navDelegate = SwiftWebViewNavDelegate()
        swWebView.navigationDelegate = self
        kbConfig.loadDefaults()
        urlString = kbConfig.homeURL
        swWebView.loadHTMLString(warningText, baseURL: URL(string: "https://localhost"))
        loadPageFromURL()
        
        //Setup notifications for settings changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(defaultsChanged),
                            name: UserDefaults.didChangeNotification,
                            object: nil)
    }
    
    func setToHelp() {
        isHelpWV = true
    }
    
    func loadHomePage() -> Bool {
        
        if(kbConfig.homeButton) {
            urlString = kbConfig.homeURL
            return loadPageFromURL()
        }
        else {
            return false
        }
    }
    
    
    
    func loadPageFromURL() -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        var domain = url.host?.lowercased() ?? ""
        
        lastInteraction = Date.init()
        
        //Get the last two parts of the subdomain if we allow subdomains
        if kbConfig.allowSubdomains {
            var domainParts = domain.split(separator: ".")
            if(domainParts.count > 2) {
                domain = ""
                domain.append(
                    String(domainParts.popLast() ?? "")
                )
                domain = "."+domain
                domain =
                    String(domainParts.popLast() ?? "") +  domain
                
            }
            debugPrint(domain)
        }
        //debugPrint(allowedDomains)
        //debugPrint(url.host ?? "")
        //Only load allowed URLs
        if kbConfig.allowedDomains.count == 0 || kbConfig.allowedDomains.contains(domain) {
            //Load a warning in case the webView doesn't load
            swWebView.loadHTMLString("<h1>Loading, if you remain on this screen please verify internet connectivity<h1/>", baseURL: URL(string: "localhost"))
            
            
                let loaded = swWebView.load(URLRequest(url: url))
            
            return true
                
            
                
        }else{
            alertText = domain+" is not on the allowed domains list"
            return false
        }
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        
        var domain = navigationAction.request.mainDocumentURL?.host?.lowercased() ?? ""
        
        //Get the last two parts of the subdomain if we allow subdomains
        if kbConfig.allowSubdomains {
            var domainParts = domain.split(separator: ".")
            if(domainParts.count > 2) {
                domain = ""
                domain.append(
                    String(domainParts.popLast() ?? "")
                )
                domain = "."+domain
                domain =
                    String(domainParts.popLast() ?? "") +  domain
                
            }
            debugPrint("Subdomain changed to "+domain+" for matching due to allow subdomains being enabled")
        }
        
        
        
        if kbConfig.allowedDomains.count == 0 || domain == "localhost" || domain == "" || kbConfig.allowedDomains.contains(domain) {
            debugPrint("Allowing Action for "+(navigationAction.request.mainDocumentURL?.host ?? ""))
            decisionHandler(.allow, preferences)
        }else{
            showBlockedPage(webView: webView,domain: domain)
            decisionHandler(.cancel, preferences)
        }
    }
    
    func showBlockedPage(webView: WKWebView,domain: String) {
        webView.loadHTMLString("<script>alert('Not on the allowed domains list');</script><h1 style='text-align:center;padding-top:10%'>"+domain+" is not on the allowed sites list.<br/><br/><input type='button' value='Load Homepage' onclick='document.location.href=\""+kbConfig.homeURL+"\"' style='background-color:#d1d1d1; color:#313131; border-radius:3;font-size:20pt;'></h1>", baseURL: URL(string:"localhost"))
    }
        
    func webView(_ webView: WKWebView, didFinish: WKNavigation) {
        debugPrint(didFinish)
    }
    
    
    
    func webView( _ webView: WKWebView, didStartProvisionalNavigation: WKNavigation) {
        debugPrint(didStartProvisionalNavigation)
        
    }
    
   
  
    
}
