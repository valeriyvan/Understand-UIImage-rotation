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
            // Center the image
            if widthFactor < heightFactor {
                thumbnailPoint.y = (targetSize.height - scaledHeight) * 0.5
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetSize.width - scaledWidth) * 0.5
            }
        }
        // This is actually the interesting part:
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

    // Rotate pixels of UIImage without considering imageOrientation property
    func imageWithRotatedPixelsByDegrees(_ degrees: CGFloat, mirror: Bool = false) -> UIImage? {
        // Calculate the size of the rotated view's containing box for drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: DegreesToRadians(degrees)).scaledBy(x: mirror ? -1.0 : 1.0, y: 1.0)
        let rotatedSize = rotatedViewBox.frame.size
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        defer { UIGraphicsEndImageContext() }
        guard let bitmap = UIGraphicsGetCurrentContext(), let cgImage else {
            return nil
        }
        // Move the origin to the middle of the image so it will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        // Rotate the image context
        bitmap.rotate(by: DegreesToRadians(degrees))
        // Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func imageWithRotatedPixelsByRadians(_ radians: CGFloat) -> UIImage? {
        imageWithRotatedPixelsByDegrees(RadiansToDegrees(radians))
    }

    func imageRotatedByDegrees(_ degrees: CGFloat, mirror: Bool = false) -> UIImage? {
        let t: (angle: CGFloat, mirror: Bool) =
            switch imageOrientation {
            case .up:
                (0.0, false)
            case .down:
                (180.0, false)
            case .left:
                (-90.0, false)
            case .right:
                (90.0, false)
            case .upMirrored:
                (0.0, true)
            case .downMirrored:
                (180.0, true)
            case .leftMirrored:
                (-90.0, true)
            case .rightMirrored:
                (90.0, true)
            @unknown default:
                (0.0, false)
            }
        return imageWithRotatedPixelsByDegrees(t.angle + degrees, mirror: t.mirror != mirror)
    }

}

let imagePath = Bundle.main.path(forResource: "Lenna_(test_image)", ofType: "png")!

let image = UIImage(contentsOfFile: imagePath)!

let imageMirrored = image.imageWithRotatedPixelsByDegrees(0, mirror: true)

let image45 = image.imageWithRotatedPixelsByDegrees(45)!

let image45Mirrored = image.imageWithRotatedPixelsByDegrees(45, mirror: true)!

let image90 = image.imageWithRotatedPixelsByDegrees(90)!

let image90Mirrored = image.imageWithRotatedPixelsByDegrees(90, mirror: true)!

let imageMinus90 = image.imageWithRotatedPixelsByDegrees(-90)!

let image180 = image90.imageWithRotatedPixelsByDegrees(90)!

let image270 = image180.imageWithRotatedPixelsByDegrees(90)!

let image360 = image270.imageWithRotatedPixelsByDegrees(90)!

let imageOrientation90 = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .right)

let imageOrientation90Rotated90 = imageOrientation90.imageWithRotatedPixelsByDegrees(90)!
print("\(imageOrientation90Rotated90.imageOrientation)")
// Pay attention that imageWithRotatedPixelsByDegrees rotates only pixel data ignoring imageOrientation property.
// Returned image has default `imageOrientation` which is `.up`.
// This is not what people expect when writing/copypasting code for rotating UIImage.

// TODO: there are still problems with mirroring
