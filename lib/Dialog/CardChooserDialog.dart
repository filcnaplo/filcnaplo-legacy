import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class CardChooserDialog extends StatefulWidget {
  const CardChooserDialog();
  @override
  CardChooserDialogState createState() => new CardChooserDialogState();
}

class CardChooserDialogState extends State<CardChooserDialog> {
  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text(
        "Milyen kártyákat mutassunk?" //TODO Translate
      ),
      contentPadding: EdgeInsets.all(10.0),
      children: <Widget>[
        Column(
          children: <Widget>[
            SwitchListTile(
              title: new Text("Hiányzás"),
              activeColor: Theme.of(context).accentColor,
              value: globals.showCardType["AbsenceCard"],
              onChanged: (b) {globals.showCardType["AbsenceCard"] = !globals.showCardType["AbsenceCard"];} //In theory this negates the bool... I have doubt.
            ),
          ],
        )
      ],
    );
  }
}