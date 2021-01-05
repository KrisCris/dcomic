import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutterdmzj/component/Drawer.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/utils/ChineseCupertinoLocalizations.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/category_page.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:flutterdmzj/view/download_page.dart';
import 'package:flutterdmzj/view/history_page.dart';
import 'package:flutterdmzj/view/home_page.dart';
import 'package:flutterdmzj/view/latest_update_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:flutterdmzj/view/ranking_page.dart';
import 'package:flutterdmzj/view/setting_page.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_bus/event_bus.dart';

import 'component/search/SearchButton.dart';
import 'event/ThemeChangeEvent.dart';
import 'http/http.dart';

void main() async {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(providers: [
      ChangeNotifierProvider<SystemSettingModel>(
        create: (_) => SystemSettingModel(),
        lazy: false,
      )
    ], child: MainFrame());
  }
}

class MainFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainFrame();
  }
}

class _MainFrame extends State<MainFrame> {
  initDownloader() async {
    print("class: MainFrame, action: initDownloader");
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
    FlutterDownloader.registerCallback(ToolMethods.downloadCallback);
  }

  initEasyRefresh() {
    EasyRefresh.defaultHeader = ClassicalHeader(
        refreshedText: '刷新完成',
        refreshFailedText: '刷新失败',
        refreshingText: '刷新中',
        refreshText: '下拉刷新',
        refreshReadyText: '释放刷新');
    EasyRefresh.defaultFooter = ClassicalFooter(
        loadReadyText: '下拉加载更多',
        loadFailedText: '加载失败',
        loadingText: '加载中',
        loadedText: '加载完成',
        noMoreText: '没有更多内容了');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDownloader();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = true;
    debugPaintSizeEnabled = false;
    // TODO: implement build
    return new MaterialApp(
        themeMode: Provider.of<SystemSettingModel>(context).themeMode,
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            platform: TargetPlatform.iOS,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            buttonTheme: ButtonThemeData(buttonColor: Colors.black)),
        routes: {
          "history": (BuildContext context) => new HistoryPage(),
          "settings": (BuildContext context) => new SettingPage(),
          "login": (BuildContext context) => new LoginPage(),
          "download": (BuildContext context) => new DownloadPage()
        },
        supportedLocales: [
          //此处
          const Locale('zh', 'CH'),
          const Locale('en', 'US'),
        ],
        localizationsDelegates: [
          //此处
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          ChineseCupertinoLocalizations.delegate,
        ],
        color: Colors.grey[400],
        showSemanticsDebugger: false,
        showPerformanceOverlay: false,
        theme: ThemeData(
            platform: TargetPlatform.iOS,
            buttonTheme: ButtonThemeData(buttonColor: Colors.blue)),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  String version;

  Future<Null> initUniLinks() async {
    getUriLinksStream().listen((Uri event) {
      print(
          'class: Main, action: deepLink, raw: $event, path: ${event.path}, query: ${event.query}');
      switch (event.path) {
        case '/comic':
          var params = event.queryParameters;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ComicDetailPage(params['id']);
          }));
          break;
      }
    });
  }

  getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      if (ToolMethods.checkVersion(packageInfo.version, version)) {
        version = packageInfo.version;
      }
    });
  }

  _openWeb(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            '${StaticLanguage.staticStrings['settingPage.canNotOpenWeb']}'),
      ));
    }
  }

  checkUpdate() async {
    DataBase dataBase = DataBase();
    version = await dataBase.getVersion();
    await getVersionInfo();
    CustomHttp http = CustomHttp();
    var response = await http.checkUpdate();
    if (response.statusCode == 200) {
      String lastVersion = response.data['tag_name'].substring(1);
      if (version == '') {
        dataBase.setVersion(lastVersion);
        return;
      }
      bool update = ToolMethods.checkVersion(lastVersion, version);
      if (update) {
        dataBase.setVersion(lastVersion);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('版本点亮：${response.data['tag_name']}'),
                content: Container(
                  width: 300,
                  height: 300,
                  child: MarkdownWidget(data: response.data['body']),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('打开网页'),
                    onPressed: () {
                      _openWeb('${response.data['html_url']}');
                    },
                  ),
                  FlatButton(
                    child: Text('更新'),
                    onPressed: () async {
                      if (response.data['assets'].length > 0) {
                        String url =
                            response.data['assets'][0]['browser_download_url'];
                        DataBase dataBase = DataBase();
                        var downloadPath = await dataBase.getDownloadPath();
                        FlutterDownloader.enqueue(
                            url: url, savedDir: '$downloadPath');
                        Navigator.pop(context);
                      } else {
                        _openWeb('${response.data['html_url']}');
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('镜像更新'),
                    onPressed: ()async{
                      if (response.data['assets'].length > 0) {
                        String url =
                        response.data['assets'][0]['browser_download_url'];
                        DataBase dataBase = DataBase();
                        var downloadPath = await dataBase.getDownloadPath();
                        FlutterDownloader.enqueue(
                            url: 'https://divine-boat-417a.hanerx.workers.dev/$url', savedDir: '$downloadPath');
                        Navigator.pop(context);
                      } else {
                        _openWeb('${response.data['html_url']}');
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
      print('check update success');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUpdate();
    initUniLinks();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 4,
      child: new Scaffold(
          appBar: new AppBar(
            title: Text('大妈之家(?)'),
            actions: <Widget>[SearchButton()],
            bottom: TabBar(
              tabs: <Widget>[
                new Tab(
                  text: '首页',
                ),
                new Tab(
                  text: '分类',
                ),
                new Tab(
                  text: '排行',
                ),
                new Tab(
                  text: '最新',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              new HomePage(),
              CategoryPage(),
              RankingPage(),
              LatestUpdatePage(),
            ],
          ),
          drawer: CustomDrawer()),
    );
  }
}
