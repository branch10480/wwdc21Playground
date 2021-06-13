//
//  AsyncAwaitViewController.swift
//  wwdc21Playground
//
//  Created by branch10480 on 2021/06/13.
//

import UIKit
import MultipeerConnectivity

class AsyncAwaitViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  
  enum FetchError: Error {
    case badID
    case badImage
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    async {
      imageView.image = try? await fetchThumbnail(for: "https://avatars.githubusercontent.com/u/5299528?v=4")
    }
  }

  func fetchThumbnail(for url: String) async throws -> UIImage {
    let request = URLRequest(url: URL(string: url)!)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw FetchError.badID
    }
    let maybeImage = UIImage(data: data)
    guard let thumbnail = await maybeImage?.thumbnail else {
      throw FetchError.badImage
    }
    return thumbnail
  }
}

extension UIImage {
  var thumbnail: UIImage? {
    get async {
      let size = CGSize(width: 100, height: 100)
      return await byPreparingThumbnail(ofSize: size)
    }
  }
}

fileprivate class ViewController: UIViewController {
  
  private var activeConfiguration: CheckedContinuation<[Any], Error>?
  
  func sharedPostsFromPeer() async throws -> [Any] {
    try await withCheckedThrowingContinuation({ continuation in
      self.activeConfiguration = continuation
    })
  }
  
  // MARK: - Demo delegate methods

  func demo(received posts: [Any]) {
    self.activeConfiguration?.resume(returning: posts)
    self.activeConfiguration = nil
  }
  
  func demo(hadError error: Error) {
    self.activeConfiguration?.resume(throwing: error)
    self.activeConfiguration = nil
  }
}
