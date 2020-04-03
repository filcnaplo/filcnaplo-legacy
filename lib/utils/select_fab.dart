import 'package:filcnaplo/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

//todo áthelyezni egy msáik kategóriába (nem tom hova lenne való)
//far from perfect ;(
class SelectButton extends StatelessWidget {
  final List<ButtonOptionItem> items;
  final ValueChanged<int> onChanged;
  final int selected;
  final String tooltip;

  SelectButton({this.items, this.onChanged, this.selected, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      overlayOpacity: 0.50,
      overlayColor: globals.isDark ? Colors.black54 : Colors.white70,
      animatedIcon: AnimatedIcons.menu_close,
      tooltip: tooltip,
      children: buildChild(),
    );
  }

  List<SpeedDialChild> buildChild() {
    List<SpeedDialChild> widgetList = new List();
    for (int i = 0; i < items.length; i++) {
      widgetList.add(SpeedDialChild(
        child: items[i].child,
        label: items[i].text,
        onTap: () => onChanged(i),
        backgroundColor: (i == selected) ? null : Colors.grey,
        labelBackgroundColor: globals.isDark ? Colors.grey[900] : Colors.white,
      ));
    }
    return widgetList;
  }
}

class ButtonOptionItem {
  final String text;
  final Widget child;

  ButtonOptionItem(this.text, this.child);
}
