import 'package:filcnaplo/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:filcnaplo/utils/string_formatter.dart';

import 'package:filcnaplo/globals.dart' as globals;

class SortDialog extends StatefulWidget {
  const SortDialog();

  @override
  SortDialogState createState() => SortDialogState();
}

class SortDialogState extends State<SortDialog> {
  int selectedSortOption = 0;

  void _onSelect(String selected, List<String> sortOptionList) {
    setState(() {
      selectedSortOption = sortOptionList.indexOf(selected);
      globals.sort = selectedSortOption;
    });
  }

  Widget build(BuildContext context) {
    List<String> sortOptionList = [
      I18n.of(context).sortTime,
      I18n.of(context).sortEval,
      I18n.of(context).sortTimeReal,
    ];

    return SimpleDialog(
      title: Text(capitalize(I18n.of(context).sort)),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        PopupMenuButton<String>(
          child: Container(
            child: Row(
              children: <Widget>[
                Text(
                  sortOptionList[globals.sort],
                  style: TextStyle(color: null, fontSize: 17.0),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: null,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 2.0),
          ),
          onSelected: (String selected) {
            _onSelect(selected, sortOptionList);
          },
          itemBuilder: (BuildContext context) {
            return sortOptionList.map((String sor) {
              return PopupMenuItem<String>(
                value: sor,
                child: Text(sor),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
