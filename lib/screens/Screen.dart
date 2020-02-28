import 'package:flutter/material.dart';
import 'package:filcnaplo/globals.dart' as globals;
import 'package:filcnaplo/GlobalDrawer.dart';
import 'package:filcnaplo/Utils/StringFormatter.dart';

class Screen extends StatelessWidget {
	final String title;
	final Widget body;
	Screen(this.title, this.body);
	Widget build(BuildContext context) {
		globals.context = context;
		return new WillPopScope(
				onWillPop: () {
					globals.screen = 0;
					Navigator.pushReplacementNamed(context, "/main");
				},
				child: Scaffold(
						drawer: GDrawer(),
						appBar: new AppBar(
							title: new Text(capitalize(this.title)),
							actions: <Widget>[],
						),
						body: this.body)
		);
	}
}