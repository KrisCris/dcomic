import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/LoadingTile.dart';
import 'package:flutterdmzj/http/http.dart';

import 'SearchListTile.dart';

class NovelSearchTab extends StatefulWidget{
  String keyword;
  Key key;

  NovelSearchTab({this.key,@required this.keyword});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelSearchTab(keyword);
  }

}

class _NovelSearchTab extends State<NovelSearchTab>{
  List list = <Widget>[];
  ScrollController _scrollController = ScrollController();
  int page = 0;
  String keyword;
  bool refreshState = false;


  _NovelSearchTab(this.keyword);

  search() async {
    if(keyword!=null &&keyword!=''){
      CustomHttp http = CustomHttp();
      var response = await http.search(keyword, page,type: 1);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          if (response.data.length == 0) {
            refreshState = true;
            return;
          }
          if(page>0){
            list.removeLast();
          }
          for (var item in response.data) {
            list.add(SearchListTile(item['cover'], item['title'], item['types'],
                item['last_name'], item['id'].toString(), item['authors'],novel:1));
          }
          refreshState = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !refreshState) {
        setState(() {
          refreshState = true;
          list.add(LoadingTile());
          page++;
        });
        search();
      }
    });
    search();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      controller: _scrollController,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return list[index];
      },
    );
  }

}
