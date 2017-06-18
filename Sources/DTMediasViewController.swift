//
//  DTMediasViewController.swift
//  DTMediasViewController
//
//  Created by 但 江 on 16/6/2.
//  Copyright © 2016年 Dan Thought Studio. All rights reserved.
//

import UIKit

public protocol DTMediasViewControllerPhotoURLHandler {
  func mediasViewController(_ mediasViewController: DTMediasViewController, photo: DTMedia, viewController: UIViewController)
}

public class DTMediasViewController: UIPageViewController {
  
  public var handler: DTMediasViewControllerPhotoURLHandler?
  
  public static func imageWithName(_ name: String) -> UIImage? {
    let bundle = Bundle(for: DTMediasViewController.self)
    let url = bundle.url(forResource: "DTMediasViewController", withExtension: "bundle")!
    let imageBundle = Bundle(url: url)
    return UIImage(named: name, in: imageBundle, compatibleWith: nil)
  }
  
  fileprivate var mediaViewControllers = [Int: DTMediaViewController]()
  fileprivate var currentPage = 0
  fileprivate var medias: [DTMedia]
  fileprivate var photoPlaceholderImage: UIImage?
  fileprivate var gifPlaceholderImage: UIImage?
  fileprivate let pageLabel = UILabel()
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(medias: [DTMedia], photoPlaceholderImage: UIImage?, gifPlaceholderImage: UIImage?, currentPage: Int) {
    self.medias = medias
    self.photoPlaceholderImage = photoPlaceholderImage
    self.gifPlaceholderImage = gifPlaceholderImage
    self.currentPage = currentPage
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  }

  public override func loadView() {
    super.loadView()
    
    view.backgroundColor = UIColor.black
    
    dataSource = self
    delegate = self
    
    if medias.count > 1 {
      pageLabel.font = UIFont.systemFont(ofSize: 14)
      pageLabel.textColor = UIColor(red: 0.52, green: 0.52, blue: 0.52, alpha: 1)
      
      view.addSubview(pageLabel)
      
      pageLabel.translatesAutoresizingMaskIntoConstraints = false
      
      let centerX = NSLayoutConstraint(item: pageLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
      let bottom = NSLayoutConstraint(item: pageLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
      
      view.addConstraints([centerX, bottom])
    }
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    if let photoViewController = mediaViewControllerWithPage(currentPage) {
      setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
    }
    reloadPageLabel()
  }
  
  public func setPhoto(_ media: DTMedia, forViewController viewController: UIViewController) {
    if let photoViewController = viewController as? DTPhotoViewController {
      photoViewController.setImageViewWithPhoto(media)
    }
  }
  
  fileprivate func mediaViewControllerWithPage(_ page: Int) -> UIViewController? {
    if page >= 0 && page < medias.count {
      if let mediaViewController = mediaViewControllers[page] {
        return mediaViewController
      } else {
        let media = medias[page]
        if media.type == .video {
          let videoViewController = DTVideoViewController(video: media)
          videoViewController.page = page
          mediaViewControllers[page] = videoViewController
          return videoViewController
        } else {
          let photoViewController = DTPhotoViewController(photo: media)
          photoViewController.delegate = self
          photoViewController.photoPlaceholderImage = photoPlaceholderImage
          photoViewController.gifPlaceholderImage = gifPlaceholderImage
          photoViewController.page = page
          mediaViewControllers[page] = photoViewController
          return photoViewController
        }
      }
    } else {
      return nil
    }
  }
  
  fileprivate func reloadPageLabel() {
    pageLabel.text = "\(currentPage + 1) / \(medias.count)"
  }
  
}

// MARK: - UIPageViewControllerDataSource

extension DTMediasViewController: UIPageViewControllerDataSource {
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let mediaViewController = viewController as? DTMediaViewController {
      return mediaViewControllerWithPage(mediaViewController.page + 1)
    } else {
      return nil
    }
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let mediaViewController = viewController as? DTMediaViewController {
      return mediaViewControllerWithPage(mediaViewController.page - 1)
    } else {
      return nil
    }
  }
  
}

// MARK: - UIPageViewControllerDelegate

extension DTMediasViewController: UIPageViewControllerDelegate {
  
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      if let mediaViewController = viewControllers?.last as? DTMediaViewController {
        currentPage = mediaViewController.page
        reloadPageLabel()
      }
    }
  }
  
}

// MARK: - DTMediasViewController

extension DTMediasViewController: DTPhotoViewControllerDelegate {
  
  func photoViewControllerLoadPhoto(_ photoViewController: DTPhotoViewController) {
    handler?.mediasViewController(self, photo: photoViewController.photo, viewController: photoViewController)
  }
  
}
