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
  @State private var username: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confPassword: String = ""
    
    @State private var errMessage: String = ""
    
    @StateObject var authService = AuthenticationService.shared

  @StateObject var imagePicker = ImagePicker()
  @State private var uploadedImagePublicId: String = "/default_avatar.png"
    
  @State private var navigateToFeedPage: Bool = false
    @State private var showErrMessage: Bool = false
    @State private var showSignupBtn: Bool = true

  var body: some View {
      VStack{

        Text("Welcome to Acebook!")
          .font(.largeTitle)
          .padding(.bottom, 20)
          .accessibilityIdentifier("welcomeText")

        Spacer()

          if showErrMessage{
              Text(errMessage)
                  .multilineTextAlignment(.center)
          } else {
              Image(systemName: "network")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 160, height: 160)
                  .accessibilityIdentifier("network-logo")
          }

        Form {
          Section(header: Text("Sign Up")
            .font(.title2)
            .multilineTextAlignment(.center)) {
                TextField("Username", text:$username).onChange(of: username) {
                    _ in showErrMessage = false
                    showSignupBtn = true
                }
              TextField("Email", text:$email).onChange(of: email) {
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
                        } else { /*look here later*/
                            print("Error: Image upload failed.")
                        }
                    }
                }
            }
            
          Section {
              if showSignupBtn{
                  Button("Sign up") {
                      let userInfo = User(email: email, username: username, password: password, avatar: uploadedImagePublicId)
                      authService.signUp(user: userInfo, confPassword: confPassword) {
                          canSignUp, errorMessage in if canSignUp {
                              print("line 74 \(navigateToFeedPage)")
                              navigateToFeedPage = true
                          } else {
                              if let errorMessage = errorMessage {
                                  errMessage = errorMessage
                                  showErrMessage = true
                                  showSignupBtn = false
                                  print(errMessage)
                              }
                              print("line 77 \(canSignUp)")
                              navigateToFeedPage = false
                          }
                      }
                  }.background(NavigationLink(destination: LoginPageView(), isActive: $navigateToFeedPage){ EmptyView() })
              }
          }
        }
      }
  }
}

#Preview {
  SignupPageView()
}

