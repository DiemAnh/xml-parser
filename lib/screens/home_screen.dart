import 'package:flutter/material.dart';

import '../models/tree_node.dart';

import '../services/xml_parser_service.dart';
import '../services/xml_json_converter.dart';
import '../services/search_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  TreeNode? root;

  String jsonResult = "";

  final TextEditingController searchController =
      TextEditingController();

  List<TreeNode> searchResult = [];

  final String sampleXml = '''
<?xml version="1.0" encoding="UTF-8"?>

<library>
  <book id="1">

    <title>
      Introduction to Algorithms
    </title>

    <author>
      <first_name>Thomas</first_name>
      <last_name>Cormen</last_name>
    </author>

    <publisher>MIT Press</publisher>

    <year>2009</year>

    <price>89.99</price>

  </book>
</library>
''';

  @override
  void initState() {
    super.initState();

    parseXml();
  }

  void parseXml() {
    root = XmlParserService.parseXml(
      sampleXml,
    );

    setState(() {});
  }

  void convertToJson() {
    jsonResult =
        XmlJsonConverter.xmlToJson(sampleXml);

    setState(() {});
  }

  void searchTag() {
    if (root == null) return;

    searchResult =
        SearchService.searchByTag(
      root!,
      searchController.text,
    );

    setState(() {});
  }

  Widget buildTree(TreeNode node) {
    return ExpansionTile(
      title: Text(
        node.tagName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: node.text != null
          ? Text(node.text!)
          : null,
      children: [
        ...node.attributes.map(
          (attr) => Padding(
            padding:
                const EdgeInsets.only(left: 16),
            child: ListTile(
              title: Text(
                "@${attr.name}",
              ),
              subtitle: Text(attr.value),
            ),
          ),
        ),

        ...node.children
            .map((e) => buildTree(e)),
      ],
    );
  }

  Widget buildSearchResult() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: searchResult
          .map(
            (e) => Card(
              child: ListTile(
                title: Text(e.tagName),
                subtitle: Text(
                  e.text ?? "",
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("XML Parser"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: parseXml,
                    child:
                        const Text("Parse XML"),
                  ),

                  ElevatedButton(
                    onPressed: convertToJson,
                    child:
                        const Text("XML -> JSON"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: searchController,
                decoration:
                    const InputDecoration(
                  border:
                      OutlineInputBorder(),
                  labelText: "Search Tag",
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: searchTag,
                child: const Text("Search"),
              ),

              const SizedBox(height: 20),

              if (searchResult.isNotEmpty)
                buildSearchResult(),

              const SizedBox(height: 20),

              const Text(
                "XML TREE",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (root != null)
                buildTree(root!),

              const SizedBox(height: 30),

              const Text(
                "JSON RESULT",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Text(jsonResult),
              ),
            ],
          ),
        ),
      ),
    );
  }
}