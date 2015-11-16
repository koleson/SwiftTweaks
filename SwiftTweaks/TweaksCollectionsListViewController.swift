//
//  TweaksCollectionsListViewController.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 11/9/15.
//  Copyright © 2015 Khan Academy. All rights reserved.
//

import UIKit

internal protocol TweaksCollectionsListViewControllerDelegate {
	func tweaksCollectionsListViewControllerDidTapDismissButton(tweaksCollectionsListViewController: TweaksCollectionsListViewController)
	func tweaksCollectionsListViewController(tweaksCollectionsListViewController: TweaksCollectionsListViewController, didSelectTweakCollection: TweakCollection)
}

internal class TweaksCollectionsListViewController: UIViewController {
	private let tableView: UITableView

	private let tweakStore: TweakStore
	private let delegate: TweaksCollectionsListViewControllerDelegate


	// MARK: Init

	internal init(tweakStore: TweakStore, delegate: TweaksCollectionsListViewControllerDelegate) {
		self.tweakStore = tweakStore
		self.delegate = delegate

		self.tableView = UITableView(frame: CGRectZero, style: .Plain)

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.registerClass(TweakCollectionCell.self, forCellReuseIdentifier: TweaksCollectionsListViewController.TweakCollectionCellIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .Plain, target: self, action: "resetStore")
		navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor()

		toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonTapped"),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Dismiss", style: .Done, target: self, action: "dismissButtonTapped")
		]
	}

	override func viewWillAppear(animated: Bool) {
		super.viewDidAppear(animated)

		if let selectedIndexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
		}
	}

	// MARK: Events

	@objc private func resetStore() {
		let confirmationAlert = UIAlertController(title: nil, message: "Reset all tweaks to their default values?", preferredStyle: .ActionSheet)
		confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		confirmationAlert.addAction(UIAlertAction(title: "Reset", style: .Destructive, handler: { _ in self.tweakStore.reset() }))
		presentViewController(confirmationAlert, animated: true, completion: nil)
	}

	@objc private func dismissButtonTapped() {
		delegate.tweaksCollectionsListViewControllerDidTapDismissButton(self)
	}

	@objc private func actionButtonTapped() {
		let alertController = UIAlertController(title: "Sharing Backups Not Yet Implemented", message: "Easy, tiger.", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	private static let TweakCollectionCellIdentifier = "TweakCollectionCellIdentifier"
	private class TweakCollectionCell: UITableViewCell {
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
			accessoryType = .DisclosureIndicator
		}

		required init?(coder aDecoder: NSCoder) {
		    fatalError("init(coder:) has not been implemented")
		}
	}
}

extension TweaksCollectionsListViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweakStore.sortedTweakCollections.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(TweaksCollectionsListViewController.TweakCollectionCellIdentifier, forIndexPath: indexPath)
		let tweakCollection = tweakStore.sortedTweakCollections[indexPath.row]
		cell.textLabel!.text = tweakCollection.title
		cell.detailTextLabel!.text = "\(tweakCollection.numberOfTweaks)"
		return cell
	}
}

extension TweaksCollectionsListViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tweaksCollectionsListViewController(self, didSelectTweakCollection: tweakStore.sortedTweakCollections[indexPath.row])
	}
}
