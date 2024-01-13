import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_app/provider/home_provider.dart';

import '../data_All/app_color.dart';
import '../data_All/font_sizes.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: AppColor.white, size: AppFontSize.font24),
          backgroundColor: AppColor.amber,
          centerTitle: true,
          title: Text(
            'Search',
            style: TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.font24),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: provider.searchController,
                    onChanged: (values) {
                      setState(() {});
                    },
                    keyboardType: TextInputType.number,
                    cursorColor: AppColor.amber,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColor.amber, width: AppFontSize.font2)),
                    )),
                provider.searchController.text.trim().isNotEmpty
                    ? provider.onSearch()
                    : SizedBox(),
              ],
            ),
          ),
        ),
      );
    });
    ;
  }
}
