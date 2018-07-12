//
//  Extensions.swift
//  ChatApplication
//
//  Created by Кирилл Трискало on 11.07.2018.
//  Copyright © 2018 Кирилл Трискало. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    // Функция загружает картинку из кэша
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        self.image = nil
        
        // если картинка есть к кэше, то вставить она вставляется в imageView
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // если ее нет, то картинка загружается по ссылке
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    // после загрузки добавляется в кэш
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    // и вставляется в imageView
                    self.image = downloadedImage
                }
            })
        }).resume()
    }
}


extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
