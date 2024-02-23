import SwiftUI
import Cloudinary

struct HomePageView: View {
    @StateObject var authService = AuthenticationService.shared
    @StateObject var logoutViewModel = LogoutViewModel()
    @ObservedObject var viewModel = PostsViewModel()
    @StateObject var userPageViewModel = UserPageViewModel()
    @State private var isLoggingOut = false
    @State private var selectedTab = "Home"
    let cloudinary = CLDCloudinary(configuration: CloudinaryConfig.configuration)
    
    
    var body: some View {
                VStack {
                    if let username = userPageViewModel.user?.username {
                        Text("Hello \(username)!")
                            .font(.title3)
                    }
                    VStack(alignment: .leading) {
                    List(viewModel.posts) { post in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .padding(.trailing, 8)
                            
                            if let createdBy = post.createdBy {
                                Text("Posted by: \(createdBy)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                        }
                                
                        VStack {
                            if let message = post.message {
                                Text(message)
                                    .font(.subheadline)
                            } else {
                                Text("No message available")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            if let postImagePath = post.image {
                                
                                cloudinaryImageView(cloudinary: cloudinary, imagePath: "acebook-mobile/\(postImagePath)")
                                    .aspectRatio(contentMode: .fit)
                                    .scaledToFit()

                            }
                            
                        }
                            
                        HStack(spacing: 80) {
                        
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .foregroundColor(.red)
                                    .imageScale(.small)
                            }
                            .padding(.horizontal, 16.0)
                            
                            Button(action: {}) {
                                Label("Comments", systemImage: "bubble.left")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.trailing, 16)
                            
                            
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                        }
                        .padding()
                    }
                }
                .navigationBarTitle("Home Page")
                .navigationBarTitleDisplayMode(.inline) // Center the title
                .onAppear {
                    viewModel.loadApiToken()
                    viewModel.fetchPosts()
                    
                }
    }
    
}



#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(AuthenticationService.shared)
    }
}
#endif
