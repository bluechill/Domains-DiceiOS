//
//  ScrollPickerView.swift
//  UM Liars Dice
//
//  Created by Alex Turner on 5/23/16.
//  Copyright © 2016 Alex Turner. All rights reserved.
//

import UIKit

@objc protocol ScrollPickerViewDataSource
{
    func scrollPickerView(numberOfRowsFor scrollPicker: ScrollPickerView) -> UInt
    func scrollPickerView(_ scrollPicker: ScrollPickerView, viewForIndex index: UInt) -> UIView
    func scrollPickerView(_ scrollPicker: ScrollPickerView, heightForRow row: UInt) -> CGFloat
    
    func scrollPickerView(_ scrollPicker: ScrollPickerView, canSelectIndex index: UInt) -> Bool
}

@objc protocol ScrollPickerViewDelegate
{
    func scrollPickerView(_ scrollPicker: ScrollPickerView, didSelectIndex index: Int)
}

extension ScrollPickerViewDataSource
{
    func scrollPickerView(_ scrollPicker: ScrollPickerView, canSelectIndex index: UInt) -> Bool
    {
        return true
    }
}

class ScrollPickerView: UIView
{
    func getSelectedIndex() -> Int {
        if let indexPath = tableView.indexPathForSelectedRow
        {
            return indexPath.row
        }
        
        return -1
    }
    
    func setSelected(index: Int)
    {
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
    }
    
    internal var animating = false
    
    var datasource: ScrollPickerViewDataSource? = nil
    var delegate: ScrollPickerViewDelegate? = nil
    
    var headerView: UIView? = nil
    var footerView: UIView? = nil
    
    private var _tableView: UITableView? = nil
    internal var tableView: UITableView
    {
        get
        {
            if _tableView == nil
            {
                _tableView = UITableView.init(frame: self.bounds)
            }
            
            return _tableView!
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.separatorColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        if headerView != nil
        {
            tableView.tableHeaderView = headerView
        }
        
        if footerView != nil
        {
            tableView.tableFooterView = footerView
        }
        
        if !self.subviews.contains(tableView)
        {
            self.addSubview(tableView)
        }
        
        scrollToSelectedIndex(false)
    }
    
    internal func scrollToSelectedIndex(_ animated: Bool = true)
    {
        tableView.selectRow(at: tableView.indexPathForSelectedRow, animated: animated, scrollPosition: UITableViewScrollPosition.middle)
        
        guard let delegate = delegate else {
            return
        }
        
        delegate.scrollPickerView(self, didSelectIndex: getSelectedIndex())
    }
}

extension ScrollPickerView: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let datasource = datasource else {
            return 0
        }
        
        return Int(datasource.scrollPickerView(numberOfRowsFor: self))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil
        {
            cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.default
        let selectionView = UIView()
        selectionView.backgroundColor = LiarsDiceColors.michiganSelectionBlue()
        cell?.selectedBackgroundView = selectionView
        cell?.backgroundView = UIView()
        cell?.backgroundColor = UIColor.clear
        
        if let cell = cell, cell.contentView.subviews.count > 0
        {
            cell.contentView.subviews[0].removeFromSuperview()
        }
        
        guard let datasource = datasource else {
            return cell!
        }
        
        let view = datasource.scrollPickerView(self, viewForIndex: UInt((indexPath as NSIndexPath).row))
        cell?.contentView.addSubview(view)
        
        return cell!
    }
}

extension ScrollPickerView: UITableViewDelegate
{
    private func wheelTheCells()
    {
        for cell in tableView.visibleCells
        {
            let degrees45: CGFloat = 45.0 * CGFloat(M_PI) / 180
            cell.layer.transform = CATransform3DIdentity
            
            var cellRelativeFrame = tableView.convert(cell.frame, to: tableView.superview)
            cellRelativeFrame.origin.x -= tableView.frame.origin.x
            cellRelativeFrame.origin.y -= tableView.frame.origin.y
            
            let cellMiddleY = cellRelativeFrame.origin.y + cellRelativeFrame.height / 2.0
            let tableMiddleY = tableView.bounds.height / 2.0
            
            let aroundMiddle: CGFloat = (cellMiddleY - tableMiddleY) / tableMiddleY
            
            cell.layer.transform = CATransform3DMakeRotation(aroundMiddle * degrees45, 1, 0, 0)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if !animating
        {
            scrollToSelectedIndex()
        }
        
        wheelTheCells()
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        scrollToSelectedIndex()
        animating = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate
        {
            scrollToSelectedIndex()
            animating = false
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        wheelTheCells()
    }
    
    private func selectedIndexFromPoint() -> Int
    {
        let selectionPoint = CGPoint(x: 0, y: tableView.frame.size.height / 2.0 + tableView.contentOffset.y)
        
        let visibleCells = tableView.visibleCells
        guard let visibleCellIndices = tableView.indexPathsForVisibleRows else {
            return -1
        }
        
        for (cell, indexPath) in zip(visibleCells, visibleCellIndices)
        {
            if cell.frame.contains(selectionPoint)
            {
                return (indexPath as NSIndexPath).row
            }
        }
        
        return -1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if !scrollView.isDragging
        {
            wheelTheCells()
            return
        }
        
        guard let datasource = datasource else {
            return
        }

        wheelTheCells()
        
        animating = true
        
        if scrollView.contentOffset.y < -scrollView.contentInset.bottom
        {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
            return
        }
    
        if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.top)
        {
            let index = datasource.scrollPickerView(numberOfRowsFor: self)
            
            tableView.selectRow(at: IndexPath(row: Int(index-1), section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
            return
        }
        
        let index = selectedIndexFromPoint()
        if index >= 0
        {
            let uIndex = UInt(index)
            
            if datasource.scrollPickerView(self, canSelectIndex: uIndex)
            {
                let indexPath = IndexPath(row: index, section: 0)
                
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                
                guard let delegate = delegate else {
                    return
                }
                
                delegate.scrollPickerView(self, didSelectIndex: Int(uIndex))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        guard let view = view as? UITableViewHeaderFooterView else
        {
            return
        }
        
        view.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    {
        guard let view = view as? UITableViewHeaderFooterView else
        {
            return
        }
        
        view.backgroundView?.backgroundColor = UIColor.clear
    }
}
