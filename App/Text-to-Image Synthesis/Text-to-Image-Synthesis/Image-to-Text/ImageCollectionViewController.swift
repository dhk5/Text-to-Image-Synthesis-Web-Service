//
//  ImageCollectionViewController.swift
//  Text-to-Image-Synthesis
//
//  Created by Ryan Kang on 1/14/19.
//

import Foundation
import UIKit


final class ImageCollectionViewController: UICollectionViewController {
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    // MARK: - Properties
    let reuseIdentifier = "ImageCell"
    let placeHolderImageName = "placeholder"
    let nameIdMapTextFileName = "name_id_map"
    
    let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    let itemsPerRow: CGFloat = 2
    let numberOfSections = 10
    let numberOfItemsInSection = 2
    let maxNumberOfSelectedData = 2

    var imageDataArr = [ImageData]()
    var arrSelectedIndex = [IndexPath]()
    var arrSelectedData = [ImageData]()
    
    var nameIdMap = [String: String]()
    var shouldReload = false
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        collectionView!.performBatchUpdates({
            // refresh cells
            for i in 0..<numberOfSections {
                let section = IndexSet([i])
                collectionView!.deleteSections(section)
                collectionView!.insertSections(section)
            }
            shouldReload = true
            
            // Clean selected data and cells
            for indexPath in arrSelectedIndex {
                let cell = collectionView!.cellForItem(at: indexPath)!
                cell.backgroundColor = UIColor.clear
            }
            nextButton.isEnabled = false
            arrSelectedData.removeAll()
        }, completion: nil)
        collectionView?.reloadData()
        shouldReload = false
    }
}

// MARK: - UIViewController
extension ImageCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = true
        loadNameIdMap()
        initImageDataArr()
    }
    
    // MARK: - UIViewController helper functions
    private func loadNameIdMap() {
        if let path = Bundle.main.path(forResource: nameIdMapTextFileName, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let strings = data.components(separatedBy: .newlines)
                for string in strings {
                    let nameAndID = string.components(separatedBy: ",")
                    if nameAndID.count == 2 {
                        nameIdMap[nameAndID[0]] = nameAndID[1]
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func initImageDataArr() {
        for _ in 0..<numberOfSections*numberOfItemsInSection {
            imageDataArr.append(ImageData())
        }
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ImageCreateViewController
        {
            let vc = segue.destination as? ImageCreateViewController
            vc?.arrSelectedData = self.arrSelectedData
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ImageCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension ImageCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return imageDataArr.count / numberOfItemsInSection
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCell
        
        if !cell.isImageLoaded || shouldReload {
            // Update cell with image name and id
            let randomImageName = nameIdMap.randomElement()?.key
            let randomImageID = nameIdMap[randomImageName!]
            
            // Update imageDataArr
            let imageDataObject = imageDataArr[(indexPath.section * numberOfItemsInSection) + indexPath.row]
            imageDataObject.imageName = randomImageName!
            imageDataObject.imageId = randomImageID!
            
            // Remove used image.
            nameIdMap.remove(at: nameIdMap.index(forKey: randomImageName!)!)
            
            self.loadImageOnCell(imageDataObject, indexPath, cell)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let cellIndex = (indexPath.section * numberOfItemsInSection) + indexPath.row
        print("You selected cell #\(cellIndex)!")
        let imageData = imageDataArr[cellIndex]
        
        // Add cell to selected and highlight when number of selected
        // is less or equal to max number of selected.
        if arrSelectedData.count < maxNumberOfSelectedData {
            let cell = collectionView.cellForItem(at: indexPath)!
            cell.backgroundColor = collectionView.tintColor
            print("You added a cell #\(cellIndex) to selected data!")
            arrSelectedIndex.append(indexPath)
            arrSelectedData.append(imageData)
            
            if arrSelectedData.count == maxNumberOfSelectedData {
                nextButton.isEnabled = true
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didDeselectItemAt indexPath: IndexPath) {
        let cellIndex = (indexPath.section * numberOfItemsInSection) + indexPath.row
        print("You de-selected cell #\(cellIndex)!")
        let imageData = imageDataArr[cellIndex]
        
        // Removed cell from selected and clear highlight when number of selected
        // is higer than 0.
        if arrSelectedData.count > 0 {
            let cell = collectionView.cellForItem(at: indexPath)!
            cell.backgroundColor = UIColor.clear
            for selectedDataIndex in 0...arrSelectedData.count-1 {
                if arrSelectedData[selectedDataIndex].imageId == imageData.imageId {
                    print("You removed a cell #\(cellIndex) to selected data!")
                    arrSelectedData.remove(at: selectedDataIndex)
                    break
                }
            }
            
            if arrSelectedData.count != maxNumberOfSelectedData {
                nextButton.isEnabled = false
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource Helper functions
    private func loadImageOnCell(_ imageData: ImageData, _ indexPath: IndexPath, _ cell: ImageCell) {
        let fetcher = ImageFetcher()
        print("Downloading Started For Cell Index: \(indexPath)")
        fetcher.fetchRandomImage(imageID: imageData.imageId) { data, response, error in
            if let error = error {
                print("Image fetch failed with error: \(error)")
                DispatchQueue.main.async() {
                    let image = UIImage(named: self.placeHolderImageName)
                    imageData.image = image
                    cell.imageLabel.text = ""
                    self.updateCellWithImage(image!, cell)
                }
            }
            
            if let data = data {
                print("Download Finished For: " + data.description)
                DispatchQueue.main.async() {
                    if let image = UIImage(data: data) {
                        imageData.image = image
                        cell.imageLabel.text = imageData.imageName
                        self.updateCellWithImage(image, cell)
                    } else {
                        let image = UIImage(named: self.placeHolderImageName)
                        imageData.image = image
                        cell.imageLabel.text = ""
                        self.updateCellWithImage(image!, cell)
                    }
                }
            }
        }
    }
    
    private func updateCellWithImage(_ image: UIImage, _ cell: ImageCell) {
        if let imageView = cell.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            cell.isImageLoaded = true
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension ImageCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width - CGFloat(15)
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
