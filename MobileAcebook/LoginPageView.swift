//
//  LoginPageView.swift
//  MobileAcebook
//
//  Created by Dan Gullis on 20/02/2024.
//

import SwiftUI

struct LoginPageView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToHomePage: Bool = false
    
    var body: some View {
        Form {
                TextField("email", text: $emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                SecureField("password", text: $password)
                    .textContentType(.password)
                

                Button("Log in") {
                    loginViewModel.logIn(email: emailAddress, password: password)
                    
                }
                .disabled(loginViewModel.isLoggingIn)
                .background(NavigationLink(destination: HomePageTestView(), isActive: .constant(loginViewModel.successMessage != nil)) {
                        EmptyView()
                    })
                
                    if let error = loginViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                if let success = loginViewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                }

            }.environmentObject(loginViewModel)
    }
}
    
    
struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView()
    }
}
    





