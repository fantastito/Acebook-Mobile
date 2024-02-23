
//  UserPageView.swift
//  MobileAcebook
//
//  Created by Dan Gullis on 20/02/2024.
//

import SwiftUI
import Cloudinary


struct UserPageView: View {
    @StateObject var authService = AuthenticationService.shared
    @StateObject var userPageViewModel = UserPageViewModel()
    @StateObject var getUserModel = GetUserModel()
    @State private var currentUser: User?
    
    
    let cloudinary = CLDCloudinary(configuration: CloudinaryConfig.configuration)

    var body: some View {
            VStack {
                Text("User Page")
                    .font(.title3)
                    .padding()
                
                if let error = userPageViewModel.errorMessage {
                    Text(error)
                }
                
                Spacer()
                
                HStack {
                    if let avatar = userPageViewModel.user?.avatar {
                        cloudinaryImageView(cloudinary: cloudinary, imagePath: avatar)
                    }
                    
                    if let username = userPageViewModel.user?.username {
                        Text(username)
                    }

                }
                .padding()
                
                Text("Under development")
                
                Spacer()
                /*
                VStack {
                    if let currentUser = currentUser {
                        Text("User: \(currentUser.username)") // Display a specific property of the user
                    } else {
                        // You can show a loading indicator or some other placeholder here
                        Text("error with new method")
                    }
                }
                 */
                
            }
            .padding()
            .onAppear {
                userPageViewModel.getUser()
                /*
                getUserModel.getUser(userId: authService.userId) { result in
                    switch result {
                    case .success(let user):
                        // Assign the user to your variable
                        currentUser = user
                    case .failure(let error):
                        // Handle the error if needed
                        print("Error: \(error)")
                    }
                }
                */
            }
                
    }
}



struct UserPageView_Previews: PreviewProvider {
    static var previews: some View {
        UserPageView()
    }
}

