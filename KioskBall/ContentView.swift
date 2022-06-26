//
//  ContentView.swift
//  KioskBall
//
//  Created by Michael Altobelli on 6/20/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var wvModel = SwiftWebViewModel()
    @StateObject var wvHelpModel = HelpWebViewModel()
    
    
    @State var showHelp: Bool = false
   
    
    var body: some View {
        let showAlert = Binding<Bool> (
            get: { self.wvModel.alertText.count > 0 },
            set: {_ in self.wvModel.alertText = ""}
        )
       
        
        VStack(spacing: 0) {
            
           
            ZStack() {
                
                //Main WebView Layout
                SwiftWebView(webView: wvModel.swWebView)
                    .opacity(showHelp ? 0.0 : 1.0)
                
                // WebView Layout for the help screen
                VStack(spacing: 0){
                    
                    SwiftWebView(webView: wvHelpModel.swWebView)
                        .border(Color.accentColor, width:5)
                        .padding(0)
                    Text("Help view. \r\nClick the Home button to return to the page you were on.", comment:"Help instructions")
                        .frame(height: 90.0)
                        .frame( maxWidth:.infinity)
                        .padding(0)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                }
                .opacity(showHelp ? 1.0 : 0.0)
                	
            }
            
            
            HStack(spacing: 10) {
                Spacer()
                
                Button(action: {  if(showHelp) {
                    showHelp = false
                }else{ wvModel.loadHomePage()}
                    wvModel.lastInteraction = Date.init()
                    wvHelpModel.lastInteraction = Date.init()
                    
                },label:{ HStack {
                        Image(systemName: "house.fill")
                            .imageScale(.large)
                    Text("Home", comment:"Home button text")
                    }
                    
                })
                .accessibilityLabel("Load home page")
                .opacity(wvModel.kbConfig.homeButton ? 1:0)
                
                Spacer()
                
                Button(
                    action: {
                    if(showHelp) {
                        wvHelpModel.loadHomePage()
                    }else{
                        if(wvHelpModel.swWebView.url?.absoluteString == wvHelpModel.kbConfig.homeURL) {
                        wvHelpModel.loadHomePage()
                        }
                        showHelp = true
                    }
                        wvModel.lastInteraction = Date.init()
                        wvHelpModel.lastInteraction = Date.init()
                },label:{
                    Image(systemName: "questionmark.circle.fill")
                        .imageScale(.large)
                    
                    Text("Help", comment:"Help button label")
                    
                })
                .accessibilityLabel("Load help page")
                .opacity(wvModel.kbConfig.helpButton ? 1:0)
                
                
                
                Spacer()
                
            }
            .frame(height: ((wvModel.kbConfig.helpButton || wvModel.kbConfig.homeButton) ? 60.0 : 0.0))
            
        }.background(Color(UIColor.systemBackground))
            .alert(isPresented: (showAlert) ) {
                Alert(title: Text(wvModel.alertText),
                      dismissButton: .default(Text("Stay on this page", comment:"Page timeout dialog text"))
                            {wvModel.lastInteraction = Date.init()
                            wvHelpModel.lastInteraction = Date.init()
                })
                
            }.onTapGesture(count: 1,
                           perform: { wvModel.lastInteraction = Date.init()
                                    wvHelpModel.lastInteraction = Date.init()
            })
       
    }
     
}
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
