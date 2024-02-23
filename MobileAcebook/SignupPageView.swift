//
// SignupPageView.swift
// MobileAcebook
//
// Created by Joshua Bhogal on 19/02/2024.
//

import SwiftUI
import PhotosUI
import Cloudinary

struct SignupPageView: View {
  @StateObject var authService = AuthenticationService.shared
  @StateObject var imagePicker = ImagePicker()
    
  @State private var username: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confPassword: String = ""
  @State private var errMessage: String = ""
  @State private var uploadedImagePublicId: String = "/default_avatar.png"

  @State private var customImageUploaded: Bool = false
  @State private var navigateToLoginPage: Bool = false
  @State private var showErrMessage: Bool = false
  @State private var showSignupBtn: Bool = true

  var body: some View {
      VStack{

        Text("Welcome to Acebook!")
          .font(.largeTitle)
          .padding(.bottom, 20)
          .accessibilityIdentifier("welcomeText")

        Spacer()

          Image(systemName: "network")
              .resizable()
              .scaledToFit()
              .frame(width: 160, height: 160)
              .accessibilityIdentifier("network-logo")

        Form {
          Section(header: Text("Sign Up")
            .font(.title2)
            .multilineTextAlignment(.center)) {
                TextField("Username", text:$username).autocapitalization(.none).onChange(of: username) {
                    _ in showErrMessage = false
                    showSignupBtn = true
                }
              TextField("Email", text:$email).autocapitalization(.none).onChange(of: email) {
                  _ in showErrMessage = false
                  showSignupBtn = true
              }
              SecureField("Password", text:$password).onChange(of: password) {
                  _ in showErrMessage = false
                  showSignupBtn = true
              }
              SecureField("Confirm Password", text:$confPassword).onChange(of: confPassword) {
                  _ in showErrMessage = false
                  showSignupBtn = true
              }
            }

            PhotosPicker(selection: $imagePicker.imageSelection) {
                Text("Upload a photo")
            }
            .onChange(of: imagePicker.imageData) { imageData in
                // This block is executed when image data is set in the ImagePicker
                // You can update the uploadedImagePublicId here
                if let imageData = imageData {
                    imagePicker.uploadToCloudinary(data: imageData) { imagePublicId in
                        if let imagePublicId = imagePublicId {
                            uploadedImagePublicId = imagePublicId
                            customImageUploaded = true
                        } else { /*look here later*/
                            print("Error: Image upload failed.")
                            customImageUploaded = false
                        }
                    }
                }
            }
            if customImageUploaded {
                Text("Image has been uploaded successfully.")
            }
            
            
            if showErrMessage{
                Text(errMessage)
                    .multilineTextAlignment(.center)
            }
            
            
          Section {
              if showSignupBtn{
                  Button("Sign up") {
                      let userInfo = User(email: email, username: username, password: password, avatar: uploadedImagePublicId)
                      authService.signUp(user: userInfo, confPassword: confPassword) {
                          canSignUp, errorMessage in if canSignUp {
                              navigateToLoginPage = true
                              
                          } else {
                              if let errorMessage = errorMessage {
                                  errMessage = errorMessage
                                  showErrMessage = true
                                  showSignupBtn = false
                                  navigateToLoginPage = false
                              }
                              
                          }
                      }
                  }
              }
          }.background(NavigationLink(destination: LoginPageView(), isActive: $navigateToLoginPage) { EmptyView()})
        }
      }
  }
}

struct SignupPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignupPageView()
            .environmentObject(AuthenticationService.shared)
    }
}

