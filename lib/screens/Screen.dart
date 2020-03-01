import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/GlobalDrawer.dart';

class Screen extends StatelessWidget {

	final Widget title;
	final Widget body;
	final String returnPage;
	final actions;
	Screen(this.title, this.body, this.returnPage, this.actions);
	Widget build(BuildContext context) {
		globals.context = context;
		return new WillPopScope(
				onWillPop: () {
					globals.screen = 0;
					Navigator.pushReplacementNamed(context, returnPage);
				},
				child: Scaffold(
						drawer: GDrawer(),
						appBar: new AppBar(
							title: title,
							actions: actions,
						),
						body: this.body)
		);
	}
}