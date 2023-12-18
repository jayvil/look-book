import 'package:flutter/material.dart';

import '../../db/db.dart';
import '../../db/models.dart';

class BrandSearch extends StatefulWidget {
  const BrandSearch({super.key});

  @override
  State<BrandSearch> createState() => _BrandSearchState();
}

class _BrandSearchState extends State<BrandSearch> {
  Map<String, int> brandMap = {};
  List<String> foundBrands = [];
  String keyword = '';

  Future<List<Map<String, dynamic>>> _loadBrandData() async {
    List<Map<String, dynamic>> brandTypes = await DB.queryAll('brand_types');
    return brandTypes;
  }

  Future<void> _runFilter(String keyword) async {
    foundBrands.clear();
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all brands
      results = await DB.queryAll('brand_types');
    } else {
      String sql =
          'SELECT * FROM brand_types WHERE brand_name LIKE \'%$keyword%\';';
      results = await DB.rawQuery(sql);
    }
    for (Map<String, dynamic> type in results) {
      BrandTypes brandTypes = BrandTypes.fromMap(type);
      foundBrands.add(brandTypes.brand_name);
    }
  }

  @override
  void initState() {
    _loadBrandData();
    super.initState();
    print('init state');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: SizedBox(
            width: width * .8,
            child: Container(
                //  padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Material(
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.search, color: Colors.grey),
                        Expanded(
                          child: TextField(
                            // textAlign: TextAlign.center,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Search brands',
                            ),
                            onChanged: (value) {
                              // _runFilter(value);
                              setState(() {
                                keyword = value;
                              });
                            },
                          ),
                        ),
                        InkWell(
                          child: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                          ),
                          onTap: () {},
                        )
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _runFilter(keyword),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            double height = MediaQuery.of(context).size.height;
            return Scrollbar(
              child: SizedBox(
                height: height,
                child: foundBrands.isNotEmpty
                    ? ListView.builder(
                        itemCount: foundBrands.length,
                        itemBuilder: (context, index) => InkWell(
                          child: ListTile(
                            title: Text(foundBrands[index]),
                            onTap: () {
                              Navigator.pop(context, foundBrands[index]);
                            },
                          ),
                        ),
                      )
                    : const Center(child: Text(' No results found')),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
