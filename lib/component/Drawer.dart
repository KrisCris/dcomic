import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/download_page.dart';
import 'package:dcomic/view/history_page.dart';
import 'package:dcomic/view/novel_pages/novel_main_page.dart';
import 'package:dcomic/view/server_controllers/server_sellect_page.dart';
import 'package:dcomic/view/settings/setting_page.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/view/dark_side_page.dart';
import 'package:dcomic/view/favorite_page.dart';
import 'package:dcomic/view/login_page.dart';
import 'package:dcomic/view/mag_maker/mag_make_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const CustomDrawer({Key key, this.navigatorKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomDrawerState();
  }
}

class CustomDrawerState extends State<CustomDrawer> {
  static const List darkMode = [
    Icons.brightness_4,
    Icons.brightness_5,
    Icons.brightness_2
  ];

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  NavigatorState getNavigatorState(context) {
    if (widget.navigatorKey == null) {
      return Navigator.of(context);
    } else {
      return widget.navigatorKey.currentState;
    }
  }

  @override
  Widget build(BuildContext context) {
    List list = buildList(context);
    // TODO: implement build
    return new Drawer(
        child: DirectSelectContainer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    ));
  }

  List<Widget> buildList(BuildContext context) {
    List<Widget> list = <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text(S.of(context).AppName),
        accountEmail: Text(
          S.of(context).DrawerEmail,
          style: TextStyle(color: Colors.white60),
        ),
        currentAccountPicture: FlutterLogo(),
        otherAccountsPictures: <Widget>[
          TextButton(
            child: Icon(
              darkMode[Provider.of<SystemSettingModel>(context).darkState],
              color: Colors.white,
            ),
            onPressed: () {
              if (Provider.of<SystemSettingModel>(context, listen: false)
                      .darkState <
                  darkMode.length - 1) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .darkState++;
              } else {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .darkState = 0;
              }
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.zero)),
          ),
          TextButton(
            child: Icon(
              Icons.group,
              color: Colors.white,
            ),
            onPressed: () {
              getNavigatorState(context).push(MaterialPageRoute(
                  builder: (context) => LoginPage(),
                  settings: RouteSettings(name: 'login_page')));
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.zero)),
          )
        ],
      ),
      ListTile(
        leading: Icon(Icons.apps),
        title: DirectSelectList<BaseSourceModel>(
          values: Provider.of<SourceProvider>(context).activeHomeSources,
          defaultItemIndex: Provider.of<SourceProvider>(context).homeIndex,
          itemBuilder: (BaseSourceModel value) =>
              DirectSelectItem<BaseSourceModel>(
                  itemHeight: 56,
                  value: value,
                  itemBuilder: (context, value) {
                    return Container(
                      child: Text(
                        value.type.title,
                        textAlign: TextAlign.start,
                      ),
                    );
                  }),
          onItemSelectedListener: (item, index, context) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(item.type.title)));
            Provider.of<SourceProvider>(context, listen: false)
                .activeHomeModel = item;
          },
          focusedItemDecoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(width: 1, color: Colors.black12),
              top: BorderSide(width: 1, color: Colors.black12),
            ),
          ),
        ),
        trailing: Icon(Icons.unfold_more),
      ),
      Divider(),
      ListTile(
        title: Text(S.of(context).Favorite),
        leading: Icon(Icons.favorite),
        onTap: () {
          if (widget.navigatorKey == null) {
            getNavigatorState(context).pop();
          }
          getNavigatorState(context).push(MaterialPageRoute(
              builder: (context) {
                return FavoritePage();
              },
              settings: RouteSettings(name: 'favorite_page')));
        },
      ),
      ListTile(
        title: Text(S.of(context).History),
        leading: Icon(Icons.history),
        onTap: () {
          if (widget.navigatorKey == null) {
            getNavigatorState(context).pop();
          }

          getNavigatorState(context).push(MaterialPageRoute(
              builder: (context) => HistoryPage(),
              settings: RouteSettings(name: 'history_page')));
        },
      ),
      ListTile(
        title: Text(S.of(context).Download),
        leading: Icon(Icons.file_download),
        onTap: () {
          if (widget.navigatorKey == null) {
            getNavigatorState(context).pop();
          }
          getNavigatorState(context).push(MaterialPageRoute(
              builder: (context) => DownloadPage(),
              settings: RouteSettings(name: 'download_page')));
          ;
        },
      )
    ];
    if (Provider.of<SystemSettingModel>(context, listen: false).darkSide) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text(S.of(context).DarkSide),
          leading: Icon(Icons.block),
          onTap: () {
            if (widget.navigatorKey == null) {
              getNavigatorState(context).pop();
            }
            getNavigatorState(context).push(MaterialPageRoute(
                builder: (context) {
                  return DarkSidePage();
                },
                settings: RouteSettings(name: 'dark_side_page')));
          },
        )
      ];
    }
    if (Provider.of<SystemSettingModel>(context, listen: false).novel) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text(S.of(context).Novel),
          leading: Icon(Icons.book),
          onTap: () {
            if (widget.navigatorKey == null) {
              getNavigatorState(context).pop();
            }
            getNavigatorState(context).push(MaterialPageRoute(
                builder: (context) {
                  return NovelMainPage();
                },
                settings: RouteSettings(name: 'novel_main_page')));
          },
        )
      ];
    }

    if (Provider.of<SourceProvider>(context, listen: false)
        .localSourceModel
        .options
        .active) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text('.manga制作器'),
          leading: Icon(Icons.edit),
          onTap: () {
            getNavigatorState(context).push(MaterialPageRoute(
                builder: (context) => MagMakePage(),
                settings: RouteSettings(name: 'mag_make_page')));
          },
        ),
      ];
    }

    if (Provider.of<SourceProvider>(context, listen: false)
            .ipfsSourceProvider
            .nodes
            .length >
        0) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text('分布式服务器管理器'),
          leading: Icon(FontAwesome5.server),
          onTap: () {
            getNavigatorState(context).push(MaterialPageRoute(
                builder: (context) => ServerSelectPage(),
                settings: RouteSettings(name: 'server_select_page')));
          },
        ),
      ];
    }
    list += <Widget>[
      Divider(),
      ListTile(
        title: Text(S.of(context).Setting),
        leading: Icon(Icons.settings),
        onTap: () {
          if (widget.navigatorKey == null) {
            getNavigatorState(context).pop();
          }
          getNavigatorState(context).push(MaterialPageRoute(
              builder: (context) => SettingPage(),
              settings: RouteSettings(name: 'settings')));
        },
      )
    ];
    return list;
  }
}
