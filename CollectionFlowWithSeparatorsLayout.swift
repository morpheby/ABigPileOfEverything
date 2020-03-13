//
//  CollectionFlowWithSeparatorsLayout.swift
//  meerkatmovies
//
//  Created by Ilya Mikhaltsou on 12/5/18.
//  Copyright © 2018 Compare The Market. All rights reserved.
//

import UIKit

class CollectionFlowWithSeparatorsLayout: UICollectionViewFlowLayout {
    var affectsSections: [Int] = []
    var separatorColor: UIColor = UIColor.black
    var separatorBacgroundColor: UIColor = UIColor.white
    var separatorMargins: (left: CGFloat, right: CGFloat) = (0, 0)
    var separatorHeight: CGFloat = 0.5 {
        didSet {
            minimumLineSpacing = separatorHeight
        }
    }

    private var attributesCache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var currentUpdates: [UICollectionViewUpdateItem] = []

    class SeparatorAttributes: UICollectionViewLayoutAttributes {
        var separatorColor: UIColor = UIColor.black
        var separatorBackgroundColor: UIColor = UIColor.white
        var separatorMargins: (left: CGFloat, right: CGFloat) = (0, 0)
        var separatorHeight: CGFloat = 0.5
    }

    private static let separatorDecorativeViewKind = "\(CollectionFlowWithSeparatorsLayout.self).Separator"

    func registerSeparator(class viewClass: AnyClass?) {
        register(viewClass, forDecorationViewOfKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind)
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        currentUpdates = updateItems

        if #available(iOS 10.0, *) {
            // Starting from iOS 10.0 UICollectionView works differently concerning animations
            // and item additions. Layout methods are no longer supposed to return final and initial
            // positions only, and may recalculate positions as needed. Thus, cache is not only
            // redundant, but also breaks stuff
        } else {
            for update in currentUpdates {
                if let indexPath = update.indexPathBeforeUpdate {
                    attributesCache.removeValue(forKey: indexPath)
                }
                if let indexPath = update.indexPathAfterUpdate {
                    attributesCache.removeValue(forKey: indexPath)
                }
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        currentUpdates = []
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        let itemAttributes = attributes.filter { attribute in
            return attribute.representedElementCategory == .cell &&
                affectsSections.contains(attribute.indexPath.section)
        }

        let separatorAttributes = itemAttributes.dropLast().compactMap { itemAttribute -> UICollectionViewLayoutAttributes? in
            return layoutAttributesForDecorationView(ofKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind, at: itemAttribute.indexPath)
        }

        return Array(attributes + separatorAttributes)
    }

    override func indexPathsToInsertForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return currentUpdates.filter {update in
            return update.indexPathBeforeUpdate != update.indexPathAfterUpdate
        } .compactMap { update in
            return update.indexPathAfterUpdate
        } .filter { indexPath in
            return affectsSections.contains(indexPath.section)
        }
    }

    override func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return currentUpdates.filter {update in
            return update.indexPathBeforeUpdate != update.indexPathAfterUpdate
        } .compactMap { update in
            return update.indexPathBeforeUpdate
        } .filter { indexPath in
            return affectsSections.contains(indexPath.section)
        }
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        assert(affectsSections.contains(indexPath.section), "Invalid update queued")

        if #available(iOS 10.0, *) {
        } else {
            if let attributes = attributesCache[indexPath] {
                return attributes
            }
        }

        guard let touchedRow = layoutAttributesForItem(at: indexPath) else {
            return nil
        }

        let attributes = separatorAttributes(for: touchedRow, at: indexPath)

        if #available(iOS 10.0, *) {
        } else {
            attributesCache[indexPath] = attributes
        }

        return attributes
    }

    private func separatorAttributes(for itemAttributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let leftEdge = itemAttributes.frame.left
        let width = itemAttributes.frame.width
        let topEdge = itemAttributes.frame.bottom
        let height = separatorHeight

        let frame = CGRect(x: leftEdge, y: topEdge, width: width, height: height)

        let attributes = SeparatorAttributes(forDecorationViewOfKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind, with: indexPath)
        attributes.frame = frame
        attributes.separatorColor = separatorColor
        attributes.separatorBackgroundColor = separatorBacgroundColor
        attributes.separatorMargins = separatorMargins
        attributes.separatorHeight = separatorHeight

        return attributes
    }

    override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let touchedRow = initialLayoutAttributesForAppearingItem(at: decorationIndexPath) else {
            return nil
        }

        let attributes = separatorAttributes(for: touchedRow, at: decorationIndexPath)

        return attributes
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {

        if #available(iOS 10.0, *) {
            // Up to iOS 10.0 collection view doesn't inform our layout of updates to sizes of
            // some cells through the designated method. Instead some of them (apparently)
            // are generated by UICollectionViewFlowLayout, and it doesn't call the designated
            // method, silently filling context with the values of cells that need updating.
            // So starting with iOS 10.0 we don't need this hack and can rely on
            // invalidationContext(forPreferredLayoutAttributes:..), while on iOS 9.3 and
            // earlier we should check again to add anything UICollectionViewFlowLayout may have
            // added before this call.
        } else {
            if let invalidatedItemIndexPaths = context.invalidatedItemIndexPaths {
                let affectedDecorations = invalidatedItemIndexPaths.filter { indexPath in affectsSections.contains(indexPath.section) }
                context.invalidateDecorationElements(ofKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind, at: affectedDecorations)
            }
        }

        if context.invalidateDataSourceCounts,
            let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let numberOfSections = dataSource.numberOfSections {
            var affectedIndexPaths: [IndexPath] = []
            let sections = numberOfSections(collectionView)
            for section in ((0..<sections).filter { section in affectsSections.contains(section) }) {
                let items = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                affectedIndexPaths.append(contentsOf: (0..<items).map { item in IndexPath(item: item, section: section) })
            }
            context.invalidateDecorationElements(ofKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind, at: affectedIndexPaths)
        }

        super.invalidateLayout(with: context)

        if #available(iOS 10.0, *) {
        } else {
            if context.invalidateEverything || context.invalidateDataSourceCounts {
                attributesCache = [:]
                return
            }

            guard let invalidatedDecorationIndexPaths = context.invalidatedDecorationIndexPaths else {
                return
            }

            for indexPath in invalidatedDecorationIndexPaths[CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind] ?? [] {
                attributesCache.removeValue(forKey: indexPath)
            }
        }
    }

    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        if var invalidatedItemIndexPaths = context.invalidatedItemIndexPaths {
            invalidatedItemIndexPaths.append(preferredAttributes.indexPath)
            var affectedDecorations = invalidatedItemIndexPaths.filter { indexPath in affectsSections.contains(indexPath.section) }

            context.invalidateDecorationElements(ofKind: CollectionFlowWithSeparatorsLayout.separatorDecorativeViewKind, at: affectedDecorations)

            let affectedSections = Array(Set(invalidatedItemIndexPaths.map { p in p.section })).map { i in IndexPath(item: 0, section: i) }

            let affectedHeaders = affectedSections.filter { section in
                if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: section),
                    attributes.size.height != 0 && attributes.size.width != 0 {
                    return true
                } else {
                    return false
                }
            }
            let affectedFooters = affectedSections.filter { section in
                if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: section),
                    attributes.size.height != 0 && attributes.size.width != 0 {
                    return true
                } else {
                    return false
                }
            }

            context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: affectedHeaders)
            context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter, at: affectedFooters)
        }

        return context
    }
}
