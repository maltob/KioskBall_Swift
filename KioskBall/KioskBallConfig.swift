//
//  KioskBallModel.swift
//  KioskBall
//
//  Created by Michael Altobelli on 6/25/22.
//

import Foundation
import UIKit


class KioskBallConfig : ObservableObject {
    @Published var homeButton: Bool = true
    @Published var helpButton: Bool = true
    @Published var autoGuidedAccess: Bool = false
    @Published var guidedAccessExitCode: String = "4321"
    

    var homeURL: String = "https://kioskball.maltob.info/appwelcome"
    var helpURL: String = "https://kioskball.maltob.info/apphelp"
    @Published var allowedDomains: [String] = [String]()
    @Published var allowSubdomains: Bool = false
    
    
    var showTimeoutWarning : Bool = false
    @Published var idleTimeoutTime : Int = 0
    
    
    func loadDefaults() {
           
            let defaults = UserDefaults.standard
            
        //Home page and button
            if let home_page_default = defaults.string(forKey: "home_page") {
                
                homeURL = home_page_default
            }
            
          
            if defaults.object(forKey: "home_button") != nil {
                let home_button = defaults.bool(forKey: "home_button")
                homeButton = home_button
            }
        // Help page and button
        
            if defaults.object(forKey: "help_button") != nil {
                let help_button = defaults.bool(forKey: "help_button")
                helpButton = help_button
            }
        
        if let help_page = defaults.string(forKey: "help_page") {
            helpURL = help_page
        }
        
        
        //Timeout for when their isn't user activity
        if defaults.object(forKey: "show_timeout_warning") != nil {
            let show_timeout_warning = defaults.bool(forKey: "show_timeout_warning")
            showTimeoutWarning = show_timeout_warning
        }
        
        if  defaults.object(forKey: "idle_timeout")  != nil{
            
            idleTimeoutTime = defaults.integer(forKey: "idle_timeout")
        }
        
        
        
        // Subdomain filtering when user browses
            if defaults.object(forKey: "allow_subdomains") != nil {
                let allow_subdomains = defaults.bool(forKey: "allow_subdomains")
                allowSubdomains = allow_subdomains
            }
            
        
        if let limit_domains = defaults.string(forKey: "domain_limit") {
            if limit_domains.count > 0 {
                allowedDomains = [String]()
                for  d in limit_domains.split(separator: ",") {
                    allowedDomains.append(String(d).lowercased())
                }
            }else{
                allowedDomains = [String]()
            }
            
        }else{
            allowedDomains = [String]()
        }
        
        
        // If we use MDM and are supervised we can force into guided access mode
        if let atgCode = defaults.string(forKey: "guided_exit_passcode") {
            guidedAccessExitCode = atgCode
        }
        if defaults.object(forKey: "auto_guided_access") != nil {
            let atg = defaults.bool(forKey: "auto_guided_access")
            autoGuidedAccess = atg
        }
        if(autoGuidedAccess && !UIAccessibility.isGuidedAccessEnabled) {
            UIAccessibility.requestGuidedAccessSession(enabled: true, completionHandler: {_ in })
            debugPrint("Not in guided access. Attempting guided access.")
        }
            
        }
    
}
