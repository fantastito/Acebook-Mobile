//
//  WelcomePageView.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 30/09/2023.
//

import SwiftUI


struct WelcomePageView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    
                    Text("Welcome to Acebook!")
                        .font(.largeTitle)
                        .padding()
                        .accessibilityIdentifier("welcomeText")
                    
                    Spacer()
                    
                    Image("makers-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
    
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink("Sign up", destination: SignupPageView()).padding(.trailing, 80.0)
                        
                        NavigationLink("Log in", destination: LoginPageView())
                    }
                    Spacer()
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageView()
    }
}

