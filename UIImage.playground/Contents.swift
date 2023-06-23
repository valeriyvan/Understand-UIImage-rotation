import UIKit

func DegreesToRadians(_ degrees: CGFloat) -> CGFloat { degrees * .pi / 180 }
func RadiansToDegrees(_ radians: CGFloat) -> CGFloat { return radians * 180 / .pi }

extension UIImage {

    func imageAtRect(_ rect: CGRect) -> UIImage? {
        cgImage
            .flatMap { $0.cropping(to: rect) }
            .flatMap(UIImage.init(cgImage:))
    }

    func imageByScalingProportionallyToMinimumSize(_ targetSize: CGSize) -> UIImage? {
        var scaledWidth = targetSize.width
        var scaledHeight = targetSize.height
        var thumbnailPoint = CGPoint.zero
        if !CGSizeEqualToSize(size, targetSize) {
            var widthFactor = targetSize.width / size.width
            var heightFactor = targetSize.height / size.height
            let scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor
            scaledWidth  = size.width * scaleFactor
            scaledHeight = size.height * scaleFactor
            // center the image
            if (widthFactor > heightFactor) {
                thumbnailPoint.y = (targetSize.height - scaledHeight) * 0.5
            } else if (widthFactor < heightFactor) {
                thumbnailPoint.x = (targetSize.width - scaledWidth) * 0.5
            }
        }
        // this is actually the interesting part:
        UIGraphicsBeginImageContext(targetSize)
        defer { UIGraphicsEndImageContext }
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaledWidth, height: scaledHeight))
        draw(in: thumbnailRect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Could not scale image")
            return nil
        }
        return newImage
    }

    func imageByScalingProportionallyToSize(_ targetSize: CGSize) -> UIImage? {
        var scaledWidth = targetSize.width
        var scaledHeight = targetSize.height
        var thumbnailPoint = CGPoint.zero
        if !CGSizeEqualToSize(size, targetSize) {
            let widthFactor = targetSize.width / size.width
            let heightFactor = targetSize.height / size.height
            let scaleFactor =  widthFactor < heightFactor ? widthFactor : heightFactor
            scaledWidth  = size.width * scaleFactor;
            scaledHeight = size.height * scaleFactor;
            // center the image
            if widthFactor < heightFactor {
                thumbnailPoint.y = (targetSize.height - scaledHeight) * 0.5
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetSize.width - scaledWidth) * 0.5
            }
        }
        // this is actually the interesting part:
        UIGraphicsBeginImageContext(targetSize)
        defer { UIGraphicsEndImageContext() }
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: CGSize(width: scaledWidth, height: scaledHeight))
        draw(in: thumbnailRect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Could not scale image")
            return nil
        }
        return newImage
    }

    // this will rotate pixels of UIImage without considering imageOrientation property
    func imageWithRotatedPixelsByDegrees(_ degrees: CGFloat) -> UIImage? {
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let t = CGAffineTransformMakeRotation(DegreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        defer { UIGraphicsEndImageContext() }
        guard let bitmap = UIGraphicsGetCurrentContext(), let cgImage else {
            return nil
        }
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        // Rotate the image context
        bitmap.rotate(by: DegreesToRadians(degrees))
        // Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(origin: CGPoint(x: -self.size.width / 2, y: -self.size.height / 2), size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func imageWithRotatedPixelsByRadians(_ radians: CGFloat) -> UIImage? {
       return imageWithRotatedPixelsByDegrees(RadiansToDegrees(radians))
    }

}

let imagePath = Bundle.main.path(forResource: "Lenna_(test_image)", ofType: "png")!
let image = UIImage(contentsOfFile: imagePath)!

let image45 = image.imageWithRotatedPixelsByDegrees(45)!

let image90 = image.imageWithRotatedPixelsByDegrees(90)!

let imageMinus90 = image.imageWithRotatedPixelsByDegrees(-90)!

let image180 = image90.imageWithRotatedPixelsByDegrees(90)!

let image270 = image180.imageWithRotatedPixelsByDegrees(90)!

let image360 = image270.imageWithRotatedPixelsByDegrees(90)!

let imageOrientation90 = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)

let imageOrientation90Rotated90 = imageOrientation90.imageWithRotatedPixelsByDegrees(90)!
print("\(imageOrientation90Rotated90.imageOrientation)")
// Pay attention that imageWithRotatedPixelsByDegrees rotates only pixel data keeping imageOrientation untouched
