import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../db/db.dart';
import '../db/models.dart';
import 'modals/brand_search.dart';

class ClothingInfoForm extends StatefulWidget {
  final Map<String, dynamic> itemDetailsMap;
  const ClothingInfoForm({super.key, required this.itemDetailsMap});

  @override
  State<ClothingInfoForm> createState() => _ClothingInfoFormState();
}

class _ClothingInfoFormState extends State<ClothingInfoForm>
    with AutomaticKeepAliveClientMixin<ClothingInfoForm> {
  String? categoryDropdownValue;
  String? subCategoryDropdownValue;
  String? colorDropdownValue;
  List<String> subCategoryDropDownList = [];
  List<String> categoryDropDownList = [];
  List<String> colorList = [];
  List<String> materialList = [];
  List<String> patternList = [];
  List<String> seasonList = [];
  Map<String, int> brandList = {};
  List<String> foundBrands = [];
  List<String> colors = [];
  double _distanceToField = 0.0;
  final TextfieldTagsController _textfieldTagsController = TextfieldTagsController();
  TextEditingController textarea = TextEditingController();
  final TextEditingController _categoryTextFormController = TextEditingController();
  final TextEditingController _colorTextFormController = TextEditingController();
  final TextEditingController _materialTextFormController = TextEditingController();
  final TextEditingController _patternTextFormController = TextEditingController();
  final TextEditingController _seasonTextFormController = TextEditingController();
  final TextEditingController _brandTextFormController = TextEditingController();
  final TextEditingController _sizeTextFormController = TextEditingController();
  final TextEditingController _priceTextFormController = TextEditingController();
  final TextEditingController _purchaseDateTextFormController =
      TextEditingController();
  bool isAvailable = false;

  void queryDB() async {
    List<Map<String, dynamic>> clothingTypes =
        await DB.queryAll('clothing_types');
    for (Map<String, dynamic> type in clothingTypes) {
      ClothingTypes clothingTypes = ClothingTypes.fromMap(type);
      categoryDropDownList.add(clothingTypes.type_name);
      // categoryDropdownValue = dropDownList.first;
    }

    List<Map<String, dynamic>> colorTypes = await DB.queryAll('color_types');
    for (Map<String, dynamic> type in colorTypes) {
      ColorTypes colorTypes = ColorTypes.fromMap(type);
      colorList.add(colorTypes.color_name);
    }

    List<Map<String, dynamic>> materialTypes =
        await DB.queryAll('material_types');
    for (Map<String, dynamic> type in materialTypes) {
      MaterialTypes materialTypes = MaterialTypes.fromMap(type);
      materialList.add(materialTypes.material_name);
    }

    List<Map<String, dynamic>> patternTypes =
        await DB.queryAll('pattern_types');
    for (Map<String, dynamic> type in patternTypes) {
      PatternTypes materialTypes = PatternTypes.fromMap(type);
      patternList.add(materialTypes.pattern_name);
    }

    seasonList = ['Spring', 'Summer', 'Fall', 'Winter'];

    List<Map<String, dynamic>> brandTypes = await DB.queryAll('brand_types');
    for (Map<String, dynamic> type in brandTypes) {
      BrandTypes brandTypes = BrandTypes.fromMap(type);
      brandList[brandTypes.brand_name] = brandTypes.id;
    }

    categoryDropDownList.sort();
    colorList.sort();
    materialList.sort();
    patternList.sort();

    setState(() {});
  }

  void populateSubCategories(String? category) async {
    subCategoryDropDownList.clear();
    List<Map<String, dynamic>> clothingTypeData = await DB
        .rawQuery('SELECT id FROM clothing_types WHERE type_name="$category"');
    int resultId = clothingTypeData[0]['id'];
    List<Map<String, dynamic>> clothingSubTypeData = await DB.rawQuery(
        'SELECT sub_type_name FROM clothing_sub_types WHERE type_id=$resultId');
    for (Map<String, dynamic> item in clothingSubTypeData) {
      subCategoryDropDownList.add(item['sub_type_name']);
      // subCategoryDropdownValue = subCategoryDropDownList.first;
    }
    subCategoryDropDownList.sort();
    setState(() {});
  }

  Future<String?> _showMultiSelect(
      BuildContext context,
      List<String> stringItems,
      Set<int> initialValuesSet,
      bool hasLeading) async {
    final selectItems = <MultiSelectDialogItem<int>>[];
    final listColors = [
      const Color(0xffC9AD93), // Beige
      Colors.black, // black
      Colors.blue, // blue
      const Color(0xffA17249), // brown
      const Color(0xffC7AA82), // camel
      const Color(0xffD2774A), // copper
      const Color(0xffE4694C), // coral
      const Color(0xffF2EED2), // cream
      const Color(0xffE5B723), // gold
      Colors.green, // green
      Colors.grey, // grey
      const Color(0xffB1A079), // khaki
      const Color(0xffDAEAF9), // light blue
      const Color(0xffC5C7C4), // light grey
      const Color(0xffA865C9), // light purple
      const Color(0xffF57D0D),
      Colors.pinkAccent,
      const Color(0xff664E88),
      const Color(0xffBD2734),
      const Color(0xffE9A7A1),
      const Color(0xffBD2734),
      const Color(0xffE9A7A1),
      const Color(0xffC8CCCE),
      const Color(0xff02D3CC),
      Colors.white70,
      Colors.yellowAccent,
    ];
    int i = 0;
    for (String label in stringItems) {
      if (hasLeading) {
        selectItems.add(
          MultiSelectDialogItem(i, label, listColors[i]),
        );
      } else {
        selectItems.add(
          MultiSelectDialogItem(i, label, Colors.transparent),
        );
      }
      i += 1;
    }

    final selectedValues = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: selectItems,
          initialSelectedValues: initialValuesSet,
        );
      },
    );

    return selectedValues;
  }

  void _showCategorySelect(BuildContext context, List<String> categories,
      List<String> subCategories) async {
    print(categories.length);
    if (!mounted) return;
    final selectedValues = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a category'),
          content: SizedBox(
            width: 100,
            height: 400,
            child: ListView(
              children: List.generate(
                categories.length,
                (index) => InkWell(
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showSubCategorySelect(context, categories[index]);
                    },
                    title: Text(categories[index]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSubCategorySelect(BuildContext context, String category) async {
    if (!mounted) return;
    // Populate the subcategory list to display in alert dialog
    // populateSubCategories(category);
    subCategoryDropDownList.clear();
    List<Map<String, dynamic>> clothingTypeData = await DB
        .rawQuery('SELECT id FROM clothing_types WHERE type_name="$category"');
    int resultId = clothingTypeData[0]['id'];
    List<Map<String, dynamic>> clothingSubTypeData = await DB.rawQuery(
        'SELECT sub_type_name FROM clothing_sub_types WHERE type_id=$resultId');
    for (Map<String, dynamic> item in clothingSubTypeData) {
      subCategoryDropDownList.add(item['sub_type_name']);
      // subCategoryDropdownValue = subCategoryDropDownList.first;
    }
    subCategoryDropDownList.sort();
    // setState(() {});
    print(subCategoryDropDownList);
    final selectedValues = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCategorySelect(
                      context, categoryDropDownList, subCategoryDropDownList);
                },
                child: const Text('Back'))
          ],
          content: SizedBox(
            width: 100,
            height: 400,
            child: ListView(
              children: List.generate(
                subCategoryDropDownList.length,
                (index) => InkWell(
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context,
                          '$category > ${subCategoryDropDownList[index]}');
                    },
                    title: Text(subCategoryDropDownList[index]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    setState(() {
      _categoryTextFormController.text = selectedValues!;
      widget.itemDetailsMap['category'] = _categoryTextFormController.text;
    });
  }

  @override
  void initState() {
    queryDB();
    // foundBrands = brandList.keys.toList();
    print(brandList);
    super.initState();
    print('init state');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // print('dispose');
    _textfieldTagsController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print('build');
    super.build(context);
    return SizedBox(
      width: width * .8,
      child: Column(
        children: [
          const Text('Item Details'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: TextFormField(
              readOnly: true,
              controller: _categoryTextFormController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Category',
                hintText: "What type of item is this?",
              ),
              onTap: () {
                print('category tapped');
                FocusScope.of(context).requestFocus(FocusNode());
                // _showMultiSelect(context, colorList);
                _showCategorySelect(
                    context, categoryDropDownList, subCategoryDropDownList);
                // ScaffoldMessenger.of(context)
                // for(var item in _selectedItems)
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: TextFormField(
              readOnly: true,
              controller: _colorTextFormController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Color',
                hintText: "What colors describe this item?",
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                List<String> initialValues =
                    _colorTextFormController.text.split(',');
                int i = 0;
                Map<String, int> myMap = <String, int>{};
                Set<int> initialValuesSet = {};
                // print(colorList);
                for (String label in colorList) {
                  myMap[label] = i;
                  i += 1;
                }
                if (initialValues.isNotEmpty && !initialValues.contains('')) {
                  for (String colorVal in initialValues) {
                    int? val = myMap[colorVal.trim()];
                    initialValuesSet.add(val!);
                    // }
                  }
                }
                String? values = await _showMultiSelect(
                    context, colorList, initialValuesSet, true);
                setState(() {
                  _colorTextFormController.text = values!;
                  widget.itemDetailsMap['color'] = values;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: TextFormField(
              readOnly: true,
              controller: _materialTextFormController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Material',
                hintText: "What materials is this item made of?",
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                List<String> initialValues =
                    _materialTextFormController.text.split(',');
                int i = 0;
                Map<String, int> myMap = <String, int>{};
                Set<int> initialValuesSet = {};
                // print(colorList);
                for (String label in materialList) {
                  myMap[label] = i;
                  i += 1;
                }
                if (initialValues.isNotEmpty && !initialValues.contains('')) {
                  for (String material in initialValues) {
                    int? val = myMap[material.trim()];
                    initialValuesSet.add(val!);
                    // }
                  }
                }
                String? values = await _showMultiSelect(
                    context, materialList, initialValuesSet, false);
                setState(() {
                  _materialTextFormController.text = values!;
                  widget.itemDetailsMap['material'] = values;
                });
              },
            ),
          ),
          // Pattern
          TextFormField(
            readOnly: true,
            controller: _patternTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Pattern',
              hintText: "What patterns does this item have?",
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              List<String> initialValues =
                  _patternTextFormController.text.split(',');
              int i = 0;
              Map<String, int> myMap = <String, int>{};
              Set<int> initialValuesSet = {};
              // print(colorList);
              for (String label in patternList) {
                myMap[label] = i;
                i += 1;
              }
              if (initialValues.isNotEmpty && !initialValues.contains('')) {
                for (String colorVal in initialValues) {
                  int? val = myMap[colorVal.trim()];
                  initialValuesSet.add(val!);
                  // }
                }
              }
              String? values = await _showMultiSelect(
                  context, patternList, initialValuesSet, false);
              setState(() {
                _patternTextFormController.text = values!;
                widget.itemDetailsMap['pattern'] = values;
              });
            },
          ),
          // Season
          TextFormField(
            readOnly: true,
            controller: _seasonTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Season',
              hintText: "What seasons do you wear this item in?",
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              List<String> initialValues =
                  _seasonTextFormController.text.split(',');
              int i = 0;
              Map<String, int> myMap = <String, int>{};
              Set<int> initialValuesSet = {};
              // print(colorList);
              for (String label in seasonList) {
                myMap[label] = i;
                i += 1;
              }
              if (initialValues.isNotEmpty && !initialValues.contains('')) {
                for (String pattern in initialValues) {
                  int? val = myMap[pattern.trim()];
                  initialValuesSet.add(val!);
                  // }
                }
              }
              String? values = await _showMultiSelect(
                  context, seasonList, initialValuesSet, false);
              setState(() {
                _seasonTextFormController.text = values!;
                widget.itemDetailsMap['season'] = values;
              });
            },
          ),
          // Brand
          TextFormField(
            readOnly: true,
            controller: _brandTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Brand',
              hintText: "What brand is this item?",
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              String? values = await showModalBottomSheet(
                // isScrollControlled: true,
                enableDrag: false,
                context: context,
                builder: (context) => const BrandSearch(),
              );
              setState(() {
                _brandTextFormController.text = values!;
                widget.itemDetailsMap['brand'] = values;
              });
            },
          ),
          // Size
          TextFormField(
            controller: _sizeTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Size',
              hintText: "What is the size of this item?",
            ),
            onChanged: (change) {
              widget.itemDetailsMap['size'] = change;
            },
          ),
          //Price
          // TODO Add units to settings and use in form
          TextFormField(
            keyboardType: TextInputType.number,
            // inputFormatters: <TextInputFormatter>[
            //   FilteringTextInputFormatter.digitsOnly
            // ],
            controller: _priceTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Price',
              hintText: "What was the price of this item?",
            ),
            onChanged: (change) {
              widget.itemDetailsMap['price'] = change;
            },
          ),
          // Purchase Date
          TextFormField(
            controller: _purchaseDateTextFormController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Purchase Date',
              hintText: "What date did you purchase this item?",
            ),
            readOnly: true,
            onTap: () async {
              var date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              _purchaseDateTextFormController.text =
                  date.toString().substring(0, 10);
              widget.itemDetailsMap['date'] =
                  _purchaseDateTextFormController.text;
            },
          ),
          // Tags
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * .8,
                child: TextFieldTags(
                    textfieldTagsController: _textfieldTagsController,
                    initialTags: const [],
                    textSeparators: const [' ', ','],
                    letterCase: LetterCase.normal,
                    validator: null,
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        print(tags);
                        String tagsString = '';
                        for (var i = 0; i < tags.length; i++) {
                          // Add tags to the map
                          if (i == 0) {
                            tagsString += tags[i];
                          } else {
                            tagsString += ' ${tags[i]}';
                          }
                        }
                        widget.itemDetailsMap['tags'] = tagsString;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: TextField(
                            enableSuggestions: true,
                            controller: tec,
                            focusNode: fn,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              isDense: true,
                              labelText: _textfieldTagsController.hasTags
                                  ? ''
                                  : 'Tags',
                              errorText: error,
                              prefixIconConstraints: BoxConstraints(
                                  maxWidth: _distanceToField * 0.74),
                              prefixIcon: tags.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller: sc,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                          children: tags.map((String tag) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            borderRadius:
                                                BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            color: Colors.blue,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 5.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Text(
                                                  tag,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onTap: () {
                                                  print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: .0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Colors.white,
                                                ),
                                                onTap: () {
                                                  onTagDelete(tag);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                    )
                                  : null,
                            ),
                            onChanged: onChanged,
                            onSubmitted: onSubmitted,
                          ),
                        );
                      });
                    }),
              )
            ],
          ),
          // Shop Link
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: TextFormField(
              controller: _sizeTextFormController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Shop Link',
                hintText: "Add a shopping link for this item",
              ),
              onChanged: (change) {
                widget.itemDetailsMap['url'] = change;
              },
            ),
          ),
          // Notes
          Column(
            children: [
              SizedBox(
                width: width,
                child: TextField(
                  controller: textarea,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Add more description about your item here",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.blue),
                    ),
                  ),
                  onChanged: (change) {
                    widget.itemDetailsMap['notes'] = change;
                  },
                ),
              ),
            ],
          ),
          // Availability
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
            child: Row(
              children: [
                const Flexible(
                  child: Column(
                    children: [
                      Text(
                        'This item is currently unavailable.\n(e.g in the laundry, loaned to a friend, etc)',
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 17.0),
                      ),
                    ],
                  ),
                ), //Text
                Checkbox(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value!;
                      widget.itemDetailsMap['isAvailable'] = isAvailable;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label, this.color);

  final V value;
  final String label;
  final Color color;
}

