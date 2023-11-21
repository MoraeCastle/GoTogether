/*
import 'package:flutter/material.dart';

Widget test() {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title!),
    ),
    body: ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            key: cardA,
            leading: const CircleAvatar(child: Text('A')),
            title: const Text('Tap me!'),
            subtitle: const Text('I expand!'),
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    """Hi there, I'm a drop-in replacement for Flutter's ExpansionTile.

Use me any time you think your app could benefit from being just a bit more Material.

These buttons control the next card down!""",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardB.currentState?.expand();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.arrow_downward),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Open'),
                      ],
                    ),
                  ),
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardB.currentState?.collapse();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.arrow_upward),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Close'),
                      ],
                    ),
                  ),
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardB.currentState?.toggleExpansion();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.swap_vert),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Toggle'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            key: cardB,
            expandedTextColor: Colors.red,
            leading: const CircleAvatar(child: Text('B')),
            title: const Text('Tap me!'),
            subtitle: const Text('I expand, too!'),
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    """Hi there, I'm a drop-in replacement for Flutter's ExpansionTile.

Use me any time you think your app could benefit from being just a bit more Material.

These buttons control the card above!""",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardA.currentState?.expand();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.arrow_downward),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Open'),
                      ],
                    ),
                  ),
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardA.currentState?.collapse();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.arrow_upward),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Close'),
                      ],
                    ),
                  ),
                  TextButton(
                    style: flatButtonStyle,
                    onPressed: () {
                      cardA.currentState?.toggleExpansion();
                    },
                    child: const Column(
                      children: <Widget>[
                        Icon(Icons.swap_vert),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Toggle'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}*/
