//
//  HomePageTestView.swift
//  MobileAcebook
//
//  Created by Dan Gullis on 23/02/2024.
//

import SwiftUI
import Cloudinary

struct HomePageTestView: View {
    @State private var selectedTab: Tab = .home
    @StateObject var authService = AuthenticationService.shared
    @StateObject var logoutViewModel = LogoutViewModel()
    @ObservedObject var viewModel = PostsViewModel()
    @State private var isLoggingOut = false
    let cloudinary = CLDCloudinary(configuration: CloudinaryConfig.configuration)
    
    enum Tab {
        case home, user, newPost, logout
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomePageView()
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            
            UserPageView()
                .tabItem{
                    Label("User", systemImage: "person.fill")
                }
                .tag(Tab.user)
            
            NewPostView()
                .tabItem{
                    Label("New Post", systemImage: "pencil.line")
                }
                .tag(Tab.newPost)
            
            Text("Logout")
                .tabItem {
                    Label("Logout", systemImage: "person.fill.xmark")
                }
                .tag(Tab.logout)

        }
        .background(NavigationLink(destination: WelcomePageView(), isActive: $isLoggingOut){ EmptyView() })
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedTab) { newValue in
            if newValue == Tab.logout {
                logoutViewModel.signOut()
                isLoggingOut = true
                print("Logging out...")
            }
        }
        
    }
}

struct HomePageTestView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageTestView()
    }
}