class MultiSelectDialog<V> extends StatefulWidget {
  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.initialSelectedValues,
  });

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final Set<V> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialSelectedValues);
    }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onClearTap() {
    setState(() {
      _selectedValues.clear();
    });
  }

  void _onSubmitTap(BuildContext context) {
    // print(_selectedValues);
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select color'),
      contentPadding: const EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
          child: Column(
        children: [
          for (var multiSelect in widget.items)
            _buildItem(multiSelect, multiSelect.color)
        ],
      )),
      elevation: 10,
      backgroundColor: Colors.grey.shade300,
      actions: [
        Container(
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade500,
          //   borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(0.0),
          //       bottomRight: Radius.circular(0.0)),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      // If the button is pressed, return green, otherwise blue
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green;
                      }
                      return Colors.blue;
                    }),
                    textStyle: MaterialStateProperty.resolveWith((states) {
                      // If the button is pressed, return size 40, otherwise 20
                      if (states.contains(MaterialState.pressed)) {
                        return const TextStyle(fontSize: 40);
                      }
                      return const TextStyle(fontSize: 20);
                    }),
                  ),
                  onPressed: _onClearTap,
                  child: const Text('Clear'),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    // var values = Navigator.pop(context, _selectedValues);
                    Map<int, String> myMap = {};
                    int count = 0;
                    String retString = '';
                    for (var item in widget.items) {
                      myMap[item.value as int] = item.label;
                    }
                    for (var element in _selectedValues) {
                      if (count == 0) {
                        retString += myMap[element] as String;
                      } else {
                        retString += ', ';
                        retString += myMap[element] as String;
                      }
                      count += 1;
                    }
                    Navigator.pop(context, retString);
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item, Color color) {
    final checked = _selectedValues.contains(item.value);
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: Colors.transparent,
      ),
      child: Ink(
        // color: checked ? Colors.red : Colors.transparent,
        child: CheckboxListTile(
          // tileColor: checked ? Colors.lightBlue : Colors.transparent,
          checkColor: Colors.white,
          value: checked,
          title: Text(item.label),
          activeColor: Colors.black45,
          secondary: SizedBox(
            width: 35,
            height: 35,
            child: Container(
              color: color,
            ),
          ),
          // controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
        ),
      ),
    );
  }
}
